import 'dart:convert';
import 'dart:io';

import 'package:expire_app/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeScreen extends StatelessWidget {
  Future getAPIdata() async {
    final queryParameters = {
      'apiKey': 'd53be8e7bdf642a6a61c4c1773958dba',
      'ingredients': 'tomato',
      'number': '1',
    };
    final uri = Uri.https('api.spoonacular.com', '/recipes/findByIngredients', queryParameters);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.get(uri, headers: headers);

    var jsondata = jsonDecode(response.body);
    final result = recipeFromJson(response.body);
    print(jsondata);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getAPIdata();
          },
          child: Text("Click me"),
        ),
      ],
    );
  }
}
