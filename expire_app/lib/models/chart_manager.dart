import 'package:expire_app/models/chartdata.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChartManager {
  /*void printProduct() {
    print(p!.items[1].title);
  }*/

  static List<dynamic> getChartData(BuildContext context, int index) {
    final ProductsProvider productData =
        Provider.of<ProductsProvider>(context, listen: false);

    ChartData l = ChartData(sugar: [
      Sugar('High', 0, Colors.redAccent),
      Sugar('Moderate', 0, Colors.amberAccent),
      Sugar('Low', 0, Colors.greenAccent)
    ], fat: [
      Fat('High', 0, Colors.redAccent),
      Fat('Moderate', 0, Colors.amberAccent),
      Fat('Low', 0, Colors.greenAccent)
    ], saturatedfat: [
      SaturatedFat('High', 0, Colors.redAccent),
      SaturatedFat('Moderate', 0, Colors.amberAccent),
      SaturatedFat('Low', 0, Colors.greenAccent)
    ], salt: [
      Salt('High', 0, Colors.redAccent),
      Salt('Moderate', 0, Colors.amberAccent),
      Salt('Low', 0, Colors.greenAccent)
    ]);

    List<dynamic> values = [];
    String key = '';
    switch (index) {
      case 0:
        values = l.sugar!;
        key = 'sugars';
        break;
      case 1:
        values = l.fat!;
        key = 'fat';
        break;
      case 2:
        values = l.saturatedfat!;
        key = 'saturated-fat';
        break;
      case 3:
        values = l.salt!;
        key = 'salt';
        break;
      default:
        values = [];
    }

    for (int i = 0; i < productData.items.length; i++) {
      if (productData.items[i].ingredientLevels != null) {
        switch (productData.items[i].ingredientLevels![key]) {
          case 'HIGH':
            values[0].value += 3;
            break;
          case 'MODERATE':
            values[1].value += 2;
            break;
          case 'LOW':
            values[2].value += 1;
            break;
        }
      }
    }
    return values;
  }
}
