import 'package:flutter/material.dart';

/* widgets */
import '../widgets/sign_in.dart';
import '../widgets/sign_up.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKeySignIn = GlobalKey<FormState>();
  final _formKeySignUp = GlobalKey<FormState>();
  final pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigo,
                Colors.indigoAccent,
              ],
              stops: [0, 1],
            ),
          ),
          child: SafeArea(
            child: PageView(
              controller: pageController,
              children: [
                SignIn(formKey: _formKeySignIn, pageController: pageController),
                SignUp(formKey: _formKeySignUp, pageController: pageController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
