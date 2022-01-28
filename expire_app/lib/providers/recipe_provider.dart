import 'package:expire_app/models/http_service.dart';
import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class RecipeProvider extends ChangeNotifier{

  static of(BuildContext context){
    return Provider.of<RecipeProvider>(context, listen: false);
  }

  final ProductsProvider? p;
   List<Recipe>? rec;

  RecipeProvider(this.p, this.rec);

  void printProduct(){
    print(p!.items[1].title);
  }

  Future<List<Recipe>> getRecipes(BuildContext context) async {
    final  ProductsProvider productData = Provider.of<ProductsProvider>(context, listen: false);

    String itemTitles = '';

    for(int i=0; i<productData.items.length; i++){
      itemTitles+=productData.items[i].title + ', ';
    }

    print("Oleeee");
    print(productData.items[0].ingredientLevels);


    //productData.items.map((e) => itemTitles+=e.title+', ');
    itemTitles = itemTitles.substring(0, itemTitles.length-2);
    print(itemTitles);
    List<Recipe> recipes = await HttpService.getRecipes(itemTitles);
    rec = recipes;
    return recipes;
  }

}