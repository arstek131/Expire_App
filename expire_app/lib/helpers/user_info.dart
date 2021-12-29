/* dart */
import 'package:flutter/material.dart';

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
    _userId = FirebaseAuthHelper.instance.userId;
    _displayName = FirebaseAuthHelper.instance.displayName;
    _familyId = await FirestoreHelper.instance.getFamilyIdFromUserId(userId: _userId!);
  }
}
