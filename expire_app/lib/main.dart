/* dart libraries */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

/* Screens */
import 'screens/main_app_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/splash_screen.dart';

/* Providers */
import './providers/products_provider.dart';
import 'providers/bottom_navigator_bar_size_provider.dart';
import './providers/auth_provider.dart';

/* helpers */
import './helpers/custom_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
            create: (_) => ProductsProvider(null, null, []),
            update: (_, auth, previousProducts) => ProductsProvider(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => BottomNavigationBarSizeProvider(),
          ),
        ],
        child: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => MaterialApp(
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
                ? MainAppScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen(),
                  ),
            routes: {
              //'/': (ctx) => MainAppScreen(),
              AddProductScreen.routeName: (ctx) => AddProductScreen(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
            },
          ),
        ));
  }
}
