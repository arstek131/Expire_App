/* flutter */
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

/* models */
import 'package:expire_app/models/shopping_list.dart';
import '../models/shopping_list_element.dart';

/* helpers */
import '../helpers/user_info.dart' as userInfo;
import '../helpers/firestore_helper.dart';

/* Firebse */
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListProvider extends ChangeNotifier {
  ShoppingListProvider();

  List<ShoppingList> _shoppingLists = [];

  bool initProvider = true;
  StreamSubscription<QuerySnapshot>? streamSub;

  List<ShoppingList> get shoppingLists {
    return [..._shoppingLists];
  }

  Future<void> fetchShoppingLists() async {
    // todo: take images from url and save them locally!
    _shoppingLists = await FirestoreHelper.instance.getShoppingListsFromFamilyId(userInfo.UserInfo.instance.familyId!);

    print(initProvider);
    if (this.initProvider) {
      print("init provider...");
      this.initProvider = false;

      // attach firestore listener
      CollectionReference reference = FirebaseFirestore.instance
          .collection('families')
          .doc(userInfo.UserInfo.instance.familyId!)
          .collection('shopping_lists');
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

    await Future.delayed(Duration(milliseconds: 300));

    notifyListeners();
  }

  Future<void> addNewShoppingList({required String title}) async {
    var uuid = const Uuid();
    String id = uuid.v1();

    final shoppingList = ShoppingList(id: id, title: title, products: [], completed: false);

    /* local insertion */
    _shoppingLists.add(shoppingList);

    notifyListeners();

    /* remote insertion */
    await FirestoreHelper.instance.addShoppingList(
      list: shoppingList,
    );
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

    /* local DB deletion */

    /* remote delete */
    FirestoreHelper.instance.deleteShoppingList(id);
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

  Future<void> addElementToShoppingList(
      {required String listId, required String shoppingListElementTitle, required int quantity}) async {
    var uuid = const Uuid();
    String id = uuid.v1();

    /* local insertion */
    List<ShoppingListElement> _list = this.getProductsFromListId(listId: listId);
    ShoppingListElement shoppingListElement = ShoppingListElement(id: id, title: shoppingListElementTitle, quantity: quantity);

    // if exists, increase quantity
    if (_list.any((element) => element.title == shoppingListElement.title || element.id == shoppingListElement.id)) {
      print("Update");
      _list[_list.indexWhere((element) => element.id == shoppingListElement.id || element.title == shoppingListElement.title)]
          .quantity += quantity;
    }
    // else add
    else {
      print("Add");
      _list.add(shoppingListElement);
    }
    notifyListeners();

    /* remote insertion */
    await FirestoreHelper.instance
        .addElementToShoppingList(listId: listId, shoppingListElement: shoppingListElement); // wait to avoid clogging in writes
  }

  Future<void> incrementProductQuantity({required String listId, required String productId}) async {
    /* local increment */
    List<ShoppingListElement> _list = this.getProductsFromListId(listId: listId);
    ShoppingListElement element = _list.firstWhere((element) => element.id == productId);
    element.incrementQuantity();

    notifyListeners();

    /* remote increment */
    FirestoreHelper.instance.updateQuantity(listId: listId, elementId: productId, quantity: element.quantity);
  }

  Future<void> decrementProductQuantity({required String listId, required String productId}) async {
    /* local increment */
    List<ShoppingListElement> _list = this.getProductsFromListId(listId: listId);
    ShoppingListElement element = _list.firstWhere((element) => element.id == productId);
    element.decrementQuantity();

    notifyListeners();

    /* remote increment */
    FirestoreHelper.instance.updateQuantity(listId: listId, elementId: productId, quantity: element.quantity);
  }

  Future<void> updateCompletedShoppingList(String shoppingListid, bool completed) async {
    /* local update  */
    _shoppingLists[_shoppingLists.indexWhere((element) => element.id == shoppingListid)].completed = completed;
    notifyListeners();

    /* remote update */
    FirestoreHelper.instance.updateCompleted(listId: shoppingListid, completed: completed);
  }

  Future<void> updateShoppingListElementChecked(String shoppingListid, String elementId, bool checked) async {
    /* local update  */
    final listIndex = _shoppingLists.indexWhere((element) => element.id == shoppingListid);
    final productIndex = _shoppingLists[listIndex].products.indexWhere((element) => element.id == elementId);
    _shoppingLists[listIndex].products[productIndex].checked = checked;
    notifyListeners();

    /* remote update */
    FirestoreHelper.instance.updateChecked(listId: shoppingListid, elementId: elementId, checked: checked);
  }

  Future<void> deleteShoppingListElement(String shoppingListid, String elementId) async {
    /* local removal */
    final list = getProductsFromListId(listId: shoppingListid);
    list.removeWhere((element) => element.id == elementId);

    /* remote removal */
    FirestoreHelper.instance.deleteShoppingListElement(shoppingListid, elementId);
  }

  int getUniqueNameId() {
    return _shoppingLists.where((element) => element.title.contains("Shopping list")).length;
  }

  void cleanProviderState() {
    streamSub?.cancel();
    initProvider = true;
    _shoppingLists = [];
  }
}
