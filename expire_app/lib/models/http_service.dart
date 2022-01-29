import 'dart:convert';
import 'dart:io';

import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/models/recipe_details.dart';
import 'package:http/http.dart';

class HttpService{
  /*
    Altre chiavi API:
    1) b385898bef554001872e9e2710451a8d
    2) d53be8e7bdf642a6a61c4c1773958dba
    3) d1829587c9b44fac84f3086e8e15e74d
  */




  static final queryParameters2 = {
    'apiKey': 'd1829587c9b44fac84f3086e8e15e74d'
  };



 static Future<List<Recipe>> getRecipes(String ingredients) async{

   Map<String, String> queryParameters = {
     'apiKey': 'd1829587c9b44fac84f3086e8e15e74d',
     'ingredients': ingredients,
     'number': '10',
   };

    final uri = Uri.https(
        'api.spoonacular.com', '/recipes/findByIngredients', queryParameters);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    Response res = await get(uri, headers: headers);

    if(res.statusCode == 200){
      List<dynamic> body = jsonDecode(res.body);

      print(uri.toString());

      List<Recipe> recipes = body.map((dynamic item) => Recipe.fromJson(item)).toList();


      return recipes;
    }else{
      throw 'can\'t get recipes';
    }

  }

   static Future <RecipeDetails> getInfoRecipes(String id) async{

    final uri = Uri.https(
        'api.spoonacular.com', '/recipes/$id/information', queryParameters2);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    Response res = await get(uri, headers: headers);

    if(res.statusCode == 200){
      Map<String, dynamic> body = jsonDecode(res.body);
      print(uri.toString());



      RecipeDetails recipesDetails = RecipeDetails.fromJson(body);
      //print(recipesDetails.title);
      //print(recipesDetails.analyzedInstructions[0].steps.length);

      return recipesDetails;
    }else{
      throw 'can\'t get infos';
    }

  }


}