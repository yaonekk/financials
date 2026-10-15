import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:financials/domain/models/transaction_item.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionItem transaction;
  final ExpenseTrackerViewModel viewModel;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(transaction.date);

    final badgeColor = isIncome
        ? AppColors.income
        : (transaction.category?.color ?? AppColors.expense);
    final badgeIcon = isIncome
        ? Icons.arrow_upward_rounded
        : (transaction.category?.icon ?? Icons.receipt_long_rounded);

    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.bgLight;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Delete',
              style: GoogleFonts.ibmPlexSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _performDelete(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                badgeIcon,
                color: badgeColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // Title, Subtitle & Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (!isIncome && transaction.category != null) ...[
                        Text(
                          transaction.category!.name,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: transaction.category!.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 10,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.note!,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Currency tag & Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Amount (+ / -)
                Text(
                  '${isIncome ? '+' : '-'}${transaction.formattedAmount}',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? AppColors.income : AppColors.expense,
                  ),
                ),
                const SizedBox(height: 4),
                // Currency Pill & Delete button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Text(
                        '${transaction.currency.flag} ${transaction.currency.code}',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _performDelete(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _performDelete(BuildContext context) {
    final deleted = viewModel.deleteTransaction(transaction.id);
    if (deleted == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(
              Icons.delete_rounded,
              color: AppColors.expense,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Deleted "${deleted.title}" (${deleted.formattedAmount})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryLight,
          onPressed: () {
            viewModel.undoDelete();
          },
        ),
      ),
    );
  }
}
