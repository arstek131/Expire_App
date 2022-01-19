import 'dart:convert';
import 'dart:io';

import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/models/recipe_details.dart';
import 'package:http/http.dart';

class HttpService{

  static Map<String, String> queryParameters = {
    'apiKey': 'd53be8e7bdf642a6a61c4c1773958dba',
    'ingredients': 'beef', 'yogurt'//atm hardcoded, will be dynamically replaced
    'number': '5',
  };

  static final queryParameters2 = {
    'apiKey': 'd53be8e7bdf642a6a61c4c1773958dba'
  };



 static Future<List<Recipe>> getRecipes() async{

    final uri = Uri.https(
        'api.spoonacular.com', '/recipes/findByIngredients', queryParameters);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    Response res = await get(uri, headers: headers);

    if(res.statusCode == 200){
      List<dynamic> body = jsonDecode(res.body);
      List<Recipe> recipes = body.map((dynamic item) => Recipe.fromJson(item)).toList();
      return recipes;
    }else{
      throw 'can\'t get recipes';
    }

  }

   static Future<List<RecipeDetails>> getInfoRecipes(String id) async{

    final uri = Uri.https(
        'api.spoonacular.com', '/recipes/$id/information', queryParameters2);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    Response res = await get(uri, headers: headers);

    var jsondata = jsonDecode(res.body);
    //final result = recipeFromJson(response.body);
    //print(jsondata);

    if(res.statusCode == 200){
      List <dynamic> body = jsonDecode(res.body);

      List<RecipeDetails> recipes = body.map((dynamic item) => RecipeDetails.fromJson(item)).toList();
      return recipes;
    }else{
      throw 'can\'t get infos';
    }

  }


}