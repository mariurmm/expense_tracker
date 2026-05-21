import 'dart:async' show unawaited;

import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:provider/provider.dart';

import 'core/services/exchange_rate_service.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'data/datasources/category_local_datasource.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/datasources/transaction_local_datasource.dart';
import 'data/models/category_model.dart';
import 'data/models/transaction_model.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'di/injection.dart';
import 'features/splash/splash_screen.dart';
import 'providers/category_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();

  Hive
    ..registerAdapter(TransactionTypeAdapter())
    ..registerAdapter(TransactionAdapter())
    ..registerAdapter(CategoryAdapter());

  await Hive.openBox<Transaction>(TransactionLocalDatasource.boxName);
  await Hive.openBox<Category>(CategoryLocalDatasource.boxName);
  await Hive.openBox<dynamic>(SettingsLocalDatasource.boxName);

  await configureDependencies();

  final txRepo = getIt<TransactionRepository>();
  final catRepo = getIt<CategoryRepository>();
  final settingsRepo = getIt<SettingsRepository>();

  await catRepo.seedDefaultCategoriesIfNeeded();

  FlutterNativeSplash.remove();

  // Create providers that need cross-wiring before runApp.
  final settingsProvider = SettingsProvider(settingsRepo)..load();
  final reportsProvider = ReportsProvider(txRepo, catRepo)..load();
  final exchangeRateService = getIt<ExchangeRateService>();

  final txProvider = TransactionProvider(txRepo)
    ..reportsProvider = reportsProvider
    ..exchangeRateService = exchangeRateService
    ..settingsProvider = settingsProvider
    ..loadTransactions();

  // Preload rates for the active currency at startup.
  unawaited(exchangeRateService.preload(settingsProvider.currencyCode));

  // Recalculate whenever the active currency changes.
  settingsProvider.addListener(() {
    txProvider.settingsProvider = settingsProvider;
    unawaited(exchangeRateService.preload(settingsProvider.currencyCode));
    unawaited(txProvider.recalculateConvertedTotals());
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: txProvider),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(catRepo)..loadCategories(),
        ),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: reportsProvider),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const AppShell(),
          builder: (context, child) {
            return SplashScreen(child: child ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}
