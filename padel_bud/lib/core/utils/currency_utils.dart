import 'package:flutter/material.dart';

class CurrencyUtils {
  static const Map<String, String> currencySymbols = {
    'ILS': '₪',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': '\$',
    'CAD': '\$',
    'CHF': 'Fr',
  };

  static String getSymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }

  static Widget getCurrencyIcon(String currency) {
    final symbol = getSymbol(currency);
    return Center(
      child: Text(
        symbol,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }
}
