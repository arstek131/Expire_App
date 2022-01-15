import 'package:expire_app/models/product.dart';
import 'package:flutter/material.dart';

/* widget */
import '../widgets/healt_product_list_tile.dart';
/* styles */
import '../app_styles.dart' as styles;

class HealthProductDetail extends StatelessWidget {
  HealthProductDetail({required this.product});

  Product product;

  @override
  Widget build(BuildContext context) {
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
              Text(
                "Score",
                style: styles.subtitle,
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: product.nutriments == null
                ? Text("No data")
                : Column(
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
                      Divider(
                        color: Colors.white12,
                        thickness: 1.5,
                      ),
                      HealthProductListTile(name: 'Energy', quantity: product.nutriments!.energyKcal, symbol: 'kcal'),
                      Divider(
                        color: Colors.white12,
                        thickness: 1.5,
                      ),
                      HealthProductListTile(name: 'Fat', quantity: product.nutriments!.energyKcal, symbol: 'g'),
                      Divider(
                        color: Colors.white12,
                        thickness: 1.5,
                      ),
                      HealthProductListTile(
                          name: 'of which acid saturated fat', quantity: product.nutriments!.saturatedFat, symbol: 'g'),
                      Divider(
                        color: Colors.white12,
                        thickness: 1.5,
                      ),
                      HealthProductListTile(name: 'Carbohydrates', quantity: product.nutriments!.carbohydrates, symbol: 'g'),
                      Divider(
                        color: Colors.white12,
                        thickness: 1.5,
                      ),
                      HealthProductListTile(name: 'of which sugar', quantity: product.nutriments!.sugars, symbol: 'g'),
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
                      HealthProductListTile(name: 'Salt', quantity: product.nutriments!.salt, symbol: 'g'),
                      Divider(
                        color: Colors.white12,
                        thickness: 1.5,
                      ),
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
                        child: Text(
                          product.ingredientsText ?? 'No ingredients data',
                          style: styles.subheading,
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
