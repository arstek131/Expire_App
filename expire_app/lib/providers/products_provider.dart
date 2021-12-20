import 'package:flutter/material.dart';

/* dart */
import 'package:flutter/material.dart';

/* models */
import '../models/product.dart';

/* helpers */
import '../helpers/db_helper.dart';

class ProductsProvider extends ChangeNotifier {
  /* TODO: if authToken != null AND userId != null then comunicate with firebase, else just store locally! */

  final String? authToken;
  final String? userId;

  List<Product> _items;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();

    DBHelper.insert(
      'user_products',
      {
        'id': product.id,
        'title': product.title,
        'expiration': product.expiration.toIso8601String(),
        'image': 'null',
      },
    );
  }

  void deleteProduct(String productId) {
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();

    DBHelper.delete('user_products', productId);
  }

  Future<void> fetchAndSetProducts() async {
    final dataList = await DBHelper.getData('user_products');
    //print(dataList);
    _items = dataList
        .map(
          (item) => Product(id: item['id'], title: item['title'], expiration: DateTime.parse(item['expiration']), image: null),
        )
        .toList();

    notifyListeners();
  }
}
