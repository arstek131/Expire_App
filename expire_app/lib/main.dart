/* dart libraries */

import 'package:expire_app/helpers/device_info.dart';
import 'package:expire_app/providers/dependencies_provider.dart';
import 'package:expire_app/providers/filters_provider.dart';
import 'package:expire_app/providers/recipe_provider.dart';
import 'package:expire_app/providers/shopping_list_provider.dart';
import 'package:expire_app/screens/family_info_screen.dart';
import 'package:expire_app/screens/product_details.dart';
import 'package:expire_app/screens/shopping_list_detail_screen.dart';
import 'package:expire_app/screens/auth_dispatcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

// TODO: remove
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

// TODO: remove
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// TODO: remove
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // todo: set for ios

  // TODO: remove
  /* notification channel */
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

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

  // TODO: remove
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

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
        Provider(
          create: (_) => DependenciesProvider(),
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
        home: AuthDispatcher(),
        /*StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            return userSnapshot.hasData
                ? // token found
                firebaseAuthHelper.isDisplayNameSet
                    ? MainAppScreen()
                    : NameInputScreen()ce00co47
                    
                : AuthScreen();
          },
        ),*/
        routes: {
          //'/': (ctx) => MainAppScreen(),
          OnBoardingPage.routeName: (ctx) => OnBoardingPage(),
          AuthDispatcher.routeName: (ctx) => AuthDispatcher(),
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
