/* dart */
import 'package:expire_app/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* helpers */
import '../helpers/firebase_auth_helper.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/device_info.dart' as deviceInfo;
import '../helpers/user_info.dart' as userInfo;

/* providers */
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/products_provider.dart';

/* widgets */
import '../widgets/sign_up.dart';

/* screens */
//import 'package:expire_app/screens/family_info_screen.dart';
import 'package:expire_app/screens/user_info_screen.dart';

/* styles */
import '../app_styles.dart' as styles;

class UserInfoContainer extends StatefulWidget {
  const UserInfoContainer();

  @override
  _UserInfoContainerState createState() => _UserInfoContainerState();
}

class _UserInfoContainerState extends State<UserInfoContainer> {
  deviceInfo.DeviceInfo _deviceInfo = deviceInfo.DeviceInfo.instance;
  FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;
  userInfo.UserInfo _userInfo = userInfo.UserInfo.instance;

  bool _isLeavingFamily = false;
  bool _isMergingFamily = false;

  Future<void> _logout() async {
    //Navigator.of(context).pushReplacementNamed('/');
    await Provider.of<ProductsProvider>(context, listen: false).cleanProviderState();
    await Provider.of<ShoppingListProvider>(context, listen: false).cleanProviderState();

    if (FirebaseAuthHelper.instance.isAuth) {
      FirebaseAuthHelper.instance.logOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              SectionDivider(text: 'Account', subtext: 'Adjust account settings to your needs'),
              /*Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 3),
                  CustomBtn2(
                    buttonHeight: height,
                    buttonWidth: width,
                    imageWidth: 75,
                    imageHeigth: 70,
                    txtcolor: Colors.black,
                    gradientColors: [HexColor("#7DC8E7"), HexColor("#7DC8E7")],
                    text: 'Completed',
                    imagePath: 'assets/icons/imac_icon.png',
                    alB: Alignment.centerLeft,
                    alE: Alignment.centerRight,
                    callback: () {},
                  ),
                  SizedBox(width: 10),
                  CustomBtn2(
                    buttonHeight: 116,
                    buttonWidth: width,
                    imageWidth: 28,
                    imageHeigth: 28,
                    txtcolor: Colors.white,
                    gradientColors: [HexColor("##7D88E7"), HexColor("#7D88E7").withAlpha(74)],
                    text: 'Change name',
                    imagePath: 'assets/icons/time_Square.png',
                    //45 degrees gradient
                    alB: Alignment(-1.0, -4.0),
                    alE: Alignment(1.0, 4.0),
                    callback: () async {
                      _changeDisplayName(context);
                    },
                  ),
                ],
              ),*/
              SectionDivider(
                text: 'Family',
                subtext: 'Manage synchronization with family members',
                icon: Icon(
                  Icons.family_restroom,
                  color: styles.ghostWhite,
                  size: 30,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 3),
                  CustomBtn(
                    buttonHeight: 250,
                    buttonWidth: _deviceInfo.deviceWidth / 2.5, //150,
                    imageWidth: 75,
                    imageHeigth: 70,
                    bgcolor: Color(0xFF6DB5CB),
                    text: 'Share family',
                    imagePath: 'assets/icons/imac_icon.png',
                    callback: () async {
                      _shareFamily(context);
                    },
                    icon: Icon(
                      Icons.mobile_screen_share_outlined,
                      color: styles.ghostWhite,
                      size: 50,
                    ),
                  ),
                  SizedBox(width: 5),
                  Column(
                    children: [
                      CustomBtn(
                        buttonHeight: 116,
                        buttonWidth: _deviceInfo.deviceWidth / 2.5,
                        imageWidth: 28,
                        imageHeigth: 28,
                        bgcolor: Color(0xFFFE7235),
                        text: 'Leave family',
                        imagePath: 'assets/icons/Close_Square.png',
                        icon: FaIcon(
                          FontAwesomeIcons.signOutAlt,
                          color: styles.ghostWhite,
                          size: 35,
                        ),
                        callback: () async {
                          _leaveFamily(context);
                        },
                      ),
                      SizedBox(height: 5),
                      CustomBtn(
                        buttonHeight: 116,
                        buttonWidth: _deviceInfo.deviceWidth / 2.5,
                        imageWidth: 28,
                        imageHeigth: 28,
                        bgcolor: styles.deepGreen,
                        text: 'Join family',
                        imagePath: 'assets/icons/Close_Square.png',
                        icon: FaIcon(
                          FontAwesomeIcons.signInAlt,
                          color: styles.ghostWhite,
                          size: 35,
                        ),
                        callback: () async {
                          _joinFamily(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              /*SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 3),
                  CustomBtn(
                    buttonHeight: height,
                    buttonWidth: width,
                    imageWidth: 28,
                    imageHeigth: 28,
                    gradientColors: [HexColor("#5751FF"), HexColor("#5751FF")],
                    text: 'Family info',
                    imagePath: 'assets/icons/Close_Square.png',
                    callback: () async {
                      dynamic resultant = await FamilyInfoScreen.getFamilyList();
                      if (resultant is bool) {
                        UserInfoScreen.showErrorDialog(context, 'You don\'t have a family!', 'Attention');
                      } else {
                        Map<String, dynamic> res = resultant as Map<String, dynamic>;
                        MaterialPageRoute materialPageRoute = new MaterialPageRoute(
                          builder: (context) => FamilyInfoScreen(
                            famusers: res['users'],
                            familyid: res['familyid'],
                          ),
                        );
                        Navigator.of(context).push(materialPageRoute);
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  CustomBtn(
                    buttonHeight: height,
                    buttonWidth: width,
                    imageWidth: 75,
                    imageHeigth: 70,
                    gradientColors: [HexColor("#5751FF"), HexColor("#5751FF")],
                    text: 'Join family',
                    imagePath: 'assets/icons/imac_icon.png',
                    callback: () async {
                      dynamic resultant = await FamilyInfoScreen.getFamilyList();
                      if (resultant is bool) {
                        SignUp.showFamilyRedeemModal(
                            context,
                            {
                              'email': '',
                              'password': '',
                              'familyId': null,
                            },
                            () {},
                            () {});
                      } else {
                        UserInfoScreen.showErrorDialog(context, 'You can\'t join another family!', 'Attention');
                      }
                    },
                  ),
                  SizedBox(width: 3),
                ],
              ),*/
              SizedBox(
                height: 40,
              ),
              LastMenu(
                text: "Favourite",
                press: () {},
              ),
              LastMenu(
                text: "Legal Notes",
                press: () => showAboutDialog(context: context, applicationVersion: "1.0", applicationLegalese: lorem(words: 30)),
              ),
              LastMenu(
                text: "Settings and Privacy",
                press: () {},
              ),
              LastMenu(
                text: "Help",
                press: () {},
              ),
              ElevatedButton(
                child: Text("LOGOUT"),
                onPressed: () async {
                  await _logout();
                },
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
        if (_isLeavingFamily || _isMergingFamily)
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: styles.ghostWhite,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  _isLeavingFamily ? "Leaving family..." : "Merging family...",
                  style: styles.subtitle,
                ),
              ],
            ),
          )
      ],
    );
  }

  Future<void> _changeDisplayName(BuildContext context) async {
    await FirebaseAuthHelper.instance.setDisplayName("uuuu");
    setState(() {});
  }

  Future<void> _shareFamily(BuildContext context) async {
    if (!_auth.isAuth) {
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
              title: Text("Not registered", textAlign: TextAlign.center),
              body: Text(
                "Please register to fully unlock the functionalities of the app",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Okay",
                          style: styles.heading,
                        ))),
              ]);
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          height: _deviceInfo.deviceHeight,
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          color: styles.primaryColor,
          child: Center(
            child: ShareFamFunQR(
              familyid: _userInfo.familyId!,
            ),
          ),
        );
      },
    );
  }

  Future<void> _leaveFamily(BuildContext context) async {
    /* not registered */
    if (!_auth.isAuth) {
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            title: Text("Not registered", textAlign: TextAlign.center),
            body: Text(
              "Please register to fully unlock the functionalities of the app",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Okay",
                        style: styles.heading,
                      ))),
            ],
          );
        },
      );
      return;
    }

    /* no other members */
    final usersId = await FirestoreHelper.instance.getUsersFromFamilyId(familyId: _userInfo.familyId!);
    if (usersId.length == 1) {
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            title: Text("Cannot leave family", textAlign: TextAlign.center),
            body: Text(
              "You can't leave the family because you are the only member!",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Okay",
                        style: styles.heading,
                      ))),
            ],
          );
        },
      );
      return;
    }

    /* leave family */
    bool choice = await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              title: const Text(
                "Leaving family",
              ),
              content: const Text(
                "Are you sure you wish to leave this current family?",
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
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
              actions: <Widget>[
                TextButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.signOutAlt,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  label: Text(
                    "LEAVE",
                    style: TextStyle(
                      fontFamily: styles.currentFontFamily,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.undoAlt,
                    color: styles.ghostWhite,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  label: const Text(
                    "CANCEL",
                    style: TextStyle(
                      fontFamily: styles.currentFontFamily,
                      color: styles.ghostWhite,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (choice) {
      setState(() {
        _isLeavingFamily = true;
      });
      await FirestoreHelper.instance.leaveFamily();

      setState(() {
        _isLeavingFamily = false;
      });

      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            title: Text("Logout", textAlign: TextAlign.center),
            body: Text(
              "You will be logged out. Please sign in again",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Okay",
                        style: styles.heading,
                      ))),
            ],
          );
        },
      );

      _logout();
    }
  }

  Future<void> _joinFamily(BuildContext context) async {
    /* not registered */
    if (!_auth.isAuth) {
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            title: Text("Not registered", textAlign: TextAlign.center),
            body: Text(
              "Please register to fully unlock the functionalities of the app",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        "Okay",
                        style: styles.heading,
                      ))),
            ],
          );
        },
      );
      return;
    }

    /* no other members */
    bool singleMember = (await FirestoreHelper.instance.getUsersFromFamilyId(familyId: _userInfo.familyId!)).length == 1;
    if (!singleMember) {
      bool choice = await showDialog(
            context: context,
            builder: (BuildContext ctx) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                title: const Text(
                  "WARNING",
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  "You already belong to a family. By continuing you will leave this family first.",
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.spaceAround,
                titleTextStyle: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
                contentTextStyle: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  fontSize: 16,
                ),
                backgroundColor: styles.secondaryColor,
                actions: <Widget>[
                  TextButton.icon(
                    icon: FaIcon(
                      FontAwesomeIcons.checkCircle,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                    label: Text(
                      "I UNDERSTAND",
                      style: TextStyle(
                        fontFamily: styles.currentFontFamily,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: FaIcon(
                      FontAwesomeIcons.undoAlt,
                      color: styles.ghostWhite,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    label: const Text(
                      "CANCEL",
                      style: TextStyle(
                        fontFamily: styles.currentFontFamily,
                        color: styles.ghostWhite,
                      ),
                    ),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!choice) {
        return;
      }
    }

    /* leave family */
    bool? mergeProducts = await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: const Text(
            "Merge products",
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "Do you want to move your current products and shopping lists into the new family?\n\nNote: all products associated to your name will be deleted from this family",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
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
          actions: <Widget>[
            TextButton.icon(
              icon: FaIcon(
                FontAwesomeIcons.timesCircle,
                color: styles.ghostWhite,
              ),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              label: Text(
                "DON'T MERGE",
                style: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  color: styles.ghostWhite,
                ),
              ),
            ),
            TextButton.icon(
              icon: FaIcon(
                FontAwesomeIcons.objectGroup,
                color: styles.ghostWhite,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              label: const Text(
                "MERGE",
                style: TextStyle(
                  fontFamily: styles.currentFontFamily,
                  color: styles.ghostWhite,
                ),
              ),
            ),
          ],
        );
      },
    );

    // clicked outside of alert
    if (mergeProducts == null) {
      return;
    }

    setState(() {
      _isMergingFamily = true;
    });

    FirestoreHelper.instance.mergeFamilies(
      familyId: "oTgLpbXDsdfDhxWdb36Q",
      mergeProducts: mergeProducts,
      singleMember: singleMember,
    );

    setState(() {
      _isMergingFamily = false;
    });

    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CustomDialog(
          title: Text("Logout", textAlign: TextAlign.center),
          body: Text(
            "You will be logged out. Please sign in again",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "Okay",
                      style: styles.heading,
                    ))),
          ],
        );
      },
    );

    _logout();
  }
}

