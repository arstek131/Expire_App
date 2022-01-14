/* dart */
import 'dart:ffi';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:expire_app/app_styles.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../enums/sign_in_method.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_lorem/flutter_lorem.dart';

import 'dart:ui' as ui;

/* providers */
import '../../providers/auth_provider.dart';

import '../../helpers/firestore_helper.dart';

class UserInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double contextWidth = size.width;
    double width = (contextWidth - 53 - 10 - 10) / 2;
    double height = 152;
    return Padding(
      padding: const EdgeInsets.fromLTRB(27, 10, 26, 10),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            actions: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircleAvatar(
                  backgroundImage: ExactAssetImage("assets/images/sorre.png"),
                ),
              ),
            ],
            leading: Text(
              "Hi, Ale!",
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(30),
              child: Align(
                child: Text('vaffancul@mail.com'),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Div(
                    text: 'Account',
                    subtext: 'Adjust account settings to your needs'),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 3),
                    CustomBtn2(
                      buttonHeight: height,
                      buttonWidth: width,
                      imageWidth: 75,
                      imageHeigth: 70,
                      txtcolor: Colors.black,
                      gradientColors: [
                        HexColor("#7DC8E7"),
                        HexColor("#7DC8E7")
                      ],
                      text: 'Completed',
                      imagePath: 'assets/icons/imac_icon.png',
                      alB: Alignment.centerLeft,
                      alE: Alignment.centerRight,
                    ),
                    SizedBox(width: 10),
                    CustomBtn2(
                      buttonHeight: 116,
                      buttonWidth: width,
                      imageWidth: 28,
                      imageHeigth: 28,
                      txtcolor: Colors.white,
                      gradientColors: [
                        HexColor("##7D88E7"),
                        HexColor("#7D88E7").withAlpha(74)
                      ],
                      text: 'Change name',
                      imagePath: 'assets/icons/time_Square.png',
                      //45 degrees gradient
                      alB: Alignment(-1.0, -4.0),
                      alE: Alignment(1.0, 4.0),
                    ),
                    SizedBox(width: 3),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Div(
                    text: 'Family',
                    subtext: 'Manage synchronization with family members'),
                SizedBox(height: 20),
                //AddMemberButton(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 3),
                    CustomBtn(
                      buttonHeight: height,
                      buttonWidth: width,
                      imageWidth: 75,
                      imageHeigth: 70,
                      gradientColors: [
                        HexColor("#6DB5CB"),
                        HexColor("#7DC8E7")
                      ],
                      text: 'Share family',
                      imagePath: 'assets/icons/imac_icon.png',
                      callback: () async {
                        try {
                          String? familyid = await FirestoreHelper.instance
                              .getFamilyIdFromUserId(
                                  userId: FirebaseAuthHelper.instance.userId!);
                          print(familyid);
                          MaterialPageRoute materialPageRoute =
                              new MaterialPageRoute(
                            builder: (context) => Mytry(
                              familyid: familyid!,
                            ),
                          );
                          Navigator.of(context).push(materialPageRoute);
                        } catch (error) {
                          const errorMessage =
                              'Could not generate QR.. Please try again later';
                          print(errorMessage);
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    CustomBtn(
                      buttonHeight: 116,
                      buttonWidth: width,
                      imageWidth: 28,
                      imageHeigth: 28,
                      gradientColors: [
                        HexColor("#FE7235"),
                        HexColor("#F97D47")
                      ],
                      text: 'Leave family',
                      //TODO evaluate whether to show dynamically
                      imagePath: 'assets/icons/Close_Square.png',
                      callback: () {
                        print("un cazz");
                      },
                    ),
                    SizedBox(width: 3),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 3),
                    CustomBtn(
                      buttonHeight: height,
                      buttonWidth: width,
                      imageWidth: 28,
                      imageHeigth: 28,
                      gradientColors: [
                        HexColor("#5751FF"),
                        HexColor("#5751FF")
                      ],
                      text: 'Family info',
                      imagePath: 'assets/icons/Close_Square.png',
                      callback: () {
                        print("un cazz2");
                      },
                    ),
                    SizedBox(width: 10),
                    CustomBtn(
                      buttonHeight: height,
                      buttonWidth: width,
                      imageWidth: 75,
                      imageHeigth: 70,
                      gradientColors: [
                        HexColor("#5751FF"),
                        HexColor("#5751FF")
                      ],
                      text: 'Join family',
                      imagePath: 'assets/icons/imac_icon.png',
                      callback: () {
                        print("un cazz3");
                      },
                    ),
                    SizedBox(width: 3),
                  ],
                ),
                /*CustomBtn(
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  buttonHeight: 120,
                  // TODO set heigth
                  buttonWidth: (contextWidth - 63),
                  imageWidth: 28,
                  imageHeigth: 28,
                  gradientColors: [HexColor("#5751FF"), HexColor("#5751FF")],
                  text: 'Change family\nmember names',
                  imagePath: 'assets/icons/time_Square.png',
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
                  press: () => showAboutDialog(
                      context: context,
                      applicationVersion: "1.0",
                      applicationLegalese: lorem(words: 30)),
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
                    Navigator.of(context).pushReplacementNamed('/');
                    FirebaseAuthHelper.instance.logOut();
                  },
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Mytry extends StatelessWidget {
  final String familyid;

  const Mytry({Key? key, required this.familyid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Codice qr"),
        centerTitle: true,
      ),
      body: Center(
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
                ),
                Container(
                  color: Colors.white,
                  width: 60,
                  height: 60,
                  child: const FlutterLogo(),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Text(
              familyid,
              style: robotoMedium16,
            )
          ],
        ),
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

class Div extends StatelessWidget {
  final String text;
  final String subtext;

  const Div({
    Key? key,
    required this.text,
    required this.subtext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: HexColor('#12175E'),
            ),
          ),
          Flexible(
            child: Text(
              subtext,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: robotoMedium16.copyWith(
                color: HexColor('#575757'),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
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

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class CustomBtn extends StatelessWidget {
  final List<Color> gradientColors;
  final Color bgcolor;
  final String text;
  final double imageWidth;
  final double imageHeigth;
  final double buttonWidth;
  final double buttonHeight;
  final String imagePath;
  final EdgeInsets margin;
  final VoidCallback callback;

  const CustomBtn({
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
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      /*onTap: () async {
        print('prova');
        String? familyid = await FirestoreHelper.instance.getFamilyIdFromUserId(userId: FirebaseAuthHelper.instance.userId!);
        print(familyid);
      },
       */
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
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
                    style: robotoMedium16.copyWith(color: Colors.white),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('prova');
      },
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
                    style: robotoMedium16.copyWith(color: txtcolor),
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
