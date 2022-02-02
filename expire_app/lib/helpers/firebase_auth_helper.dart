/* dart */
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

/* enums */
import '../enums/sign_in_method.dart';
/* helper */
import '../helpers/firestore_helper.dart';

class FirebaseAuthHelper {
  /* singleton */
  FirebaseAuthHelper._privateConstructor();

  static final FirebaseAuthHelper _instance = FirebaseAuthHelper._privateConstructor();

  //static FirebaseAuthHelper get instance => _instance;

  factory FirebaseAuthHelper({mockAuth, mockGoogleAuth, mockFirestoreHelper}) {
    _instance._auth =
        mockAuth ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuth.instance : MockFirebaseAuth());
    _instance._firestore = mockFirestoreHelper ?? FirestoreHelper();
    _instance.googleSignIn =
        mockGoogleAuth ?? (!Platform.environment.containsKey('FLUTTER_TEST') ? GoogleSignIn() : MockGoogleSignIn());
    return _instance;
  }

  /* variables */
  late dynamic _auth; //!Platform.environment.containsKey('FLUTTER_TEST') ? FirebaseAuth.instance : null;
  late dynamic _firestore;
  SignInMethod _signInMethod = SignInMethod.None; // default

  // OAuth
  late GoogleSignIn googleSignIn;
  FacebookAuth facebookAuth = FacebookAuth.instance;

  /* getters */
  FirebaseAuth get auth {
    return _auth;
  }

  bool get isAuth {
    return _auth.currentUser != null;
  }

  bool get isDisplayNameSet {
    print(_auth.currentUser!.displayName);
    print(_auth.currentUser!.displayName != null);
    return isAuth
        ? _auth.currentUser!.displayName != null && _auth.currentUser!.displayName!.replaceAll(" ", "").isNotEmpty
        : false;
  }

  String? get displayName {
    return isDisplayNameSet ? _auth.currentUser!.displayName : null;
  }

  String? get userId {
    return isAuth ? _auth.currentUser!.uid : null;
  }

  SignInMethod get signInMethod {
    return _signInMethod;
  }

  String? get email {
    return isAuth ? _auth.currentUser!.email : null;
  }

  /* setters */

  Future<void>? setDisplayName(String? displayName) async {
    if (isAuth && displayName != null) {
      await _firestore.setDisplayName(userId: userId!, displayName: displayName);
    }

    return isAuth ? _auth.currentUser!.updateDisplayName(displayName) : null;
  }

  /* auth methods */
  Future<void> signInWithEmail({required String email, required String password}) async {
    _signInMethod = SignInMethod.EmailAndPassword;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUpWithEmail({required String email, required String password, String? familyId}) async {
    UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      rethrow;
    }
    _signInMethod = SignInMethod.EmailAndPassword;

    await _firestore.addUser(userId: userCredential.user!.uid, familyId: familyId);
  }

  Future<void> googleLogIn() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      GoogleSignInAccount? _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final response = await FirebaseAuth.instance.signInWithCredential(credential);
      _signInMethod = SignInMethod.Google;

      if (response.additionalUserInfo!.isNewUser) {
        String userId = response.user!.uid;
        String displayName = _user.displayName!;

        await _firestore.addUser(userId: userId);
        await setDisplayName(displayName);
        await _firestore.setDisplayName(userId: userId, displayName: displayName);
      }
    } on FirebaseAuthException catch (error) {
      rethrow;
    } catch (error) {
      print(error);
    }
  }

  Future<void> facebookLogIn() async {
    try {
      final facebookLoginResult = await facebookAuth.login();
      if (false) {
        //facebookLoginResult.status) {
        return;
      }
      final _user = await facebookAuth.getUserData();

      final facebookAuthCredential = FacebookAuthProvider.credential(facebookLoginResult.accessToken!.token);
      final response = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      _signInMethod = SignInMethod.Facebook;

      if (response.additionalUserInfo!.isNewUser) {
        String userId = response.user!.uid;
        String displayName = _user['name'];

        await _firestore.addUser(userId: userId);
        await setDisplayName(displayName);
        await _firestore.setDisplayName(userId: userId, displayName: displayName);
      }
    } on FirebaseAuthException catch (error) {
      rethrow;
    } catch (error) {
      print(error);
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();

    switch (signInMethod) {
      case SignInMethod.Google:
        await googleSignIn.disconnect();
        break;
      case SignInMethod.Facebook:
        await facebookAuth.logOut();
        break;
      default:
        break;
    }

    _signInMethod = SignInMethod.None;
  }
}
