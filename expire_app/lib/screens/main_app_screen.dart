/* Dart */
import 'package:flutter/material.dart';

/* Widgets */
import '../widgets/custom_bottom_navigation_bar.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/* Screens */
import '../screens/products_overview_screen.dart';

/* helpers */
import '../helpers/sign_in_method.dart';

class MainAppScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<MainAppScreen> {
  /* Variables */
  var _pageIndex = 2;
  final pageController = PageController(initialPage: 2);
  List<Map<String, dynamic>> _pages = [];

  /* Class methods */
  void _bottomNavigationBarHandler(index) {
    setState(() {
      _pageIndex = index;
    });
    pageController.jumpToPage(index);
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
            onPressed: () async {
              //Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);
              //Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              final auth = Provider.of<AuthProvider>(context, listen: false);

              print(auth.signInMethod);
              switch (auth.signInMethod) {
                case SignInMethod.EmailAndPassword:
                  await auth.logout();
                  break;
                case SignInMethod.Google:
                  auth.googleLogout();
                  break;
                default:
                  print(auth.signInMethod);
                  throw Exception("Something went wrong during log-out");
                  break;
              }
            },
          ),
        ),
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
