import 'package:flutter/material.dart';

/* dart */
import 'package:flutter/material.dart';

/* models */
import '../models/product.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _items = [Product(id: '0', title: 'Nutella', expiration: DateTime.now(), image: null)];

  List<Product> get items {
    return [..._items];
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }
}
