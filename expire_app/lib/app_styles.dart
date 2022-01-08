import 'package:flutter/material.dart';
import './size_configs.dart';

/* text styles */
final kTitle = TextStyle(
  fontFamily: 'SanFrancisco',
  fontSize: SizeConfig.blockSizeH! * 7,
  color: kSecondaryColor,
);

final kBodyText1 = TextStyle(
  color: kSecondaryColor,
  fontSize: SizeConfig.blockSizeH! * 4.5,
  fontWeight: FontWeight.bold,
);

const TextStyle title = TextStyle(
  color: ghostWhite,
  fontSize: 28,
  fontFamily: 'SanFrancisco',
  fontWeight: FontWeight.bold,
);

const TextStyle subheading = TextStyle(
  color: ghostWhite,
  fontSize: 15,
  fontFamily: 'SanFrancisco',
  fontWeight: FontWeight.bold,
);

const TextStyle robotoMedium16 = TextStyle(
  color: Colors.black,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
  fontSize: 16,
);

/* colors */
const Color primaryColor = Color(0xFF5353FF);
const Color kSecondaryColor = Colors.black;
const Color kTertiaryColor = Colors.indigo;
const Color ghostWhite = Color(0xFFF8F8FF);
