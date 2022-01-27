import 'package:flutter/material.dart';
import 'package:googleapis/workflowexecutions/v1.dart';

/* helpers */
import '../helpers/firebase_auth_helper.dart';

/* styles */
import '../app_styles.dart' as styles;

class StatisticsContainer extends StatefulWidget {
  StatisticsContainer();

  @override
  _StatisticsContainerState createState() => _StatisticsContainerState();
}

class _StatisticsContainerState extends State<StatisticsContainer> {
  FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;

  @override
  Widget build(BuildContext context) {
    if (!_auth.isAuth) {
      return Stack(
        children: [
          Positioned.fill(
              // replace with blurred image
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.red,
              )),
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            alignment: Alignment.center,
            title: Text(
              "Premium feature",
              textAlign: TextAlign.center,
            ),
            content: Text(
              "This is a premium feature! Please register to fully unlock the functionalities of the app",
              textAlign: TextAlign.center,
            ),
            titleTextStyle: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            contentTextStyle: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontSize: 16,
            ),
            backgroundColor: styles.deepAmber,
          ),
        ],
      );
    }
    return Container();
  }
}
