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
}
