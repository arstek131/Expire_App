/* dart */
import 'dart:ui';

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
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io' as pltf show Platform;

// google apis
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart';

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


class CredentialsProvider {
  CredentialsProvider();

  Future<ServiceAccountCredentials> get _credentials async {
    String _file = await rootBundle.loadString('assets/auth/credentials.json');
    return ServiceAccountCredentials.fromJson(_file);
  }

  Future<AutoRefreshingAuthClient> get client async {
    AutoRefreshingAuthClient _client = await clientViaServiceAccount(
        await _credentials, [vision.VisionApi.cloudVisionScope]);
    return _client;
  }
}

class RekognizeProvider {
  var _client = CredentialsProvider().client;

  Future<String?> extractTextAnnotation(String image) async {
    var _vision = vision.VisionApi(await _client);
    var _api = _vision.images;
    var _response = await _api.annotate(vision.BatchAnnotateImagesRequest.fromJson({
      "requests": [
        {
          "image": {
            "content": image
          },
          "features": [
            {"type": "TEXT_DETECTION"}
          ]
        }
      ]
    }));

    return _response.responses?.first.fullTextAnnotation?.text;
  }
}

class AddItemModal extends StatefulWidget {
  final BuildContext modalContext;

  AddItemModal({required this.modalContext});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _kcalsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _saturatedFatController = TextEditingController();
  final TextEditingController _carboController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fibersController = TextEditingController();
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();
  final TextEditingController _ingredientsTextController = TextEditingController();
  final TextEditingController _alergiesTextController = TextEditingController();
  final TextEditingController _packagingTextController = TextEditingController();

  final PageController _nutriscorePageViewController = PageController(initialPage: 1, viewportFraction: 0.9);
  final PageController _ecoscorePageViewController = PageController(initialPage: 1, viewportFraction: 0.9);


  bool _isLoading = false;
  bool _isFetchingProduct = false;
    bool _isExtractingText = false;

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
  int _nutriScoreIndex = 1;
  final nutriscoreValues = ['N/A', 'A', 'B', 'C', 'D'];
  List<String>? _allergens;
  String? _ecoscore;
  int _ecoScoreIndex = 1;
  final ecoscoreValues = ['N/A', 'A', 'B', 'C', 'D'];
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
    _kcalsController.dispose();
    _fatController.dispose();
    _saturatedFatController.dispose();
    _carboController.dispose();
    _sugarController.dispose();
    _fibersController.dispose();
    _proteinsController.dispose();
    _saltController.dispose();
    _ingredientsTextController.dispose();
    _alergiesTextController.dispose();
    _packagingTextController.dispose();

