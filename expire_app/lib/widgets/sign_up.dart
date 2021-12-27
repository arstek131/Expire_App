/* dart */
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

/* providers */
import '../providers/auth_provider.dart';

/* models */
import '../models/http_exception.dart';

/* screens */
import '../screens/family_id_choice_screen.dart';

class SignUp extends StatefulWidget {
  SignUp({
    Key? key,
    required GlobalKey<FormState> formKey,
    required PageController pageController,
  })  : _formKey = formKey,
        _pageController = pageController,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final PageController _pageController;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFamilyIdSet = false;

  Map<String, String?> _authData = {
    'email': '',
    'password': '',
    'familyId': null,
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

      await Provider.of<AuthProvider>(context, listen: false).signUp(
        email: _authData['email']!,
        password: _authData['password']!,
        familyId: _authData['familyId'],
      );
    } on HttpException catch (error) {
      print(error);
      var errorMessage = 'Authentication failed';

      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email addresss';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }

      _showErrorDialog(errorMessage);
    } catch (e, stacktrace) {
      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());

      const errorMessage = 'Chould not authenticate you. Please try again later';

      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () =>
                    widget._pageController.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.white,
                    fontFamily: 'SanFrancisco',
                  ),
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
                topLeft: Radius.circular(0),
                topRight: Radius.circular(45),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  /*padding: EdgeInsets.all(10),
                  height: 280,
                  width: 423,*/
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(
                      "./assets/images/auth_signup_img.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Form(
                    key: widget._formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'e-mail',
                            ),
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
                            onSaved: (value) {
                              _authData['email'] = value!;
                            },
                            onFieldSubmitted: (value) {
                              _authData['email'] = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.password, color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'password',
                            ),
                            controller: _passwordController,
                            onSaved: (value) {
                              _authData['password'] = value!;
                            },
                            onFieldSubmitted: (value) {
                              _authData['password'] = value;
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.check, color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              hintText: 'confirm password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            var familyId = await Navigator.of(context).pushNamed(FamilyIdChoiceScreen.routeName);
                            if (familyId != null) {
                              _authData['familyId'] = familyId as String?;
                              setState(() {
                                _isFamilyIdSet = true;
                              });
                            } else {
                              setState(() {
                                _isFamilyIdSet = false;
                              });
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _isFamilyIdSet ? "Valid family ID " : "I have a family ID ",
                                  style: TextStyle(color: _isFamilyIdSet ? Colors.green : Colors.blue),
                                ),
                                WidgetSpan(
                                  child: _isFamilyIdSet
                                      ? const Icon(
                                          Icons.check_circle_outline_outlined,
                                          color: Colors.green,
                                          size: 16,
                                        )
                                      : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                            ),
                            onPressed: () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (widget._formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                    'Signing up, hold tight!',
                                    textAlign: TextAlign.center,
                                  )),
                                );
                                _submit();
                              }
                            },
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : const Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey, fontSize: 12.0),
                            children: <TextSpan>[
                              TextSpan(text: 'By clicking Sign Up, you agree to our '),
                              TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print('Terms of Service"');
                                    }),
                              TextSpan(text: ' and that you have read our '),
                              TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: Colors.blue),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print('Privacy Policy"');
                                    }),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey, fontSize: 12.0),
                            children: <TextSpan>[
                              TextSpan(text: 'Already a member? '),
                              TextSpan(
                                text: 'Sign in',
                                style: TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    widget._pageController
                                        .animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                                  },
                              ),
                            ],
                          ),
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
