import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = 'FCFA', String locale = 'fr_FR'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 0,
    );
    return '${formatter.format(amount)} $symbol';
  }

  static String formatWithDecimals(double amount, {String symbol = 'FCFA'}) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '',
      decimalDigits: 2,
    );
    return '${formatter.format(amount)} $symbol';
  }

  static String formatCompact(double amount, {String symbol = 'FCFA'}) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B $symbol';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $symbol';
    }
    return format(amount, symbol: symbol);
  }

  static double? parse(String amountString) {
    try {
      final cleaned = amountString.replaceAll(RegExp(r'[^\d,.-]'), '');
      final normalized = cleaned.replaceAll(',', '.');
      return double.tryParse(normalized);
    } catch (e) {
      return null;
    }
  }

  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }
}