    _nutriscorePageViewController.dispose();
    _ecoscorePageViewController.dispose();
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
      maxHeight: 1024,
      maxWidth: 768,
      preferredCameraDevice: CameraDevice.front,
    );

    if (imageFile == null) {
      return;
    }

    var convertedImage = File(imageFile.path);
    final croppedImage = await ImageCropper.cropImage(
      sourcePath: convertedImage.path, 
      aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: styles.primaryColor,
              toolbarWidgetColor: styles.ghostWhite,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false
          ),
          iosUiSettings: IOSUiSettings(
            title: 'Cropper',
          ), 
      );

    if(croppedImage == null)
    {
      return;
    }
    
    convertedImage = croppedImage;

    setState(() {
      _pickedImage = convertedImage;
      _imageUrl = null;
      productInsertionMethod = ProductInsertionMethod.Manually;
    });
  }

  Future<void> _extractTextFromImage(ImageSource imageSource, TextEditingController controller) async
  {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: imageSource,
      maxHeight: 1024,
      maxWidth: 768,
      preferredCameraDevice: CameraDevice.front,
    );

    if (imageFile == null) {
      return;
    }

    var convertedImage = File(imageFile.path);

    final croppedImage = await ImageCropper.cropImage(
      sourcePath: convertedImage.path, 
      aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: styles.primaryColor,
              toolbarWidgetColor: styles.ghostWhite,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false
          ),
          iosUiSettings: IOSUiSettings(
            title: 'Cropper',
          ), 
      );

    if(croppedImage == null)
    {
      return;
    }
    
    convertedImage = croppedImage;
    RekognizeProvider rekognizeProvider = new RekognizeProvider();
    List<int> imageBytes = convertedImage.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);

    setState(() {
      _isExtractingText = true;
    });

    var extractedText;

    try {
        extractedText = await rekognizeProvider.extractTextAnnotation(base64Image);
    } catch(error)
    {
      print(error);
      rethrow;
    }


    print(extractedText);

    setState(() {
      _isExtractingText = false;
    });

    controller.text = extractedText ?? "";
  }

  
  //TODO: push and get nutritionscore and ingredientText to server + use consumer on health

  Future<void> _scanBarcode() async {
    _formKey.currentState?.reset();
    // todo: set meat, fish, vegetarian etc... automatically

    String? scanResult;

    scanResult = "8013355999662"; // LEAVE FOR TESTING
    scanResult = "3168930010265";
    scanResult = "689544001737";
    scanResult = "8000090003297";
    scanResult = "8000090003297";
    scanResult = "5053990160075";

    try {
      BarcodeResult result = await FlutterScandit(symbologies: [
        Symbology.EAN13_UPCA,
        Symbology.EAN8,
        Symbology.QR,
        Symbology.UPCE,
        Symbology.UPCE,
      ], licenseKey: pltf.Platform.isAndroid ? SCANDIT_API_KEY_ANDROID : SCANDIT_API_KEY_IOS)
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
      // extracting product name
      _productNameController.text = result.product?.productName ?? '';

      // extract nutriments
      final resultNutriments = result.product?.nutriments;
      if(resultNutriments != null)
      {
        print(resultNutriments.energy);
        _nutriments.energyKcal = resultNutriments.energyKcal ?? (resultNutriments.energy == null ? null : resultNutriments.energy! * 0.239);

        _nutriments.fat = resultNutriments.fat;
        _nutriments.saturatedFat = resultNutriments.saturatedFat;
        _nutriments.carbohydrates = resultNutriments.carbohydrates;
        _nutriments.sugars = resultNutriments.sugars;
        _nutriments.fiber = resultNutriments.fiber;
        _nutriments.proteins = resultNutriments.proteins;
        _nutriments.salt = resultNutriments.salt;

        _kcalsController.text = _nutriments.energyKcal == null ? 'N/A' : _nutriments.energyKcal!.toStringAsFixed(2);
        _fatController.text = _nutriments.fat == null ? 'N/A' : _nutriments.fat!.toStringAsFixed(2);
        _saturatedFatController.text = _nutriments.saturatedFat == null ? 'N/A' : _nutriments.saturatedFat!.toStringAsFixed(2);
        _carboController.text = _nutriments.carbohydrates == null ? 'N/A' : _nutriments.carbohydrates!.toStringAsFixed(2);
        _sugarController.text = _nutriments.sugars == null ? 'N/A' : _nutriments.sugars!.toStringAsFixed(2);
        _fibersController.text = _nutriments.fiber == null ? 'N/A' : _nutriments.fiber!.toStringAsFixed(2);
        _proteinsController.text = _nutriments.proteins == null ? 'N/A' : _nutriments.proteins!.toStringAsFixed(2);
        _saltController.text = _nutriments.salt == null ? 'N/A' : _nutriments.salt!.toStringAsFixed(2);
      }
      

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
      _ingredientsText = result.product?.ingredientsTextInLanguages?[openfoodfacts.OpenFoodFactsLanguage.ENGLISH] ?? result.product?.ingredientsText;
      if (_ingredientsText != null) {
        _ingredientsTextController.text = _ingredientsText!;
      }

      // extract nutriscore
      _nutriscore = result.product?.nutriscore;
      
      if(_nutriscore != null)
      {
        //_nutriscorePageViewController.jumpToPage(4); not working
      }

      // extract product image
      final images = result.product?.images;
      String? imageUrl;
      if (images != null && images.isNotEmpty) {
        imageUrl = images.firstWhere((element) => element.size == openfoodfacts.ImageSize.DISPLAY).url ??
            result.product?.images?.firstWhere((element) => element.size == openfoodfacts.ImageSize.SMALL).url;
      }

      // extracting allergies or intolerances
      _allergens = result.product?.allergens?.names;

      if(_allergens != null)
      {
        _alergiesTextController.text = _allergens!.join(", ");
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            const Text(
                              "Scan barcode",
                              style: styles.heading,
                              textAlign: TextAlign.center,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 65,
                                width: 300,
                                child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    decoration: ShapeDecoration(
                                      color: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ), //CircleBorder(),
                                    ),
                                    child: IconButton(
                                      //padding: EdgeInsets.symmetric(horizontal: 20),
                                      icon: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const FaIcon(
                                            FontAwesomeIcons.barcode,
                                            size: 35,
                                          ),
                                          const FaIcon(
                                            FontAwesomeIcons.barcode,
                                            size: 35,
                                          ),
                                          const FaIcon(
                                            FontAwesomeIcons.barcode,
                                            size: 35,
                                          ),
                                          const FaIcon(
                                            FontAwesomeIcons.barcode,
                                            size: 35,
                                          ),
                                        ],
                                      ),
                                      color: Colors.white,
                                      onPressed: _scanBarcode,
                                    ),
                                  ),
                              ),
                            ),
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
                                    width: 1.5,
                                    color: styles.ghostWhite,
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
                                                    fit: BoxFit.contain,
                                                  )
                                                : Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Container(
                                                      child: Image.network(
                                                          _imageUrl!,
                                                          fit: BoxFit.cover,
                                                          color: Colors.black.withOpacity(0.4),
                                                          colorBlendMode: BlendMode.colorBurn,
                                                        ),
                                                    ),
                                                    Positioned.fill(
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                                        child: Container(color: Colors.black.withOpacity(0.0),),
                                                      )
                                                    ),
                                                    Image.network(
                                                        _imageUrl!,
                                                        fit: BoxFit.contain,
                                                      ),
                                                  ],
                                                )
                                            : _pickedImage == null
                                                ? Image.asset(
                                                    "assets/images/missing_image_placeholder.png",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Container(
                                                      child: Image.file(
                                                          _pickedImage!,
                                                          fit: BoxFit.cover,
                                                          color: Colors.black.withOpacity(0.4),
                                                          colorBlendMode: BlendMode.colorBurn,
                                                        ),
                                                    ),
                                                    Positioned.fill(
                                                      child: BackdropFilter(
                                                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                                        child: Container(color: Colors.black.withOpacity(0.0),),
                                                      )
                                                    ),
                                                    Image.file(
                                                      _pickedImage!,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ],
                                                )
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
                                    ? CircularProgressIndicator(
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
                              "Nutriments",
                              style: styles.heading,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            HealthInfoInput(
                              title: 'Energy', 
                              symbol: 'kcal', 
                              controller: _kcalsController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.energyKcal = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.energyKcal = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: 'Fat', 
                              symbol: 'g', 
                              controller: _fatController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.fat = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.fat = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: '   of which acid saturated fat', 
                              symbol: 'g', 
                              controller: _saturatedFatController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.saturatedFat = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.saturatedFat = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: 'Carbohydrates', 
                              symbol: 'g', 
                              controller: _carboController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.carbohydrates = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.carbohydrates = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: '   of which sugar', 
                              symbol: 'g', 
                              controller: _sugarController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.sugars = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.sugars = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: 'Fibers', 
                              symbol: 'g', 
                              controller: _fibersController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.fiber = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.fiber = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: 'Proteins', 
                              symbol: 'g', 
                              controller: _proteinsController, 
                              divider: true, 
                              onSaved: (value) => _nutriments.proteins = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.proteins = double.tryParse(value),
                            ),
                            HealthInfoInput(
                              title: 'Salt', 
                              symbol: 'g', 
                              controller: _saltController, 
                              divider: false, 
                              onSaved: (value) => _nutriments.salt = (value == null ? null : double.tryParse(value)), 
                              onFieldSubmitted: (value) => _nutriments.salt = double.tryParse(value),
                            ),    
                            SizedBox(height: 20), 
                            Divider(color: styles.ghostWhite.withOpacity(0.8)),
                            SizedBox(height: 20), 
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Ingredients",
                                  style: styles.heading,
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.camera, 
                                    size: 16, 
                                    color: styles.ghostWhite,
                                  ),
                                  onPressed: () async {
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
                                    _extractTextFromImage(imageSource, _ingredientsTextController);
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _ingredientsTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 10,
                              style: styles.subheading,
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
                                hintText: 'e.g. 200g oil, milk, ...',
                                hintStyle: styles.subheading
                              ),
                              validator: (value) {
                                /*if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }*/

                                return null;
                              },
                              onSaved: (value) {
                                _ingredientsText = value;
                              },
                              onFieldSubmitted: (value) {
                                _ingredientsText = value;
                              },
                            ),
                            SizedBox(height: 20), 
                            Divider(color: styles.ghostWhite.withOpacity(0.8)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text("Nutri-score", style: styles.subtitle, textAlign: TextAlign.center,),
                                    SizedBox(
                                      height: 70, // card height
                                      width: 120,
                                      child: PageView.builder(
                                      itemCount: 5,
                                      pageSnapping: true,
                                      controller: _nutriscorePageViewController,
                                      onPageChanged: (int index) {
                                        setState(() => _nutriScoreIndex = index);
                                        _nutriscore = (index == 0 ? null : nutriscoreValues[index]);
                                      },
                                      itemBuilder: (_, i) {
                                        final List<Color> colors = [Colors.grey, Colors.green.shade900, Colors.green.shade300, Colors.yellow.shade600, Colors.orange.shade600, Colors.red.shade700];
                                        return Transform.scale(
                                          scale: i == _nutriScoreIndex ? 1 : 0.9,
                                          child: Card(
                                            color: colors[i],
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            child: Center(
                                              child: FittedBox(
                                                child: Text(
                                                  nutriscoreValues[i],
                                                  style: styles.subtitle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text("Eco-score", style: styles.subtitle, textAlign: TextAlign.center,),
                                    SizedBox(
                                      height: 70, // card height
                                      width: 120,
                                      child: PageView.builder(
                                        itemCount: 5,
                                        controller: _ecoscorePageViewController,
                                        onPageChanged: (int index) {
                                        setState(() => _ecoScoreIndex = index);
                                          _ecoscore = (index == 0 ? null : nutriscoreValues[index]);
                                        },
                                        itemBuilder: (_, i) {
                                          final List<Color> colors = [Colors.grey, Colors.green.shade900, Colors.green.shade300, Colors.yellow.shade600, Colors.orange.shade600, Colors.red.shade700];
                                          return Transform.scale(
                                            scale: i == _ecoScoreIndex ? 1 : 0.9,
                                            child: Card(
                                            color: colors[i],
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            child: Center(
                                              child: FittedBox(
                                                child: Text(
                                                  ecoscoreValues[i],
                                                  style: styles.subtitle,
                                                ),
                                              ),
                                            ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),          
                            SizedBox(height: 20), 
                            Divider(color: styles.ghostWhite.withOpacity(0.8)),
                            SizedBox(height: 10), 
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Alergies or intolerances",
                                  style: styles.heading,
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.camera, 
                                    size: 16, 
                                    color: styles.ghostWhite,
                                  ),
                                  onPressed: () async {
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
                                    _extractTextFromImage(imageSource, _alergiesTextController);
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _alergiesTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              style: styles.subheading,
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
                                hintText: 'e.g. eggs, milk, shrimps...',
                                hintStyle: styles.subheading
                              ),
                              validator: (value) {
                                /*if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }*/

                                return null;
                              },
                              onSaved: (value) {
                                _allergens = value == null ? null : value.split(",");
                              },
                              onFieldSubmitted: (value) {
                                _allergens = value.split(",");
                              },
                            ),
                            SizedBox(height: 20), 
                            Divider(color: styles.ghostWhite.withOpacity(0.8)),
                            SizedBox(height: 10),  
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Packaging",
                                  style: styles.heading,
                                  textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: FaIcon(
                                    FontAwesomeIcons.camera, 
                                    size: 16, 
                                    color: styles.ghostWhite,
                                  ),
                                  onPressed: () async {
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
                                    _extractTextFromImage(imageSource, _packagingTextController);
                                  }
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _packagingTextController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                              style: styles.subheading,
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
                                hintText: 'e.g. glass, cardboard...',
                                hintStyle: styles.subheading
                              ),
                              validator: (value) {
                                /*if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }*/

                                return null;
                              },
                              onSaved: (value) {
                                _packaging = value ?? null;
                              },
                              onFieldSubmitted: (value) {
                                _packaging = value;
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            /*Positioned(
              top: 20,
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
            ),*/
            if (_isFetchingProduct)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
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
              ),
            if (_isExtractingText)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: styles.ghostWhite,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Extracting ingredients text...",
                      style: styles.subtitle,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

class HealthInfoInput extends StatelessWidget {
  String title;
  String symbol;
  TextEditingController controller;
  bool divider;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;

  HealthInfoInput({required this.title, required this.symbol, required this.controller, required this.onSaved, required this.onFieldSubmitted, this.divider = false});

  bool isNumeric(String? string) {
  if(string == null)
  {
    return false;
  }

  final numericRegex = 
    RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

  return numericRegex.hasMatch(string);
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  color: styles.ghostWhite,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 50, 
                    child: TextFormField(
                      controller: controller,
                      style: styles.subheading,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        isDense: true,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: styles.ghostWhite,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 2.0,
                          ), 
                        ),
                      ),
                      validator: (value) {
                        if (!isNumeric(value)) {
                          return ' ';
                        }
                        return null;
                      },
                      onSaved: onSaved,
                      onFieldSubmitted: onFieldSubmitted,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    symbol,
                    style: TextStyle(
                      fontFamily: styles.currentFontFamily,
                      color: styles.ghostWhite,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if(divider)
            SizedBox(height: 5,),
          if(divider)
            Divider(
              color: Colors.white12,
              thickness: 1.5,
            ),
        ],
      ),
    );
  }
}
