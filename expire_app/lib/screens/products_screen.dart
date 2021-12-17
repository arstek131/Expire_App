import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  static const routeName = '/';
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  /* Variables */
  var _bottom_navigation_bar_index = 0;
  List<Map<String, dynamic>> _pages = [];

  /* Class methods */
  void _bottomNavigationBarHandler(index) {
    setState(() {
      _bottom_navigation_bar_index = index;
    });
  }

  @override
  void initState() {
    _pages = [
      {
        'page': const Icon(Icons.call, size: 150),
      },
      {
        'page': const Icon(Icons.camera, size: 150),
      },
      {
        'page': const Icon(Icons.call, size: 150),
      },
      {
        'page': const Icon(Icons.call, size: 150),
      },
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Expire app"),
      ),
      body: Center(
        child: _pages.elementAt(_bottom_navigation_bar_index)['page'],
      ),
      bottomNavigationBar: BottomAppBar(
        /*type: BottomNavigationBarType.shifting,
        elevation: 10,
        currentIndex: _bottom_navigation_bar_index,
        onTap: _bottomNavigationBarHandler,
        backgroundColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.amberAccent,
        selectedFontSize: 15,
        //showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 25,
        selectedIconTheme: const IconThemeData(color: Colors.amberAccent),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'add'),
        ],*/
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[],
        ),
        color: Colors.blueGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
