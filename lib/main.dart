import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

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
import 'features/home/home_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'providers/category_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';

Future<void> main() async {
  // Keep the native splash visible until we call FlutterNativeSplash.remove()
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // ── Hive initialisation ──────────────────────────────────────────────────
  await Hive.initFlutter();

  // Register adapters in typeId order
  Hive.registerAdapter(TransactionTypeAdapter()); // typeId 1
  Hive.registerAdapter(TransactionAdapter());     // typeId 0
  Hive.registerAdapter(CategoryAdapter());        // typeId 2

  // Open boxes
  await Hive.openBox<Transaction>(TransactionLocalDatasource.boxName);
  await Hive.openBox<Category>(CategoryLocalDatasource.boxName);
  await Hive.openBox(SettingsLocalDatasource.boxName); // dynamic box

  // Seed default categories on first launch
  if (Hive.box<Category>(CategoryLocalDatasource.boxName).isEmpty) {
    final catDs = CategoryLocalDatasource();
    for (final cat in buildDefaultCategories()) {
      await catDs.put(cat);
    }
  }

  // ── Repositories ─────────────────────────────────────────────────────────
  final txRepo = TransactionRepository(
      datasource: TransactionLocalDatasource());
  final catRepo = CategoryRepository(
      datasource: CategoryLocalDatasource());
  final settingsRepo = SettingsRepository(
      datasource: SettingsLocalDatasource());

  // Hive is ready — remove the native splash screen now
  FlutterNativeSplash.remove();

  // ── App ───────────────────────────────────────────────────────────────────
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TransactionProvider(txRepo)..loadTransactions(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CategoryProvider(catRepo)..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportsProvider(txRepo, catRepo)..load(),
        ),
      ],
      child: const App(),
    ),
  );
}

// ── Root widget ──────────────────────────────────────────────────────────────

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}

// ── Bottom-navigation shell ──────────────────────────────────────────────────

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
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
