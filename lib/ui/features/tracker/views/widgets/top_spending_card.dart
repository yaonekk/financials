import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class TopSpendingCard extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;
  final VoidCallback? onViewAllStats;

  const TopSpendingCard({
    super.key,
    required this.viewModel,
    this.onViewAllStats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = viewModel.topSpendingCategory;
    final currency = viewModel.primaryCurrency;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.bgLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Highest Spend This Month',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onViewAllStats != null)
                TextButton(
                  onPressed: onViewAllStats,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.only(left: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'All Stats',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: accentColor,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (top == null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(
                'No expenses logged for this month yet 🎉',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: top.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: top.category.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    top.category.icon,
                    color: top.category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              top.category.name,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currency.symbol}${top.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${top.count} transaction${top.count > 1 ? 's' : ''}',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            '${top.percentage.toStringAsFixed(1)}% of total',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: top.category.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (top.percentage / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(top.category.color),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
