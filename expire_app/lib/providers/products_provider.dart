/* dart */
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/* models */
import '../models/product.dart';
import '../models/http_exception.dart';

/* helpers */
import '../helpers/db_helper.dart';

class ProductsProvider extends ChangeNotifier {
  final String? _authToken;
  final String? _userId;
  final String? _familyId;
  final bool _isAuth;

  List<Product> _items;

  bool _disposed = false;

  /* Firebase */
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  ProductsProvider(this._authToken, this._userId, this._familyId, this._isAuth, this._items);

  List<Product> get items {
    return [..._items];
  }

  final baseUrl = "https://expire-app-8070c-default-rtdb.europe-west1.firebasedatabase.app";

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    /* remote insertion */
    try {
      final response = await firestore.collection("families").doc(_familyId).collection(_userId!).add({
        'title': product.title,
        'expiration': product.expiration.toIso8601String(),
        'creatorId': _userId,
      });

      String productId = response.id;

      // storing image on firestore
      if (product.image != null) {
        final ref = FirebaseStorage.instance.ref().child(_userId!).child('$productId.jpg');
        await ref.putFile(product.image!);
        final url = await ref.getDownloadURL();
      }

      /* local insertion */
      Product newProduct = Product(
        id: productId,
        title: product.title,
        expiration: product.expiration,
        creatorId: _userId!,
        image: product.image,
      );

      _items.add(newProduct);
      _items.sort((a, b) => a.expiration.compareTo(b.expiration));
      //_items = _items.reversed.toList();

      notifyListeners();

      DBHelper.insert(
        'user_products',
        {
          'id': newProduct.id,
          'title': newProduct.title,
          'expiration': newProduct.expiration.toIso8601String(),
          'creatorId': newProduct.creatorId,
          'image': newProduct.image != null ? newProduct.image!.path : "",
        },
      );
    } catch (e, stacktrace) {
      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());

      throw HttpException("Something went wrong while inserting product");
    }
  }

  Future<void> deleteProduct(String productId) async {
    String creatorId = await DBHelper.getCreatorId(productId: productId);
    print("Deleting product $productId on creatorId $creatorId");

    /* remote delete */
    firestore.collection("families").doc(_familyId).collection(creatorId).doc(productId).delete();

    /* local delete */
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();

    DBHelper.delete('user_products', productId);
  }

  // todo: use this instead of fetchandset...
  void updateProductsOnChange() async {
    try {
      var querySnapshot = await firestore.collection('families').doc(_familyId).get();

      for (final userId in querySnapshot.data()!['_users']) {
        print("starting listening on user $userId");
        CollectionReference reference = FirebaseFirestore.instance.collection('families').doc(_familyId).collection(userId);
        reference.snapshots().listen((querySnapshot) {
          fetchAndSetProducts();
          /*for (final change in querySnapshot.docChanges) {
            print("Launching changes on $userId");
            final productData = change.doc.data() as Map<String, dynamic>;
            print(productData);
            if (!productData.containsKey('displayName')) {
              print("Changing product ${change.doc.id}");
              Product newProduct = Product(
                  id: change.doc.id,
                  title: productData['title'],
                  expiration: DateTime.parse(productData['expiration']),
                  creatorId: productData['creatorId']);
              _items[_items.indexWhere((element) => element.id == change.doc.id)] = newProduct;
              print("Finished updating product ${change.doc.id}");
            }
            print("Finished updating $userId...");
          }*/
        });
      }
    } catch (e, stacktrace) {
      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }

    //notifyListeners();
  }

  bool init = true;
  Future<void> fetchAndSetProducts() async {
    print("Fetch called");
    if (init) {
      init = false;
      updateProductsOnChange();
    }

    List<Product> products = [];

    /* fetch on remote DB */
    try {
      var querySnapshot = await firestore.collection('families').doc(_familyId).get();

      for (final userId in querySnapshot.data()!['_users']) {
        final productsRef = await firestore.collection('families').doc(_familyId).collection(userId).get();
        for (final product in productsRef.docs.where((element) => element.id != 'userInfo')) {
          String imageUrl = await FirebaseStorage.instance.ref().child(_userId!).child('${product.id}.jpg').getDownloadURL();
          print(imageUrl);
          products.add(
            Product(
              id: product.id,
              title: product['title'],
              expiration: DateTime.parse(product['expiration']),
              creatorId: userId,
            ),
          );
        }
      }
    } catch (e, stacktrace) {
      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }

    /* store on local DB */
    for (final product in products) {
      DBHelper.insert(
        'user_products',
        {
          'id': product.id,
          'title': product.title,
          'expiration': product.expiration.toIso8601String(),
          'creatorId': product.creatorId,
          'image': 'null',
        },
      );
    }

    /* fetch locally */
    final dataList = await DBHelper.getProductsFromFamilyId(familyId: _familyId!);

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
            image: null,
          ),
        )
        .toList();
    _items.sort((a, b) => a.expiration.compareTo(b.expiration));
    //_items = _items.reversed.toList();

    notifyListeners();
  }
}
