import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/shopping_list_element.dart';

class ShoppingList {
  ShoppingList({
    required this.id,
    required this.title,
    required this.products,
    this.completed = false,
  });

  String id;
  String title;
  List<ShoppingListElement> products;
  bool completed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingList &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          listEquals(products, other.products) &&
          completed == other.completed;

  @override
  int get hashCode => id.hashCode;
}
