/* dart libraries */
import 'package:flutter/material.dart';
import 'dart:io';

/* Screens */
import './screens/products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expire app',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        '/': (ctx) => ProductsScreen(),
      },
    );
  }
}
