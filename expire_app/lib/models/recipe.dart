import 'dart:convert';

List<Recipe> recipeFromJson(String str) => List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

String recipeToJson(List<Recipe> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recipe {
  Recipe({
    this.id,
    this.image,
    this.imageType,
    this.likes,
    this.missedIngredientCount,
    this.missedIngredients,
    this.title,
    this.unusedIngredients,
    this.usedIngredientCount,
    this.usedIngredients,
  });

  final int? id;
  final String? image;
  final String? imageType;
  final int? likes;
  final int? missedIngredientCount;
  final List<SedIngredient>? missedIngredients;
  final String? title;
  final List<SedIngredient>? unusedIngredients;
  final int? usedIngredientCount;
  final List<SedIngredient>? usedIngredients;

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json["id"],
    image: json["image"],
    imageType: json["imageType"],
    likes: json["likes"],
    missedIngredientCount: json["missedIngredientCount"],
    missedIngredients: List<SedIngredient>.from(json["missedIngredients"].map((x) => SedIngredient.fromJson(x))),
    title: json["title"],
    unusedIngredients: List<SedIngredient>.from(json["unusedIngredients"].map((x) => SedIngredient.fromJson(x))),
    usedIngredientCount: json["usedIngredientCount"],
    usedIngredients: List<SedIngredient>.from(json["usedIngredients"].map((x) => SedIngredient.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image": image,
    "imageType": imageType,
    "likes": likes,
    "missedIngredientCount": missedIngredientCount,
    "missedIngredients": List<dynamic>.from(missedIngredients!.map((x) => x.toJson())),
    "title": title,
    "unusedIngredients": List<dynamic>.from(unusedIngredients!.map((x) => x.toJson())),
    "usedIngredientCount": usedIngredientCount,
    "usedIngredients": List<dynamic>.from(usedIngredients!.map((x) => x.toJson())),
  };
}

class SedIngredient {
  SedIngredient({
    this.aisle,
    this.amount,
    this.id,
    this.image,
    this.meta,
    this.name,
    this.original,
    this.originalName,
    this.unit,
    this.unitLong,
    this.unitShort,
    this.extendedName,
  });

  final String? aisle;
  final double? amount;
  final int? id;
  final String? image;
  final List<String>? meta;
  final String? name;
  final String? original;
  final String? originalName;
  final String? unit;
  final String? unitLong;
  final String? unitShort;
  final String? extendedName;

  factory SedIngredient.fromJson(Map<String, dynamic> json) => SedIngredient(
    aisle: json["aisle"],
    amount: json["amount"].toDouble(),
    id: json["id"],
    image: json["image"],
    meta: List<String>.from(json["meta"].map((x) => x)),
    name: json["name"],
    original: json["original"],
    originalName: json["originalName"],
    unit: json["unit"],
    unitLong: json["unitLong"],
    unitShort: json["unitShort"],
    extendedName: json["extendedName"] == null ? null : json["extendedName"],
  );

  Map<String, dynamic> toJson() => {
    "aisle": aisle,
    "amount": amount,
    "id": id,
    "image": image,
    "meta": List<dynamic>.from(meta!.map((x) => x)),
    "name": name,
    "original": original,
    "originalName": originalName,
    "unit": unit,
    "unitLong": unitLong,
    "unitShort": unitShort,
    "extendedName": extendedName == null ? null : extendedName,
  };
}
