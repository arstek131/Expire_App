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
      MockFirebaseAuth(mockUser: MockUser(uid: 'uid', displayName: 'displayName_temp', email: 'email@email.com'), signedIn: true);
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
    expect(firebaseAuthHelper.isDisplayNameSet, false);
  });

  test('Sign in with google', () async {
    // SETUP
    firebaseAuthHelper = FirebaseAuthHelper(
      mockAuth: MockFirebaseAuth(
          mockUser: MockUser(uid: 'uid', displayName: 'displayName_temp', email: 'email@email.com'), signedIn: false),
      mockFirestoreHelper: mockFirestoreHelper,
      mockGoogleAuth: mockGoogleSignIn,
    );

    when(mockFirestoreHelper.addUser(userId: anyNamed('userId'))).thenAnswer((_) async => null);
    when(mockFirestoreHelper.setDisplayName(userId: anyNamed('userId'), displayName: anyNamed('displayName')))
        .thenAnswer((_) async => null);

    // RUN
    firebaseAuthHelper.googleLogIn();
    // VERIFY
  });
}
