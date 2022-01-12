/* Dart */
import 'package:expire_app/app_styles.dart';
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';
import 'dart:math' as math;

/* Widgets */
import '../widgets/custom_bottom_navigation_bar.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../helpers/user_info.dart';

/* Screens */
import '../screens/products_overview_screen.dart';
import '../screens/user_info_screen.dart';
import '../screens/name_input_screen.dart';

/* helpers */
import '../enums/sign_in_method.dart';

class MainAppScreen extends StatefulWidget {
  static const routeName = '/main-app-screen';
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<MainAppScreen> {
  FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper.instance;

  /* Variables */
  var _pageIndex = 2;
  final pageController = PageController(initialPage: 2);

  List<Map<String, dynamic>> _pages = [];

  /* Class methods */
  void _bottomNavigationBarHandler(int newIndex) {
    int oldIndex = _pageIndex;

    setState(() {
      _pageIndex = newIndex;
    });

    // avoid long sliding between pageviews
    if ((newIndex - oldIndex).abs() == 1) {
      pageController.animateToPage(newIndex, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    } else {
      pageController.jumpToPage(newIndex);
    }
  }

  @override
  void initState() {
    _pages = [
      {
        'page': Center(
          child: Text(firebaseAuthHelper.displayName ?? "null"),
        ),
        'title': "Recipes",
      },
      {
        'page': const Center(
          child: Text("test1"),
        ),
        'title': "Shopping list",
      },
      {
        'page': ProductsOverviewScreen(),
        'title': "Products",
      },
      {
        'page': const Center(
          child: Text("test3"),
        ),
        'title': "Analytics",
      },
      {
        'page': UserInfoScreen(),
        'title': "User settings",
      },
    ];

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  late final Future? initUserInfoProvider = UserInfo.instance.initUserInfoProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SizedBox(
        child: SafeArea(
          top: true,
          child: Scaffold(
            body: FutureBuilder(
              future: initUserInfoProvider,
              builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Stack(
                      children: [
                        PageView(
                          //physics: BouncingScrollPhysics(),
                          controller: pageController,
                          children: _pages.map<Widget>((pageElement) => pageElement['page']).toList(),
                          onPageChanged: (index) => setState(
                            () {
                              _pageIndex = index;
                            },
                          ),
                        ),
                        SafeArea(
                          child: Align(
                            child: CustomBottomNavigationBar(setIndex: _bottomNavigationBarHandler, pageIndex: _pageIndex),
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