class ShareFamFunQR extends StatelessWidget {
  final String familyid;

  const ShareFamFunQR({Key? key, required this.familyid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: styles.ghostWhite,
        borderRadius: BorderRadius.circular(25.0),
      ),
      height: 300,
      width: 300,
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              BarcodeWidget(
                barcode: Barcode.qrCode(
                  errorCorrectLevel: BarcodeQRCorrectionLevel.high,
                ),
                data: familyid,
                width: 200,
                height: 200,
                color: Colors.black,
              ),
              Container(
                color: styles.ghostWhite,
                width: 60,
                height: 60,
                child: const FlutterLogo(),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SelectableText(
            familyid,
            style: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}

class LastMenu extends StatelessWidget {
  const LastMenu({
    Key? key,
    required this.text,
    required this.press,
  }) : super(key: key);

  final String text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: press,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      title: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
        size: 13,
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  final String text;
  final String subtext;
  final dynamic icon;

  const SectionDivider({
    required this.text,
    required this.subtext,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                text,
                style: styles.subtitle,
              ),
              SizedBox(width: 8),
              icon ?? Container(),
            ],
          ),
          Flexible(
            child: Text(
              subtext,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: styles.subheading,
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderArea extends StatelessWidget {
  const HeaderArea({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.2,
      child: Stack(children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 16 + 20,
          ),
          height: size.height * 0.2 - 27,
          decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              )),
          child: Container(),
        )
      ]),
    );
  }
}

