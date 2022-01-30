import 'package:expire_app/models/product.dart';
import 'package:expire_app/widgets/ingredient_analysis_clip.dart';
import 'package:flutter/material.dart';

/* styles */
import '../app_styles.dart' as styles;
/* widget */
import '../widgets/healt_product_list_tile.dart';
import '../widgets/nutri_score_clip.dart';

class HealthProductDetail extends StatelessWidget {
  HealthProductDetail({required this.product});

  Product product;

  @override
  Widget build(BuildContext context) {
    print(product.ingredientLevels);

    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Health",
                style: styles.subtitle,
              ),
              Row(
                children: [
                  Text(
                    "Nutri-score:  ",
                    style: styles.subheading,
                  ),
                  NutriScoreClip(nutriscore: product.nutriscore)
                ],
              )
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nutritional values",
                        style: TextStyle(
                          fontFamily: styles.sanFrancisco,
                          color: styles.ghostWhite,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "For 100g",
                        style: TextStyle(
                          fontFamily: styles.sanFrancisco,
                          color: styles.ghostWhite,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.nutriments == null)
                  Container(
                    padding: EdgeInsets.only(left: 8.0),
                    width: double.infinity,
                    child: Text(
                      'No nutriments data',
                      style: TextStyle(
                        fontFamily: styles.currentFontFamily,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else ...[
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(
                    name: 'Energy',
                    quantity: product.nutriments!.energyKcal,
                    symbol: 'kcal',
                  ),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(
                    name: 'Fat',
                    quantity: product.nutriments!.energyKcal,
                    symbol: 'g',
                    level: product.ingredientLevels?['fat'],
                  ),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(
                    name: '   of which acid saturated fat',
                    quantity: product.nutriments!.saturatedFat,
                    symbol: 'g',
                    level: product.ingredientLevels?['saturated-fat'],
                  ),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(name: 'Carbohydrates', quantity: product.nutriments!.carbohydrates, symbol: 'g'),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(
                    name: '   of which sugar',
                    quantity: product.nutriments!.sugars,
                    symbol: 'g',
                    level: product.ingredientLevels?['sugar'] ?? product.ingredientLevels?['sugars'],
                  ),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(name: 'Fibers', quantity: product.nutriments!.fiber, symbol: 'g'),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(name: 'Proteins', quantity: product.nutriments!.proteins, symbol: 'g'),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                  HealthProductListTile(
                    name: 'Salt',
                    quantity: product.nutriments!.salt,
                    symbol: 'g',
                    level: product.ingredientLevels?['salt'],
                  ),
                  Divider(
                    color: Colors.white12,
                    thickness: 1.5,
                  ),
                ],
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Ingredients",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: styles.sanFrancisco,
                      color: styles.ghostWhite,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: (product.ingredientsText == null || product.ingredientsText!.isEmpty)
                      ? Text(
                          'No ingredients data',
                          style: TextStyle(
                            fontFamily: styles.currentFontFamily,
                            color: Colors.grey,
                          ),
                        )
                      : Text(
                          product.ingredientsText!,
                          style: styles.subheading,
                        ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Allergies or intolerances",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: styles.sanFrancisco,
                      color: styles.ghostWhite,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.0),
                  width: double.infinity,
                  child: (product.allergens == null || product.allergens!.isEmpty)
                      ? Text(
                          'No allergies or intolerances data',
                          style: TextStyle(
                            fontFamily: styles.currentFontFamily,
                            color: Colors.grey,
                          ),
                        )
                      : Text(
                          product.allergens!.join(", "),
                          style: styles.subheading,
                        ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: Text(
                    "Ingredients analysis",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: styles.sanFrancisco,
                      color: styles.ghostWhite,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (product.isPalmOilFree == null && product.isVegan == null && product.isVegetarian == null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No allergies or intolerances data',
                      style: TextStyle(
                        fontFamily: styles.currentFontFamily,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                    width: double.infinity,
                    child: Wrap(
                      children: [
                        IngredientAnalysisClip(product.isVegan),
                        SizedBox(width: 4),
                        IngredientAnalysisClip(product.isPalmOilFree),
                        SizedBox(width: 4),
                        IngredientAnalysisClip(product.isVegetarian),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
