/* dart */
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_scandit/flutter_scandit.dart';
import 'package:googleapis/versionhistory/v1.dart';
import 'dart:io' as pltf show Platform;

/* helpers */
import '../helpers/firestore_helper.dart';

/* styles */
import '../app_styles.dart' as styles;

/* const */
import '../constants.dart';

class FamilyIdChoiceModal extends StatefulWidget {
  @override
  _FamilyIdChoiceModalState createState() => _FamilyIdChoiceModalState();
}

class _FamilyIdChoiceModalState extends State<FamilyIdChoiceModal> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? referenceId;

  bool _firstCheck = true;
  bool _isLoading = false;
  bool _isValid = false;

  var _controller = TextEditingController();

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    try {
      bool familyExists = await FirestoreHelper.instance.familyExists(familyId: referenceId!);
      setState(() {
        _isValid = familyExists;
      });
    } catch (e, stacktrace) {
      setState(() {
        _isValid = false;
      });

      print('Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
      rethrow;
    }
    setState(() {
      _isLoading = false;
    });

    if (_isValid) {
      Future.delayed(Duration(seconds: 2)).then((_) => Navigator.of(context).pop(referenceId));
    }
  }

  Future<void> _scanFamilyQrCode() async {
    String? scanResult;
    FocusScope.of(context).unfocus();

    /*try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF3F51B5',
        'Cancel',
        true,
        ScanMode.QR,
      );
      print(scanResult);
    } on BarcodeException {
      rethrow;
    }*/

    try {
      BarcodeResult result = await FlutterScandit(symbologies: [
        Symbology.EAN13_UPCA,
        Symbology.EAN8,
        Symbology.QR,
        Symbology.UPCE,
        Symbology.UPCE,
      ], licenseKey: pltf.Platform.isAndroid ? SCANDIT_API_KEY_ANDROID : SCANDIT_API_KEY_IOS)
          .scanBarcode();

      scanResult = result.data;
    } on BarcodeScanException catch (error) {
      print(error);
      rethrow;
    } on BarcodeException catch (error) {
      print(error);
      rethrow;
    } catch (error) {
      print(error);
      rethrow;
    }

    if (!mounted || scanResult == null) {
      return;
    }

    _controller.text = scanResult;

    referenceId = scanResult;

    setState(() {
      _firstCheck = false;
    });

    if (_formKey.currentState!.validate()) {
      _submit();
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
                "Indicate your family ID below",
                style: styles.subtitle,
                textAlign: TextAlign.center,
              ),
            ),
            const SelectableText(
              // todo: remove
              "6Ar2c5ATtIVtwPGHyPqI",
              style: TextStyle(color: Colors.white),
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
                      child: Column(
                        children: [
                          Stack(
                            children: <Widget>[
                              TextFormField(
                                controller: _controller,
                                autofocus: true,
                                decoration: InputDecoration(
                                  suffixIcon: !_isLoading
                                      ? Container(
                                          margin: EdgeInsets.only(right: _firstCheck ? 4 : 40),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.qr_code_scanner,
                                              size: 25,
                                            ),
                                            color: Colors.black,
                                            onPressed: () async {
                                              await _scanFamilyQrCode();
                                            },
                                          ),
                                        )
                                      : null,
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
                              /*if (_firstCheck)
                                Positioned(
                                  top: 10,
                                  right: 25,
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(Icons.qr_code_scanner),
                                        color: Colors.black,
                                        onPressed: () {
                                          print("scanner");
                                        },
                                      ),
                                    ),
                                  ),
                                ),*/
                              if (!_firstCheck)
                                _isLoading
                                    ? const Positioned(
                                        top: 20,
                                        right: 20,
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              backgroundColor: styles.ghostWhite,
                                            ),
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
                    if (!_firstCheck)
                      const SizedBox(
                        height: 10,
                      ),
                    if (!_firstCheck)
                      _isValid
                          ? const Text(
                              "Valid family ID",
                              style: TextStyle(color: Colors.green),
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
