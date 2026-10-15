import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class StatisticsScreen extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;

  const StatisticsScreen({
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
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final monthFormat = DateFormat('MMMM yyyy');
        final currentMonthStr = monthFormat.format(viewModel.selectedMonth);
        final breakdown = viewModel.categorySpendingBreakdown;
        final top = viewModel.topSpendingCategory;
        final currency = viewModel.primaryCurrency;
        final totalExpense = viewModel.monthlyExpense;
        final totalIncome = viewModel.monthlyIncome;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              'Spending Analytics',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Switcher Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left_rounded, color: textPrimary),
                        onPressed: viewModel.previousMonth,
                      ),
                      Text(
                        currentMonthStr,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right_rounded, color: textPrimary),
                        onPressed: viewModel.nextMonth,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Top Spending Hero Highlight
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), AppColors.cardDark]
                          : [const Color(0xFFEFF6FF), AppColors.cardLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: top != null
                          ? top.category.color.withValues(alpha: 0.3)
                          : cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              size: 18,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'BIGGEST EXPENSE THIS MONTH',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 11,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (top != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: top.category.color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: top.category.color.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(
                                top.category.icon,
                                color: top.category.color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    top.category.name,
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Accounts for ${top.percentage.toStringAsFixed(1)}% of all spending in $currentMonthStr',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 12,
                                      color: top.category.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Spent on this category',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                '${currency.symbol}${top.totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No spending logged for this month yet.',
                            style: GoogleFonts.ibmPlexSans(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Cashflow comparison bar
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash Flow Balance',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.income,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'In: ${currency.symbol}${totalIncome.toStringAsFixed(2)}',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.expense,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Out: ${currency.symbol}${totalExpense.toStringAsFixed(2)}',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: totalIncome == 0 && totalExpense == 0
                              ? Container(color: cardBorder)
                              : Row(
                                  children: [
                                    Expanded(
                                      flex: (totalIncome * 100).toInt().clamp(1, 100000),
                                      child: Container(color: AppColors.income),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: (totalExpense * 100).toInt().clamp(1, 100000),
                                      child: Container(color: AppColors.expense),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Category Spending Breakdown List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '${breakdown.length} Categories',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (breakdown.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: Text(
                      'No expense records to analyze',
                      style: GoogleFonts.ibmPlexSans(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ] else ...[
                  ...breakdown.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.category.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.category.icon,
                                  color: item.category.color,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category.name,
                                      style: GoogleFonts.ibmPlexSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${item.count} transaction${item.count > 1 ? 's' : ''}',
                                      style: GoogleFonts.ibmPlexSans(
                                        fontSize: 11,
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${currency.symbol}${item.totalAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${item.percentage.toStringAsFixed(1)}%',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: item.category.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (item.percentage / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: surfaceColor,
                              valueColor: AlwaysStoppedAnimation<Color>(item.category.color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
