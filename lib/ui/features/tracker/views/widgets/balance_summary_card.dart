import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class BalanceSummaryCard extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;

  const BalanceSummaryCard({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = viewModel.primaryCurrency;
    final income = viewModel.monthlyIncome;
    final expense = viewModel.monthlyExpense;
    final balance = viewModel.monthlyNetBalance;
    final savingsRate = viewModel.monthlySavingsRate;

    final isPositive = balance >= 0;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final bgDark = isDark ? AppColors.bgDark : const Color(0xFFEFF6FF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Net Balance Label + Savings Rate Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NET MONTHLY BALANCE',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.income.withValues(alpha: 0.15)
                      : AppColors.expense.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPositive
                        ? AppColors.income.withValues(alpha: 0.4)
                        : AppColors.expense.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: isPositive ? AppColors.income : AppColors.expense,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}% Saved',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPositive ? AppColors.income : AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Big Net Balance Value
          Text(
            '${isPositive ? '' : '-'}${currency.symbol}${balance.abs().toStringAsFixed(2)}',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              color: isPositive ? textPrimary : AppColors.expense,
            ),
          ),

          const SizedBox(height: 20),

          // Income and Expense Split Metrics
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                // Income Column
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.income.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.income,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currency.symbol}${income.toStringAsFixed(2)}',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.income,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Divider
                Container(
                  height: 36,
                  width: 1,
                  color: cardBorder,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Expense Column
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: AppColors.expense,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expense',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 12,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${currency.symbol}${expense.toStringAsFixed(2)}',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.expense,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
