/* dart */
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_scandit/flutter_scandit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:googleapis/versionhistory/v1.dart';
import 'dart:io' as pltf show Platform;

/* helpers */
import '../helpers/firestore_helper.dart';

/* styles */
import '../app_styles.dart' as styles;

/* const */
import '../constants.dart';

class DisplayNameChoiceModal extends StatefulWidget {
  const DisplayNameChoiceModal();

  @override
  _DisplayNameChoiceModalState createState() => _DisplayNameChoiceModalState();
}

class _DisplayNameChoiceModalState extends State<DisplayNameChoiceModal> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? displayName;

  var _controller = TextEditingController();

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    Future.delayed(Duration(seconds: 2)).then(
      (_) => Navigator.of(context).pop(displayName!.trim().isNotEmpty ? displayName : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (displayName == null || displayName!.trim().isEmpty) {
          Navigator.of(context).pop(null);
        } else {
          Navigator.of(context).pop(displayName);
        }

        return false;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutCirc,
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 30,
          bottom: 30 + MediaQuery.of(context).viewInsets.bottom,
        ),
        color: styles.primaryColor,
        //height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Indicate your new display name below",
                style: styles.subtitle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Card(
              elevation: 5,
              color: styles.ghostWhite,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _controller,
                        autofocus: true,
                        decoration: InputDecoration(
                          suffixIcon: displayName != null && displayName!.trim().isNotEmpty
                              ? Container(
                                  margin: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: Colors.green,
                                  ),
                                )
                              : null,
                          hintText: 'Display name',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: const FaIcon(
                              FontAwesomeIcons.signature,
                              size: 28,
                            ),
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
                              color: Colors.grey,
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter some text';
                          }

                          return null;
                        },
                        /*onSaved: (value) {
                          displayName = value!.trim();
                        },*/
                        onFieldSubmitted: (value) {
                          displayName = value.trim();

                          if (_formKey.currentState!.validate()) {
                            _submit();
                          }
                        },
                      ),
                    ),
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
