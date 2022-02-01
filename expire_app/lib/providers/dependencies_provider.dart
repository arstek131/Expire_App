import 'dart:io';

import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';

class DependenciesProvider {
  DependenciesProvider({mockFirestoreHelper, mockFirebaseAuthHelper, mockFirebaseStorage, mockUserInfo, mockSharedPreferences}) {
    if (true) {
      _firestore = mockFirestoreHelper ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirestoreHelper() : null);
      _auth = mockFirebaseAuthHelper ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : null);
      _userInfo = mockUserInfo ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : null);
      _firebaseStorage = mockFirebaseStorage ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : null);
      _sharedPreferences =
          mockSharedPreferences ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuthHelper() : null);
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
  late final _firestore;
  late final _auth;
  late final _userInfo;
  late final _firebaseStorage;
  late final _sharedPreferences;

  get firestore => this._firestore;
  get auth => this._auth;
  get userInfo => this._userInfo;
  get firebaseStorage => this._firebaseStorage;
  get sharedPreferences => this._sharedPreferences;
}
