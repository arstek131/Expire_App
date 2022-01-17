import 'package:flutter/material.dart';
import '../app_styles.dart' as styles;
import 'package:openfoodfacts/model/NutrientLevels.dart';

class HealthProductListTile extends StatelessWidget {
  String name;
  double? quantity;
  String symbol;
  String? level;
  late Color levelColor;

  HealthProductListTile({required this.name, required this.quantity, required this.symbol, this.level}) {
    switch (level) {
      case "HIGH":
        levelColor = Colors.red;
        break;
      case "MODERATE":
        levelColor = Colors.yellow.shade600;
        break;
      case "LOW":
        levelColor = Colors.green;
        break;
      default:
        levelColor = Colors.transparent;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            this.name,
            style: TextStyle(
              fontFamily: styles.currentFontFamily,
              color: styles.ghostWhite,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                (this.quantity == null ? 'N/A' : quantity!.toStringAsFixed(2)) + ' ${this.symbol}',
                style: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  color: styles.ghostWhite,
                  fontSize: 16,
                ),
              ),
              if (level != null && level != "UNDEFINED")
                SizedBox(
                  width: 5,
                ),
              if (level != null && level != "UNDEFINED")
                CircleAvatar(
                  backgroundColor: this.levelColor,
                  radius: 4.5,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
