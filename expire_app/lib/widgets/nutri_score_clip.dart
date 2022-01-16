import 'package:flutter/material.dart';

import '../app_styles.dart' as styles;

class NutriScoreClip extends StatelessWidget {
  final String? nutriscore;
  late Color nutriColor;

  NutriScoreClip({required this.nutriscore}) {
    if (nutriscore == null) {
      nutriColor = Colors.grey;
      return;
    }

    switch (nutriscore!.toUpperCase()) {
      case 'A':
        nutriColor = Colors.green.shade900;
        break;
      case 'B':
        nutriColor = Colors.green.shade300;
        break;
      case 'C':
        nutriColor = Colors.yellow.shade600;
        break;
      case 'D':
        nutriColor = Colors.orange.shade600;
        break;
      case 'E':
        nutriColor = Colors.red.shade700;
        break;
      default:
        nutriColor = Colors.grey;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Card(
        color: nutriColor,
        elevation: 20,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
          child: Text(
            (nutriscore == null ||
                    ![
                      'A',
                      'B',
                      'C',
                      'D',
                      'E',
                    ].contains(nutriscore!.toUpperCase()))
                ? "N/A"
                : nutriscore!.toUpperCase(),
            style: nutriscore == null ? styles.subtitle : styles.title,
          ),
        ),
      ),
    );
  }
}
