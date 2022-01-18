import 'dart:convert';

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class Recipe {
  Recipe({
    this.id,
    this.title,
    this.image,
    this.imageType,
    this.usedIngredientCount,
    this.missedIngredientCount,
    this.missedIngredients,
    this.usedIngredients,
    this.unusedIngredients,
    this.likes,
  });

  factory Recipe.fromJson(Map<String, dynamic> jsonRes) {
    final List<MissedIngredients>? missedIngredients =
    jsonRes['missedIngredients'] is List ? <MissedIngredients>[] : null;
    if (missedIngredients != null) {
      for (final dynamic item in jsonRes['missedIngredients']!) {
        if (item != null) {
          missedIngredients.add(
              MissedIngredients.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }

    final List<UsedIngredients>? usedIngredients =
    jsonRes['usedIngredients'] is List ? <UsedIngredients>[] : null;
    if (usedIngredients != null) {
      for (final dynamic item in jsonRes['usedIngredients']!) {
        if (item != null) {
          usedIngredients
              .add(UsedIngredients.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }

    final List<Object>? unusedIngredients =
    jsonRes['unusedIngredients'] is List ? <Object>[] : null;
    if (unusedIngredients != null) {
      for (final dynamic item in jsonRes['unusedIngredients']!) {
        if (item != null) {
          unusedIngredients.add(asT<Object>(item)!);
        }
      }
    }
    return Recipe(
      id: asT<int?>(jsonRes['id']),
      title: asT<String?>(jsonRes['title']),
      image: asT<String?>(jsonRes['image']),
      imageType: asT<String?>(jsonRes['imageType']),
      usedIngredientCount: asT<int?>(jsonRes['usedIngredientCount']),
      missedIngredientCount: asT<int?>(jsonRes['missedIngredientCount']),
      missedIngredients: missedIngredients,
      usedIngredients: usedIngredients,
      unusedIngredients: unusedIngredients,
      likes: asT<int?>(jsonRes['likes']),
    );
  }

  int? id;
  String? title;
  String? image;
  String? imageType;
  int? usedIngredientCount;
  int? missedIngredientCount;
  List<MissedIngredients>? missedIngredients;
  List<UsedIngredients>? usedIngredients;
  List<Object>? unusedIngredients;
  int? likes;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'image': image,
    'imageType': imageType,
    'usedIngredientCount': usedIngredientCount,
    'missedIngredientCount': missedIngredientCount,
    'missedIngredients': missedIngredients,
    'usedIngredients': usedIngredients,
    'unusedIngredients': unusedIngredients,
    'likes': likes,
  };
}

class MissedIngredients {
  MissedIngredients({
    this.id,
    this.amount,
    this.unit,
    this.unitLong,
    this.unitShort,
    this.aisle,
    this.name,
    this.original,
    this.originalString,
    this.originalName,
    this.metaInformation,
    this.meta,
    this.image,
  });

  factory MissedIngredients.fromJson(Map<String, dynamic> jsonRes) {
    final List<Object>? metaInformation =
    jsonRes['metaInformation'] is List ? <Object>[] : null;
    if (metaInformation != null) {
      for (final dynamic item in jsonRes['metaInformation']!) {
        if (item != null) {
          metaInformation.add(asT<Object>(item)!);
        }
      }
    }

    final List<Object>? meta = jsonRes['meta'] is List ? <Object>[] : null;
    if (meta != null) {
      for (final dynamic item in jsonRes['meta']!) {
        if (item != null) {
          meta.add(asT<Object>(item)!);
        }
      }
    }
    return MissedIngredients(
      id: asT<int?>(jsonRes['id']),
      amount: asT<int?>(jsonRes['amount']),
      unit: asT<String?>(jsonRes['unit']),
      unitLong: asT<String?>(jsonRes['unitLong']),
      unitShort: asT<String?>(jsonRes['unitShort']),
      aisle: asT<String?>(jsonRes['aisle']),
      name: asT<String?>(jsonRes['name']),
      original: asT<String?>(jsonRes['original']),
      originalString: asT<String?>(jsonRes['originalString']),
      originalName: asT<String?>(jsonRes['originalName']),
      metaInformation: metaInformation,
      meta: meta,
      image: asT<String?>(jsonRes['image']),
    );
  }

  int? id;
  int? amount;
  String? unit;
  String? unitLong;
  String? unitShort;
  String? aisle;
  String? name;
  String? original;
  String? originalString;
  String? originalName;
  List<Object>? metaInformation;
  List<Object>? meta;
  String? image;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'amount': amount,
    'unit': unit,
    'unitLong': unitLong,
    'unitShort': unitShort,
    'aisle': aisle,
    'name': name,
    'original': original,
    'originalString': originalString,
    'originalName': originalName,
    'metaInformation': metaInformation,
    'meta': meta,
    'image': image,
  };
}

class UsedIngredients {
  UsedIngredients({
    this.id,
    this.amount,
    this.unit,
    this.unitLong,
    this.unitShort,
    this.aisle,
    this.name,
    this.original,
    this.originalString,
    this.originalName,
    this.metaInformation,
    this.meta,
    this.image,
  });

  factory UsedIngredients.fromJson(Map<String, dynamic> jsonRes) {
    final List<String>? metaInformation =
    jsonRes['metaInformation'] is List ? <String>[] : null;
    if (metaInformation != null) {
      for (final dynamic item in jsonRes['metaInformation']!) {
        if (item != null) {
          metaInformation.add(asT<String>(item)!);
        }
      }
    }

    final List<String>? meta = jsonRes['meta'] is List ? <String>[] : null;
    if (meta != null) {
      for (final dynamic item in jsonRes['meta']!) {
        if (item != null) {
          meta.add(asT<String>(item)!);
        }
      }
    }
    return UsedIngredients(
      id: asT<int?>(jsonRes['id']),
      amount: asT<int?>(jsonRes['amount']),
      unit: asT<String?>(jsonRes['unit']),
      unitLong: asT<String?>(jsonRes['unitLong']),
      unitShort: asT<String?>(jsonRes['unitShort']),
      aisle: asT<String?>(jsonRes['aisle']),
      name: asT<String?>(jsonRes['name']),
      original: asT<String?>(jsonRes['original']),
      originalString: asT<String?>(jsonRes['originalString']),
      originalName: asT<String?>(jsonRes['originalName']),
      metaInformation: metaInformation,
      meta: meta,
      image: asT<String?>(jsonRes['image']),
    );
  }

  int? id;
  int? amount;
  String? unit;
  String? unitLong;
  String? unitShort;
  String? aisle;
  String? name;
  String? original;
  String? originalString;
  String? originalName;
  List<String>? metaInformation;
  List<String>? meta;
  String? image;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'amount': amount,
    'unit': unit,
    'unitLong': unitLong,
    'unitShort': unitShort,
    'aisle': aisle,
    'name': name,
    'original': original,
    'originalString': originalString,
    'originalName': originalName,
    'metaInformation': metaInformation,
    'meta': meta,
    'image': image,
  };
}
