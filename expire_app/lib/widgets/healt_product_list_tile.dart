import 'package:flutter/material.dart';
import '../app_styles.dart' as styles;

class HealthProductListTile extends StatelessWidget {
  String name;
  double? quantity;
  String symbol;

  HealthProductListTile({required this.name, required this.quantity, required this.symbol});

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
          Text(
            (this.quantity == null ? 'N/A' : quantity!.toStringAsFixed(2)) + ' ${this.symbol}',
            style: TextStyle(
              fontFamily: styles.currentFontFamily,
              color: styles.ghostWhite,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
