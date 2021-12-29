/* dart */
import 'package:flutter/material.dart';

/* helpers */
import '../helpers/db_helper.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/firebase_auth_helper.dart';

class UserInfoProvider extends ChangeNotifier {
  UserInfoProvider() {
    throw Deprecated("This class has been deprecated and no longer functioning.");
  }

  /*bool get isNameSet {
    return _displayName != null;
  }

  String? get userId {
    return _userId;
  }

  String? get familyId {
    return _familyId;
  }

  String? get displayName {
    return _displayName;
  }

  Future<void> tryFetchDisplayName() async {
    _displayName =
        await DBHelper.getDisplayNameFromUserId(userId!); // if OAuth login, this will be set by auth provider in the DB
    print("Family id: $_familyId");
    if (_displayName == null) {
      print("Need to check displayName in the firebase DB!");
      final document = await firestore.collection('families').doc(_familyId).collection(_userId!).doc('userInfo').get();
      if (document.data()!.isNotEmpty) {
        _displayName = document.data()!['displayName'];
      }

      if (_displayName == null) {
        print("Something went wrong");
        return;
      }
      // update local DB
      await DBHelper.insert(
        'users',
        {
          'userId': _userId!,
          'displayName': _displayName!,
        },
      );
    } else {
      print("No need to check displayName on remote DB!");
    }
    print("displayName: $_displayName");
    //notifyListeners(); //causing setState to be triggered again!! also futurebuilder
  }

  Future<void> setDisplayName(String? displayName) async {
    _displayName = displayName;

    // display name
    await DBHelper.insert(
      'users',
      {
        'userId': _userId!,
        'displayName': _displayName!, // todo: change
      },
    );
    print("Display name: $_displayName");

    // set to remote DB
    await firestore.collection("families").doc(_familyId).collection(_userId!).doc('userInfo').set(
      {
        'displayName': _displayName,
      },
    );

    notifyListeners();
  }*/
}
