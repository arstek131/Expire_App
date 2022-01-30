/* flutter */
import 'dart:async';
import 'dart:io';

/* Firebse */
import 'package:cloud_firestore/cloud_firestore.dart';
/* models */
import 'package:expire_app/models/shopping_list.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../helpers/db_manager.dart';
import '../helpers/firebase_auth_helper.dart';
import '../helpers/firestore_helper.dart';
/* helpers */
import '../helpers/user_info.dart' as userInfo;
import '../models/shopping_list_element.dart';

class ShoppingListProvider extends ChangeNotifier {
  ShoppingListProvider({mockFirebaseAuthHelper, mockFirestoreHelper, mockUserInfo, mockDBManager}) {
    // injectable mock-dependencies
    _auth = mockFirebaseAuthHelper ?? FirebaseAuthHelper();
    _firestore = mockFirestoreHelper ?? FirestoreHelper();
    _userInfo = mockUserInfo ?? userInfo.UserInfo.instance;
    _db = mockDBManager ?? DBManager();
  }

  List<ShoppingList> _shoppingLists = [];

  bool initProvider = Platform.environment.containsKey('FLUTTER_TEST') ? false : true;
  StreamSubscription<QuerySnapshot>? streamSub;

  late FirebaseAuthHelper _auth;
  late DBManager _db;
  late userInfo.UserInfo _userInfo;
  late FirestoreHelper _firestore;

  List<ShoppingList> get shoppingLists {
    return [..._shoppingLists];
  }

  Future<void> fetchShoppingLists() async {
    if (_auth.isAuth) {
      // todo: take images from url and save them locally!
      _shoppingLists = await _firestore.getShoppingListsFromFamilyId(_userInfo.familyId!);

      if (this.initProvider) {
        print("init provider...");
        this.initProvider = false;

        // attach firestore listener
        CollectionReference reference =
            FirebaseFirestore.instance.collection('families').doc(_userInfo.familyId!).collection('shopping_lists');
        streamSub = reference.snapshots().listen(
          (querySnapshot) {
            querySnapshot.docChanges.forEach((change) async {
              print(change.type);
              List<ShoppingListElement> products = [];
              for (final productJSON in change.doc['products']) {
                products.add(ShoppingListElement.fromJSON(productJSON));
              }

              ShoppingList updatedShoppingList = ShoppingList(
                id: change.doc.id,
                title: change.doc['title'],
                products: products,
                completed: change.doc['completed'],
              );

              if (change.type == DocumentChangeType.modified) {
                modifyShoppingList(updatedShoppingList);
                print("Something changed for: ${change.doc.id}");
              } else if (change.type == DocumentChangeType.removed) {
                _shoppingLists.removeWhere((element) => element.id == updatedShoppingList.id);
                notifyListeners();
                print("List deleted: ${change.doc.id}");
              } else if (change.type == DocumentChangeType.added) {
                if (!_shoppingLists.any((element) => element.id == updatedShoppingList.id)) {
                  _shoppingLists.add(updatedShoppingList);
                }
                notifyListeners();
                print("New list added: ${change.doc.id}");
              } else {
                print("UNSUPPORTED OPERATION FROM SERVER");
                throw Exception();
              }
            });
          },
        );
      }
    } else {
      _shoppingLists = await _db.getShoppingLists();
    }

    await Future.delayed(Duration(milliseconds: 300));

    notifyListeners();
  }

  Future<String?> addNewShoppingList({required String title, List<ShoppingListElement>? products}) async {
    var uuid = const Uuid();
    String id = uuid.v1();

    final shoppingList = ShoppingList(id: id, title: title, products: products ?? [], completed: false);

    /* local insertion */
    _shoppingLists.add(shoppingList);

    notifyListeners();

    /* remote insertion */
    if (_auth.isAuth) {
      _firestore.addShoppingList(
        list: shoppingList,
      );
    } else {
      _db.addShoppingList(list: shoppingList);
    }

    return id;
  }

  void modifyShoppingList(ShoppingList shoppingList) {
    /* if exists, update */
    if (_shoppingLists.any((element) => element.id == shoppingList.id)) {
      _shoppingLists[_shoppingLists.indexWhere((element) => element.id == shoppingList.id)] = shoppingList;
    }
    notifyListeners();
  }

  void deleteShoppingList(String id) {
    /* local delete */
    _shoppingLists.removeWhere((element) => element.id == id);

    notifyListeners();

    if (_auth.isAuth) {
      /* remote delete */
      _firestore.deleteShoppingList(id);
    }
    /* local DB deletion */
    else {
      _db.deleteShoppingList(id);
    }
  }

