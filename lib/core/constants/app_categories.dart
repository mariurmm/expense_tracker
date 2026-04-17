import 'package:flutter/material.dart';

class AppCategories {
  AppCategories._();

  static const List<String> all = [
    'Food',
    'Transport',
    'Salary',
    'Shopping',
    'Health',
    'Other',
  ];

  static const Map<String, IconData> icons = {
    'Food': Icons.restaurant_outlined,
    'Transport': Icons.directions_car_outlined,
    'Salary': Icons.account_balance_wallet_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Health': Icons.favorite_outline,
    'Other': Icons.category_outlined,
  };

  static IconData iconOf(String category) =>
      icons[category] ?? Icons.category_outlined;
}
