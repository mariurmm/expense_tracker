/// Synchronous fallback rates relative to KZT.
/// Used when async conversion is not possible (e.g. sync getters).
const Map<String, double> kFallbackRatesFromKZT = {
  'KZT': 1.0,
  'RUB': 0.21,
  'USD': 0.002,
  'EUR': 0.0018,
  'GBP': 0.0015,
};

double convertCurrencySync(
  double amount,
  String fromCode,
  String toCode,
) {
  if (fromCode == toCode) return amount;
  final fromRate = kFallbackRatesFromKZT[fromCode] ?? 1.0;
  final toRate = kFallbackRatesFromKZT[toCode] ?? 1.0;
  return (amount / fromRate) * toRate;
}
