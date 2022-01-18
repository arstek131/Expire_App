import 'dart:convert';

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class RecipeDetails {
  RecipeDetails({
    this.vegetarian,
    this.vegan,
    this.glutenFree,
    this.dairyFree,
    this.veryHealthy,
    this.cheap,
    this.veryPopular,
    this.sustainable,
    this.weightWatcherSmartPoints,
    this.gaps,
    this.lowFodmap,
    this.aggregateLikes,
    this.spoonacularScore,
    this.healthScore,
    this.creditsText,
    this.license,
    this.sourceName,
    this.pricePerServing,
    this.extendedIngredients,
    this.id,
    this.title,
    this.readyInMinutes,
    this.servings,
    this.sourceUrl,
    this.image,
    this.imageType,
    this.summary,
    this.cuisines,
    this.dishTypes,
    this.diets,
    this.occasions,
    this.winePairing,
    this.instructions,
    this.analyzedInstructions,
    this.originalId,
    this.spoonacularSourceUrl,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> jsonRes) {
    final List<ExtendedIngredients>? extendedIngredients =
    jsonRes['extendedIngredients'] is List ? <ExtendedIngredients>[] : null;
    if (extendedIngredients != null) {
      for (final dynamic item in jsonRes['extendedIngredients']!) {
        if (item != null) {
          extendedIngredients.add(
              ExtendedIngredients.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }

    final List<Object>? cuisines =
    jsonRes['cuisines'] is List ? <Object>[] : null;
    if (cuisines != null) {
      for (final dynamic item in jsonRes['cuisines']!) {
        if (item != null) {
          cuisines.add(asT<Object>(item)!);
        }
      }
    }

    final List<String>? dishTypes =
    jsonRes['dishTypes'] is List ? <String>[] : null;
    if (dishTypes != null) {
      for (final dynamic item in jsonRes['dishTypes']!) {
        if (item != null) {
          dishTypes.add(asT<String>(item)!);
        }
      }
    }

    final List<String>? diets = jsonRes['diets'] is List ? <String>[] : null;
    if (diets != null) {
      for (final dynamic item in jsonRes['diets']!) {
        if (item != null) {
          diets.add(asT<String>(item)!);
        }
      }
    }

    final List<Object>? occasions =
    jsonRes['occasions'] is List ? <Object>[] : null;
    if (occasions != null) {
      for (final dynamic item in jsonRes['occasions']!) {
        if (item != null) {
          occasions.add(asT<Object>(item)!);
        }
      }
    }

    final List<AnalyzedInstructions>? analyzedInstructions =
    jsonRes['analyzedInstructions'] is List
        ? <AnalyzedInstructions>[]
        : null;
    if (analyzedInstructions != null) {
      for (final dynamic item in jsonRes['analyzedInstructions']!) {
        if (item != null) {
          analyzedInstructions.add(
              AnalyzedInstructions.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }
    return RecipeDetails(
      vegetarian: asT<bool?>(jsonRes['vegetarian']),
      vegan: asT<bool?>(jsonRes['vegan']),
      glutenFree: asT<bool?>(jsonRes['glutenFree']),
      dairyFree: asT<bool?>(jsonRes['dairyFree']),
      veryHealthy: asT<bool?>(jsonRes['veryHealthy']),
      cheap: asT<bool?>(jsonRes['cheap']),
      veryPopular: asT<bool?>(jsonRes['veryPopular']),
      sustainable: asT<bool?>(jsonRes['sustainable']),
      weightWatcherSmartPoints: asT<int?>(jsonRes['weightWatcherSmartPoints']),
      gaps: asT<String?>(jsonRes['gaps']),
      lowFodmap: asT<bool?>(jsonRes['lowFodmap']),
      aggregateLikes: asT<int?>(jsonRes['aggregateLikes']),
      spoonacularScore: asT<int?>(jsonRes['spoonacularScore']),
      healthScore: asT<int?>(jsonRes['healthScore']),
      creditsText: asT<String?>(jsonRes['creditsText']),
      license: asT<String?>(jsonRes['license']),
      sourceName: asT<String?>(jsonRes['sourceName']),
      pricePerServing: asT<double?>(jsonRes['pricePerServing']),
      extendedIngredients: extendedIngredients,
      id: asT<int?>(jsonRes['id']),
      title: asT<String?>(jsonRes['title']),
      readyInMinutes: asT<int?>(jsonRes['readyInMinutes']),
      servings: asT<int?>(jsonRes['servings']),
      sourceUrl: asT<String?>(jsonRes['sourceUrl']),
      image: asT<String?>(jsonRes['image']),
      imageType: asT<String?>(jsonRes['imageType']),
      summary: asT<String?>(jsonRes['summary']),
      cuisines: cuisines,
      dishTypes: dishTypes,
      diets: diets,
      occasions: occasions,
      winePairing: asT<Object?>(jsonRes['winePairing']),
      instructions: asT<String?>(jsonRes['instructions']),
      analyzedInstructions: analyzedInstructions,
      originalId: asT<Object?>(jsonRes['originalId']),
      spoonacularSourceUrl: asT<String?>(jsonRes['spoonacularSourceUrl']),
    );
  }

  bool? vegetarian;
  bool? vegan;
  bool? glutenFree;
  bool? dairyFree;
  bool? veryHealthy;
  bool? cheap;
  bool? veryPopular;
  bool? sustainable;
  int? weightWatcherSmartPoints;
  String? gaps;
  bool? lowFodmap;
  int? aggregateLikes;
  int? spoonacularScore;
  int? healthScore;
  String? creditsText;
  String? license;
  String? sourceName;
  double? pricePerServing;
  List<ExtendedIngredients>? extendedIngredients;
  int? id;
  String? title;
  int? readyInMinutes;
  int? servings;
  String? sourceUrl;
  String? image;
  String? imageType;
  String? summary;
  List<Object>? cuisines;
  List<String>? dishTypes;
  List<String>? diets;
  List<Object>? occasions;
  Object? winePairing;
  String? instructions;
  List<AnalyzedInstructions>? analyzedInstructions;
  Object? originalId;
  String? spoonacularSourceUrl;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'vegetarian': vegetarian,
    'vegan': vegan,
    'glutenFree': glutenFree,
    'dairyFree': dairyFree,
    'veryHealthy': veryHealthy,
    'cheap': cheap,
    'veryPopular': veryPopular,
    'sustainable': sustainable,
    'weightWatcherSmartPoints': weightWatcherSmartPoints,
    'gaps': gaps,
    'lowFodmap': lowFodmap,
    'aggregateLikes': aggregateLikes,
    'spoonacularScore': spoonacularScore,
    'healthScore': healthScore,
    'creditsText': creditsText,
    'license': license,
    'sourceName': sourceName,
    'pricePerServing': pricePerServing,
    'extendedIngredients': extendedIngredients,
    'id': id,
    'title': title,
    'readyInMinutes': readyInMinutes,
    'servings': servings,
    'sourceUrl': sourceUrl,
    'image': image,
    'imageType': imageType,
    'summary': summary,
    'cuisines': cuisines,
    'dishTypes': dishTypes,
    'diets': diets,
    'occasions': occasions,
    'winePairing': winePairing,
    'instructions': instructions,
    'analyzedInstructions': analyzedInstructions,
    'originalId': originalId,
    'spoonacularSourceUrl': spoonacularSourceUrl,
  };
}

class ExtendedIngredients {
  ExtendedIngredients({
    this.id,
    this.aisle,
    this.image,
    this.consistency,
    this.name,
    this.nameClean,
    this.original,
    this.originalString,
    this.originalName,
    this.amount,
    this.unit,
    this.meta,
    this.metaInformation,
    this.measures,
  });

  factory ExtendedIngredients.fromJson(Map<String, dynamic> jsonRes) {
    final List<String>? meta = jsonRes['meta'] is List ? <String>[] : null;
    if (meta != null) {
      for (final dynamic item in jsonRes['meta']!) {
        if (item != null) {
          meta.add(asT<String>(item)!);
        }
      }
    }

    final List<String>? metaInformation =
    jsonRes['metaInformation'] is List ? <String>[] : null;
    if (metaInformation != null) {
      for (final dynamic item in jsonRes['metaInformation']!) {
        if (item != null) {
          metaInformation.add(asT<String>(item)!);
        }
      }
    }
    return ExtendedIngredients(
      id: asT<int?>(jsonRes['id']),
      aisle: asT<String?>(jsonRes['aisle']),
      image: asT<String?>(jsonRes['image']),
      consistency: asT<String?>(jsonRes['consistency']),
      name: asT<String?>(jsonRes['name']),
      nameClean: asT<String?>(jsonRes['nameClean']),
      original: asT<String?>(jsonRes['original']),
      originalString: asT<String?>(jsonRes['originalString']),
      originalName: asT<String?>(jsonRes['originalName']),
      amount: asT<int?>(jsonRes['amount']),
      unit: asT<String?>(jsonRes['unit']),
      meta: meta,
      metaInformation: metaInformation,
      measures: jsonRes['measures'] == null
          ? null
          : Measures.fromJson(asT<Map<String, dynamic>>(jsonRes['measures'])!),
    );
  }

  int? id;
  String? aisle;
  String? image;
  String? consistency;
  String? name;
  String? nameClean;
  String? original;
  String? originalString;
  String? originalName;
  int? amount;
  String? unit;
  List<String>? meta;
  List<String>? metaInformation;
  Measures? measures;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'aisle': aisle,
    'image': image,
    'consistency': consistency,
    'name': name,
    'nameClean': nameClean,
    'original': original,
    'originalString': originalString,
    'originalName': originalName,
    'amount': amount,
    'unit': unit,
    'meta': meta,
    'metaInformation': metaInformation,
    'measures': measures,
  };
}

class Measures {
  Measures({
    this.us,
    this.metric,
  });

  factory Measures.fromJson(Map<String, dynamic> jsonRes) => Measures(
    us: jsonRes['us'] == null
        ? null
        : Us.fromJson(asT<Map<String, dynamic>>(jsonRes['us'])!),
    metric: jsonRes['metric'] == null
        ? null
        : Metric.fromJson(asT<Map<String, dynamic>>(jsonRes['metric'])!),
  );

  Us? us;
  Metric? metric;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'us': us,
    'metric': metric,
  };
}

class Us {
  Us({
    this.amount,
    this.unitShort,
    this.unitLong,
  });

  factory Us.fromJson(Map<String, dynamic> jsonRes) => Us(
    amount: asT<int?>(jsonRes['amount']),
    unitShort: asT<String?>(jsonRes['unitShort']),
    unitLong: asT<String?>(jsonRes['unitLong']),
  );

  int? amount;
  String? unitShort;
  String? unitLong;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amount': amount,
    'unitShort': unitShort,
    'unitLong': unitLong,
  };
}

class Metric {
  Metric({
    this.amount,
    this.unitShort,
    this.unitLong,
  });

  factory Metric.fromJson(Map<String, dynamic> jsonRes) => Metric(
    amount: asT<int?>(jsonRes['amount']),
    unitShort: asT<String?>(jsonRes['unitShort']),
    unitLong: asT<String?>(jsonRes['unitLong']),
  );

  int? amount;
  String? unitShort;
  String? unitLong;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amount': amount,
    'unitShort': unitShort,
    'unitLong': unitLong,
  };
}

class AnalyzedInstructions {
  AnalyzedInstructions({
    this.name,
    this.steps,
  });

  factory AnalyzedInstructions.fromJson(Map<String, dynamic> jsonRes) {
    final List<Steps>? steps = jsonRes['steps'] is List ? <Steps>[] : null;
    if (steps != null) {
      for (final dynamic item in jsonRes['steps']!) {
        if (item != null) {
          steps.add(Steps.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }
    return AnalyzedInstructions(
      name: asT<String?>(jsonRes['name']),
      steps: steps,
    );
  }

  String? name;
  List<Steps>? steps;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'steps': steps,
  };
}

class Steps {
  Steps({
    this.number,
    this.step,
    this.ingredients,
    this.equipment,
    this.length,
  });

  factory Steps.fromJson(Map<String, dynamic> jsonRes) {
    final List<Ingredients>? ingredients =
    jsonRes['ingredients'] is List ? <Ingredients>[] : null;
    if (ingredients != null) {
      for (final dynamic item in jsonRes['ingredients']!) {
        if (item != null) {
          ingredients
              .add(Ingredients.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }

    final List<Equipment>? equipment =
    jsonRes['equipment'] is List ? <Equipment>[] : null;
    if (equipment != null) {
      for (final dynamic item in jsonRes['equipment']!) {
        if (item != null) {
          equipment.add(Equipment.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }
    return Steps(
      number: asT<int?>(jsonRes['number']),
      step: asT<String?>(jsonRes['step']),
      ingredients: ingredients,
      equipment: equipment,
      length: jsonRes['length'] == null
          ? null
          : Length.fromJson(asT<Map<String, dynamic>>(jsonRes['length'])!),
    );
  }

  int? number;
  String? step;
  List<Ingredients>? ingredients;
  List<Equipment>? equipment;
  Length? length;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'number': number,
    'step': step,
    'ingredients': ingredients,
    'equipment': equipment,
    'length': length,
  };
}

class Ingredients {
  Ingredients({
    this.id,
    this.name,
    this.localizedName,
    this.image,
  });

  factory Ingredients.fromJson(Map<String, dynamic> jsonRes) => Ingredients(
    id: asT<int?>(jsonRes['id']),
    name: asT<String?>(jsonRes['name']),
    localizedName: asT<String?>(jsonRes['localizedName']),
    image: asT<String?>(jsonRes['image']),
  );

  int? id;
  String? name;
  String? localizedName;
  String? image;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'localizedName': localizedName,
    'image': image,
  };
}

class Equipment {
  Equipment({
    this.id,
    this.name,
    this.localizedName,
    this.image,
    this.temperature,
  });

  factory Equipment.fromJson(Map<String, dynamic> jsonRes) => Equipment(
    id: asT<int?>(jsonRes['id']),
    name: asT<String?>(jsonRes['name']),
    localizedName: asT<String?>(jsonRes['localizedName']),
    image: asT<String?>(jsonRes['image']),
    temperature: jsonRes['temperature'] == null
        ? null
        : Temperature.fromJson(
        asT<Map<String, dynamic>>(jsonRes['temperature'])!),
  );

  int? id;
  String? name;
  String? localizedName;
  String? image;
  Temperature? temperature;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'localizedName': localizedName,
    'image': image,
    'temperature': temperature,
  };
}

class Temperature {
  Temperature({
    this.number,
    this.unit,
  });

  factory Temperature.fromJson(Map<String, dynamic> jsonRes) => Temperature(
    number: asT<int?>(jsonRes['number']),
    unit: asT<String?>(jsonRes['unit']),
  );

  int? number;
  String? unit;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'number': number,
    'unit': unit,
  };
}

class Length {
  Length({
    this.number,
    this.unit,
  });

  factory Length.fromJson(Map<String, dynamic> jsonRes) => Length(
    number: asT<int?>(jsonRes['number']),
    unit: asT<String?>(jsonRes['unit']),
  );

  int? number;
  String? unit;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'number': number,
    'unit': unit,
  };
}
