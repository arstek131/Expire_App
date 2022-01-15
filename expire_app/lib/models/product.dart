import 'dart:io';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class Product {
  /* product info */
  String? id;
  String title;
  dynamic image;
  Nutriments? nutriments;
  String? ingredientsText;
  String? nutriscore;

  /* current product instance info */
  DateTime expiration;

  /* product metadata */
  String creatorId;
  String creatorName;

  Product({
    required this.id,
    required this.title,
    required this.expiration,
    required this.creatorId,
    required this.creatorName,
    this.image,
    this.nutriments,
    this.ingredientsText,
    this.nutriscore,
  });
}
