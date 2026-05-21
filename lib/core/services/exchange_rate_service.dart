import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class ExchangeRateService {
  final Map<String, _CachedRates> _cache = {};

  /// True if at least one successful API response was received this session.
  bool _hasLiveRates = false;
  bool get hasLiveRates => _hasLiveRates;

  static const Map<String, double> _fallbackFromKZT = {
    'KZT': 1.0,
    'RUB': 0.21,
    'USD': 0.002,
    'EUR': 0.0018,
    'GBP': 0.0015,
  };

  /// Returns cached rates if < 1 hour old, otherwise fetches from API.
  Future<Map<String, double>> _fetchRates(String base) async {
    final cached = _cache[base];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt).inHours < 1) {
      debugPrint('[ExchangeRate] Using cached rates for $base');
      return cached.rates;
    }

    try {
      final uri = Uri.parse(
        'https://api.exchangerate-api.com/v4/latest/$base',
      );
      debugPrint('[ExchangeRate] Fetching: $uri');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 6));

      debugPrint('[ExchangeRate] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = (data['rates'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble()));
        _cache[base] = _CachedRates(rates: rates, fetchedAt: DateTime.now());
        _hasLiveRates = true;
        debugPrint('[ExchangeRate] ✓ Live rates loaded for $base '
            '(${rates.length} currencies)');
        return rates;
      } else {
        debugPrint('[ExchangeRate] ✗ Bad status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      debugPrint('[ExchangeRate] ✗ Timeout: $e');
    } on Exception catch (e) {
      debugPrint('[ExchangeRate] ✗ Error: $e');
    }

    debugPrint('[ExchangeRate] Using fallback rates for $base');
    return _fallbackRatesFor(base);
  }

  Map<String, double> _fallbackRatesFor(String base) {
    final baseToKZT = 1.0 / (_fallbackFromKZT[base] ?? 1.0);
    return _fallbackFromKZT
        .map((code, kztRate) => MapEntry(code, baseToKZT * kztRate));
  }

  double _getFallbackRate(String from, String to) {
    final fromToKZT = 1.0 / (_fallbackFromKZT[from] ?? 1.0);
    final kztToTarget = _fallbackFromKZT[to] ?? 1.0;
    return fromToKZT * kztToTarget;
  }

  /// Convert [amount] from [fromCode] to [toCode] using live rates.
  Future<double> convert(
    double amount,
    String fromCode,
    String toCode,
  ) async {
    if (fromCode == toCode) return amount;
    final rates = await _fetchRates(fromCode);
    final rate = rates[toCode] ?? _getFallbackRate(fromCode, toCode);
    return amount * rate;
  }

  /// Synchronous conversion using hardcoded fallback rates only.
  double convertSync(double amount, String fromCode, String toCode) {
    if (fromCode == toCode) return amount;
    final fromToKZT = 1.0 / (_fallbackFromKZT[fromCode] ?? 1.0);
    final kztToTarget = _fallbackFromKZT[toCode] ?? 1.0;
    return amount * fromToKZT * kztToTarget;
  }

  /// Preload rates for [currencyCode] into cache.
  /// Call on app start and whenever the active currency changes.
  Future<void> preload(String currencyCode) async {
    await _fetchRates(currencyCode);
  }

  void clearCache() {
    _cache.clear();
    _hasLiveRates = false;
    debugPrint('[ExchangeRate] Cache cleared');
  }
}

class _CachedRates {
  const _CachedRates({required this.rates, required this.fetchedAt});
  final Map<String, double> rates;
  final DateTime fetchedAt;
}
