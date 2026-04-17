import 'package:flutter/material.dart';
import 'category_model.dart';

/// Builds the six pre-defined categories seeded on first launch and after
/// a "clear all data" reset.
List<Category> buildDefaultCategories() => [
      Category(
        id: 'cat_food',
        name: 'Food',
        icon: Icons.restaurant.codePoint,
        color: 0xFFFF7043,
        isCustom: false,
      ),
      Category(
        id: 'cat_transport',
        name: 'Transport',
        icon: Icons.directions_car.codePoint,
        color: 0xFF42A5F5,
        isCustom: false,
      ),
      Category(
        id: 'cat_salary',
        name: 'Salary',
        icon: Icons.account_balance_wallet.codePoint,
        color: 0xFF66BB6A,
        isCustom: false,
      ),
      Category(
        id: 'cat_shopping',
        name: 'Shopping',
        icon: Icons.shopping_bag.codePoint,
        color: 0xFFAB47BC,
        isCustom: false,
      ),
      Category(
        id: 'cat_health',
        name: 'Health',
        icon: Icons.favorite.codePoint,
        color: 0xFFEF5350,
        isCustom: false,
      ),
      Category(
        id: 'cat_other',
        name: 'Other',
        icon: Icons.category.codePoint,
        color: 0xFF78909C,
        isCustom: false,
      ),
    ];
