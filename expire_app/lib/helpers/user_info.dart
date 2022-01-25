/* dart */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* firebase */
import '../helpers/firebase_auth_helper.dart';
import '../helpers/firestore_helper.dart';

class UserInfo {
  /* singleton */
  UserInfo._privateConstructor();

  static final UserInfo _instance = UserInfo._privateConstructor();

  static UserInfo get instance => _instance;

  /* variables */
  String? _userId;
  String? _familyId;
  String? _displayName;
  FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;

  /* getters */

  String? get userId {
    return _userId;
  }

  String? get familyId {
    return _familyId;
  }

  String? get displayName {
    return _displayName;
  }

  /* setters */

  set userId(userId) {
    _userId = userId;
  }

  set familyId(familyId) {
    _familyId = familyId;
  }

  set displayName(displayName) {
    _displayName = displayName;
  }

  /* other */
  Future<void> initUserInfoProvider() async {
    // if registered user, fetch data
    if (_auth.isAuth) {
      _userId = FirebaseAuthHelper.instance.userId;
      _displayName = FirebaseAuthHelper.instance.displayName;
      _familyId = await FirestoreHelper.instance.getFamilyIdFromUserId(userId: _userId!);
    }
    // if unregistered, get data from shared preferences
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString("localUserId");
      _displayName = prefs.getString("localDisplayName");
      _familyId = prefs.getString("localFamilyId");
    }
  }
}
