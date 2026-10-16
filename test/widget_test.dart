import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financials/data/models/category_storage_model.dart';
import 'package:financials/data/models/transaction_storage_model.dart';
import 'package:financials/data/repositories/transaction_repository_impl.dart';
import 'package:financials/data/services/transaction_local_service.dart';
import 'package:financials/domain/models/currency.dart';
import 'package:financials/domain/models/transaction_item.dart';
import 'package:financials/domain/use_cases/calculate_monthly_analytics_use_case.dart';
import 'package:financials/main.dart';
import 'package:financials/ui/features/settings/views/settings_screen.dart';
import 'package:financials/ui/features/splash/views/splash_screen.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';
import 'package:financials/ui/features/tracker/views/home_screen.dart';
import 'package:financials/ui/features/tracker/views/widgets/add_transaction_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TransactionLocalService localService;
  late TransactionRepositoryImpl repository;
  late CalculateMonthlyAnalyticsUseCase analyticsUseCase;
  late ExpenseTrackerViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    localService = await TransactionLocalService.create();
    repository = TransactionRepositoryImpl(localService: localService);
    analyticsUseCase = const CalculateMonthlyAnalyticsUseCase();
    viewModel = ExpenseTrackerViewModel(
      repository: repository,
      calculateAnalyticsUseCase: analyticsUseCase,
    );
  });

  group('Data Layer (DTOs, Service & Repository) Tests', () {
    test('App starts with fresh state (no dummy data)', () {
      final transactions = repository.getTransactions();
      expect(
        transactions,
        isEmpty,
        reason: 'Dummy data should be removed for a fresh start',
      );
      expect(repository.getCustomCategories(), isEmpty);
    });

    test('TransactionStorageModel and CategoryStorageModel serialize/deserialize cleanly', () {
      final item = TransactionItem(
        id: 'dto-tx-1',
        title: 'Coffee',
        amount: 4.5,
        type: TransactionType.expense,
        category: TransactionCategory.findById('food'),
        currency: AppCurrency.fromCode('USD'),
        date: DateTime(2026, 10, 15),
        note: 'Morning espresso',
      );

      final dto = TransactionStorageModel.fromDomain(item);
      final json = dto.toJson();
      final parsedDto = TransactionStorageModel.fromJson(json);
      final restoredItem = parsedDto.toDomain(
        TransactionCategory.defaultExpenseCategories,
      );

      expect(restoredItem.id, 'dto-tx-1');
      expect(restoredItem.title, 'Coffee');
      expect(restoredItem.amount, 4.5);
      expect(restoredItem.category?.id, 'food');
      expect(restoredItem.note, 'Morning espresso');

      final cat = TransactionCategory(
        id: 'custom-1',
        name: 'Pets',
        icon: Icons.pets_rounded,
        color: const Color(0xFF3B82F6),
        isCustom: true,
      );
      final catDto = CategoryStorageModel.fromDomain(cat);
      final restoredCat = CategoryStorageModel.fromJson(catDto.toJson()).toDomain();
      expect(restoredCat.id, 'custom-1');
      expect(restoredCat.name, 'Pets');
      expect(restoredCat.icon, Icons.pets_rounded);
      expect(restoredCat.isCustom, isTrue);
    });

    test('Data persists across TransactionLocalService reloads via SharedPreferences', () async {
      final item = TransactionItem(
        id: 'persisted-tx-1',
        title: 'Monthly Rent',
        amount: 1200.0,
        type: TransactionType.expense,
        category: TransactionCategory.findById('housing'),
        currency: AppCurrency.fromCode('USD'),
        date: DateTime.now(),
        note: 'Apartment rent check',
      );

      repository.addTransaction(item);
      expect(repository.getTransactions().length, 1);

      // Create new service + repository instance with existing mock prefs to simulate app restart
      final reloadedService = await TransactionLocalService.create();
      final reloadedRepo = TransactionRepositoryImpl(localService: reloadedService);
      final loadedTransactions = reloadedRepo.getTransactions();

      expect(loadedTransactions.length, 1);
      expect(loadedTransactions.first.id, 'persisted-tx-1');
      expect(loadedTransactions.first.title, 'Monthly Rent');
      expect(loadedTransactions.first.amount, 1200.0);
      expect(loadedTransactions.first.category?.id, 'housing');
    });

    test('Custom categories persist and deleting them falls back safely', () async {
      final customCat = repository.addCustomCategory(
        name: 'Gym & Fitness',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF10B981),
      );

      expect(customCat.name, 'Gym & Fitness');
      expect(customCat.isCustom, isTrue);

      // Reload service + repository
      final reloadedService = await TransactionLocalService.create();
      final reloadedRepo = TransactionRepositoryImpl(localService: reloadedService);
      expect(reloadedRepo.getCustomCategories().length, 1);
      expect(reloadedRepo.getCustomCategories().first.name, 'Gym & Fitness');

      // Delete custom category
      reloadedRepo.deleteCustomCategory(customCat.id);
      expect(reloadedRepo.getCustomCategories(), isEmpty);
    });
  });

  group('Domain UseCase & ViewModel Financial Analytics Tests', () {
    test('Initial balance and expenses are zero on fresh start', () {
      expect(viewModel.monthlyIncome, 0.0);
      expect(viewModel.monthlyExpense, 0.0);
      expect(viewModel.monthlyNetBalance, 0.0);
      expect(viewModel.topSpendingCategory, isNull);
      expect(viewModel.categorySpendingBreakdown, isEmpty);
    });

    test('Adding income and expenses computes correct net balance & top spend via UseCase', () {
      final now = viewModel.selectedMonth;

      final salary = TransactionItem(
        id: 'inc-1',
        title: 'Tech Salary',
        amount: 5000.0,
        type: TransactionType.income,
        category: null,
        currency: AppCurrency.fromCode('USD'),
        date: now,
      );

      final rent = TransactionItem(
        id: 'exp-1',
        title: 'Apartment Rent',
        amount: 1500.0,
        type: TransactionType.expense,
        category: TransactionCategory.findById('housing'),
        currency: AppCurrency.fromCode('USD'),
        date: now,
      );

      final food = TransactionItem(
        id: 'exp-2',
        title: 'Groceries',
        amount: 400.0,
        type: TransactionType.expense,
        category: TransactionCategory.findById('food'),
        currency: AppCurrency.fromCode('USD'),
        date: now,
      );

      viewModel.addTransaction(salary);
      viewModel.addTransaction(rent);
      viewModel.addTransaction(food);

      expect(viewModel.monthlyIncome, 5000.0);
      expect(viewModel.monthlyExpense, 1900.0);
      expect(viewModel.monthlyNetBalance, 3100.0);
      expect(viewModel.topSpendingCategory?.category.id, 'housing');
      expect(viewModel.topSpendingCategory?.totalAmount, 1500.0);
    });

    test('Delete transaction with Undo functionality works reliably', () {
      final tx = TransactionItem(
        id: 'undo-tx',
        title: 'Dinner with friends',
        amount: 80.0,
        type: TransactionType.expense,
        category: TransactionCategory.findById('food'),
        currency: AppCurrency.fromCode('USD'),
        date: viewModel.selectedMonth,
      );

      viewModel.addTransaction(tx);
      expect(viewModel.filteredTransactions.length, 1);

      final deleted = viewModel.deleteTransaction('undo-tx');
      expect(deleted, isNotNull);
      expect(viewModel.hasUndoAvailable, isTrue);
      expect(viewModel.filteredTransactions, isEmpty);

      final restored = viewModel.undoDelete();
      expect(restored, isTrue);
      expect(viewModel.filteredTransactions.length, 1);
      expect(viewModel.hasUndoAvailable, isFalse);
    });

    test('Supports multi-currency conversions including MAD, EUR, USD', () {
      final mad = AppCurrency.fromCode('MAD');
      expect(mad.code, 'MAD');
      expect(mad.symbol, 'DH');
      expect(mad.flag, '🇲🇦');

      final eur = AppCurrency.fromCode('EUR');
      expect(eur.code, 'EUR');

      final usd = AppCurrency.fromCode('USD');
      expect(usd.code, 'USD');
    });
  });

  group('UI Layer (Views & MVVM Integration) Tests', () {
    testWidgets('SplashScreen renders logo and title properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            nextScreen: Scaffold(body: Text('Home Loaded')),
            durationMs: 500,
          ),
        ),
      );

      // Verify app title and tagline on splash
      expect(find.text('Financials'), findsOneWidget);
      expect(find.text('Smart money, clear vision.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Advance time past the splash duration
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Home Loaded'), findsOneWidget);
    });

    testWidgets(
      'HomeScreen renders fresh empty state with Add Transaction button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: HomeScreen(viewModel: viewModel),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Financials'), findsOneWidget);
        expect(find.text('NET MONTHLY BALANCE'), findsOneWidget);
        expect(find.text('No transactions yet'), findsOneWidget);
        expect(
          find.text('Add your first income or expense to get started.'),
          findsOneWidget,
        );
        expect(find.text('Add Transaction'), findsOneWidget);
      },
    );

    testWidgets('AddTransactionModal opens and allows entering expense', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(viewModel: viewModel),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the Add Transaction button in the empty state
      final addBtn = find.widgetWithText(ElevatedButton, 'Add Transaction');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Verify modal is open
      expect(find.byType(AddTransactionModal), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);

      // Enter amount and title
      await tester.enterText(find.byType(TextFormField).first, '120.00');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Grocery shopping',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Expense'));
      await tester.pumpAndSettle();

      // Transaction is now logged and displayed in the list
      expect(viewModel.filteredTransactions.length, 1);
      expect(viewModel.filteredTransactions.first.title, 'Grocery shopping');
      expect(viewModel.filteredTransactions.first.amount, 120.0);
      expect(find.text('Grocery shopping'), findsOneWidget);
    });

    testWidgets(
      'SettingsScreen displays app info and all sharing platform chips',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: SettingsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Check App Info
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Financials'), findsOneWidget);
        expect(find.text('1.0.0'), findsOneWidget);
        expect(find.text('BrightLab'), findsOneWidget);

        // Check Share Section and platforms
        expect(
          find.text('Share Financials with friends & family'),
          findsOneWidget,
        );
        expect(find.text('WhatsApp'), findsOneWidget);
        expect(find.text('Facebook'), findsOneWidget);
        expect(find.text('Twitter/X'), findsOneWidget);
        expect(find.text('Instagram'), findsOneWidget);
        expect(find.text('Telegram'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('SMS'), findsOneWidget);
        expect(find.text('More...'), findsOneWidget);
        expect(find.text('Share Financials'), findsOneWidget);
      },
    );

    testWidgets(
      'FinancialsApp root widget integrates ThemeMode.system and Splash',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(FinancialsApp(viewModel: viewModel));
        // First renders splash screen
        expect(find.byType(SplashScreen), findsOneWidget);

        // Pump past splash duration to settle all timers
        await tester.pump(const Duration(milliseconds: 2500));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });
}
