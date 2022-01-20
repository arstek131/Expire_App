import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:flutter/cupertino.dart';

class RecipeProvider extends ChangeNotifier{

  final ProductsProvider? p;
  final List<Recipe>? rec;

  RecipeProvider(this.p, this.rec);

  void printProduct(){
    print(p!.items[1].title);
  }

}