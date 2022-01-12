/* dart libraries */
import 'dart:io';

import 'package:expire_app/screens/product_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* Screens */
import 'screens/main_app_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/name_input_screen.dart';

import 'screens/onboarding_page.dart';

/* Providers */
import 'package:provider/provider.dart';
import './providers/products_provider.dart';
import './providers/bottom_navigator_bar_size_provider.dart';

/* helpers */
import 'helpers/custom_route.dart';

/* firebase */
import './helpers/firebase_auth_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    print("initializeApp still not implemented for iOS");
    return;
  }
  await Firebase.initializeApp(); // todo: set for ios

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuthHelper firebaseAuthHelper = FirebaseAuthHelper.instance;

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
      ],
      child: MaterialApp(
        title: 'Expire app',
        theme: ThemeData(
          textTheme: const TextTheme(/* Insert text theme here pair name : TextStyle(...) */),
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
        },
      ),
    );
  }
}
