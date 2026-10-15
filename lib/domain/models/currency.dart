/// Supported currencies with display symbol, code, and standard rates to USD
class AppCurrency {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final double rateToUsd; // For normalized financial calculations

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.rateToUsd,
  });

  static const List<AppCurrency> supportedCurrencies = [
    AppCurrency(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      flag: '🇺🇸',
      rateToUsd: 1.0,
    ),
    AppCurrency(
      code: 'EUR',
      symbol: '€',
      name: 'Euro',
      flag: '🇪🇺',
      rateToUsd: 1.08,
    ),
    AppCurrency(
      code: 'GBP',
      symbol: '£',
      name: 'British Pound',
      flag: '🇬🇧',
      rateToUsd: 1.28,
    ),
    AppCurrency(
      code: 'JPY',
      symbol: '¥',
      name: 'Japanese Yen',
      flag: '🇯🇵',
      rateToUsd: 0.0066,
    ),
    AppCurrency(
      code: 'CAD',
      symbol: 'CA\$',
      name: 'Canadian Dollar',
      flag: '🇨🇦',
      rateToUsd: 0.74,
    ),
    AppCurrency(
      code: 'AUD',
      symbol: 'AU\$',
      name: 'Australian Dollar',
      flag: '🇦🇺',
      rateToUsd: 0.65,
    ),
    AppCurrency(
      code: 'SAR',
      symbol: 'SAR',
      name: 'Saudi Riyal',
      flag: '🇸🇦',
      rateToUsd: 0.27,
    ),
    AppCurrency(
      code: 'AED',
      symbol: 'AED',
      name: 'UAE Dirham',
      flag: '🇦🇪',
      rateToUsd: 0.27,
    ),
    AppCurrency(
      code: 'MAD',
      symbol: 'DH',
      name: 'Moroccan Dirham',
      flag: '🇲🇦',
      rateToUsd: 0.10,
    ),
    AppCurrency(
      code: 'CHF',
      symbol: 'CHF',
      name: 'Swiss Franc',
      flag: '🇨🇭',
      rateToUsd: 1.13,
    ),
    AppCurrency(
      code: 'INR',
      symbol: '₹',
      name: 'Indian Rupee',
      flag: '🇮🇳',
      rateToUsd: 0.012,
    ),
  ];

  static AppCurrency defaultCurrency = supportedCurrencies.first;

  static AppCurrency fromCode(String code) {
    return supportedCurrencies.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => defaultCurrency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppCurrency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

