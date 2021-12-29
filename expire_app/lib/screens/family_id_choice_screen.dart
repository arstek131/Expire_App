/* dart */
import 'package:flutter/material.dart';
import 'dart:ui';

/* helpers */
import '../helpers/firestore_helper.dart';

class FamilyIdChoiceScreen extends StatefulWidget {
  static const routeName = "/family-id-choice";
  @override
  _FamilyIdChoiceScreenState createState() => _FamilyIdChoiceScreenState();
}

class _FamilyIdChoiceScreenState extends State<FamilyIdChoiceScreen> {
  var screenHeight = window.physicalSize.height / window.devicePixelRatio;
  var screenWidth = window.physicalSize.width / window.devicePixelRatio;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? referenceId;

  bool _firstCheck = true;
  bool _isLoading = false;
  bool _isValid = false;

  List<String> listOfUsersName = [];

  Future<void> _submit() async {
    listOfUsersName = [];
    var userIDs = [];
    setState(() {
      _isLoading = true;
    });
    try {
      userIDs = await FirestoreHelper.instance.getUsersFromFamilyId(familyId: referenceId!);
      for (final userId in userIDs) {
        final usersDisplayName = await FirestoreHelper.instance.getDisplayNameFromUserId(userId: userId, familyId: referenceId!);
        if (usersDisplayName != null) {
          setState(() {
            listOfUsersName.add(usersDisplayName);
          });
        }
      }
      print(listOfUsersName);
    } catch (e, stacktrace) {
      setState(() {
        _isValid = false;
      });

      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    if (userIDs.isNotEmpty) {
      setState(() {
        _isValid = true;
      });
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isValid && referenceId != null) {
          Navigator.of(context).pop(referenceId);
        } else {
          Navigator.of(context).pop(null);
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: Colors.indigo,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Indicate your family ID below",
                style: TextStyle(fontSize: 20, fontFamily: "SanFrancisco", color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SelectableText(
              // todo: remove
              "4PIrcoc7lWvymtw5Mq6v",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 20,
            ),
            Card(
              elevation: 10,
              margin: const EdgeInsets.only(left: 20.0, right: 20.0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Stack(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Family ID',
                                  prefixIcon: const Icon(
                                    Icons.family_restroom,
                                    size: 28,
                                  ),
                                  errorMaxLines: 2,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: _firstCheck || _isLoading
                                          ? Colors.grey
                                          : _isValid
                                              ? Colors.green
                                              : Colors.red,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                autocorrect: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  referenceId = value!;
                                },
                                onFieldSubmitted: (value) {
                                  referenceId = value;
                                  setState(() {
                                    _firstCheck = false;
                                  });

                                  if (_formKey.currentState!.validate()) {
                                    _submit();
                                  }
                                },
                              ),
                              if (!_firstCheck)
                                _isLoading
                                    ? const Positioned(
                                        top: 20,
                                        right: 20,
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      )
                                    : _isValid
                                        ? const Positioned(
                                            top: 18,
                                            right: 20,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Center(
                                                child: Icon(
                                                  Icons.check_circle_outline_outlined,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const Positioned(
                                            top: 18,
                                            right: 20,
                                            child: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Center(
                                                child: Icon(
                                                  Icons.cancel_outlined,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!_firstCheck)
                      _isValid
                          ? Column(
                              children: [
                                const Text(
                                  "Family found",
                                  style: TextStyle(color: Colors.green),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ...listOfUsersName.map((userName) => Text(userName)).toList()
                              ],
                            )
                          : const Text(
                              "No family found with gived ID",
                              style: TextStyle(color: Colors.red),
                            )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
