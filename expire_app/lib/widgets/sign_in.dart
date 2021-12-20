import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SignIn extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.login,
                color: Colors.white,
                size: 35,
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    color: Colors.white,
                    fontFamily: 'SanFrancisco',
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 280,
                  width: 423,
                  child: Image.asset(
                    "./assets/images/auth_login_img.png",
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: TextFormField(
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
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
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Processing Data')),
                                );
                              }
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                            children: <TextSpan>[
                              const TextSpan(text: 'Not a member? '),
                              TextSpan(
                                text: 'Sign up',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _pageController.animateToPage(1,
                                        duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
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
