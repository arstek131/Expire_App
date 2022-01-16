import 'package:flutter/material.dart';
import '../app_styles.dart' as styles;

class ShoppingListDetail extends StatefulWidget {
  const ShoppingListDetail();

  @override
  _ShoppingListDetailState createState() => _ShoppingListDetailState();
}

class _ShoppingListDetailState extends State<ShoppingListDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator.adaptive(
              strokeWidth: 2,
              backgroundColor: styles.ghostWhite,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Loading shopping lists...",
              style: styles.heading,
            )
          ],
        ),
      ),
    );
  }
}
