/* dart */
import 'package:expire_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';
import 'package:flutter_scandit/flutter_scandit.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as openfoodfacts;
import 'package:flutter_vibrate/flutter_vibrate.dart';

/* provider */
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';

/* models */
import '../models/product.dart';

/* enums */
import '../enums/product_insertion_method.dart';

/* firebase */
import 'package:expire_app/helpers/firestore_helper.dart';

/* constants */
import '../constants.dart';

/* styles */
import '../app_styles.dart' as styles;

class AddItemModal extends StatefulWidget {
  final BuildContext modalContext;

  AddItemModal({required this.modalContext});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();

  bool _isLoading = false;
  bool _isFetchingProduct = false;

  final List<Map<String, Object>> _choicesList = [
    {"title": "MEAT", "icon": const FaIcon(FontAwesomeIcons.drumstickBite)},
    {"title": "FISH", "icon": const FaIcon(FontAwesomeIcons.fish)},
    {"title": "VEGETARIAN", "icon": const FaIcon(FontAwesomeIcons.leaf)},
    {"title": "FRUIT", "icon": const FaIcon(FontAwesomeIcons.appleAlt)}
  ];
  List<int> _chosenIndexes = [];

  Map<String, Object?> _productData = {
    'title': null,
    'expiration': null,
  };

  DateTime _pickedDate = DateTime.now();
  File? _pickedImage;
  String? barcodeString;
  String? _imageUrl;
  ProductInsertionMethod productInsertionMethod = ProductInsertionMethod.None;

