import 'dart:io';
import 'package:openfoodfacts/model/Nutriments.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:flutter/foundation.dart';

class Product {
  /* product info */
  String? id;
  String title;
  dynamic image;
  Nutriments? nutriments;
  String? ingredientsText;
  String? nutriscore;
  List<String>? allergens;
  String? ecoscore;
  String? packaging;
  Map<String, String>? ingredientLevels;
  String? isPalmOilFree;
  String? isVegetarian;
  String? isVegan;
  String? brandName;
  String? quantity;

  /* current product instance info */
  DateTime expiration;
  DateTime dateAdded;

  /* product metadata */
  String creatorId;
  String creatorName;

  Product({
    required this.id,
    required this.title,
    required this.expiration,
    required this.creatorId,
    required this.creatorName,
    required this.dateAdded,
    this.image,
    this.nutriments,
    this.ingredientsText,
    this.nutriscore,
    this.allergens,
    this.ecoscore,
    this.packaging,
    this.ingredientLevels,
    this.isPalmOilFree,
    this.isVegetarian,
    this.isVegan,
    this.brandName,
    this.quantity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          expiration.millisecondsSinceEpoch == other.expiration.millisecondsSinceEpoch &&
          creatorId == other.creatorId &&
          creatorName == other.creatorName &&
          dateAdded.millisecondsSinceEpoch == other.dateAdded.millisecondsSinceEpoch &&
          image == other.image &&
          //nutriments == other.nutriments &&
          ingredientsText == other.ingredientsText &&
          nutriscore == other.nutriscore &&
          listEquals(allergens, other.allergens) &&
          ecoscore == other.ecoscore &&
          packaging == other.packaging &&
          mapEquals(ingredientLevels, other.ingredientLevels) &&
          isPalmOilFree == other.isPalmOilFree &&
          isVegetarian == other.isVegetarian &&
          isVegan == other.isVegan &&
          brandName == other.brandName &&
          quantity == other.quantity;

  @override
  int get hashCode => id.hashCode;
}
