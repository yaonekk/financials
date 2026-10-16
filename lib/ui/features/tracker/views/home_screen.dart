import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:financials/domain/models/transaction_item.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/settings/views/settings_screen.dart';
import 'package:financials/ui/features/statistics/views/statistics_screen.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';
import 'package:financials/ui/features/tracker/views/widgets/add_transaction_modal.dart';
import 'package:financials/ui/features/tracker/views/widgets/balance_summary_card.dart';
import 'package:financials/ui/features/tracker/views/widgets/filter_bar.dart';
import 'package:financials/ui/features/tracker/views/widgets/month_selector_header.dart';
import 'package:financials/ui/features/tracker/views/widgets/top_spending_card.dart';
import 'package:financials/ui/features/tracker/views/widgets/transaction_list_tile.dart';

class HomeScreen extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;

  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final transactions = viewModel.filteredTransactions;
        final hasActiveCategoryFilter = viewModel.selectedCategoryId != null;
        final hasActiveTypeFilter = viewModel.filterType != FilterType.all;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Financials',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              // Analytics Screen Action Button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 20,
                    color: accentColor,
                  ),
                ),
                tooltip: 'Spending Statistics',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StatisticsScreen(viewModel: viewModel),
                    ),
                  );
                },
              ),
              // Settings Button
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 20,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Month Selector and Currency Switcher
              SliverToBoxAdapter(
                child: MonthSelectorHeader(viewModel: viewModel),
              ),

              // Hero Balance Card: Income & Expense Summary
              SliverToBoxAdapter(
                child: BalanceSummaryCard(viewModel: viewModel),
              ),

              // "What did he spend the most money on this month?" Insight
              SliverToBoxAdapter(
                child: TopSpendingCard(
                  viewModel: viewModel,
                  onViewAllStats: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StatisticsScreen(viewModel: viewModel),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Filter Bar (Type & Category tags)
              SliverToBoxAdapter(
                child: FilterBar(viewModel: viewModel),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Transactions',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Text(
                              '${transactions.length}',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (hasActiveCategoryFilter || hasActiveTypeFilter)
                        GestureDetector(
                          onTap: () {
                            viewModel.setSelectedCategory(null);
                            viewModel.setFilterType(FilterType.all);
                          },
                          child: Text(
                            'Reset filters',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Transactions List or Empty State
              if (transactions.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.surfaceDark : AppColors.bgLight),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 32,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No transactions yet',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add your first income or expense to get started.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => AddTransactionModal.show(
                            context,
                            viewModel: viewModel,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(
                            'Add Transaction',
                            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = transactions[index];
                      return TransactionListTile(
                        transaction: item,
                        viewModel: viewModel,
                      );
                    },
                    childCount: transactions.length,
                  ),
                ),

              // Bottom padding so items aren't obscured by the FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Floating Action Button Group
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Quick Add Income button
              FloatingActionButton.extended(
                heroTag: 'add_income_fab',
                onPressed: () => AddTransactionModal.show(
                  context,
                  viewModel: viewModel,
                  initialType: TransactionType.income,
                ),
                backgroundColor: AppColors.income,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                label: Text(
                  'Income',
                  style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              // Quick Add Expense button
              FloatingActionButton.extended(
                heroTag: 'add_expense_fab',
                onPressed: () => AddTransactionModal.show(
                  context,
                  viewModel: viewModel,
                  initialType: TransactionType.expense,
                ),
                backgroundColor: AppColors.expense,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                label: Text(
                  'Expense',
                  style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
