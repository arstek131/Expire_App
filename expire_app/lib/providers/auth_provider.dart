/* dart */
import 'package:expire_app/helpers/db_helper.dart';
import 'package:expire_app/providers/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/* helpers */
import '../helpers/sign_in_method.dart';

/* models */
import '../models/http_exception.dart';

/* getting things */
/*firestore.collection('families').get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        //print(document.data());
        //print(document.id);
      });
    });*/

/* pushing things */
/*firestore.collection('families').add({
      "PROVA": "prova",
    });*/
/*firestore.collection('families').doc("prova").set({
      'porco': 'dio',
    });*/

/* firestore.collection('families').add({
      "PROVA": "prova",
    }).then((docRef) => print(docRef.id));*/

class AuthProvider with ChangeNotifier {
  static const WEB_API_KEY = "AIzaSyCB3lLOarxGaMlJxRhL1QXVKUCh-O2T83Q";

  /* Session related */
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  String? _familyId;
  Timer? _authTimer;

  /* Firebase */
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  /* OAuth */
  SignInMethod _signInMethod = SignInMethod.None; // default

  // Google
  final googleSignIn = GoogleSignIn();

  // Facebook
  FacebookAuth facebookAuth = FacebookAuth.instance;

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

  String? get familyId {
    return _familyId;
  }

  SignInMethod get signInMethod {
    return _signInMethod;
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
    // authenitcate
    await _authenticate(email, password, 'signUp'); // set token, userId, expiryDate

    // generate new family and insert id
    await firestore.collection('families').add({}).then(
      (familyReference) {
        _familyId = familyReference.id;
        print("Family id: $_familyId");
        return firestore.collection("families").doc(familyReference.id).collection(_userId!).doc('userInfo').set(
          {},
        );
      },
    );

    // family id registering on db
    await DBHelper.insert(
      'family',
      {
        'userId': _userId!,
        'familyId': _familyId!, // todo: change
      },
    );

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authenticate(email, password, 'signInWithPassword');

    // family ID
    _familyId = await DBHelper.getFamilyIdFromUserId(_userId!);
    if (_familyId == null) {
      print("Need to check familyId in the firebase DB!");

      // check on remote DB
      var querySnapshot = await firestore.collection('families').get();
      for (final document in querySnapshot.docs) {
        print("Searching in document: ${document.id}");
        try {
          // check if family collection has subuser with given id
          var sub = await firestore.collection('families').doc(document.id).collection(_userId!).get();
          if (sub.docs.length > 0) {
            print("user ${_userId} found family: ${document.id}");
            _familyId = document.id;
          }
        } catch (e, stacktrace) {
          print('Exception: ' + e.toString());
          print('Stacktrace: ' + stacktrace.toString());
        }
        //print(document.id);
      }

      if (_familyId == null) {
        print("Something went wrong");
        return;
      }
      // update local DB
      await DBHelper.insert(
        'family',
        {
          'userId': _userId!,
          'familyId': _familyId!,
        },
      );
    } else {
      print("No need to check familyId on remote DB!");
    }

    notifyListeners();
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
    _familyId = null;
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
    // TODO with UserCredential(additionalUserInfo: AdditionalUserInfo(isNewUser: true, ...
    try {
      // Google sign in
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      // User info
      GoogleSignInAccount? _user = googleUser;
      //_displayName = _user.displayName;

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

      _signInMethod = SignInMethod.Google;

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
      prefs.setString('signInMethod', EnumToString.convertToString(signInMethod));

      /* if user doens't belong to any family, generate new family and insert id */
      // search for familyId
      _familyId = await DBHelper.getFamilyIdFromUserId(_userId!);
      if (_familyId == null) {
        print("Need to check on remote DB");
        var querySnapshot = await firestore.collection('families').get();
        for (final document in querySnapshot.docs) {
          print("Searching in document: ${document.id}");
          try {
            // check if family collection has subuser with given id
            var sub = await firestore.collection('families').doc(document.id).collection(_userId!).get();
            if (sub.docs.length > 0) {
              print("user ${_userId} found family: ${document.id}");
              _familyId = document.id;
            }
          } catch (e, stacktrace) {
            print('Exception: ' + e.toString());
            print('Stacktrace: ' + stacktrace.toString());
          }
          //print(document.id);
        }

        // add if doens't exist
        if (_familyId == null) {
          print("First time logging in with google account");
          var familyReference = await firestore.collection('families').add({});
          _familyId = familyReference.id;
          print("Family id: $_familyId");

          await firestore.collection("families").doc(familyReference.id).collection(_userId!).doc('userInfo').set(
            {
              'displayName': _user.displayName,
            },
          );
        } else {
          print("Not the first time logging in with google account");
        }

        // family id registering on db
        await DBHelper.insert(
          'family',
          {
            'userId': _userId!,
            'familyId': _familyId!, // todo: change
          },
        );
      } else {
        print("No need to check on remote DB for familyid");
      }

      // display Name
      await DBHelper.insert(
        'users',
        {
          'userId': _userId!,
          'displayName': _user.displayName as String,
        },
      );

      notifyListeners();
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

  Future<void> facebookLogIn() async {
    final facebookLoginResult = await facebookAuth.login();

    final _user = await facebookAuth.getUserData();
    print("USER DATA: $_user");

    _token = facebookLoginResult.accessToken!.token;

    final facebookAuthCredential = FacebookAuthProvider.credential(_token!);
    final response = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    print("RESPONSE: $response");
    _userId = response.user!.uid;

    bool isNewUser = response.additionalUserInfo!.isNewUser;

    // default 1h expiration token
    _expiryDate = DateTime.now().add(
      const Duration(
        seconds: 3600,
      ),
    );

    _autoLogout(googleLogout);

    _signInMethod = SignInMethod.Facebook;

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate!.toIso8601String(),
    });
    prefs.setString('userData', userData);
    prefs.setString('signInMethod', EnumToString.convertToString(signInMethod));

    if (isNewUser) {
      // for sure we don't have data in DB, communicate with remote DB + store locally
      print("New facebook user!");
      var familyReference = await firestore.collection('families').add({});
      _familyId = familyReference.id;
      print("Family id: $_familyId");

      await firestore.collection("families").doc(_familyId).collection(_userId!).doc('userInfo').set(
        {
          'displayName': _user['name'],
        },
      );
    } else {
      print("Not the first time i see you around uh");

      // retrieving existing family Id
      _familyId = await DBHelper.getFamilyIdFromUserId(_userId!);
      if (_familyId == null) {
        print("Need to check on remote DB");
        var querySnapshot = await firestore.collection('families').get();
        for (final document in querySnapshot.docs) {
          try {
            // check if family collection has subuser with given id
            var sub = await firestore.collection('families').doc(document.id).collection(_userId!).get();
            if (sub.docs.length > 0) {
              print("user ${_userId} found family: ${document.id}");
              _familyId = document.id;
            }
          } catch (e, stacktrace) {
            print('Exception: ' + e.toString());
            print('Stacktrace: ' + stacktrace.toString());
          }
        }
      } else {
        print("No need to check on remote DB for familyid");
      }
    }

    // family id registering on db
    await DBHelper.insert(
      'family',
      {
        'userId': _userId!,
        'familyId': _familyId!, // todo: change
      },
    );

    // display Name
    await DBHelper.insert(
      'users',
      {
        'userId': _userId!,
        'displayName': _user['name'] as String,
      },
    );

    notifyListeners();
  }

  Future<void> facebookLogout() async {
    await FacebookAuth.instance.logOut();
    FirebaseAuth.instance.signOut();
    logout();
  }
}
