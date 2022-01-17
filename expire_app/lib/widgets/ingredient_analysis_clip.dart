import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app_styles.dart' as styles;
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;

enum Type { PALM_OIL, VEGETARIAN, VEGAN }
enum Free { FREE, MAYBE, NOT, UNKNOWN }

class IngredientAnalysisClip extends StatelessWidget {
  IngredientAnalysisClip(this.isXfree);

  String? isXfree;
  late String displayString;
  late Type type;
  late Free free;

  @override
  Widget build(BuildContext context) {
    if (isXfree == null) {
      return Container();
    } else {
      displayString = toBeginningOfSentenceCase(isXfree!.replaceAll("_", " ").toLowerCase())!;

      if (isXfree!.contains("PALM")) {
        type = Type.PALM_OIL;
      } else if (isXfree!.contains("VEGAN")) {
        type = Type.VEGAN;
      } else {
        type = Type.VEGETARIAN;
      }

      if (isXfree!.contains("NON")) {
        free = Free.NOT;
      } else if (isXfree!.contains("MAYBE")) {
        free = Free.MAYBE;
      } else if (isXfree!.contains("UNKNOWN")) {
        free = Free.UNKNOWN;
      } else {
        free = Free.FREE;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          height: 40,
          color: free == Free.FREE
              ? Colors.green
              : free == Free.MAYBE
                  ? Colors.orange.shade400
                  : free == Free.NOT
                      ? Colors.red
                      : Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (type == Type.PALM_OIL)
                FaIcon(
                  FontAwesomeIcons.tint,
                  color: styles.ghostWhite.withOpacity(0.9),
                )
              else if (type == Type.VEGAN)
                FaIcon(
                  FontAwesomeIcons.carrot,
                  color: styles.ghostWhite.withOpacity(0.9),
                )
              else
                FaIcon(
                  FontAwesomeIcons.egg,
                  color: styles.ghostWhite.withOpacity(0.9),
                ),
              SizedBox(width: 7),
              Text(
                displayString,
                style: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  color: styles.ghostWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
