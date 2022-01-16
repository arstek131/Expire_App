import 'dart:convert';
import 'dart:io';

import 'package:expire_app/app_styles.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:expire_app/models/mock_recipemodel.dart';
import 'package:expire_app/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'MockRecipeDetails.dart';

class RecipeScreen extends StatelessWidget {
  Future getAPIdata() async {
    final queryParameters = {
      'apiKey': 'd53be8e7bdf642a6a61c4c1773958dba',
      'ingredients': 'tomato',
      'number': '1',
    };
    final uri = Uri.https(
        'api.spoonacular.com', '/recipes/findByIngredients', queryParameters);
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    final response = await http.get(uri, headers: headers);

    var jsondata = jsonDecode(response.body);
    final result = recipeFromJson(response.body);
    print(jsondata);
    return result;
  }

  /*@override
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
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: MockRecipeModel.demoRecipe.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MockRecipeDetails(
                            recipeModel: MockRecipeModel.demoRecipe[index],
                          ),
                        )),
                    child: RecipeCard(
                      recipeModel: MockRecipeModel.demoRecipe[index],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatefulWidget {
  final MockRecipeModel? recipeModel;

  const RecipeCard({Key? key, this.recipeModel}) : super(key: key);

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool loved = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image(
                  height: 320,
                  width: 320,
                  fit: BoxFit.cover,
                  image: AssetImage(widget.recipeModel!.imgPath),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipeModel!.title,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.recipeModel!.writer,
                      style: Theme.of(context).textTheme.caption,
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Icon(FlutterIcons.timer_mco),
                    SizedBox(
                      width: 4,
                    ),
                    Text(widget.recipeModel!.cookingTime.toString() + '\''),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          loved = !loved;
                        });
                      },
                      child: Icon(
                        FlutterIcons.heart_circle_mco,
                        color: loved ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
