import 'dart:io';

import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:expire_app/helpers/user_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DependenciesProvider {
  DependenciesProvider({
    mockFirestoreHelper,
    mockFirebaseAuthHelper,
    mockFirebaseStorage,
    mockUserInfo,
    mockSharedPreferences,
    mockFirebaseMessaging,
  }) {
    if (true) {
      if (mockFirestoreHelper == null) {
        _firestoreHelper = (!Platform.environment.containsKey('FLUTTER_TEST') ? FirestoreHelper() : null);
      } else {
        _mockFirestoreHelper = mockFirestoreHelper;
      }

      if (mockFirebaseAuthHelper == null) {
        _firebaseAuthHelper = (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : null);
      } else {
        _mockFirebaseAuthHelper = mockFirebaseAuthHelper;
      }

      if (mockUserInfo == null) {
        _userInfo = (!Platform.environment.containsKey('FLUTTER_TEST') ? UserInfo() : null);
      } else {
        _mockUserInfo = mockUserInfo;
      }

      if (mockFirebaseStorage == null) {
        _firebaseStorage = (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseStorage.instance : null);
      } else {
        _mockFirebaseStorage = mockFirebaseStorage;
      }

      if (mockSharedPreferences == null) {
        _sharedPreferences = (!Platform.environment.containsKey('FLUTTER_TEST') ? null : null);
      } else {
        mockSharedPreferences = mockSharedPreferences;
      }

      if (mockFirebaseMessaging == null) {
        _firebaseMessaging = (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseMessaging.instance : null);
      } else {
        mockFirebaseMessaging = mockFirebaseMessaging;
      }
    }
  }

  /* varialbes */
  FirestoreHelper? _firestoreHelper;
  FirebaseAuthHelper? _firebaseAuthHelper;
  UserInfo? _userInfo;
  FirebaseStorage? _firebaseStorage;
  SharedPreferences? _sharedPreferences;
  FirebaseMessaging? _firebaseMessaging;

  dynamic _mockFirestoreHelper;
  dynamic _mockFirebaseAuthHelper;
  dynamic _mockUserInfo;
  dynamic _mockFirebaseStorage;
  dynamic _mockSharedPreferences;
  dynamic _mockFirebaseMessaging;

  get firestore => _mockFirestoreHelper != null ? _mockFirestoreHelper : _firestoreHelper;
  get auth => _mockFirebaseAuthHelper != null ? _mockFirebaseAuthHelper : _firebaseAuthHelper;
  get userInfo => _mockUserInfo != null ? _mockUserInfo : _userInfo;
  get firebaseStorage => _mockFirebaseStorage != null ? _mockFirebaseStorage : _firebaseStorage;
  get sharedPreferences => _mockSharedPreferences != null ? _mockSharedPreferences : _sharedPreferences;
  get messaging => _mockFirebaseMessaging != null ? _mockFirebaseMessaging : _firebaseMessaging;

  /*DependenciesProvider({
    mockFirestoreHelper,
    mockFirebaseAuthHelper,
    mockFirebaseStorage,
    mockUserInfo,
    mockSharedPreferences,
    mockFirebaseMessaging,
  }) {
    if (true) {
      _firestore = mockFirestoreHelper ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirestoreHelper() : null);
      _auth = mockFirebaseAuthHelper ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : null);
      _userInfo = mockUserInfo ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? UserInfo() : null);
      print(_userInfo.familyId);
      _firebaseStorage =
          mockFirebaseStorage ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseStorage.instance : null);
      _sharedPreferences = mockSharedPreferences ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? null : null);
      _messaging =
          mockFirebaseMessaging ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseMessaging.instance : null);
    } else {
      _firestore = mockFirestoreHelper ?? (/*!Platform.environment.containsKey('FLUTTER_TEST') ? FirestoreHelper() : */ null);
      _auth = mockFirebaseAuthHelper ?? (/*!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : */ null);
      _userInfo = mockUserInfo ?? (/*!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : */ null);
      _firebaseStorage =
          mockFirebaseStorage ?? (/*!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : */ null);
      _sharedPreferences =
          mockSharedPreferences ?? (/*!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : */ null);
    }
  }

  /* varialbes */
  late dynamic _firestore;
  late dynamic _auth;
  late UserInfo _userInfo;
  late dynamic _firebaseStorage;
  late dynamic _sharedPreferences;
  late dynamic _messaging;

  get firestore => this._firestore;
  get auth => this._auth;
  get userInfo => this._userInfo;
  get firebaseStorage => this._firebaseStorage;
  get sharedPreferences => this._sharedPreferences;
  get messaging => this._messaging;*/
}
