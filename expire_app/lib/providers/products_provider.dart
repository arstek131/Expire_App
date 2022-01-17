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

/* enums */
import '../enums/ordering.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider();

  bool initProvider = true;
  Ordering _ordering = Ordering.ExpiringSoon;

  StreamSubscription<QuerySnapshot>? streamSub;

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchProducts() async {
    // todo: take images from url and save them locally!
    _items = await FirestoreHelper.instance.getProductsFromFamilyId(userInfo.UserInfo.instance.familyId!);
    sortProducts(_ordering);

    print(initProvider);
    if (this.initProvider) {
      print("init provider...");
      this.initProvider = false;

      // attach firestore listener
      CollectionReference reference =
          FirebaseFirestore.instance.collection('families').doc(userInfo.UserInfo.instance.familyId!).collection('products');
      streamSub = reference.snapshots().listen(
        (querySnapshot) {
          querySnapshot.docChanges.forEach((change) async {
            modifyProduct(
              Product(
                id: change.doc.id,
                title: change.doc['title'],
                expiration: DateTime.parse(change.doc['expiration']),
                dateAdded: DateTime.parse(change.doc['dateAdded']),
                creatorId: change.doc['creatorId'],
                image: change.doc['imageUrl'],
                creatorName: (await FirestoreHelper.instance.getDisplayNameFromUserId(userId: change.doc['creatorId']))!,
                nutriments: FirestoreHelper.instance.parseNutriments(change.doc['nutriments']),
                ingredientsText: change.doc['ingredientsText'],
                nutriscore: change.doc['nutriscore'],
                allergens: change.doc['allergens'] == null ? null : List<String>.from(change.doc['allergens']),
                ecoscore: change.doc['ecoscore'],
                packaging: change.doc['packaging'],
                ingredientLevels:
                    change.doc['ingredientLevels'] == null ? null : Map<String, String>.from(change.doc['ingredientLevels']),
                isPalmOilFree: change.doc['isPalmOilFree'],
                isVegetarian: change.doc['isVegetarian'],
                isVegan: change.doc['isVegan'],
                brandName: change.doc['brandName'],
                quantity: change.doc['quantity'],
              ),
            );
            print("Something changed for: ${change.doc.id}");
          });
        },
      );
    }

    await Future.delayed(Duration(milliseconds: 300));
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    var uuid = const Uuid();
    String productId = uuid.v1();

    /* local cache insertion */
    Product newProduct = Product(
      id: productId,
      title: product.title,
      expiration: product.expiration,
      dateAdded: product.dateAdded,
      creatorId: userInfo.UserInfo.instance.userId!,
      creatorName: userInfo.UserInfo.instance.displayName!,
      image: product.image,
      nutriments: product.nutriments,
      ingredientsText: product.ingredientsText,
      nutriscore: product.nutriscore,
      allergens: product.allergens,
      ecoscore: product.ecoscore,
      packaging: product.packaging,
      ingredientLevels: product.ingredientLevels,
      isPalmOilFree: product.isPalmOilFree,
      isVegetarian: product.isVegetarian,
      isVegan: product.isVegan,
      brandName: product.brandName,
      quantity: product.quantity,
    );

    print(newProduct.ingredientLevels);

    _items.add(newProduct);
    sortProducts(_ordering);

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

  void sortProducts(Ordering ordering) {
    _ordering = ordering;

    switch (ordering) {
      case Ordering.ExpiringSoon:
        _items.sort((a, b) => a.expiration.compareTo(b.expiration));
        break;
      case Ordering.ExpiringLast:
        _items.sort((a, b) => a.expiration.compareTo(b.expiration));
        _items = _items.reversed.toList();
        break;
      default:
        break;
    }

    notifyListeners();
  }

  Product getItemFromId(String productId) {
    return _items.firstWhere((element) => element.id == productId);
  }

  void cleanProviderState() {
    streamSub?.cancel();
    initProvider = true;
    _ordering = Ordering.ExpiringSoon;
    _items = [];
  }
}