class CustomBtn extends StatelessWidget {
  final Color bgcolor;
  final String text;
  final double imageWidth;
  final double imageHeigth;
  final double buttonWidth;
  final double buttonHeight;
  final String imagePath;
  final EdgeInsets margin;
  final VoidCallback callback;
  final dynamic icon;

  const CustomBtn({
    Key? key,
    required this.bgcolor,
    required this.text,
    required this.imageHeigth,
    required this.imageWidth,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.imagePath,
    this.margin = EdgeInsets.zero,
    required this.callback,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: bgcolor,
        child: SizedBox(
          height: buttonHeight,
          width: buttonWidth,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*Container(
                  height: imageHeigth,
                  width: imageWidth,
                  child: Image.asset(imagePath),
                  margin: EdgeInsets.only(bottom: 8.0),
                ),*/
                icon,
                SizedBox(height: 8),
                Text(
                  text,
                  style: styles.subheading.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBtn2 extends StatelessWidget {
  final List<Color> gradientColors;
  final Color bgcolor;
  final Color txtcolor;
  final String text;
  final double imageWidth;
  final double imageHeigth;
  final double buttonWidth;
  final double buttonHeight;
  final String imagePath;
  final EdgeInsets margin;
  final AlignmentGeometry alB;
  final AlignmentGeometry alE;
  final VoidCallback callback;

  const CustomBtn2({
    Key? key,
    this.bgcolor = Colors.transparent,
    required this.text,
    required this.imageHeigth,
    required this.imageWidth,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.imagePath,
    this.margin = EdgeInsets.zero,
    this.gradientColors = const [],
    required this.alB,
    required this.alE,
    required this.txtcolor,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      highlightColor: Colors.white,
      child: Container(
        margin: margin,
        height: buttonHeight,
        width: buttonWidth,
        padding: EdgeInsets.fromLTRB(14, 21, 7.5, 21),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(14.0)),
          gradient: LinearGradient(
            begin: alB,
            end: alE,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, 0),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Container(
                    height: imageHeigth,
                    width: imageWidth,
                    child: Image.asset(imagePath),
                  ),
                  SizedBox(height: 8),
                  Text(
                    text,
                    style: styles.heading.copyWith(color: txtcolor),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
