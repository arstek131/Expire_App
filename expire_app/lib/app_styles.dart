import 'package:flutter/material.dart';
import './size_configs.dart';

/* fonts */
const circular = 'Circular';
const sanFrancisco = 'SanFrancisco';

const currentFontFamily = circular;

/* colors */
const Color ghostWhite = Color(0xFFF8F8FF);
const Color catchyBlue = Color(0xFF5353FF);
const Color deepIndigo = Color(0xFF023e7d);
Color deepOrange = Colors.orange.shade700;
Color deepGreen = Colors.green.shade600;
Color lightIndigo = secondaryColor.withOpacity(0.95);

const Color primaryColor = catchyBlue;
const Color secondaryColor = Colors.indigoAccent;
const Color tertiaryColor = Colors.amber;
const Color kSecondaryColor = Colors.black;
const Color kTertiaryColor = Colors.indigo;

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
  fontSize: 30,
  fontFamily: currentFontFamily,
  fontWeight: FontWeight.bold,
);

const TextStyle subtitle = TextStyle(
  color: ghostWhite,
  fontSize: 24,
  fontFamily: currentFontFamily,
  fontWeight: FontWeight.bold,
);

const TextStyle heading = TextStyle(
  color: ghostWhite,
  fontSize: 20,
  fontFamily: currentFontFamily,
  fontWeight: FontWeight.w200,
);

const TextStyle subheading = TextStyle(
  color: ghostWhite,
  fontSize: 15,
  fontFamily: currentFontFamily,
  fontWeight: FontWeight.w200,
);

const TextStyle robotoMedium16 = TextStyle(
  color: Colors.black,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
  fontSize: 16,
);
