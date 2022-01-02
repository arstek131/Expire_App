import 'package:flutter/material.dart';
import './size_configs.dart';

Color kPrimaryColor = Colors.indigoAccent;
Color kSecondaryColor = Colors.black;
Color kTertiaryColor = Colors.indigo;

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