/* dart */
import 'dart:io';
import 'dart:typed_data';

import 'package:expire_app/providers/filters_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

/* Firebse */
import '../helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/firebase_auth_helper.dart';

/* models */
import '../models/product.dart';
import '../models/filter.dart';

/* helpers */
import '../helpers/user_info.dart' as userInfo;
import '../helpers/db_manager.dart';

/* enums */
import '../enums/ordering.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider();

  bool _initProvider = true;
  Ordering _ordering = Ordering.ExpiringSoon;

  StreamSubscription<QuerySnapshot>? streamSub;

  List<Product> _items = [];

  FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;
  DBManager _db = DBManager.instance;

  List<Product> get items {
    return [..._items];
  }

  List<Product> getItems({Filter? filter}) {
    if (filter == null || !filter.isFilterSet()) {
      return items;
    }

    List<Product> products = [];

    if (filter.isFish) {}

    if (filter.isMeat) {}

    if (filter.isPalmOilFree) {
      List<Product> tmps = _items
          .where(
            (element) => element.isPalmOilFree != null
                ? !element.isPalmOilFree!.toUpperCase().contains("NON") &&
                    !element.isPalmOilFree!.toUpperCase().contains("UNKNOWN")
                : false,
          )
          .toList();

      for (final tmp in tmps) {
        if (!products.any((item) => item.id == tmp.id)) {
          products.add(tmp);
        }
      }
    }

    if (filter.isVegan) {
      List<Product> tmps = _items
          .where(
            (element) => element.isVegan != null
                ? !element.isVegan!.toUpperCase().contains("NON") && !element.isVegan!.toUpperCase().contains("UNKNOWN")
                : false,
          )
          .toList();

      for (final tmp in tmps) {
        if (!products.any((item) => item.id == tmp.id)) {
          products.add(tmp);
        }
      }
    }

    if (filter.isVegetarian) {
      List<Product> tmps = _items
          .where(
            (element) => element.isVegetarian != null
                ? !element.isVegetarian!.toUpperCase().contains("NON") && !element.isVegetarian!.toUpperCase().contains("UNKNOWN")
                : false,
          )
          .toList();

      for (final tmp in tmps) {
        if (!products.any((item) => item.id == tmp.id)) {
          products.add(tmp);
        }
      }
    }

    // todo: implement search that updates every keystroke
    if (filter.searchKeywords.isNotEmpty) {
      List<Product> referenceList;

      if (!filter.areCategoriesSet()) {
        referenceList = _items;
      } else {
        referenceList = products;
      }

      for (final searchKeyword in filter.searchKeywords) {
        products = referenceList.where((product) {
          if (product.title.toLowerCase().contains(searchKeyword.toLowerCase())) {
            return true;
          }
          return false;
        }).toList();

        referenceList = products;
      }
    }

    if (filter.hideExpired) {
      List<Product> referenceList;

      if (products.isEmpty) {
        referenceList = _items;
      } else {
        referenceList = products;
      }

      products = referenceList.where((element) {
        DateTime today = DateTime.now();

        int dateDifferenceInDays = DateTime(element.expiration.year, element.expiration.month, element.expiration.day)
            .difference(
              DateTime(today.year, today.month, today.day),
            )
            .inDays;

        if (dateDifferenceInDays < 0) {
          return false;
        } else {
          return true;
        }
      }).toList();
    }

    return products;
  }

  Future<void> fetchProducts() async {
    // fetch from server
    if (_auth.isAuth) {
      // todo: take images from url and save them locally!
      _items = await FirestoreHelper.instance.getProductsFromFamilyId(userInfo.UserInfo.instance.familyId!);

      if (this._initProvider) {
        this._initProvider = false;

        // attach firestore listener
        CollectionReference reference =
            FirebaseFirestore.instance.collection('families').doc(userInfo.UserInfo.instance.familyId!).collection('products');
        streamSub = reference.snapshots().listen(
          (querySnapshot) {
            querySnapshot.docChanges.forEach((change) async {
              Product updatedProduct = Product(
                id: change.doc.id,
                title: change.doc['title'],
                expiration: DateTime.parse(change.doc['expiration']),
                dateAdded: DateTime.parse(change.doc['dateAdded']),
                creatorId: change.doc['creatorId'],
                image: change.doc['imageUrl'],
                creatorName:
                    (await FirestoreHelper.instance.getDisplayNameFromUserId(userId: change.doc['creatorId'])) ?? "Uknown",
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
              );
              if (change.type == DocumentChangeType.modified) {
                modifyProduct(updatedProduct);
                print("Something changed for product: ${change.doc.id}");
              } else if (change.type == DocumentChangeType.removed) {
                _items.removeWhere((element) => element.id == updatedProduct.id);
                notifyListeners();
                print("Product deleted: ${change.doc.id}");
              } else if (change.type == DocumentChangeType.added) {
                if (!_items.any((element) => element.id == updatedProduct.id)) {
                  _items.add(updatedProduct);
                }
                notifyListeners();
                print("New product added: ${change.doc.id}");
              } else {
                print("UNSUPPORTED OPERATION FROM SERVER");
                throw Exception();
              }

              print("Something changed for: ${change.doc.id}");
            });
          },
        );
      }
    }
    // fetch from local DB
    else {
      _items = await _db.getProducts();
    }

    sortProducts(_ordering);
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
    if (_auth.isAuth) {
      await FirestoreHelper.instance.addProduct(
        product: newProduct,
        image: product.image,
      );
    }
    /* local DB insertion */
    else {
      Uint8List? imageRaw;
      // convert image to Uint8List
      if (product.image != null) {
        // gallery or camera format (File)
        if (product.image is File) {
          imageRaw = await product.image.readAsBytes();
        }
        // url format (String)
        else if (product.image is String) {
          imageRaw = (await NetworkAssetBundle(
            Uri.parse(product.image),
          ).load(product.image))
              .buffer
              .asUint8List();
        }
        // BLOB format (Uint8List)
        else if (product.image is Uint8List) {
        } else {
          imageRaw = null;
        }
      }

      _db.addProduct(
        product: newProduct,
        imageRaw: imageRaw,
      );
    }
  }

  void modifyProduct(Product product) {
    /* if exists, update */
    if (_items.any((element) => element.id == product.id)) {
      _items[_items.indexWhere((element) => element.id == product.id)] = product;
    }
    notifyListeners();
  }

  void deleteProduct(String productId) {
    /* local delete */
    _items.removeWhere((element) => element.id == productId);

    notifyListeners();

    /* remote delete */
    if (_auth.isAuth) {
      FirestoreHelper.instance.deleteProduct(productId);
    }
    /* local DB deletion */
    else {
      _db.deleteProduct(productId: productId);
    }
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

  Future<void> cleanProviderState() async {
    await streamSub?.cancel();
    _initProvider = true;
    _ordering = Ordering.ExpiringSoon;
    _items = [];
  }
}
