/* dart */
import 'package:barcode_widget/barcode_widget.dart';
import 'package:expire_app/helpers/user_info.dart';
import 'package:expire_app/providers/dependencies_provider.dart';
import 'package:expire_app/providers/filters_provider.dart';
import 'package:expire_app/screens/family_info_screen.dart';
import 'package:expire_app/widgets/custom_dialog.dart';
import 'package:expire_app/widgets/display_name_choice_moda.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
/* providers */
import 'package:provider/provider.dart';

/* styles */
import '../app_styles.dart' as styles;
import '../helpers/device_info.dart' as deviceInfo;
/* helpers */
import '../helpers/firebase_auth_helper.dart';
import '../helpers/firestore_helper.dart';
import '../providers/products_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/family_id_choice_modal.dart';

class UserInfoContainer extends StatefulWidget {
  const UserInfoContainer();

  @override
  _UserInfoContainerState createState() => _UserInfoContainerState();
}

class _UserInfoContainerState extends State<UserInfoContainer> {
  late final firebaseAuthHelper;
  late final messaging;
  late final userInfo;
  late final auth;

  deviceInfo.DeviceInfo _deviceInfo = deviceInfo.DeviceInfo.instance;

  @override
  initState() {
    super.initState();
    auth = firebaseAuthHelper = Provider.of<DependenciesProvider>(context, listen: false).auth;
    userInfo = Provider.of<DependenciesProvider>(context, listen: false).userInfo;
    messaging = Provider.of<DependenciesProvider>(context, listen: false).messaging;
  }

  bool _isLeavingFamily = false;
  bool _isMergingFamily = false;

