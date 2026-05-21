class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
  });

  final String code;
  final String symbol;
  final String name;
  final String locale;
}

const List<CurrencyInfo> kSupportedCurrencies = [
  CurrencyInfo(code: 'KZT', symbol: '₸',  name: 'Kazakhstani Tenge', locale: 'kk_KZ'),
  CurrencyInfo(code: 'RUB', symbol: '₽',  name: 'Russian Ruble',     locale: 'ru_RU'),
  CurrencyInfo(code: 'USD', symbol: r'$', name: 'US Dollar',          locale: 'en_US'),
  CurrencyInfo(code: 'EUR', symbol: '€',  name: 'Euro',               locale: 'eu'),
  CurrencyInfo(code: 'GBP', symbol: '£',  name: 'British Pound',      locale: 'en_GB'),
];

CurrencyInfo currencyByCode(String code) =>
    kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kSupportedCurrencies.first,
    );
