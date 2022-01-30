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

@GenerateMocks([FirestoreHelper, UserInfo])
void main() {
  // MOCKS
  MockFirestoreHelper mockFirestoreHelper = MockFirestoreHelper();
  MockFirebaseAuth mockFirebaseAuth =
      MockFirebaseAuth(mockUser: MockUser(uid: 'uid', displayName: 'displayName', email: 'email@email.com'), signedIn: true);
  MockGoogleSignIn mockGoogleSignIn = MockGoogleSignIn();

  /* UNIT UNDER TEST (UPDATABLE SINGLETON) */
  FirebaseAuthHelper firebaseAuthHelper;

  /* STATIC STUBS */
  when(mockFirestoreHelper.setDisplayName(displayName: anyNamed('displayName'), userId: anyNamed('userId')))
      .thenAnswer((_) async => null);

  /***
   * Note: Resetting stubs every time is necessary because call count are not resetted between each tests
   * making it impossible to test callcount() or verifyNever().
   * By calling the reset function, also stubs are deleted and needs therefore to be re-defined.
   */

  group('[Auth, email and password]', () {
    test('Not logged in', () {
      // SETUP
      firebaseAuthHelper = FirebaseAuthHelper(
        mockAuth: MockFirebaseAuth(mockUser: null, signedIn: false),
        mockFirestoreHelper: mockFirestoreHelper,
        mockGoogleAuth: mockGoogleSignIn,
      );

      // RUN

      // VERIFY
      expect(firebaseAuthHelper.isAuth, false);
    });

    test('Get user info', () async {
      // SETUP
      firebaseAuthHelper = FirebaseAuthHelper(
        mockAuth: mockFirebaseAuth,
        mockFirestoreHelper: mockFirestoreHelper,
        mockGoogleAuth: mockGoogleSignIn,
      );

      // RUN
      bool isAuth = firebaseAuthHelper.isAuth;
      bool isDisplayNameSet = firebaseAuthHelper.isDisplayNameSet;
      String? displayName = firebaseAuthHelper.displayName;
      String? userId = firebaseAuthHelper.userId;
      String? email = firebaseAuthHelper.email;

      // VERIFY
      expect(isAuth, true);
      expect(isDisplayNameSet, true);
      expect(displayName, 'displayName');
      expect(userId, 'uid');
      expect(email, 'email@email.com');

      await firebaseAuthHelper.setDisplayName('test');
      /*expect(firebaseAuthHelper.displayName, 'test');*/
    });
  });
}
