import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expire_app/models/product.dart';
import 'package:expire_app/models/shopping_list.dart';
import 'package:expire_app/models/shopping_list_element.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as openfoodfacts;
import 'package:openfoodfacts/model/Nutriments.dart';

/* helper */
import '../helpers/user_info.dart' as userinfo;
import '../helpers/firebase_auth_helper.dart';

class FirestoreHelper {
  /* singleton */
  FirestoreHelper._privateConstructor();
  static final FirestoreHelper _instance = FirestoreHelper._privateConstructor();
  static FirestoreHelper get instance => _instance;

  /* varialbes */
  final firestore = FirebaseFirestore.instance;
  final userInfo = userinfo.UserInfo.instance;

  /* getters */
  Future<bool> familyExists({required String familyId}) async {
    final docSnapshot = await firestore.collection('families').doc(familyId).get();
    if (docSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> getUsersFromFamilyId({required String familyId}) async {
    final response = await firestore.collection('families').doc(familyId).get();

    if (response.data() != null) {
      return response.data()!["_users"];
    } else {
      return [];
    }
  }

  Future<String?> getFamilyIdFromUserId({required String userId}) async {
    final userRef = await firestore.collection('users').doc(userId).get();
    if (userRef.data() != null && userRef.data()!.containsKey('familyId')) {
      return userRef.data()!['familyId'];
    } else {
      return null;
    }
  }

  Future<String?> getDisplayNameFromUserId({required String userId}) async {
    final userRef = await firestore.collection('users').doc(userId).get();
    if (userRef.data() != null && userRef.data()!.containsKey('displayName')) {
      return userRef.data()!['displayName'];
    } else {
      return null;
    }
  }

  Future<String?> getImageUrlFromProductId({required String productId}) async {
    final productRef = await firestore.collection("families").doc(userInfo.familyId).collection('products').doc(productId).get();

    if (productRef.data()!.containsKey("imageUrl")) {
      return productRef.data()!['imageUrl'];
    } else {
      return null;
    }
  }

  Future<List<Product>> getProductsFromFamilyId(String familyId) async {
    List<Product> products = [];

    final productsRef = await firestore.collection('families').doc(familyId).collection('products').get();

    for (var product in productsRef.docs) {
      Nutriments? nutriments = parseNutriments(product['nutriments']);

      products.add(
        Product(
          id: product.id,
          title: product['title'],
          expiration: DateTime.parse(product['expiration']),
          dateAdded: DateTime.parse(product['dateAdded']),
          creatorId: product['creatorId'],
          creatorName: (await getDisplayNameFromUserId(userId: product['creatorId']))!,
          image: product['imageUrl'],
          nutriments: nutriments,
          ingredientsText: product['ingredientsText'],
          nutriscore: product['nutriscore'],
          allergens: product['allergens'] == null ? null : List<String>.from(product['allergens']),
          ecoscore: product['ecoscore'],
          packaging: product['packaging'],
          ingredientLevels: product['ingredientLevels'] == null ? null : Map<String, String>.from(product['ingredientLevels']),
          isPalmOilFree: product['isPalmOilFree'],
          isVegetarian: product['isVegetarian'],
          isVegan: product['isVegan'],
          brandName: product['brandName'],
          quantity: product['quantity'],
        ),
      );
    }
    return products;
  }

  Future<List<ShoppingList>> getShoppingListsFromFamilyId(String familyId) async {
    List<ShoppingList> lists = [];

    final listsRef = await firestore.collection('families').doc(familyId).collection('shopping_lists').get();
    for (var list in listsRef.docs) {
      List<ShoppingListElement> products = [];

      for (final productJSON in list['products']) {
        products.add(ShoppingListElement.fromJSON(productJSON));
      }

      lists.add(
        ShoppingList(
          id: list.id,
          title: list['title'],
          products: products,
          completed: list['completed'],
        ),
      );
    }
    return lists;
  }

  Stream<QuerySnapshot> getFamilyProductsStream({required String familyId}) {
    return firestore.collection('families').doc(familyId).collection('products').snapshots();
  }

  /* setters */
  Future<void> setDisplayName({required String userId, required String displayName}) async {
    await firestore.collection('users').doc(userId).set(
      {
        'displayName': displayName,
      },
      SetOptions(merge: true),
    );
  }


  /* other */
  Future<void> addUser({required String userId, String? familyId}) async {
    // generate new family if none given and add username to user list
    if (familyId == null) {
      // generate new family and insert id
      final familyReference = await firestore.collection('families').add(
        {
          '_users': [
            userId,
          ]
        },
      );
      familyId = familyReference.id;
    } else {
      firestore.collection('families').doc(familyId).update({
        "_users": FieldValue.arrayUnion([userId]),
      });
    }

    // add user to set of users
    await firestore.collection("users").doc(userId).set({
      'familyId': familyId,
    });
  }

  Future<String?> addProduct({required Product product, dynamic image}) async {
    String? imageUrl;
    var uuid = const Uuid();

    // storing image on firestore if any
    if (image != null && !(image is String)) {
      final ref = FirebaseStorage.instance.ref().child(userInfo.userId!).child(uuid.v1());
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    } else {
      imageUrl = product.image;
    }

    final data = {
      'title': product.title,
      'expiration': product.expiration.toIso8601String(),
      'dateAdded': product.dateAdded.toIso8601String(),
      'creatorId': product.creatorId,
      'imageUrl': imageUrl,
      'nutriments': product.nutriments?.toJson(),
      'nutriscore': product.nutriscore,
      'ingredientsText': product.ingredientsText,
      'allergens': product.allergens,
      'ecoscore': product.ecoscore,
      'packaging': product.packaging,
      'ingredientLevels': product.ingredientLevels,
      'isPalmOilFree': product.isPalmOilFree,
      'isVegetarian': product.isVegetarian,
      'isVegan': product.isVegan,
      'brandName': product.brandName,
      'quantity': product.quantity,
    };

    final productRef = await firestore.collection('families').doc(userInfo.familyId).collection('products');

    if (product.id != null) {
      productRef.doc(product.id).set(data);
      return null;
    } else {
      productRef.add(data);
      return productRef.id;
    }
  }

  Future<void> addShoppingList({required ShoppingList list}) async {
    // storing shopping list on shoppingLists collection
    final listsRef = await firestore.collection('families').doc(userInfo.familyId).collection('shopping_lists');

    final data = {
      'title': list.title,
      'products': list.products,
      'completed': list.completed,
    };

    listsRef.doc(list.id).set(data);
  }

  Future<void> deleteProduct(String productId) async {
    String? imageUrl = await getImageUrlFromProductId(productId: productId);

    // delte product record
    await firestore.collection("families").doc(userInfo.familyId).collection('products').doc(productId).delete();

    // delete image
    if (imageUrl != null && imageUrl.contains("firebasestorage")) {
      String filename = FirebaseStorage.instance.refFromURL(imageUrl).name;

      final ref = FirebaseStorage.instance.ref().child(userInfo.userId!).child(filename);
      await ref.delete();
    }
  }

  Future<void> deleteShoppingList(String id) async {
    // delte shopping list record
    await firestore.collection("families").doc(userInfo.familyId).collection('shopping_lists').doc(id).delete();
  }

  Future<void> deleteShoppingListElement(String shoppingListid, String elementId) async {
    final ref =
        await firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(shoppingListid).get();
    List<dynamic> jsonProducts = ref.data()!['products'] as List<dynamic>;

    jsonProducts.removeWhere((element) => element['id'] == elementId);

    firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(shoppingListid).update(
      {'products': jsonProducts},
    );
  }

  Future<void> updateCompleted({required String listId, required bool completed}) async {
    firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).update({
      "completed": completed,
    });
  }

  Future<void> updateQuantity({required String listId, required String elementId, required int quantity}) async {
    final ref = await firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).get();
    List<dynamic> jsonProducts = ref.data()!['products'] as List<dynamic>;

    jsonProducts[jsonProducts.indexWhere((element) => element['id'] == elementId)]['quantity'] = quantity;

    firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).update(
      {'products': jsonProducts},
    );
  }

  Future<void> updateChecked({required String listId, required String elementId, required bool checked}) async {
    final ref = await firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).get();
    List<dynamic> jsonProducts = ref.data()!['products'] as List<dynamic>;

    jsonProducts[jsonProducts.indexWhere((element) => element['id'] == elementId)]['checked'] = checked;

    firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).update(
      {'products': jsonProducts},
    );
  }

  Future<void> addElementToShoppingList({required String listId, required ShoppingListElement shoppingListElement}) async {
    final ref = await firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).get();
    List<dynamic> jsonProducts = ref.data()!['products'] as List<dynamic>;

    if (jsonProducts.any((element) => element['title'] == shoppingListElement.title || element['id'] == shoppingListElement.id)) {
      jsonProducts[jsonProducts
              .indexWhere((element) => element['id'] == shoppingListElement.id || element['title'] == shoppingListElement.title)]
          ['quantity'] += shoppingListElement.quantity;
    } else {
      jsonProducts.add(shoppingListElement.toJSON());
    }

    firestore.collection('families').doc(userInfo.familyId).collection("shopping_lists").doc(listId).update({
      "products": jsonProducts, //FieldValue.arrayUnion([shoppingListElement.toJSON()]),
    });
  }

  Nutriments? parseNutriments(Map<String, dynamic> JSONnutriments) {
    if (JSONnutriments.isEmpty) {
      return null;
    }

    Nutriments nutriments = new Nutriments();

    nutriments.energyKcal = JSONnutriments['energy-kcal'];
    nutriments.fat = JSONnutriments['fat_100g'];
    nutriments.saturatedFat = JSONnutriments['saturated-fat_100g'];
    nutriments.carbohydrates = JSONnutriments['carbohydrates_100g'];
    nutriments.sugars = JSONnutriments['sugars_100g'];
    nutriments.fiber = JSONnutriments['fiber_100g'];
    nutriments.proteins = JSONnutriments['proteins_100g'];
    nutriments.salt = JSONnutriments['salt_100g'];

    return nutriments;
  }
}
