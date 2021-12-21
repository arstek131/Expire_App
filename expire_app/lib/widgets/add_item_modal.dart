import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddItemModal extends StatefulWidget {
  final BuildContext modalContext;

  AddItemModal({required this.modalContext});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<Map<String, Object>> _choicesList = [
    {"title": "MEAT", "icon": const FaIcon(FontAwesomeIcons.drumstickBite)},
    {"title": "FISH", "icon": const FaIcon(FontAwesomeIcons.fish)},
    {"title": "VEGETARIAN", "icon": const FaIcon(FontAwesomeIcons.leaf)},
    {"title": "FRUIT", "icon": const FaIcon(FontAwesomeIcons.appleAlt)}
  ];
  List<int> _chosenIndexes = [];

  @override
  initState() {
    super.initState();
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
    print(_chosenIndexes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
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
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: FaIcon(
                            FontAwesomeIcons.pizzaSlice,
                            size: 24,
                            color: Colors.indigo,
                          ),
                        ), //Icon(Icons.person, color: Colors.indigoAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        hintText: 'product name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }

                        return null;
                      },
                      /*onSaved: (value) {
                            _authData['email'] = value!;
                            print(_authData);
                          },
                          onFieldSubmitted: (value) {
                            _authData['email'] = value;
                            print(_authData);
                          },*/
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Validate returns true if the form is valid, or false otherwise.
                          /*if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                'Signing up, hold tight!',
                                textAlign: TextAlign.center,
                              )),
                            );
                            _submit();
                          }*/
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
    );
  }
}
