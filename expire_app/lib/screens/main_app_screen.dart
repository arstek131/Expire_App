/* Dart */
import 'package:flutter/material.dart';

/* Widgets */
import '../widgets/custom_bottom_navigation_bar.dart';

/* Screens */
import '../screens/products_overview_screen.dart';

class MainAppScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<MainAppScreen> {
  /* Variables */
  var _pageIndex = 2;
  List<Map<String, dynamic>> _pages = [];

  /* Class methods */
  void _bottomNavigationBarHandler(index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  void initState() {
    _pages = [
      {
        'page': Center(
          child: Text("test0"),
        ),
        'title': "Recipes",
      },
      {
        'page': Center(
          child: Text("test1"),
        ),
        'title': "Shopping list",
      },
      {
        'page': ProductsOverviewScreen(),
        'title': "Products",
      },
      {
        'page': Center(
          child: Text("test3"),
        ),
        'title': "Analytics",
      },
      {
        'page': Center(
          child: Text("test4"),
        ),
        'title': "User settings",
      },
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(_pages.elementAt(_pageIndex)['title']),
      ),
      body: Stack(
        children: [
          _pages.elementAt(_pageIndex)['page'],
          SafeArea(
            child: Align(
              child: CustomBottomNavigationBar(setIndex: _bottomNavigationBarHandler, pageIndex: _pageIndex),
              alignment: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}
