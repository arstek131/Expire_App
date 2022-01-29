import 'package:expire_app/models/mock_recipemodel.dart';
import 'package:expire_app/models/recipe_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'package:expire_app/models/http_service.dart';

import '../app_styles.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final String idOfRecipe;
  final MockRecipeModel? recipeModel;
  final RecipeDetails? recipeDetails;

  const RecipeDetailsScreen(
      {Key? key,
      this.recipeModel,
      this.recipeDetails,
      required this.idOfRecipe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final _textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: FutureBuilder(
        future: HttpService.getInfoRecipes(idOfRecipe),
        builder: (BuildContext context, AsyncSnapshot<RecipeDetails> snapshot) {
          if (snapshot.hasData) {
            RecipeDetails? recipesDetails = snapshot.data;

            return SlidingUpPanel(
              parallaxEnabled: true,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12,
              ),
              minHeight: (size.height / 2),
              maxHeight: size.height / 1.2,
              panel: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: Text(
                        recipesDetails!.title, //recipesDetails![0].title!,
                        style: _textTheme.headline5!
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          FlutterIcons.timer_mco,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          recipesDetails.readyInMinutes
                              .toString(), //recipesDetails[0].readyInMinutes.toString(),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 2,
                          height: 30,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          recipesDetails.servings.toString() +
                              ' Servings', //recipesDetails[0].readyInMinutes.toString() + ' Servings',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    Expanded(
                      child: DefaultTabController(
                        length: 2,
                        initialIndex: 0,
                        child: Column(
                          children: [
                            TabBar(
                              isScrollable: true,
                              indicatorColor: Colors.red,
                              tabs: [
                                Tab(
                                  text: "Ingredients".toUpperCase(),
                                ),
                                Tab(
                                  text: "Preparation".toUpperCase(),
                                ),
                              ],
                              labelColor: Colors.black,
                              indicator: DotIndicator(
                                color: Colors.black,
                                distanceFromCenter: 16,
                                radius: 3,
                                paintingStyle: PaintingStyle.fill,
                              ),
                              unselectedLabelColor:
                                  Colors.black.withOpacity(0.3),
                              labelStyle: subheading.copyWith(fontSize: 17),
                              labelPadding: EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                            ),
                            Divider(
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Ingredients(recipeModel: snapshot.data!),
                                  //recipesDetails[0]),
                                  Container(
                                    child: Preparation(
                                        recipeModel: snapshot.data!),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Hero(
                          tag: recipesDetails.image, //recipesDetails[0].image!,
                          child: ClipRRect(
                            child: Image(
                              width: double.infinity,
                              height: (size.height / 2) + 50,
                              fit: BoxFit.cover,
                              image: NetworkImage(recipesDetails
                                  .image), //NetworkImage(recipesDetails[0].image!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            FlutterIcons.back_ant,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Generic error');
          } else
            return Center(child: CircularProgressIndicator());
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Preparation extends StatelessWidget {
  const Preparation({Key? key, required this.recipeModel}) : super(key: key);

  final RecipeDetails recipeModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: recipeModel.analyzedInstructions.isNotEmpty
                  ? recipeModel.analyzedInstructions[0].steps.length
                  : 0,
              //recipeModel.extendedIngredients!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                  ),
                  child: Text(
                    recipeModel.analyzedInstructions[0].steps[index].number
                            .toString() +
                        '.'
                            ' ' +
                        recipeModel.analyzedInstructions[0].steps[index].step
                            .toString(),
                    style: robotoMedium16,
                  ), //recipeModel.extendedIngredients![index].nameClean.toString()),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Ingredients extends StatelessWidget {
  const Ingredients({Key? key, required this.recipeModel}) : super(key: key);

  final RecipeDetails recipeModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: recipeModel.extendedIngredients.length,
              //recipeModel.extendedIngredients!.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                  ),
                  child: Text(
                    '\u2022  ' +
                        recipeModel.extendedIngredients[index].nameClean
                            .capitalize(),
                    style: robotoMedium16,
                  ), //recipeModel.extendedIngredients![index].nameClean.toString()),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(color: Colors.black.withOpacity(0.3));
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension capitalizedString on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
