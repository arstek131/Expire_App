import 'package:expire_app/models/chartdata.dart';
import 'package:expire_app/models/http_service.dart';
import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ChartProvider extends ChangeNotifier {
  static of(BuildContext context) {
    return Provider.of<ChartProvider>(context, listen: false);
  }

  final ProductsProvider? p;
  ChartData char;

  ChartProvider(this.p, this.char);

  /*void printProduct() {
    print(p!.items[1].title);
  }*/

  ChartData getChartData(BuildContext context) {
    final ProductsProvider productData =
        Provider.of<ProductsProvider>(context, listen: false);

    ChartData l = ChartData([
      (Sugar('High', 0)),
      Sugar('Moderate', 0),
      Sugar('Low', 0)
    ], [
      Fat('High', 0),
      Fat('Moderate', 0),
      Fat('Low', 0)
    ], [
      SaturatedFat('High', 0),
      SaturatedFat('Moderate', 0),
      SaturatedFat('Low', 0)
    ], [
      Salt('High', 0),
      Salt('Moderate', 0),
      Salt('Low', 0)
    ]);



    for (int i = 0; i < productData.items.length; i++) {
      if (productData.items[i].ingredientLevels != null) {
        switch (productData.items[i].ingredientLevels!['sugars']) {
          case 'HIGH':
            l.sugar[0].value += 3;
            break;
          case 'MODERATE':
            l.sugar[1].value += 2;
            break;
          case 'LOW':
            l.sugar[2].value += 1;
            break;
        }
        switch (productData.items[i].ingredientLevels!['fat']) {
          case 'HIGH':
            l.fat[0].value += 3;
            break;
          case 'MODERATE':
            l.fat[1].value += 2;
            break;
          case 'LOW':
            l.fat[2].value += 1;
            break;
        }
        switch (productData.items[i].ingredientLevels!['saturated-fat']) {
          case 'HIGH':
            l.saturatedfat[0].value += 3;
            break;
          case 'MODERATE':
            l.saturatedfat[1].value += 2;
            break;
          case 'LOW':
            l.saturatedfat[2].value += 1;
            break;
        }
        switch (productData.items[i].ingredientLevels!['salt']) {
          case 'HIGH':
            l.salt[0].value += 3;
            break;
          case 'MODERATE':
            l.salt[1].value += 2;
            break;
          case 'LOW':
            l.salt[2].value += 1;
            break;
        }
      }
    }

    print("Oleeee2");

    char = l;

    return l;
  }
}
