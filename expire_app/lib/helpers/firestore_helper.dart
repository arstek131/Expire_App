import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expire_app/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

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

  Future<void> addProduct({required Product product, File? image}) async {
    final userInfo = userinfo.UserInfo.instance;
    String? imageUrl;
    var uuid = const Uuid();

    // storing image on firestore if any
    if (image != null) {
      final ref = FirebaseStorage.instance.ref().child(userInfo.userId!).child(uuid.v1());
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    } else {
      imageUrl = product.imageUrl;
    }

    final productRef = await firestore.collection('families').doc(userInfo.familyId).collection('products').add(
      {
        'title': product.title,
        'expiration': product.expiration.toIso8601String(),
        'creatorId': userInfo.userId,
        'imageUrl': imageUrl,
      },
    );
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
}
