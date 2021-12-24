/* dart libraries */
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

/* Screens */
import 'screens/main_app_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/name_input_screen.dart';

/* Providers */
import './providers/products_provider.dart';
import './providers/bottom_navigator_bar_size_provider.dart';
import './providers/auth_provider.dart';
import './providers/user_info_provider.dart';

/* helpers */
import './helpers/custom_route.dart';

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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => ProductsProvider(null, null, null, []),
          update: (_, auth, previousProducts) => ProductsProvider(
            auth.token,
            auth.userId,
            auth.familyId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserInfoProvider>(
          create: (_) => UserInfoProvider(null, null, null),
          update: (_, auth, previousInfo) => UserInfoProvider(
            auth.userId,
            auth.familyId,
            previousInfo?.displayName,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BottomNavigationBarSizeProvider(),
        ),
      ],
      child: Consumer2<AuthProvider, UserInfoProvider>(
        builder: (ctx, auth, userInfo, _) => MaterialApp(
          title: 'Expire app',
          theme: ThemeData(
            textTheme: const TextTheme(/* Insert text theme here pair name : TextStyle(...) */),
            primarySwatch: Colors.indigo,
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),
          home: auth.isAuth
              ? FutureBuilder(
                  future: userInfo.tryFetchDisplayName(),
                  builder: (context, userInfoSnapshot) => userInfoSnapshot.connectionState == ConnectionState.waiting
                      ? SplashScreen()
                      : (userInfo.isNameSet ? MainAppScreen() : NameInputScreen()))
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
                ),
          routes: {
            //'/': (ctx) => MainAppScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            NameInputScreen.routeName: (ctx) => NameInputScreen(),
          },
        ),
      ),
    );
  }
}
