/* dart */
import 'package:expire_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/model/EcoscoreData.dart';
import 'package:openfoodfacts/model/NutrientLevels.dart';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';
import 'package:flutter_scandit/flutter_scandit.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as openfoodfacts;
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:enum_to_string/enum_to_string.dart';

/* provider */
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';

/* models */
import '../models/product.dart';
import '../models/categories.dart' as categories;

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

  final List<Map<String, Object>> _choicesList = categories.categories;
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
  List<String>? _allergens;
  String? _ecoscore;
  String? _packaging;
  Map<String, String>? _ingredientLevels;
  String? _isPalmOilFree;
  String? _isVegetarian;
  String? _isVegan;
  String? _brandName;
  String? _quantity;

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
          dateAdded: DateTime.now(),
          creatorId: '',
          creatorName: '',
          image: productInsertionMethod == ProductInsertionMethod.Manually ? _pickedImage : _imageUrl,
          nutriments: _nutriments,
          ingredientsText: _ingredientsText,
          nutriscore: _nutriscore,
          allergens: _allergens,
          ecoscore: _ecoscore,
          packaging: _packaging,
          ingredientLevels: _ingredientLevels,
          isPalmOilFree: _isPalmOilFree,
          isVegetarian: _isVegetarian,
          isVegan: _isVegan,
          brandName: _brandName,
          quantity: _quantity,
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

  Future<void> _takePicture(ImageSource imageSource) async {
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
      source: imageSource,
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

    scanResult = "8013355999662"; // LEAVE FOR TESTING
    scanResult = "3168930010265";
    scanResult = "689544001737";
    scanResult = "8000090003297";

    /*try {
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

     */

    print("fetching product...");

    setState(() {
      _isFetchingProduct = true;
    });

    await Future.delayed(Duration(seconds: 1)); // faking user interaction

    openfoodfacts.ProductQueryConfiguration configuration = openfoodfacts.ProductQueryConfiguration(scanResult,
        /*language: openfoodfacts.OpenFoodFactsLanguage.GERMAN,*/ fields: [openfoodfacts.ProductField.ALL]);
    openfoodfacts.ProductResult result = await openfoodfacts.OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
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

      // extracting nutriments levels
      final _ingredientLevelsTmp = result.product?.nutrientLevels?.levels;

      if (_ingredientLevelsTmp != null) {
        _ingredientLevels = {};
        for (final ingredient in _ingredientLevelsTmp.keys) {
          _ingredientLevels?.putIfAbsent(ingredient, () => EnumToString.convertToString(_ingredientLevelsTmp[ingredient]));
        }
      }

      if(result.product?.ingredientsAnalysisTags != null)
      {
        // extraction of ingredients analysis (vegan, vegetaria, palm oil free...)
        _isPalmOilFree = EnumToString.convertToString(result.product?.ingredientsAnalysisTags?.palmOilFreeStatus);
        _isVegan = EnumToString.convertToString(result.product?.ingredientsAnalysisTags?.veganStatus);
        _isVegetarian = EnumToString.convertToString(result.product?.ingredientsAnalysisTags?.vegetarianStatus);
      }
      // extracting ecological data
      _ecoscore = result.product?.ecoscoreGrade;
      _packaging = result.product?.packaging;

      // extract brand name(s)
      _brandName = result.product?.brands;

      // extract quantity
      _quantity = result.product?.quantity;

      // extract ingredients (default english)
      _ingredientsText = result.product?.ingredientsTextInLanguages?[openfoodfacts.OpenFoodFactsLanguage.ENGLISH];
      if (_ingredientsText == null) {
        _ingredientsText = result.product?.ingredientsText;
      }

      // extract nutriscore
      _nutriscore = result.product?.nutriscore;

      // extract product image
      final images = result.product?.images;
      String? imageUrl;
      if (images != null && images.isNotEmpty) {
        imageUrl = images.firstWhere((element) => element.size == openfoodfacts.ImageSize.DISPLAY).url ??
            result.product?.images?.firstWhere((element) => element.size == openfoodfacts.ImageSize.SMALL).url;
      }

      // extracting allergies or intolerances
      _allergens = result.product?.allergens?.names;

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
      height: MediaQuery.of(context).size.height * 0.9,
      child: Stack(
        children: [
          Container(
            color: styles.secondaryColor.withOpacity(0.95),
            child: Column(
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
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Product informations",
                            style: styles.heading,
                            textAlign: TextAlign.center,
                          ),
                           const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              ImageSource? imageSource = await showModalBottomSheet<ImageSource>(
                                isScrollControlled: true,
                                enableDrag: true,
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                builder: (BuildContext ctx) {
                                  return Row(
                                    children: [
                                      
                                        Expanded(
                                          child: GestureDetector(
                                        onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                                        child: Container(
                                          color: Colors.blue.shade300,
                                          child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                FaIcon(FontAwesomeIcons.images, size: 32, color: styles.ghostWhite,),
                                                SizedBox(height: 2),
                                                Text("Pick an image", style: TextStyle(fontFamily: styles.currentFontFamily, color: styles.ghostWhite, fontSize: 16,),)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ),
                                      
                                        Expanded(
                                          child: GestureDetector(
                                        onTap: () => Navigator.of(context).pop(ImageSource.camera),
                                          child: Container(
                                            color: Colors.pink.shade600,
                                            child: Container(
                                               margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.camera, size: 35, color: styles.ghostWhite,)
                                                  SizedBox(height: 2),
                                                  Text("Take a picture", style: TextStyle(fontFamily: styles.currentFontFamily, color: styles.ghostWhite, fontSize: 16,),)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      
                                    ],
                                  );
                                },
                              );
                              if (imageSource == null) {
                                return;
                              }

                              _takePicture(imageSource);
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: styles.ghostWhite.withOpacity(0.9),
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
                          TextFormField(
                            controller: _productNameController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: styles.ghostWhite, 
                                fontFamily: styles.currentFontFamily, 
                                fontWeight: FontWeight.bold,
                                ),
                            decoration: InputDecoration( 
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: styles.ghostWhite,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 2.0,
                                ), 
                              ),
                              hintText: 'Product name',
                              hintStyle: styles.subheading
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
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  icon: FaIcon(
                                    FontAwesomeIcons.calendarAlt,
                                    size: 23,
                                    color: styles.ghostWhite.withOpacity(0.9)
                                  ),
                                  label: Text(DateFormat('dd MMMM yyyy').format(_pickedDate),
                                      style: styles.subheading,
                                      ),
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<EdgeInsets>(
                                      EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(color: styles.ghostWhite),
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
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  styles.deepOrange,
                                ),
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
                                  ? CircularProgressIndicator.adaptive(
                                      strokeWidth: 2,
                                      backgroundColor: styles.ghostWhite,
                                    )
                                  : const Text(
                                      'Submit',
                                      style: styles.subheading,
                                    ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(color: styles.ghostWhite.withOpacity(0.8)),
                          const Text(
                            "Category",
                            style: styles.heading,
                            textAlign: TextAlign.center,
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
                                  selectedColor: styles.deepGreen,
                                  backgroundColor: Colors.indigo[100],
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  labelStyle: _chosenIndexes.contains(i) 
                                    ? styles.subheading 
                                    : TextStyle(fontFamily: styles.currentFontFamily, 
                                                color: Colors.black,
                                                fontSize: 15,
                                      ),
                                  avatar: _chosenIndexes.contains(i) ? _choicesList[i]['icon'] as FaIcon : null,
                                  label: Text(
                                    _choicesList[i]['title'] as String,
                                  ),
                                  selected: _chosenIndexes.contains(i),
                                  onSelected: (bool selected) => _chipSelectionHandler(i, selected),
                                ),
                              ),
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                          Divider(color: styles.ghostWhite.withOpacity(0.8)),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "Additional info",
                            style: styles.heading,
                            textAlign: TextAlign.center,
                          ),
                          
                          // dummy element for default padding, do not delete
                          const SizedBox(
                            height: 150,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Scan barcode  ",
                  style: styles.subheading,
                ),
                Container(
                  height: 50,
                  width: 100,
                  decoration: ShapeDecoration(
                    color: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ), //CircleBorder(),
                  ),
                  child: IconButton(
                    //padding: EdgeInsets.symmetric(horizontal: 20),
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
                  CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    backgroundColor: styles.ghostWhite,
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
