import 'package:expire_app/models/product.dart';
import 'package:flutter/material.dart';

/* styles */
import '../app_styles.dart' as styles;
import '../widgets/nutri_score_clip.dart';

class EcoProductDetail extends StatelessWidget {
  EcoProductDetail({required this.product});

  Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Eco",
                style: styles.subtitle,
              ),
              Row(
                children: [
                  Text(
                    "Eco-score:  ",
                    style: styles.subheading,
                  ),
                  NutriScoreClip(nutriscore: product.ecoscore)
                ],
              )
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    "Packaging:",
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
                  child: (product.packaging == null || product.packaging!.isEmpty)
                      ? Text(
                          'No packaging data',
                          style: TextStyle(
                            fontFamily: styles.currentFontFamily,
                            color: Colors.grey,
                          ),
                        )
                      : Text(
                          product.packaging!
                                  .split(",")
                                  .where((element) => element.contains("en:"))
                                  .join(", ")
                                  .replaceAll("en:", "")
                                  .isEmpty
                              ? product.packaging!
                              : product.packaging!
                                  .split(",")
                                  .where((element) => element.contains("en:"))
                                  .join(", ")
                                  .replaceAll("en:", ""),
                          style: styles.subheading,
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
