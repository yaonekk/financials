import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:financials/domain/models/currency.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class MonthSelectorHeader extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;

  const MonthSelectorHeader({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final monthFormat = DateFormat('MMMM yyyy');
    final formattedMonth = monthFormat.format(viewModel.selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Month navigation cluster
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left_rounded, size: 22, color: textPrimary),
                  onPressed: viewModel.previousMonth,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Previous month',
                ),
                GestureDetector(
                  onTap: () => _pickMonth(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedMonth,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, size: 22, color: textPrimary),
                  onPressed: viewModel.nextMonth,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Next month',
                ),
              ],
            ),
          ),

          // Currency selector pill
          InkWell(
            onTap: () => _showCurrencyPicker(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewModel.primaryCurrency.flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    viewModel.primaryCurrency.code,
                    style: GoogleFonts.ibmPlexSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select Month & Year',
    );
    if (picked != null) {
      viewModel.setSelectedMonth(picked);
    }
  }

  void _showCurrencyPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final dividerColor = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Primary Display Currency',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: AppCurrency.supportedCurrencies.length,
                  separatorBuilder: (ctx, index) => Divider(
                    color: dividerColor,
                    height: 1,
                  ),
                  itemBuilder: (ctx, i) {
                    final curr = AppCurrency.supportedCurrencies[i];
                    final isSelected = curr.code == viewModel.primaryCurrency.code;
                    return ListTile(
                      leading: Text(
                        curr.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        '${curr.name} (${curr.symbol})',
                        style: GoogleFonts.ibmPlexSans(
                          color: isSelected ? accentColor : textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        curr.code,
                        style: GoogleFonts.ibmPlexSans(
                          color: isSelected ? accentColor : textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        viewModel.setPrimaryCurrency(curr);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
