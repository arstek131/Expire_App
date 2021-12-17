import 'dart:io';

class Product {
  String id;
  String title;
  DateTime expiration;
  File? image;

  Product({required this.id, required this.title, required this.expiration, required this.image});
}
