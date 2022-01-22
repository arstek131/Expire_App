/* flutter */
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

/* models */
import 'package:expire_app/models/shopping_list.dart';

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
            modifyShoppingList(
              ShoppingList(
                id: change.doc.id,
                title: change.doc['title'],
                products: [],
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

  Future<void> addShoppingList({required String title}) async {
    var uuid = const Uuid();
    String id = uuid.v1();

    final shoppingList = ShoppingList(id: id, title: title, products: []);

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

      notifyListeners();
    }
  }

  void deleteShoppingList(String id) {
    /* local delete */
    _shoppingLists.removeWhere((element) => element.id == id);

    notifyListeners();

    /* local DB deletion */

    /* remote delete */
    FirestoreHelper.instance.deleteShoppingList(id);
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
