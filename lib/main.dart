import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/services/transaction_local_service.dart';
import 'domain/repositories/transaction_repository.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/splash/splash_screen.dart';
import 'ui/features/tracker/view_models/expense_tracker_view_model.dart';
import 'ui/features/tracker/views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar, adapt brightness to system theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Initialize persistent storage service
  final localService = await TransactionLocalService.create();
  final TransactionRepository repository =
      TransactionRepositoryImpl(localService: localService);
  final viewModel = ExpenseTrackerViewModel(repository: repository);

  runApp(FinancialsApp(viewModel: viewModel));
}

class FinancialsApp extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;

  const FinancialsApp({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financials',
      debugShowCheckedModeBanner: false,
      // System-adaptive theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(
        nextScreen: HomeScreen(viewModel: viewModel),
      ),
    );
  }
}
