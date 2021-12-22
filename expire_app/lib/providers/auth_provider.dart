/* dart */
import 'package:expire_app/helpers/db_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:enum_to_string/enum_to_string.dart';

/* helpers */
import '../helpers/sign_in_method.dart';

/* models */
import '../models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  static const WEB_API_KEY = "AIzaSyCB3lLOarxGaMlJxRhL1QXVKUCh-O2T83Q";

  /* Session related */
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  /* User info */
  String? _displayName;

  /* OAuth */
  SignInMethod _signInMethod = SignInMethod.None; // default

  // Google
  final googleSignIn = GoogleSignIn();

  // Facebook
  //...

  // Apple
  //...

  /* End of OAuth */

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null && _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  SignInMethod get signInMethod {
    return _signInMethod;
  }

  String? get displayName {
    return _displayName;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$WEB_API_KEY";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );

      _autoLogout(logout);
      notifyListeners();

      await DBHelper.insert(
        'users',
        {
          'userId': _userId!,
          'displayName': "Alessandro Sorrentino", // todo: change
        },
      );

      _signInMethod = SignInMethod.EmailAndPassword;

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
      prefs.setString('signInMethod', EnumToString.convertToString(signInMethod));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    // need to keep track of signinmethod! have to save it too?
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _signInMethod = EnumToString.fromString(SignInMethod.values, prefs.getString("signInMethod")!)!;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout(logout);
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); // purge all! use remove to remove single key
  }

  void _autoLogout(logOutFunction) {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOutFunction);
  }

  Future<void> googleLogIn() async {
    try {
      // Google sign in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      // User info
      GoogleSignInAccount? _user = googleUser;
      _displayName = _user.displayName;

      // Google authentication (token, id, ...)
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      _token = credential.accessToken; // not auth= ... but access_token=

      // Firebase OAuth
      final response = await FirebaseAuth.instance.signInWithCredential(credential);

      _userId = response.user!.uid;

      // default 1h expiration token
      _expiryDate = DateTime.now().add(
        const Duration(
          seconds: 3600,
        ),
      );

      _autoLogout(googleLogout);
      notifyListeners();

      _signInMethod = SignInMethod.Google;

      await DBHelper.insert(
        'users',
        {
          'userId': _userId!,
          'displayName': _displayName as String,
        },
      );

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
      prefs.setString('signInMethod', EnumToString.convertToString(signInMethod));
      //prefs.setString('signInMethod', signInMethod.name);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> googleLogout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    logout();
  }
}
