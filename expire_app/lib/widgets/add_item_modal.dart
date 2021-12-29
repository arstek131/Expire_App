/* dart */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:convert';

/* provider */
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';

/* models */
import '../models/product.dart';

/* enums */
import '../enums/product_insertion_method.dart';

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

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
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

    // todo: if _pickedImage == null, use dummy image

    /* add product locally */
    // local storage
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(_pickedImage!.path);
    final savedImage = await _pickedImage!.copy('${appDir.path}/$fileName');

    // local DB (image path)

    /* add product remotely */

    try {
      await Provider.of<ProductsProvider>(context, listen: false).addProduct(
        Product(
            id: '',
            title: _productData['title'] as String,
            expiration: _pickedDate, //_productData['expiration'] as DateTime,
            creatorId: '',
            image: _pickedImage),
      );
    } catch (error) {
      const errorMessage = 'Chould not upload product. Please try again later';

      _showErrorDialog(errorMessage);

      print(error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 300,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 80,
    );

    if (imageFile == null) {
      return;
    }

    final convertedImage = File(imageFile.path);

    setState(() {
      _pickedImage = convertedImage;
      productInsertionMethod = ProductInsertionMethod.Manually;
    });
  }

  Future<void> _scanBarcode() async {
    /*try {
      String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#FF3F51B5',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      print(scanResult);
    } on PlatformException {
      rethrow;
    }

    if (!mounted) {
      return;
    }

    this.barcodeString = scanResult;
    print(this.scanResult);*/
    this.barcodeString = "8013355998702";

    print("fetching product...");
    final String url = "https://world.openfoodfacts.org/api/v0/product/$barcodeString.json";

    final response = await http.get(Uri.parse(url));
    final decodedResponse = json.decode(response.body);

    setState(() {
      _productNameController.text = decodedResponse['product']["product_name"];
      _imageUrl = decodedResponse['product']['selected_images']['front']['display']['it'];
      productInsertionMethod = ProductInsertionMethod.Scanner;
    });
    print(_imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          Column(
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
                            color: Colors.grey,
                            fontFamily: 'SanFrancisco',
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
                                    fontFamily: 'SanFrancisco',
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
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.indigo,
                              ),
                            ),
                            child: productInsertionMethod == ProductInsertionMethod.None
                                ? const Text(
                                    "Click to add image",
                                    textAlign: TextAlign.center,
                                  )
                                : productInsertionMethod == ProductInsertionMethod.Scanner
                                    ? Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        _pickedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                            /*_pickedImage != null
                                ? Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : _imageUrl != null
                                    ? Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Text(
                                        "Click to add image",
                                        textAlign: TextAlign.center,
                                      ),*/
                            alignment: Alignment.center,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "PRODUCT NAME:",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'SanFrancisco',
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
                          style: const TextStyle(color: Colors.black),
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
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                icon: Icon(Icons.calendar_today_rounded),
                                label: Text(
                                  DateFormat('dd MMMM yyyy').format(_pickedDate),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: Colors.indigoAccent),
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
                                    style: TextStyle(fontSize: 16),
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
                  "Scan barcode ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "SanFrancisco",
                  ),
                ),
                Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.black87,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
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
        ],
      ),
    );
  }
}
