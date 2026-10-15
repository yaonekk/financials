import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:financials/domain/models/currency.dart';
import 'package:financials/domain/models/transaction_item.dart';
import 'package:financials/ui/core/theme/app_theme.dart';
import 'package:financials/ui/features/tracker/view_models/expense_tracker_view_model.dart';

class AddTransactionModal extends StatefulWidget {
  final ExpenseTrackerViewModel viewModel;
  final TransactionType initialType;

  const AddTransactionModal({
    super.key,
    required this.viewModel,
    this.initialType = TransactionType.expense,
  });

  static Future<void> show(
    BuildContext context, {
    required ExpenseTrackerViewModel viewModel,
    TransactionType initialType = TransactionType.expense,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionModal(
        viewModel: viewModel,
        initialType: initialType,
      ),
    );
  }

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  late TransactionType _selectedType;
  late AppCurrency _selectedCurrency;
  late TransactionCategory _selectedCategory;
  late DateTime _selectedDate;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCurrency = widget.viewModel.primaryCurrency;
    _selectedDate = DateTime.now();
    _selectedCategory = widget.viewModel.expenseCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isExpense = _selectedType == TransactionType.expense;
    final activeColor = isExpense ? AppColors.expense : AppColors.income;
    final expenseCategories = widget.viewModel.expenseCategories;

    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    // Safety fallback if selected category was deleted
    if (!expenseCategories.any((c) => c.id == _selectedCategory.id)) {
      _selectedCategory = expenseCategories.first;
    }

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cardBorder,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Top Segmented Switch: Expense vs Income
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypeSegment(
                          title: 'Expense',
                          icon: Icons.arrow_downward_rounded,
                          type: TransactionType.expense,
                          activeColor: AppColors.expense,
                          textSecondary: textSecondary,
                        ),
                      ),
                      Expanded(
                        child: _buildTypeSegment(
                          title: 'Income',
                          icon: Icons.arrow_upward_rounded,
                          type: TransactionType.income,
                          activeColor: AppColors.income,
                          textSecondary: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Amount Input Box with integrated Currency Picker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: activeColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      // Currency selector pill
                      GestureDetector(
                        onTap: _pickCurrency,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCurrency.flag,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedCurrency.code,
                                style: GoogleFonts.ibmPlexSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Currency Symbol
                      Text(
                        _selectedCurrency.symbol,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: activeColor,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Numerical TextField
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: GoogleFonts.ibmPlexSans(
                              color: textMuted,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter an amount';
                            }
                            final val = double.tryParse(value.trim());
                            if (val == null || val <= 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.ibmPlexSans(color: textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Title / Description',
                    labelStyle: GoogleFonts.ibmPlexSans(color: textSecondary),
                    hintText: isExpense
                        ? 'e.g. Grocery Store, Coffee, Rent'
                        : 'e.g. Salary, Client Invoice, Freelance',
                    hintStyle: GoogleFonts.ibmPlexSans(color: textMuted),
                    prefixIcon: Icon(Icons.edit_note_rounded, color: textSecondary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Date Picker row
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              color: accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Transaction Date',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Section ONLY shown for Expense
                if (isExpense) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXPENSE CATEGORY',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: textSecondary,
                        ),
                      ),
                      Text(
                        _selectedCategory.name,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedCategory.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category Grid + Add New Category Option
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Render all categories (default + custom)
                      ...expenseCategories.map((cat) {
                        final isChosen = _selectedCategory.id == cat.id;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isChosen
                                  ? cat.color.withValues(alpha: 0.2)
                                  : cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isChosen ? cat.color : cardBorder,
                                width: isChosen ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  size: 16,
                                  color: isChosen ? cat.color : textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 12,
                                    fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                                    color: isChosen ? cat.color : textPrimary,
                                  ),
                                ),
                                // Delete icon for user-created custom categories
                                if (cat.isCustom) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _deleteCustomCategory(cat),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColors.expense.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 13,
                                        color: AppColors.expense,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),

                      // "+ Add Category" button chip
                      InkWell(
                        onTap: _showCreateCategoryDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                size: 16,
                                color: accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '+ Add Category',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 18),

                // Optional Note
                TextFormField(
                  controller: _noteController,
                  style: GoogleFonts.ibmPlexSans(color: textPrimary),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Optional Note / Memo',
                    labelStyle: GoogleFonts.ibmPlexSans(color: textSecondary),
                    hintText: 'Add extra details, tags, receipt info...',
                    hintStyle: GoogleFonts.ibmPlexSans(color: textMuted),
                    prefixIcon: Icon(Icons.notes_rounded, color: textSecondary),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExpense ? Icons.add_circle_outline : Icons.arrow_upward_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isExpense ? 'Save Expense' : 'Save Income',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSegment({
    required String title,
    required IconData icon,
    required TransactionType type,
    required Color activeColor,
    required Color textSecondary,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isSelected ? Colors.white : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Date',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _pickCurrency() {
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
                  'Select Transaction Currency',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 16,
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
                    final isChosen = curr.code == _selectedCurrency.code;
                    return ListTile(
                      leading: Text(
                        curr.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        '${curr.name} (${curr.symbol})',
                        style: GoogleFonts.ibmPlexSans(
                          color: isChosen ? accentColor : textPrimary,
                          fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        curr.code,
                        style: GoogleFonts.ibmPlexSans(
                          color: isChosen ? accentColor : textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCurrency = curr;
                        });
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

  void _deleteCustomCategory(TransactionCategory category) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete "${category.name}"?',
          style: GoogleFonts.ibmPlexSans(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this custom category? Any expenses in it will be moved to Other Expense.',
          style: GoogleFonts.ibmPlexSans(color: textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.ibmPlexSans(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            child: Text('Delete', style: GoogleFonts.ibmPlexSans(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.viewModel.deleteCustomCategory(category.id);
      setState(() {
        if (_selectedCategory.id == category.id) {
          _selectedCategory = widget.viewModel.expenseCategories.first;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted category "${category.name}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showCreateCategoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    Color chosenColor = const Color(0xFF3B82F6);
    IconData chosenIcon = Icons.label_rounded;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final availableColors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF97316), // Orange
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEAB308), // Yellow
      const Color(0xFF14B8A6), // Teal
    ];

    final availableIcons = [
      Icons.label_rounded,
      Icons.local_cafe_rounded,
      Icons.sports_esports_rounded,
      Icons.school_rounded,
      Icons.pets_rounded,
      Icons.fitness_center_rounded,
      Icons.directions_bike_rounded,
      Icons.laptop_mac_rounded,
      Icons.music_note_rounded,
      Icons.local_gas_station_rounded,
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Create Custom Category',
                style: GoogleFonts.ibmPlexSans(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.ibmPlexSans(color: textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        labelStyle: GoogleFonts.ibmPlexSans(color: textSecondary),
                        hintText: 'e.g. Subscriptions, Coffee, Gym',
                        hintStyle: GoogleFonts.ibmPlexSans(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Choose Color',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableColors.map((color) {
                        final isSel = chosenColor == color;
                        return GestureDetector(
                          onTap: () => setDialogState(() => chosenColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSel
                                  ? Border.all(color: Colors.white, width: 2.5)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Choose Icon',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableIcons.map((icon) {
                        final isSel = chosenIcon == icon;
                        return GestureDetector(
                          onTap: () => setDialogState(() => chosenIcon = icon),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? chosenColor.withValues(alpha: 0.25)
                                  : cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? chosenColor : cardBorder,
                              ),
                            ),
                            child: Icon(
                              icon,
                              size: 20,
                              color: isSel ? chosenColor : textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.ibmPlexSans(color: textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final created = widget.viewModel.addCustomCategory(
                      name: name,
                      icon: chosenIcon,
                      color: chosenColor,
                    );
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedCategory = created;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                  child: Text(
                    'Add Category',
                    style: GoogleFonts.ibmPlexSans(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final isExpense = _selectedType == TransactionType.expense;

    final newTransaction = TransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: isExpense ? _selectedCategory : null,
      currency: _selectedCurrency,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    widget.viewModel.addTransaction(newTransaction);
    Navigator.pop(context);

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${_selectedType.label.toLowerCase()}: "${newTransaction.title}" (${newTransaction.formattedAmount})',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
