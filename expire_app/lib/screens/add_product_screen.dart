import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  static const routeName = '/add-product';
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Todo: change
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () => Navigator.of(context).pop());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add product"),
      ),
      body: const Center(
        child: Text("TODO:"),
      ),
    );
  }
}
