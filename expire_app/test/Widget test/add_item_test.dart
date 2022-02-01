/* dart */
import 'dart:io';

import 'package:expire_app/widgets/sign_up.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/* mocks */
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import './sign_in_up_test.mocks.dart';

/* dependencies */
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expire_app/providers/dependencies_provider.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:expire_app/helpers/user_info.dart' as userinfo;

/* screens */
import 'package:expire_app/screens/name_input_screen.dart';
import 'package:expire_app/screens/main_app_screen.dart';

/* widgets */
import 'package:expire_app/widgets/sign_in.dart';

/* HELPER FUNCTIONS */
void _SETUP_DEVICE_RES(binding) {
  binding.window.physicalSizeTestValue = Size(1080, 2340);
  binding.window.devicePixelRatioTestValue = 1.0;
}

void _RESET_DEVICE_RES(binding, tester) {
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
}

String? fromRichTextToPlainText(final Widget widget) {
  if (widget is RichText) {
    if (widget.text is TextSpan) {
      final buffer = StringBuffer();
      (widget.text as TextSpan).computeToPlainText(buffer);
      return buffer.toString();
    }
  }
  return null;
}

class TestObserver extends NavigatorObserver {
  bool didNavigatorPush = false;
  bool didNavigatorPop = false;
  bool didNavigatorRemove = false;
  bool didNavigatorReplace = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    this.didNavigatorPush = true;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    this.didNavigatorPop = true;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    this.didNavigatorRemove = true;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    this.didNavigatorReplace = true;
  }

  void resetTestObserver() {
    didNavigatorPush = false;
    didNavigatorPop = false;
    didNavigatorRemove = false;
    didNavigatorReplace = false;
  }
}

@GenerateMocks([FirebaseAuthHelper, FirestoreHelper, SharedPreferences, userinfo.UserInfo])
void main() {
  // INITIAL SETUP

  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;

  MockFirebaseAuthHelper mockFirebaseAuthHelper = MockFirebaseAuthHelper();
  MockSharedPreferences mockSharedPreferences = MockSharedPreferences();
  MockFirestoreHelper mockFirestoreHelper = MockFirestoreHelper();
  MockUserInfo mockUserInfo = MockUserInfo();
  TestObserver mockNavigatorObserver = TestObserver();

  /* STATIC STUBS */
  when(mockUserInfo.userId).thenReturn("userId"); 
  when(mockUserInfo.displayName).thenReturn("displayName");
  when(mockUserInfo.familyId).thenReturn("familyId");

  Widget makeWidgetTestable(Widget child) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => DependenciesProvider(
            mockFirebaseAuthHelper: mockFirebaseAuthHelper,
            mockFirestoreHelper: mockFirestoreHelper,
          ),
        ),
      ],
      child: MaterialApp(
        routes: {
          NameInputScreen.routeName: (ctx) => NameInputScreen(),
          MainAppScreen.routeName: (ctx) => MainAppScreen(),
        },
        navigatorObservers: [mockNavigatorObserver],
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }
}
