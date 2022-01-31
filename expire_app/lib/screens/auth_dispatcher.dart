/* dart libraries */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/* firebase */
import '../helpers/firebase_auth_helper.dart';
import '../screens/auth_screen.dart';
/* Screens */
import '../screens/main_app_screen.dart';
import '../screens/name_input_screen.dart';

class AuthDispatcher extends StatefulWidget {
  AuthDispatcher({Key? key}) : super(key: key);
  static const routeName = "/tmp";

  @override
  State<AuthDispatcher> createState() => _AuthDispatcherState();
}

class _AuthDispatcherState extends State<AuthDispatcher> {
  FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        return userSnapshot.hasData
            ? // token found
            firebaseAuthHelper.isDisplayNameSet
                ? MainAppScreen()
                : NameInputScreen()
            : AuthScreen();
      },
    );
  }
}
