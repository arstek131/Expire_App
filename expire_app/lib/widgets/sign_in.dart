import 'dart:io';

import 'package:expire_app/screens/main_app_screen.dart';
import 'package:expire_app/screens/name_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* firebase */
import '../helpers/firebase_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

/* styles */
import '../app_styles.dart' as styles;

class SignIn extends StatefulWidget {
  const SignIn({
    Key? key,
    required GlobalKey<FormState> formKey,
    required PageController pageController,
  })  : _formKey = formKey,
        _pageController = pageController,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final PageController _pageController;

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _isLoading = false;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(title: Text("An error occurred"), content: Text(message), actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Okay")),
      ]),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!widget._formKey.currentState!.validate()) {
      // Invalid!
      return;
    } // redundant??
    widget._formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      // Sign user up
      await FirebaseAuthHelper.instance.signInWithEmail(
        email: _authData['email']!,
        password: _authData['password']!,
      );
    } on FirebaseAuthException catch (error) {
      if (error.message != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message!,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Theme.of(context).errorColor,
          ),
        );
      }
    } catch (error) {
      print(error);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                "Sign In",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: styles.currentFontFamily,
                ),
              ),
              IconButton(
                onPressed: () =>
                    widget._pageController.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut),
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Image.asset(
                    "./assets/images/auth_login_img.png",
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0, bottom: 20.0),
                  child: Form(
                    key: widget._formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'e-mail',
                            ),
                            onSaved: (value) {
                              _authData['email'] = value!;
                            },
                            onFieldSubmitted: (value) {
                              _authData['email'] = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (!RegExp(
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                  .hasMatch(value)) {
                                return 'Please insert a valid e-mail';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.password, color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'password',
                            ),
                            onSaved: (value) {
                              _authData['password'] = value!;
                              print(_authData);
                            },
                            onFieldSubmitted: (value) {
                              _authData['password'] = value;
                              print(_authData);
                            },
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo.shade500),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (widget._formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                    'Logging in. Hold tight!',
                                    textAlign: TextAlign.center,
                                  )),
                                );
                                await _submit();
                              }
                            },
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    backgroundColor: styles.ghostWhite,
                                  )
                                : const Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 16, fontFamily: styles.currentFontFamily),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            // check on shared preferences if name is set
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? displayName = prefs.getString('localDisplayName');

                            String targetRoute = (displayName == null) ? NameInputScreen.routeName : MainAppScreen.routeName;
                            Navigator.of(context).pushReplacementNamed(targetRoute);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30.0),
                            child: const Text(
                              'CONTINUE WITHOUT REGISTRATION',
                              style: TextStyle(
                                fontFamily: styles.currentFontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Or sign in with:",
                              style: TextStyle(fontFamily: styles.currentFontFamily),
                            ),
                            if (Platform.isIOS)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF161618)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      barrierDismissible: false, // user must tap button!
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Not implemented!', textAlign: TextAlign.center),
                                          content: Text(
                                              'Apple login was not implemented because it required expensive apple developer account.',
                                              textAlign: TextAlign.center),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('I understand'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      FaIcon(
                                        FontAwesomeIcons.apple,
                                        size: 32,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Sign-in using Apple',
                                        style: TextStyle(fontSize: 16, fontFamily: styles.currentFontFamily),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFdb3236)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  FirebaseAuthHelper.instance.googleLogIn();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    FaIcon(
                                      FontAwesomeIcons.google,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Sign-in using Google',
                                      style: TextStyle(fontSize: 16, fontFamily: styles.currentFontFamily),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF3b5998)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  FirebaseAuthHelper.instance.facebookLogIn();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    FaIcon(
                                      FontAwesomeIcons.facebookSquare,
                                      size: 32,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Sign-in using Facebook',
                                      style: TextStyle(fontSize: 16, fontFamily: styles.currentFontFamily),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                            children: <TextSpan>[
                              const TextSpan(text: 'Not a member? ', style: TextStyle(fontFamily: styles.currentFontFamily)),
                              TextSpan(
                                text: 'Sign up',
                                style: const TextStyle(color: Colors.blue, fontFamily: styles.currentFontFamily),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    widget._pageController
                                        .animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
