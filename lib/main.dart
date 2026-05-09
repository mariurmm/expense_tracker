import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/category_local_datasource.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/datasources/transaction_local_datasource.dart';
import 'data/models/category_model.dart';
import 'data/models/default_categories.dart';
import 'data/models/transaction_model.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'di/injection.dart';
import 'features/home/home_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transactions/transactions_screen.dart';
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

  if (Hive.box<Category>(CategoryLocalDatasource.boxName).isEmpty) {
    final catDs = CategoryLocalDatasource();
    for (final cat in buildDefaultCategories()) {
      await catDs.put(cat);
    }
  }

  await configureDependencies();

  final txRepo = getIt<TransactionRepository>();
  final catRepo = getIt<CategoryRepository>();
  final settingsRepo = getIt<SettingsRepository>();

  FlutterNativeSplash.remove();

  final txProvider = TransactionProvider(txRepo)..loadTransactions();
  final reportsProvider = ReportsProvider(txRepo, catRepo)..load();
  txProvider.reportsProvider = reportsProvider;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: txProvider),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(catRepo)..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepo)..load(),
        ),
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
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const AppShell(),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              height: 64,
              backgroundColor: isDark
                  ? AppColors.cardBackgroundDark
                  : AppColors.cardBackground,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.list_alt_outlined),
                  selectedIcon: const Icon(Icons.list_alt),
                  label: l10n.navTransactions,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart),
                  label: l10n.navReports,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l10n.navSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