  List<ShoppingListElement> getProductsFromListId({required String listId}) {
    ShoppingList? shoppingList;
    try {
      shoppingList = _shoppingLists.firstWhere(
        (element) => element.id == listId,
      );
    } on StateError catch (_) {
      return [];
    }

    return shoppingList.products;
  }

  Future<String?> addElementToShoppingList(
      {required String listId, required String shoppingListElementTitle, required int quantity}) async {
    var uuid = const Uuid();
    String id = uuid.v1();

    /* local insertion */
    List<ShoppingListElement> _list = this.getProductsFromListId(listId: listId);
    ShoppingListElement shoppingListElement = ShoppingListElement(id: id, title: shoppingListElementTitle, quantity: quantity);

    // if exists, increase quantity
    if (_list.any((element) => element.title == shoppingListElement.title || element.id == shoppingListElement.id)) {
      _list[_list.indexWhere((element) => element.id == shoppingListElement.id || element.title == shoppingListElement.title)]
          .quantity += quantity;
    }
    // else add
    else {
      _list.add(shoppingListElement);
    }
    notifyListeners();

    /* remote insertion */
    if (_auth.isAuth) {
      await _firestore.addElementToShoppingList(
          listId: listId, shoppingListElement: shoppingListElement); // wait to avoid clogging in writes
    }
    /* local insertion in DB */
    else {
      await _db.addElementToShoppingList(listId: listId, shoppingListElement: shoppingListElement);
    }

    return id;
  }

  Future<void> incrementProductQuantity({required String listId, required String productId}) async {
    /* local increment */
    List<ShoppingListElement> _list = this.getProductsFromListId(listId: listId);
    ShoppingListElement element = _list.firstWhere((element) => element.id == productId);
    element.incrementQuantity();

    notifyListeners();

    /* remote increment */
    if (_auth.isAuth) {
      _firestore.updateQuantity(listId: listId, elementId: productId, quantity: element.quantity);
    }
    /* local increment */
    else {
      _db.updateQuantity(elementId: productId, quantity: element.quantity);
    }
  }

  Future<void> decrementProductQuantity({required String listId, required String productId}) async {
    /* local increment */
    List<ShoppingListElement> _list = this.getProductsFromListId(listId: listId);
    ShoppingListElement element = _list.firstWhere((element) => element.id == productId);
    element.decrementQuantity();

    notifyListeners();

    /* remote decrement */
    if (_auth.isAuth) {
      _firestore.updateQuantity(listId: listId, elementId: productId, quantity: element.quantity);
    }
    /* local decrement */
    else {
      _db.updateQuantity(elementId: productId, quantity: element.quantity);
    }
  }

  Future<void> updateCompletedShoppingList(String shoppingListid, bool completed) async {
    /* local update  */
    _shoppingLists[_shoppingLists.indexWhere((element) => element.id == shoppingListid)].completed = completed;
    notifyListeners();

    if (_auth.isAuth) {
      /* remote update */
      _firestore.updateCompleted(listId: shoppingListid, completed: completed);
    } else {
      _db.updateCompletedShoppingList(listId: shoppingListid, completed: completed);
    }
  }

  Future<void> updateShoppingListElementChecked(String shoppingListid, String elementId, bool checked) async {
    /* local update  */
    final listIndex = _shoppingLists.indexWhere((element) => element.id == shoppingListid);
    final productIndex = _shoppingLists[listIndex].products.indexWhere((element) => element.id == elementId);
    _shoppingLists[listIndex].products[productIndex].checked = checked;
    notifyListeners();

    /* remote update */
    if (_auth.isAuth) {
      _firestore.updateChecked(listId: shoppingListid, elementId: elementId, checked: checked);
    }
    /* local DB update */
    else {
      _db.updateCheckedElementList(elementId: elementId, checked: checked);
    }
  }

  Future<void> deleteShoppingListElement(String shoppingListid, String elementId) async {
    /* local removal */
    final list = getProductsFromListId(listId: shoppingListid);
    list.removeWhere((element) => element.id == elementId);

    /* remote removal */
    if (_auth.isAuth) {
      _firestore.deleteShoppingListElement(shoppingListid, elementId);
    }
    /* local removal */
    else {
      _db.deleteShoppingListElement(elementId);
    }
  }

  int getUniqueNameId() {
    return _shoppingLists.where((element) => element.title.contains("Shopping list")).length;
  }

  Future<void> cleanProviderState() async {
    await streamSub?.cancel();
    initProvider = true;
    _shoppingLists = [];
  }
}
