import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  /* singleton */
  FirestoreHelper._privateConstructor();
  static final FirestoreHelper _instance = FirestoreHelper._privateConstructor();
  static FirestoreHelper get instance => _instance;

  /* varialbes */
  final firestore = FirebaseFirestore.instance;

  /* getters */
  Future<List<dynamic>> getUsersFromFamilyId({required String familyId}) async {
    final response = await firestore.collection('families').doc(familyId).get();

    if (response.data() != null) {
      return response.data()!["_users"];
    } else {
      return [];
    }
  }

  Future<String?> getFamilyIdFromUserId({required String userId}) async {
    // Legacy
    /*
    var querySnapshot = await firestore.collection('families').get();
    for (final document in querySnapshot.docs) {
      print("Searching in document: ${document.id}");
      try {
        // check if family collection has subuser with given id
        var sub = await firestore.collection('families').doc(document.id).get();
        final userIds = List<String>.from(sub.data()!["_users"]);
        if (userIds.contains(userId)) {
          return document.id;
        }
      } catch (e, stacktrace) {
        print('Exception: ' + e.toString());
        print('Stacktrace: ' + stacktrace.toString());
      }
    }
    return null;*/
  }

  Future<String?> getDisplayNameFromUserId({required String userId, String? familyId}) async {
    // legacy
    /*
    // if no family ID provided, find family id first
    if (familyId == null) {
      familyId = await getFamilyIdFromUserId(userId: userId);
      if (familyId == null) {
        throw Exception("no familyId found from userId given");
      }
    }
    // get display name
    var response = await firestore.collection("families").doc(familyId).collection(userId).doc('userInfo').get();

    return response["displayName"];*/
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
      final familyReference = await firestore.collection('families').add({
        '_users': [
          userId,
        ]
      });
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
}
