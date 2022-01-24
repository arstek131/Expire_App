/* dart */
import 'dart:io';
import 'package:expire_app/screens/products_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'dart:math';

/* providers */
import 'package:provider/provider.dart';
import '../helpers/user_info.dart';

/* firebase */
import '../helpers/firebase_auth_helper.dart';

/* screens */
import '../screens/main_app_screen.dart';

/* other */
import '../app_styles.dart' as styles;

class NameInputScreen extends StatefulWidget {
  static const routeName = '/name-input-screen';

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> with TickerProviderStateMixin {
  FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper.instance;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, String> _userData = {
    "name": "",
    "surname": "",
  };

  var screenHeight = window.physicalSize.height / window.devicePixelRatio;
  var screenWidth = window.physicalSize.width / window.devicePixelRatio;
  bool _isLoading = false;

  AnimationController? _controller;
  AnimationController? _controller2;
  Animation<double>? _opacityAnimation;
  Animation<double>? _sizeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _controller2 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller2!,
      curve: Curves.fastLinearToSlowEaseIn,
    );

    Future.delayed(const Duration(seconds: 1)).then(
      (_) => setState(
        () {
          _controller!.forward();
          Future.delayed(Duration(seconds: 1), () {
            _controller2!.forward();
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller2!.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    final String displayName = _userData['name']! + " " + _userData['surname']!;

    await firebaseAuthHelper.setDisplayName(displayName);

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushNamed(MainAppScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "./assets/images/name_input_animated.gif",
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  "All set up!\nHow do we have to call you?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "SanFrancisco",
                    color: styles.ghostWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizeTransition(
                  sizeFactor: _sizeAnimation!,
                  axis: Axis.vertical,
                  child: Card(
                    clipBehavior: Clip.none,
                    elevation: 10,
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    color: styles.ghostWhite,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: FadeTransition(
                        opacity: _opacityAnimation!,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.text_format_outlined,
                                    size: 30,
                                    color: Colors.indigo,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  hintText: 'Name',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _userData['name'] = value!;
                                },
                                onFieldSubmitted: (value) {
                                  _userData['name'] = value;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.name,
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.text_fields, size: 30, color: Colors.indigo),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  hintText: 'Surname',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _userData['surname'] = value!;
                                },
                                onFieldSubmitted: (value) {
                                  _userData['surname'] = value;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: screenWidth * 0.4,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 10.0,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submit();
                      }
                    },
                    child: _isLoading
                        ? const FittedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: styles.ghostWhite,
                            ),
                          )
                        : const Text(
                            "NEXT",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'SanFrancisco',
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
