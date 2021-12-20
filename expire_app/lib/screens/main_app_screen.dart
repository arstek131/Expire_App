/* Dart */
import 'package:flutter/material.dart';

/* Widgets */
import '../widgets/custom_bottom_navigation_bar.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
  final pageController = PageController(initialPage: 2);

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
          child: ElevatedButton(
            child: Text("LOGOUT"),
            onPressed: () {
              //Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);
              //Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
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
        //title: Text(_pages.elementAt(_pageIndex)['title']),
        centerTitle: true,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(
                size: 30,
              ),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Text(_pages.elementAt(_pageIndex)['title']),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          /*IndexedStack(
            index: _pageIndex,
            children: _pages.map<Widget>((pageElement) => pageElement['page']).toList(),
          ),*/
          PageView(
            controller: pageController,
            children: _pages.map<Widget>((pageElement) => pageElement['page']).toList(),
            onPageChanged: (value) {
              _bottomNavigationBarHandler(value);
            },
          ),
          //_pages.elementAt(_pageIndex)['page'],
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
