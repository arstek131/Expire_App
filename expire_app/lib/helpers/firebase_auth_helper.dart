/* dart */
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/* enums */
import '../enums/sign_in_method.dart';

class FirebaseAuthHelper {
  /* singleton */
  FirebaseAuthHelper._privateConstructor();

  static final FirebaseAuthHelper _instance = FirebaseAuthHelper._privateConstructor();

  static FirebaseAuthHelper get instance => _instance;

  /* variables */
  final _auth = FirebaseAuth.instance;

  SignInMethod _signInMethod = SignInMethod.None; // default

  // OAuth
  GoogleSignIn googleSignIn = GoogleSignIn();

  /* getters */
  FirebaseAuth get auth {
    return _auth;
  }

  bool get isAuth {
    return _auth.currentUser != null;
  }

  bool get isDisplayNameSet {
    return isAuth ? _auth.currentUser!.displayName != null : false;
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

  /* setters */

  Future<void>? setDisplayName(String? displayName) async {
    if (isAuth && displayName != null) {
      await FirestoreHelper.instance.setDisplayName(userId: FirebaseAuthHelper.instance.userId!, displayName: displayName);
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

    await FirestoreHelper.instance.addUser(userId: userCredential.user!.uid, familyId: familyId);
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

        await FirestoreHelper.instance.addUser(userId: userId);
        await setDisplayName(displayName);
        await FirestoreHelper.instance.setDisplayName(userId: userId, displayName: displayName);
      }
    } on FirebaseAuthException catch (error) {
      rethrow;
    } catch (error) {
      print(error);
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();

    if (signInMethod == SignInMethod.Google) {
      await googleSignIn.disconnect();
    }
  }
}
