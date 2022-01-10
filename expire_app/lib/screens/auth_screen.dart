/* flutter */
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* widgets */
import '../widgets/sign_in.dart';
import '../widgets/sign_up.dart';

/* pages */
import '../screens/onboarding_page.dart';

/* helpers */
import '../models/onboard_data.dart';

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
  void initState() {
    super.initState();
    checkIfFirstLaunch();
  }

  Future<void> checkIfFirstLaunch() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool seenOnboard = pref.getBool('seenOnboard') ?? false;

    if (!seenOnboard) {
      await Navigator.of(context).pushNamed(OnBoardingPage.routeName);
      pref.setBool('seenOnboard', true);
    }
  }

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
