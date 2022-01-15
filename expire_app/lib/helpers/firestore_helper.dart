import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expire_app/models/product.dart';
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
    final userInfo = userinfo.UserInfo.instance;
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
          creatorId: product['creatorId'],
          creatorName: (await getDisplayNameFromUserId(userId: product['creatorId']))!,
          image: product['imageUrl'],
          nutriments: nutriments,
        ),
      );
    }
    return products;
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
    final userInfo = userinfo.UserInfo.instance;
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
      'creatorId': product.creatorId,
      'imageUrl': imageUrl,
      'nutriments': product.nutriments?.toJson(),
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

  Future<void> deleteProduct(String productId) async {
    final userInfo = userinfo.UserInfo.instance;

    String? imageUrl = await getImageUrlFromProductId(productId: productId);

    // delte product record
    await firestore.collection("families").doc(userInfo.familyId).collection('products').doc(productId).delete();

    // delete image
    if (imageUrl != null) {
      String filename = FirebaseStorage.instance.refFromURL(imageUrl).name;

      final ref = FirebaseStorage.instance.ref().child(userInfo.userId!).child(filename);
      await ref.delete();
    }
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
