/* dart */
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expire_app/widgets/user_info_container.dart';
import 'package:flutter/material.dart';
/* providers */
import 'package:provider/provider.dart';

/* styles */
import '../app_styles.dart' as styles;
/* helpers */
import '../helpers/device_info.dart' as deviceInfo;
import '../helpers/firebase_auth_helper.dart';
import '../helpers/user_info.dart' as userInfo;
import '../providers/bottom_navigator_bar_size_provider.dart';

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
  FirebaseAuthHelper _auth = FirebaseAuthHelper();

  late double _barTopPadding;
  late double _barBottomPadding;
  bool _scrolling = false;
  late double _avatarRadius;
  double _emailTextHeight = 30;

  @override
  void initState() {
    _barTopPadding = _deviceInfo.isPhone ? _deviceInfo.deviceHeight * 0.045 : _deviceInfo.deviceWidth * 0.03;
    _avatarRadius = _deviceInfo.isPhone ? 35 : 45;
    _barBottomPadding = _deviceInfo.isPhone ? 20 : 20;
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
                  top: _deviceInfo.isPhonePotrait(context) || _deviceInfo.isTablet ? _barTopPadding : 0,
                  left: _deviceInfo.isPhone
                      ? 30
                      : _deviceInfo.isTabletLandscape(context)
                          ? 100
                          : 70,
                  right: _deviceInfo.isPhone
                      ? 40
                      : _deviceInfo.isTabletLandscape(context)
                          ? 110
                          : 80,
                  bottom: _barBottomPadding,
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
                            style: _scrolling
                                ? styles.subtitle
                                : _deviceInfo.isPhone
                                    ? styles.title
                                    : styles.title.copyWith(fontSize: 40),
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
                          "assets/images/croc.png",
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
                          _avatarRadius = _deviceInfo.isPhone ? 25 : 35;
                          _emailTextHeight = 0;
                        });
                        Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyShrink();
                      } else {
                        setState(() {
                          _barTopPadding =
                              _deviceInfo.isPhone ? _deviceInfo.deviceHeight * 0.045 : _deviceInfo.deviceWidth * 0.03;
                          _barBottomPadding = _deviceInfo.isPhone ? 20 : 20;
                          _scrolling = false;
                          _avatarRadius = _deviceInfo.isPhone ? 35 : 45;
                          _emailTextHeight = 30;
                        });
                        Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyGrow();
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
