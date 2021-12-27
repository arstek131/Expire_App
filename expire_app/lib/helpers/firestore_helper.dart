import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<List<dynamic>> getUsersFromFamilyId({required String familyId}) async {
    final response = await firestore.collection('families').doc(familyId).get();

    if (response.data() != null) {
      return response.data()!["_users"];
    } else {
      return [];
    }
  }

  static Future<String?> getFamilyIdFromUserId({required String userId}) async {
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
    return null;
  }

  static Future<String> getDisplayNameFromUserId({required String userId, String? familyId}) async {
    // if no family ID provided, find family id first
    if (familyId == null) {
      familyId = await FirestoreHelper.getFamilyIdFromUserId(userId: userId);
      if (familyId == null) {
        throw Exception("no familyId found from userId given");
      }
    }
    // get display name
    var response = await firestore.collection("families").doc(familyId).collection(userId).doc('userInfo').get();

    return response["displayName"];
  }
}