  Future<void> _logout() async {
    //Navigator.of(context).pushReplacementNamed('/');
    await Provider.of<ProductsProvider>(context, listen: false).cleanProviderState();
    await Provider.of<ShoppingListProvider>(context, listen: false).cleanProviderState();
    Provider.of<FiltersProvider>(context, listen: false).clearFilter();
    //Provider.of<DependenciesProvider>(context, listen: false).cleanProviderState();

    if (auth.isAuth) {
      messaging.unsubscribeFromTopic(userInfo.familyId!);
      auth.logOut();
    } else {
      auth.logOut();
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: _deviceInfo.isPhone
                  ? 30
                  : _deviceInfo.isTabletLandscape(context)
                      ? 80
                      : 60,
              vertical: 15),
          child: _deviceInfo.isTablet
              ? ListView(
                  physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SectionDivider(
                              text: 'Account',
                              subtext: 'Adjust account settings to your needs',
                              icon: Icon(
                                Icons.supervised_user_circle_rounded,
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
                                  buttonHeight: 160,
                                  buttonWidth: _deviceInfo.deviceWidth / (_deviceInfo.isLandscape(context) ? 5.5 : 8.5),
                                  imageWidth: 28,
                                  imageHeigth: 28,
                                  bgcolor: Colors.pink.shade800,
                                  text: 'Change name',
                                  imagePath: 'assets/icons/Close_Square.png',
                                  icon: FaIcon(
                                    FontAwesomeIcons.signature,
                                    color: styles.ghostWhite,
                                    size: 35,
                                  ),
                                  callback: () async {
                                    _changeDisplayName(context);
                                  },
                                ),
                                SizedBox(width: 5),
                                CustomBtn(
                                  buttonHeight: 120,
                                  buttonWidth: _deviceInfo.deviceWidth / (_deviceInfo.isLandscape(context) ? 5.5 : 8.5),
                                  imageWidth: 28,
                                  imageHeigth: 28,
                                  bgcolor: Colors.deepOrange.shade600,
                                  text: 'Delete account',
                                  imagePath: 'assets/icons/Close_Square.png',
                                  icon: FaIcon(
                                    FontAwesomeIcons.userSlash,
                                    color: styles.ghostWhite,
                                    size: 30,
                                  ),
                                  callback: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                                Column(
                                  children: [
                                    CustomBtn(
                                      buttonHeight: 220,
                                      buttonWidth: _deviceInfo.deviceWidth / (_deviceInfo.isLandscape(context) ? 5.5 : 8.5),
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
                                    CustomBtn(
                                      buttonHeight: 150,
                                      buttonWidth:
                                          _deviceInfo.deviceWidth / (_deviceInfo.isLandscape(context) ? 5.5 : 8.5), //150,
                                      imageWidth: 75,
                                      imageHeigth: 70,
                                      bgcolor: Colors.pink.shade800,
                                      text: 'Family members',
                                      imagePath: 'assets/icons/imac_icon.png',
                                      callback: () => Navigator.of(context).pushNamed(FamilyInfoScreen.routeName),
                                      icon: Icon(
                                        Icons.search,
                                        color: styles.ghostWhite,
                                        size: 50,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5),
                                Column(
                                  children: [
                                    CustomBtn(
                                      buttonHeight: 140,
                                      buttonWidth: _deviceInfo.deviceWidth / (_deviceInfo.isLandscape(context) ? 5.5 : 8.5),
                                      imageWidth: 28,
                                      imageHeigth: 28,
                                      bgcolor: Colors.deepOrange.shade600,
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
                                    CustomBtn(
                                      buttonHeight: 230,
                                      buttonWidth: _deviceInfo.deviceWidth / (_deviceInfo.isLandscape(context) ? 5.5 : 8.5),
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
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    LastMenu(
                      text: "Legal Notes",
                      press: () =>
                          showAboutDialog(context: context, applicationVersion: "1.0", applicationLegalese: lorem(words: 30)),
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    LastMenu(
                      text: "Settings and Privacy",
                      press: () {},
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    LastMenu(
                      text: "Help",
                      press: () {},
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    SizedBox(height: 40),
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
                )
              : ListView(
                  physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    SectionDivider(
                      text: 'Account',
                      subtext: 'Adjust account settings to your needs',
                      icon: Icon(
                        Icons.supervised_user_circle_rounded,
                        color: styles.ghostWhite,
                        size: 30,
                      ),
                    ),
                    if (_deviceInfo.isPhonePotrait(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 3),
                          CustomBtn(
                            buttonHeight: 160,
                            buttonWidth: _deviceInfo.deviceWidth / 2.7,
                            imageWidth: 28,
                            imageHeigth: 28,
                            bgcolor: Colors.pink.shade800,
                            text: 'Change name',
                            imagePath: 'assets/icons/Close_Square.png',
                            icon: FaIcon(
                              FontAwesomeIcons.signature,
                              color: styles.ghostWhite,
                              size: 35,
                            ),
                            callback: () async {
                              _changeDisplayName(context);
                            },
                          ),
                          SizedBox(width: 5),
                          CustomBtn(
                            buttonHeight: 120,
                            buttonWidth: _deviceInfo.deviceWidth / 2.7,
                            imageWidth: 28,
                            imageHeigth: 28,
                            bgcolor: Colors.deepOrange.shade600,
                            text: 'Delete account',
                            imagePath: 'assets/icons/Close_Square.png',
                            icon: FaIcon(
                              FontAwesomeIcons.userSlash,
                              color: styles.ghostWhite,
                              size: 30,
                            ),
                            callback: () {},
                          ),
                        ],
                      ),
                    if (_deviceInfo.isPhoneLandscape(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width: 3),
                          CustomBtn(
                            buttonHeight: 160,
                            buttonWidth: _deviceInfo.deviceWidth / 1.3,
                            imageWidth: 28,
                            imageHeigth: 28,
                            bgcolor: Colors.pink.shade800,
                            text: 'Change name',
                            imagePath: 'assets/icons/Close_Square.png',
                            icon: FaIcon(
                              FontAwesomeIcons.signature,
                              color: styles.ghostWhite,
                              size: 35,
                            ),
                            callback: () async {
                              _changeDisplayName(context);
                            },
                          ),
                          SizedBox(width: 5),
                          CustomBtn(
                            buttonHeight: 120,
                            buttonWidth: _deviceInfo.deviceWidth / 1.3,
                            imageWidth: 28,
                            imageHeigth: 28,
                            bgcolor: Colors.deepOrange.shade600,
                            text: 'Delete account',
                            imagePath: 'assets/icons/Close_Square.png',
                            icon: FaIcon(
                              FontAwesomeIcons.userSlash,
                              color: styles.ghostWhite,
                              size: 30,
                            ),
                            callback: () {},
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    SectionDivider(
                      text: 'Family',
                      subtext: 'Manage synchronization with family members',
                      icon: Icon(
                        Icons.family_restroom,
                        color: styles.ghostWhite,
                        size: 30,
                      ),
                    ),
                    if (_deviceInfo.isPhonePotrait(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 3),
                          Column(
                            children: [
                              CustomBtn(
                                buttonHeight: 220,
                                buttonWidth: _deviceInfo.deviceWidth / 2.7, //150,
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
                              CustomBtn(
                                buttonHeight: 150,
                                buttonWidth: _deviceInfo.deviceWidth / 2.7, //150,
                                imageWidth: 75,
                                imageHeigth: 70,
                                bgcolor: Colors.pink.shade800,
                                text: 'Family members',
                                imagePath: 'assets/icons/imac_icon.png',
                                callback: () => Navigator.of(context).pushNamed(FamilyInfoScreen.routeName),
                                icon: Icon(
                                  Icons.search,
                                  color: styles.ghostWhite,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 5),
                          Column(
                            children: [
                              CustomBtn(
                                buttonHeight: 140,
                                buttonWidth: _deviceInfo.deviceWidth / 2.7,
                                imageWidth: 28,
                                imageHeigth: 28,
                                bgcolor: Colors.deepOrange.shade600,
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
                              CustomBtn(
                                buttonHeight: 230,
                                buttonWidth: _deviceInfo.deviceWidth / 2.7,
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
                      )
                    else if (_deviceInfo.isPhoneLandscape(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomBtn(
                            buttonHeight: _deviceInfo.deviceHeight / 4.5,
                            buttonWidth: _deviceInfo.deviceWidth / 2.4, //150,
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
                          CustomBtn(
                            buttonHeight: 150,
                            buttonWidth: _deviceInfo.deviceWidth / 2.4, //150,
                            imageWidth: 75,
                            imageHeigth: 70,
                            bgcolor: Color(0xFFFE7235),
                            text: 'Family members',
                            imagePath: 'assets/icons/imac_icon.png',
                            callback: () => Navigator.of(context).pushNamed(FamilyInfoScreen.routeName),
                            icon: Icon(
                              Icons.search,
                              color: styles.ghostWhite,
                              size: 50,
                            ),
                          ),
                          CustomBtn(
                            buttonHeight: 200,
                            buttonWidth: _deviceInfo.deviceWidth / 2.4,
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
                          CustomBtn(
                            buttonHeight: 140,
                            buttonWidth: _deviceInfo.deviceWidth / 2.4,
                            imageWidth: 28,
                            imageHeigth: 28,
                            bgcolor: Colors.deepOrange.shade600,
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
                        ],
                      ),
                    //else
                    //...

                    SizedBox(
                      height: 40,
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    LastMenu(
                      text: "Legal Notes",
                      press: () =>
                          showAboutDialog(context: context, applicationVersion: "1.0", applicationLegalese: lorem(words: 30)),
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    LastMenu(
                      text: "Settings and Privacy",
                      press: () {},
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    LastMenu(
                      text: "Help",
                      press: () {},
                    ),
                    Divider(height: 1, color: styles.ghostWhite.withOpacity(0.7)),
                    SizedBox(height: 40),
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
    String? displayName = await showModalBottomSheet<String?>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext ctx) => DisplayNameChoiceModal(),
    );

    if (displayName == null) {
      return;
    }

    userInfo.displayName = displayName;
  }

  Future<void> _shareFamily(BuildContext context) async {
    if (!auth.isAuth) {
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
              familyid: userInfo.familyId!,
            ),
          ),
        );
      },
    );
  }

  Future<void> _leaveFamily(BuildContext context) async {
    /* not registered */
    if (!auth.isAuth) {
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
    final usersId = await FirestoreHelper().getUsersFromFamilyId(familyId: userInfo.familyId!);
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
      await FirestoreHelper().leaveFamily();

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
    if (!auth.isAuth) {
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
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    /* choose family ID */
    String? chosenFamilyId = await showModalBottomSheet<String?>(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext ctx) => FamilyIdChoiceModal(),
    );

    if (chosenFamilyId == null) {
      return;
    }

    if (chosenFamilyId == userInfo.familyId) {
      await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CustomDialog(
            title: Text("Cannot join family", textAlign: TextAlign.center),
            body: Text(
              "You cannot join your own family!",
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
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    /* no other members */
    bool singleMember = (await FirestoreHelper().getUsersFromFamilyId(familyId: userInfo.familyId!)).length == 1;
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
            "Do you want to move your current products into the new family?\n\nNote: all products associated to your name will be deleted from this family and shopping lists will remain.",
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

    FirestoreHelper().mergeFamilies(
      familyId: chosenFamilyId,
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
                child: Image(
                  image: AssetImage('assets/logo/expiry_app_logo.png'),
                ),
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
        style: styles.subheading,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: styles.ghostWhite,
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
                style: deviceInfo.DeviceInfo.instance.isPhone ? styles.subtitle : styles.title.copyWith(fontSize: 35),
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
