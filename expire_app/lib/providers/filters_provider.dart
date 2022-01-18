import 'package:flutter/material.dart';
import '../models/filter.dart';

class FiltersProvider extends ChangeNotifier {
  FiltersProvider();

  Filter _filter = new Filter();

  Filter get filter {
    return _filter;
  }

  void set filter(Filter filter) {
    this._filter = filter;

    notifyListeners();
  }

  void setSingleFilter({
    bool? isFish,
    bool? isMeat,
    bool? isPalmOilFree,
    bool? isVegan,
    bool? isVegetarian,
  }) {
    if (isFish != null) filter.isFish = isFish;
    if (isMeat != null) filter.isMeat = isMeat;
    if (isPalmOilFree != null) filter.isPalmOilFree = isPalmOilFree;
    if (isVegan != null) filter.isVegan = isVegan;
    if (isVegetarian != null) filter.isVegetarian = isVegetarian;

    notifyListeners();
  }
}
