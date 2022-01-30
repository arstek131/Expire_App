/* dart libraries */

import 'package:expire_app/helpers/device_info.dart';
import 'package:expire_app/providers/filters_provider.dart';
import 'package:expire_app/providers/recipe_provider.dart';
import 'package:expire_app/providers/shopping_list_provider.dart';
import 'package:expire_app/screens/family_info_screen.dart';
import 'package:expire_app/screens/product_details.dart';
import 'package:expire_app/screens/shopping_list_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
/* Providers */
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './constants.dart' as constants;
import './helpers/db_manager.dart';
/* firebase */
import './helpers/firebase_auth_helper.dart';
import './providers/bottom_navigator_bar_size_provider.dart';
import './providers/products_provider.dart';
/* helpers */
import 'helpers/custom_route.dart';
import 'screens/auth_screen.dart';
/* Screens */
import 'screens/main_app_screen.dart';
import 'screens/name_input_screen.dart';
import 'screens/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // todo: set for ios

  /* setting local user data for unregistered usage */
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString("localUserId") == null) {
    await prefs.setString("localUserId", constants.localUserId);
  }
  if (prefs.getString("localFamilyId") == null) {
    await prefs.setString("localFamilyId", constants.localFamilyId);
  }

  /* DB init */
  await DBManager().init();

  /* init device info such as device type, screen size etc...*/
  DeviceInfo.instance;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BottomNavigationBarSizeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ShoppingListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FiltersProvider(),
        ),
        ChangeNotifierProxyProvider<ProductsProvider, RecipeProvider>(
          create: (BuildContext context) => RecipeProvider(null, null),
          update: (context, products, previousRecipes) => RecipeProvider(products, previousRecipes!.rec),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expire app',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          }),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) => userSnapshot.hasData
              ? // token found
              firebaseAuthHelper.isDisplayNameSet
                  ? MainAppScreen()
                  : NameInputScreen()
              : AuthScreen(),
        ),
        routes: {
          //'/': (ctx) => MainAppScreen(),
          OnBoardingPage.routeName: (ctx) => OnBoardingPage(),
          AuthScreen.routeName: (ctx) => AuthScreen(),
          NameInputScreen.routeName: (ctx) => NameInputScreen(),
          MainAppScreen.routeName: (ctx) => MainAppScreen(),
          ProductDetails.routeName: (ctx) => ProductDetails(),
          ShoppingListDetailScreen.routeName: (ctx) => ShoppingListDetailScreen(),
          FamilyInfoScreen.routeName: (ctx) => FamilyInfoScreen(),
        },
      ),
    );
  }
}
