import 'dart:convert';
import 'dart:io';

import 'package:expire_app/app_styles.dart';
import 'package:expire_app/models/http_service.dart';
import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/models/recipe.dart';
import 'package:expire_app/providers/recipe_provider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:expire_app/models/mock_recipemodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'recipe_details_screen.dart';

/*
Main screen
  1) FROM -> /recipes/findByIngredients
    -id (id of the recipe)
    -title
    -image
    -readyInMinutes (retrieved from 2)

  2) FROM -> recipes/{id}/information
    -readyInMinutes (used also in 1)
    -extendedIngredients (for ingredients section), list of ingredients
    -analyzedInstructions (for preparation section)
    -servings
 */

class RecipeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final recipeData = Provider.of<RecipeProvider>(context).printProduct();
    return Scaffold(
      body: FutureBuilder(
        future: HttpService.getRecipes(),
        builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
          if (snapshot.hasData) {
            List<Recipe>? recipes = snapshot.data;
            if(snapshot.data!.length > 0){
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 12,
                          ),
                          child: RecipeCard(
                            recipe: snapshot.data![index],
                          ),
                        );
                      },
                    )
                  ],
                ),
              );
            }
           else return Center(
              child: Text('No recipes available'),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class RecipeCard extends StatefulWidget {
  //final MockRecipeModel? recipeModel;
  final Recipe recipe;

  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

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
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(
                          idOfRecipe: widget.recipe.id.toString(),
                        ),
                      )),
                  child: Image(
                    height: 320,
                    width: 320,
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.recipe.image!),
                  ),
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
                    Center(
                      child: Text(
                        widget.recipe.title!,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
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
