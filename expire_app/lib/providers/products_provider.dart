/* dart */
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

/* models */
import '../models/product.dart';
import '../models/http_exception.dart';

/* helpers */
import '../helpers/db_helper.dart';

class ProductsProvider extends ChangeNotifier {
  /* TODO: if authToken != null AND userId != null then comunicate with firebase, else just store locally! */

  final String? authToken;
  final String? userId;
  final String? familyId;

  List<Product> _items;

  ProductsProvider(this.authToken, this.userId, this.familyId, this._items);

  List<Product> get items {
    return [..._items];
  }

  final baseUrl = "https://expire-app-8070c-default-rtdb.europe-west1.firebasedatabase.app";

  Future<void> addProduct(Product product) async {
    final url = "$baseUrl/families/$familyId/$userId.json?auth=$authToken";
    print(url);
    // http post
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'expiration': product.expiration.toIso8601String(),
            'imageUrl': null,
            'creatorId': userId,
          },
        ),
      );

      final decodedResponse = json.decode(response.body);
      final productId = decodedResponse['name'];

      Product newProduct = Product(
        id: productId,
        title: product.title,
        expiration: product.expiration,
        creatorId: userId!,
      );

      // local
      _items.add(newProduct);
      notifyListeners();

      DBHelper.insert(
        'user_products',
        {
          'id': newProduct.id,
          'title': newProduct.title,
          'expiration': newProduct.expiration.toIso8601String(),
          'creatorId': newProduct.creatorId,
          'image': 'null',
        },
      );
    } catch (error) {
      print(error);
      throw HttpException("Something went wrong while inserting product");
    }
  }

  void deleteProduct(String productId) {
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();

    DBHelper.delete('user_products', productId);
  }

  Future<void> fetchAndSetProducts() async {
    // todo: change with DB call
    final dataList = await DBHelper.getData(table: 'user_products');
    //print(dataList);
    _items = dataList
        .map(
          (item) => Product(
              id: item['id'],
              title: item['title'],
              expiration: DateTime.parse(
                item['expiration'],
              ),
              creatorId: item['creatorId'],
              image: null),
        )
        .toList();

    notifyListeners();
  }
}
