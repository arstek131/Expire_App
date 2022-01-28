/* dart */
import 'package:barcode_widget/barcode_widget.dart';
import 'package:expire_app/widgets/user_info_container.dart';
import '../helpers/user_info.dart' as userInfo;
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

/* helpers */
import '../helpers/device_info.dart' as deviceInfo;
import '../helpers/firebase_auth_helper.dart';

/* styles */
import '../app_styles.dart' as styles;
import '../app_styles.dart';

/* providers */
import '../providers/auth_provider.dart';

import '../helpers/firestore_helper.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();

  static showErrorDialog(BuildContext context, String msg, String title, {bool shouldLeave = false}) {
    Widget dismissBtn = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          if (shouldLeave) {
            Navigator.of(context).pop();
          }
        },
        child: Text('Dismiss'));
    //TODO manage platform specific error dialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [dismissBtn],
    );

    showDialog(context: context, builder: (context) => alert);
  }
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  userInfo.UserInfo _userInfo = userInfo.UserInfo.instance;
  deviceInfo.DeviceInfo _deviceInfo = deviceInfo.DeviceInfo.instance;
  FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;

  late double _barTopPadding;
  double _barBottomPadding = 20;
  bool _scrolling = false;
  double _avatarRadius = 35;
  double _emailTextHeight = 30;

  @override
  void initState() {
    _barTopPadding = _deviceInfo.deviceHeight * 0.08;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height * 0.01
                      : 10.0),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    styles.primaryColor,
                    styles.primaryColor.withOpacity(0.6),
                  ],
                  stops: [0.9, 1],
                ),
                shape: BoxShape.rectangle,
                color: Colors.pinkAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade700,
                    offset: const Offset(0, 10),
                    blurRadius: 5.0,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).orientation == Orientation.portrait ? _barTopPadding : 0,
                  left: 30,
                  right: 40,
                  bottom: MediaQuery.of(context).orientation == Orientation.portrait ? _barBottomPadding : 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: AutoSizeText(
                            "Hi ${_userInfo.displayName}!",
                            overflow: TextOverflow.fade,
                            maxLines: 2,
                            style: _scrolling ? styles.subtitle : styles.title,
                          ),
                        ),
                        if (_userInfo.email != null)
                          AnimatedContainer(
                            height: _emailTextHeight,
                            duration: const Duration(milliseconds: 120),
                            child: AnimatedOpacity(
                              opacity: _scrolling ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: Text(
                                _userInfo.email!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: styles.currentFontFamily,
                                  color: Colors.grey.shade300,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    CircleAvatar(
                      radius: _avatarRadius + 2,
                      backgroundColor: styles.deepAmber,
                      child: CircleAvatar(
                        radius: _avatarRadius,
                        backgroundImage: AssetImage(
                          "assets/images/sorre.png",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll.metrics.pixels > 10) {
                        setState(() {
                          _barTopPadding = 0;
                          _barBottomPadding = 10;
                          _scrolling = true;
                          _avatarRadius = 25;
                          _emailTextHeight = 0;
                        });
                      } else {
                        setState(() {
                          _barTopPadding = _deviceInfo.deviceHeight * 0.08;
                          _barBottomPadding = 20;
                          _scrolling = false;
                          _avatarRadius = 35;
                          _emailTextHeight = 30;
                        });
                      }
                      return true;
                    },
                    child: UserInfoContainer(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
