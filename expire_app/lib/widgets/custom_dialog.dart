import 'package:flutter/material.dart';
import '../app_styles.dart' as styles;

class CustomDialog extends StatelessWidget {
  const CustomDialog({required this.title, required this.body, this.actions});
  final Widget title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      alignment: Alignment.center,
      title: title,
      content: body,
      titleTextStyle: TextStyle(
        fontFamily: styles.currentFontFamily,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      contentTextStyle: TextStyle(
        fontFamily: styles.currentFontFamily,
        fontSize: 16,
      ),
      backgroundColor: styles.primaryColor,
      actions: actions,
    );
  }
}
