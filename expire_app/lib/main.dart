/* dart libraries */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/* Screens */
import 'screens/main_app_screen.dart';
import 'screens/add_product_screen.dart';

/* Providers */
import './providers/products_provider.dart';
import 'providers/bottom_navigator_bar_size_provider.dart';

/* helpers */
import './helpers/custom_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BottomNavigationBarSizeProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Expire app',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          }),
        ),
        routes: {
          '/': (ctx) => MainAppScreen(),
          AddProductScreen.routeName: (ctx) => AddProductScreen(),
        },
      ),
    );
  }
}
