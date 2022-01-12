/* dart */
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

/* Firebse */
import '../helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* models */
import '../models/product.dart';

/* helpers */
import '../helpers/user_info.dart' as userInfo;
import '../helpers/db_helper.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider();

  bool initProvider = true;
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchProducts() async {
    // todo: take images from url and save them locally!
    _items = await FirestoreHelper.instance.getProductsFromFamilyId(userInfo.UserInfo.instance.familyId!);

    if (this.initProvider) {
      this.initProvider = false;

      // attach firestore listener
      CollectionReference reference =
          FirebaseFirestore.instance.collection('families').doc(userInfo.UserInfo.instance.familyId!).collection('products');
      reference.snapshots().listen(
        (querySnapshot) {
          querySnapshot.docChanges.forEach((change) {
            modifyProduct(
              Product(
                id: change.doc.id,
                title: change.doc['title'],
                expiration: DateTime.parse(change.doc['expiration']),
                creatorId: change.doc['creatorId'],
                image: change.doc['imageUrl'],
              ),
            );
            print("Something changed for: ${change.doc.id}");
          });
        },
      );
    }
  }

  Future<void> addProduct(Product product) async {
    var uuid = const Uuid();
    String productId = uuid.v1();

    /* local cache insertion */
    Product newProduct = Product(
      id: productId,
      title: product.title,
      expiration: product.expiration,
      creatorId: userInfo.UserInfo.instance.userId!,
      image: product.image,
    );

    _items.add(newProduct);
    _items.sort((a, b) => a.expiration.compareTo(b.expiration));

    notifyListeners();

    /* remote insertion */
    await FirestoreHelper.instance.addProduct(
      product: newProduct,
      image: product.image,
    );

    /* local DB insertion */
    /*  DBHelper.insert(
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
    }*/
  }

  void modifyProduct(Product product) {
    /* if exists, update */
    if (_items.any((element) => element.id == product.id)) {
      _items[_items.indexWhere((element) => element.id == product.id)] = product;

      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    /* local delete */
    _items.removeWhere((element) => element.id == productId);

    notifyListeners();

    /* local DB deletion */

    /* remote delete */
    FirestoreHelper.instance.deleteProduct(productId);
  }
}
