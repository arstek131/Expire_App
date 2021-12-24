/* dart */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'dart:math';

/* providers */
import 'package:provider/provider.dart';
import '../providers/user_info_provider.dart';

class NameInputScreen extends StatefulWidget {
  static const routeName = '/name-input-screen';

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> with TickerProviderStateMixin {
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

    await Provider.of<UserInfoProvider>(context, listen: false).setDisplayName(displayName);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text(
          "How do we have to call you?",
          style: TextStyle(fontSize: 22, fontFamily: "SanFrancisco", color: Colors.white),
        ),
        const SizedBox(
          height: 30,
        ),
        SizeTransition(
          sizeFactor: _sizeAnimation!,
          axis: Axis.vertical,
          child: Card(
            elevation: 10,
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(45),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
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
                          prefixIcon: Icon(Icons.text_format_outlined, size: 30, color: Colors.indigoAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          hintText: 'Name',
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
                          prefixIcon: Icon(Icons.text_fields, size: 30, color: Colors.indigoAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          hintText: 'Surname',
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
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 8.0,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _submit();
                            }
                          },
                          child: _isLoading
                              ? CircularProgressIndicator()
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
          ),
        ),
      ]),
    );
  }
}
