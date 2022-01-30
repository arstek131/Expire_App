/* testing */
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

/* models */

/* dependencies */
import 'package:expire_app/helpers/user_info.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';

/* mocks */
import './products_provider_test.mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

/* enums */

@GenerateMocks([FirestoreHelper])
void main() {
  // MOCKS
  MockFirestoreHelper mockFirestoreHelper = MockFirestoreHelper();
  MockFirebaseAuth mockFirebaseAuth =
      MockFirebaseAuth(mockUser: MockUser(uid: 'uid', displayName: null, email: 'email@email.com'), signedIn: true);
  MockGoogleSignIn mockGoogleSignIn = MockGoogleSignIn();

  /* UNIT UNDER TEST (UPDATABLE SINGLETON) */
  FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper(
    mockAuth: mockFirebaseAuth,
    mockFirestoreHelper: mockFirestoreHelper,
    mockGoogleAuth: mockGoogleSignIn,
  );

  /* STATIC STUBS */

  /***
   * Note: Resetting stubs every time is necessary because call count are not resetted between each tests
   * making it impossible to test callcount() or verifyNever().
   * By calling the reset function, also stubs are deleted and needs therefore to be re-defined.
   */
}