  Nutriments _nutriments = new Nutriments();
  String? _ingredientsText;
  String? _nutriscore;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _productNameController.dispose();
    //_cameraController!.dispose();
  }

  void _chipSelectionHandler(int index, selected) {
    if (!selected) {
      setState(() {
        _chosenIndexes.remove(index);
      });
    } else {
      setState(() {
        _chosenIndexes.add(index);
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(title: Text("An error occurred"), content: Text(message), actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Okay")),
      ]),
    );
  }

  Future<void> _submit() async {
    // save remote or local image to storage + localDB + firestore
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ProductsProvider>(context, listen: false).addProduct(
        Product(
          id: null,
          title: _productData['title'] as String,
          expiration: _pickedDate, //_productData['expiration'] as DateTime,
          creatorId: '',
          creatorName: '',
          image: productInsertionMethod == ProductInsertionMethod.Manually ? _pickedImage : _imageUrl,
          nutriments: _nutriments,
          ingredientsText: _ingredientsText,
          nutriscore: _nutriscore,
        ),
      );
    } catch (error, stacktrace) {
      const errorMessage = 'Chould not upload product. Please try again later';

      _showErrorDialog(errorMessage);

      print(error);
      print('Exception: ' + error.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }

    /* add product locally */
    // local storage
    /*final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(_pickedImage!.path);
    final savedImage = await _pickedImage!.copy('${appDir.path}/$fileName');*/

    // local DB (image path)

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _pickedDate) {
      setState(() {
        _pickedDate = picked;
      });
    }
    print(_pickedDate.toLocal());
  }

  Future<void> _takePicture() async {
    // todo: dropdown to choose to take picture or upload

    // todo bug on oneplus 6T, not working
    /*try {
      if (!_cameraController!.value.isInitialized) {
        throw Exception("prova");
      }
      CameraPreview(_cameraController!);
      _cameraController!.takePicture();
    } catch (error) {
      print(error);
      rethrow;
    }*/

    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 480,
      maxWidth: 640,
      preferredCameraDevice: CameraDevice.front,
    );

    if (imageFile == null) {
      return;
    }

    final convertedImage = File(imageFile.path);

    setState(() {
      _pickedImage = convertedImage;
      _imageUrl = null;
      productInsertionMethod = ProductInsertionMethod.Manually;
    });
  }

  //TODO: push and get nutritionscore and ingredientText to server + use consumer on health

  Future<void> _scanBarcode() async {
    // todo: set meat, fish, vegetarian etc... automatically

    String? scanResult;

    //scanResult = "8013355998702"; // LEAVE FOR TESTING

    try {
      BarcodeResult result = await FlutterScandit(symbologies: [
        Symbology.EAN13_UPCA,
        Symbology.EAN8,
        Symbology.QR,
        Symbology.UPCE,
        Symbology.UPCE,
      ], licenseKey: SCANDIT_API_KEY)
          .scanBarcode();

      if (result.data == null) {
        return;
      }

      Vibrate.feedback(FeedbackType.success);

      scanResult = result.data;
      print(scanResult);
    } on BarcodeScanException catch (error) {
      print(error);
      rethrow;
    }

    print("fetching product...");

    setState(() {
      _isFetchingProduct = true;
    });

    await Future.delayed(Duration(seconds: 1)); // faking user interaction

    openfoodfacts.ProductQueryConfiguration configuration = openfoodfacts.ProductQueryConfiguration(scanResult,
        /*language: openfoodfacts.OpenFoodFactsLanguage.GERMAN,*/ fields: [openfoodfacts.ProductField.ALL]);
    openfoodfacts.ProductResult result = await openfoodfacts.OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      /*print(result.product?.productName); // name of product
      print(result.product?.nutriments); // get list of nutriments, null if not there
      print(result.product?.ingredients); // list of ingredient objects
      print(result.product?.ingredientsTags); // list of ingredient tags
      print(result.product?.ingredientsText); // Stringa degli ingredienti
      print(result.product?.ingredientsAnalysisTags?.veganStatus); // check if vegan or something
      print(result.product?.images?[2].url);*/

      // extracting product name
      _productNameController.text = result.product?.productName ?? '';

      // extract nutriments
      final resultNutriments = result.product?.nutriments;
      _nutriments.energyKcal = resultNutriments?.energyKcal;
      _nutriments.fat = resultNutriments?.fat;
      _nutriments.saturatedFat = resultNutriments?.saturatedFat;
      _nutriments.carbohydrates = resultNutriments?.carbohydrates;
      _nutriments.sugars = resultNutriments?.sugars;
      _nutriments.fiber = resultNutriments?.fiber;
      _nutriments.proteins = resultNutriments?.proteins;
      _nutriments.salt = resultNutriments?.salt;

      // extract ingredients
      _ingredientsText = result.product?.ingredientsText;

      // extract nutriscore
      _nutriscore = result.product?.nutriscore;

      // extract product image
      final images = result.product?.images;
      String? imageUrl;
      if (images != null && images.isNotEmpty) {
        imageUrl = images.firstWhere((element) => element.size == openfoodfacts.ImageSize.DISPLAY).url ??
            result.product?.images?.firstWhere((element) => element.size == openfoodfacts.ImageSize.SMALL).url;
      }

      setState(() {
        _pickedImage = null;
        _imageUrl = imageUrl;
        productInsertionMethod = ProductInsertionMethod.Scanner;
      });
    } else {
      Vibrate.feedback(FeedbackType.error);

      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(ctx).pop(true);
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            alignment: Alignment.center,
            title: const Text(
              "Not found",
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "No product was found with scanned barcode. Try to scan it again or insert it manually.",
              textAlign: TextAlign.center,
            ),
            titleTextStyle: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            contentTextStyle: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontSize: 16,
            ),
            backgroundColor: styles.primaryColor,
          );
        },
      );
    }

    setState(() {
      _isFetchingProduct = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //alignment: Alignment.bottomCenter,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5, bottom: 10),
                height: 5,
                width: MediaQuery.of(widget.modalContext).size.width * 0.4,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.black54, blurRadius: 15.0, offset: Offset(0.0, 0.75)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const Text(
                          "Category:",
                          style: TextStyle(
                            fontFamily: styles.sanFrancisco,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _choicesList.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: ChoiceChip(
                                elevation: 2,
                                selectedColor: Colors.amber,
                                backgroundColor: Colors.indigo[100],
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                ),
                                avatar: _choicesList[i]['icon'] as FaIcon,
                                label: Text(
                                  _choicesList[i]['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: styles.currentFontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: _chosenIndexes.contains(i),
                                onSelected: (bool selected) => _chipSelectionHandler(i, selected),
                              ),
                            ),
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                        const Text(
                          "Product:",
                          style: TextStyle(
                            fontFamily: styles.sanFrancisco,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _productNameController,
                          style: const TextStyle(
                              color: Colors.indigo, fontFamily: styles.currentFontFamily, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            hintText: 'Product name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _productData['title'] = value!;
                          },
                          onFieldSubmitted: (value) {
                            _productData['title'] = value;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: styles.ghostWhite.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(
                                width: 1,
                                color: Colors.black54,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13.0),
                              child: Center(
                                child: productInsertionMethod == ProductInsertionMethod.None
                                    ? const Text(
                                        "Click to add image",
                                        textAlign: TextAlign.center,
                                      )
                                    : productInsertionMethod == ProductInsertionMethod.Scanner
                                        ? _imageUrl == null
                                            ? Image.asset(
                                                "assets/images/missing_image_placeholder.png",
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                _imageUrl!,
                                                fit: BoxFit.cover,
                                              )
                                        : _pickedImage == null
                                            ? Image.asset(
                                                "assets/images/missing_image_placeholder.png",
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                _pickedImage!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                icon: FaIcon(
                                  FontAwesomeIcons.calendarAlt,
                                  size: 23,
                                ),
                                label: Text(DateFormat('dd MMMM yyyy').format(_pickedDate),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: styles.currentFontFamily,
                                    )),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
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
                            onPressed: () async {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                await _submit();
                                Navigator.of(widget.modalContext).pop();
                              }
                            },
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : const Text(
                                    'Submit',
                                    style: styles.subheading,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Scan barcode  ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: styles.sanFrancisco,
                  ),
                ),
                Ink(
                  decoration: ShapeDecoration(
                    color: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ), //CircleBorder(),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    icon: const FaIcon(
                      FontAwesomeIcons.barcode,
                      size: 27,
                    ),
                    color: Colors.white,
                    onPressed: _scanBarcode,
                  ),
                ),
              ],
            ),
          ),
          if (_isFetchingProduct)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: styles.ghostWhite,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Fetching product...",
                    style: styles.subtitle,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
