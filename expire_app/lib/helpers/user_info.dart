/* dart */
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _email;
  FirebaseAuthHelper _auth = FirebaseAuthHelper();

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

  String? get email {
    return _email;
  }

  /* setters */
  set userId(userId) {
    _userId = userId;
  }

  set familyId(familyId) {
    _familyId = familyId;
  }

  set displayName(displayName) {
    if (_auth.isAuth) {
      FirebaseAuthHelper().setDisplayName(displayName);
    } else {
      SharedPreferences.getInstance().then((prefs) => prefs.setString('localDisplayName', displayName));
    }
    _displayName = displayName;
  }

  set email(email) {
    _email = email;
  }

  /* other */
  Future<void> initUserInfoProvider() async {
    // if registered user, fetch data
    if (_auth.isAuth) {
      _userId = FirebaseAuthHelper().userId;
      _displayName = FirebaseAuthHelper().displayName;
      _familyId = await FirestoreHelper().getFamilyIdFromUserId(userId: _userId!);
      _email = FirebaseAuthHelper().email;
    }
    // if unregistered, get data from shared preferences
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString("localUserId");
      _displayName = prefs.getString("localDisplayName");
      _familyId = prefs.getString("localFamilyId");
      _email = null;
    }
  }
}
