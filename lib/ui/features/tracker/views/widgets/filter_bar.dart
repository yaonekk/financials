import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class FilterBar extends StatelessWidget {
  final ExpenseTrackerViewModel viewModel;

  const FilterBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = viewModel.expenseCategories;
    final showCategoryFilter = viewModel.filterType != FilterType.income;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type filter pills (All / Expenses / Income)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTypeChip(
                context: context,
                label: 'All',
                isSelected: viewModel.filterType == FilterType.all,
                activeColor: accentColor,
                cardColor: cardColor,
                cardBorder: cardBorder,
                textSecondary: textSecondary,
                onTap: () => viewModel.setFilterType(FilterType.all),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                context: context,
                label: 'Expenses',
                isSelected: viewModel.filterType == FilterType.expenses,
                activeColor: AppColors.expense,
                cardColor: cardColor,
                cardBorder: cardBorder,
                textSecondary: textSecondary,
                onTap: () => viewModel.setFilterType(FilterType.expenses),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                context: context,
                label: 'Income',
                isSelected: viewModel.filterType == FilterType.income,
                activeColor: AppColors.income,
                cardColor: cardColor,
                cardBorder: cardBorder,
                textSecondary: textSecondary,
                onTap: () {
                  viewModel.setSelectedCategory(null);
                  viewModel.setFilterType(FilterType.income);
                },
              ),
            ],
          ),
        ),

        if (showCategoryFilter) ...[
          const SizedBox(height: 10),

          // Category filter chips scrollview
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = viewModel.selectedCategoryId == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        'All Categories',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? accentColor : textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => viewModel.setSelectedCategory(null),
                      showCheckmark: false,
                      backgroundColor: cardColor,
                      selectedColor: accentColor.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: isSelected ? accentColor : cardBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }

                final category = categories[index - 1];
                final isSelected = viewModel.selectedCategoryId == category.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      category.icon,
                      size: 14,
                      color: isSelected ? category.color : textSecondary,
                    ),
                    label: Text(
                      category.name,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? category.color : textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      viewModel.setSelectedCategory(selected ? category.id : null);
                    },
                    showCheckmark: false,
                    backgroundColor: cardColor,
                    selectedColor: category.color.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: isSelected ? category.color : cardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color cardColor,
    required Color cardBorder,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.15) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
