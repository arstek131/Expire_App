/* dart */
import 'dart:async';
import 'dart:io';

import 'package:expire_app/widgets/sign_up.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

@GenerateMocks([FirebaseAuthHelper, FirestoreHelper, FirebaseMessaging, SharedPreferences, userinfo.UserInfo])
void main() {
  // INITIAL SETUP

  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;

  MockFirebaseAuthHelper mockFirebaseAuthHelper = MockFirebaseAuthHelper();
  MockSharedPreferences mockSharedPreferences = MockSharedPreferences();
  MockFirestoreHelper mockFirestoreHelper = MockFirestoreHelper();
  MockUserInfo mockUserInfo = MockUserInfo();
  MockFirebaseMessaging mockFirebaseMessaging = MockFirebaseMessaging();
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
            mockFirebaseMessaging: mockFirebaseMessaging,
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

  group('[Sign in]', () {
    testWidgets('Rendering test', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
      )));

      // VERIFY
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(submitButton, findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
    });

    testWidgets('Correct email and password', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
      )));

      await tester.enterText(emailField, 'test@test.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pump();

      // VERIFY
      verify(mockFirebaseAuthHelper.signInWithEmail(email: 'test@test.ir', password: 'wwwwww')).called(1);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    });

    /*testWidgets('Wrong email or password', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password'))).thenAnswer(
          (_) async => throw FirebaseAuthException(code: 'auth/wrong-password', message: 'You inserted the wrong password'));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
      )));

      await tester.enterText(emailField, 'test@test.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pump(Duration(milliseconds: 1500)); // 1.5s

      // VERIFY
      verify(mockFirebaseAuthHelper.signInWithEmail(email: 'test@test.ir', password: 'wwwwww')).called(1);
      expect(find.text('You inserted the wrong password'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    }); */

    testWidgets('Wrong formatted e-mail', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      //when(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')))
      //    .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
      )));

      await tester.enterText(emailField, 'testtest.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')));
      expect(find.text('Please insert a valid e-mail'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    });

    testWidgets('Empty e-mail and password', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      //when(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')))
      //    .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
      )));

      await tester.enterText(emailField, '');
      await tester.enterText(passwordField, '');
      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')));
      expect(find.text('Please enter some text'), findsWidgets);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    });

    testWidgets('Google sign in', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final submitButton = find.byKey(ValueKey('google_sing_in_button'));

      when(mockFirebaseAuthHelper.googleLogIn()).thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
      )));

      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verify(mockFirebaseAuthHelper.googleLogIn()).called(1);
      verifyNever(mockFirebaseAuthHelper.facebookLogIn());
      verifyNever(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')));
      //expect(find.text('Choose an account'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    });

    testWidgets('Facebook sign in', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final submitButton = find.byKey(ValueKey('facebook_sing_in_button'));

      when(mockFirebaseAuthHelper.facebookLogIn()).thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
      )));

      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verify(mockFirebaseAuthHelper.facebookLogIn()).called(1);
      verifyNever(mockFirebaseAuthHelper.googleLogIn());
      verifyNever(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')));
      //expect(find.text('Choose an account'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    });

    testWidgets('Continue without registration, display name not yet set', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final submitButton = find.byKey(ValueKey('continue_without_registration_button'));

      when(mockSharedPreferences.getString('localDisplayName')).thenReturn(null);

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
        mockSharedPreferences: mockSharedPreferences,
      )));

      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.facebookLogIn());
      verifyNever(mockFirebaseAuthHelper.googleLogIn());
      verifyNever(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')));

      expect(mockNavigatorObserver.didNavigatorPush, true);
      expect(find.byType(NameInputScreen), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      reset(mockSharedPreferences);
      mockNavigatorObserver.resetTestObserver();
    });

    testWidgets('Continue without registration, display already set', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final submitButton = find.byKey(ValueKey('continue_without_registration_button'));

      when(mockSharedPreferences.getString('localDisplayName')).thenReturn('displayName');
      when(mockFirebaseAuthHelper.isAuth).thenReturn(false);

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
        mockSharedPreferences: mockSharedPreferences,
      )));

      await tester.tap(submitButton);

      await tester.pump(Duration(seconds: 5));

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.facebookLogIn());
      verifyNever(mockFirebaseAuthHelper.googleLogIn());
      verifyNever(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password')));

      expect(mockNavigatorObserver.didNavigatorPush, true);
      //expect(find.byType(MainAppScreen), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      reset(mockSharedPreferences);
      mockNavigatorObserver.resetTestObserver();
    });
  });

  group('[Sign up]', () {
    testWidgets('Rendering test', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));
      final familyIdButton = find.byKey(ValueKey('family_id_button'));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      // VERIFY

      final familyIdButtonText = fromRichTextToPlainText(
          find.descendant(of: familyIdButton, matching: find.byType(RichText)).evaluate().toList().first.widget as RichText);

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(confirmPasswordField, findsOneWidget);
      expect(submitButton, findsOneWidget);
      expect(familyIdButtonText?.contains('I have a family ID'), true);
      expect(familyIdButtonText?.contains('Valid family ID'), false);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      mockNavigatorObserver.resetTestObserver();
    });

    testWidgets('Correct email, password and confirm password', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signUpWithEmail(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      await tester.enterText(emailField, 'test@test.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.enterText(confirmPasswordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pump();

      // VERIFY
      verify(mockFirebaseAuthHelper.signUpWithEmail(email: 'test@test.ir', password: 'wwwwww')).called(1);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      mockNavigatorObserver.resetTestObserver();
    });

    /*testWidgets('Wrong email or password', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signInWithEmail(email: anyNamed('email'), password: anyNamed('password'))).thenAnswer(
          (_) async => throw FirebaseAuthException(code: 'auth/wrong-password', message: 'You inserted the wrong password'));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignIn(
        formKey: _formKeySignIn,
        pageController: pageController,
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
      )));

      await tester.enterText(emailField, 'test@test.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pump(Duration(milliseconds: 1500)); // 1.5s

      // VERIFY
      verify(mockFirebaseAuthHelper.signInWithEmail(email: 'test@test.ir', password: 'wwwwww')).called(1);
      expect(find.text('You inserted the wrong password'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
    });*/

    testWidgets('Wrong formatted e-mail', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signUpWithEmail(
              email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      await tester.enterText(emailField, 'testtest.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.enterText(confirmPasswordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.signUpWithEmail(
          email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')));
      expect(find.text('Please insert a valid e-mail'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      mockNavigatorObserver.resetTestObserver();
    });

    testWidgets('Not matching password', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signUpWithEmail(
              email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      await tester.enterText(emailField, 'testtest.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.enterText(confirmPasswordField, 'wwwww');
      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.signUpWithEmail(
          email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')));
      expect(find.text('Passwords do not match!'), findsOneWidget);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      mockNavigatorObserver.resetTestObserver();
    });

    testWidgets('Empty fields', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signUpWithEmail(
              email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      await tester.enterText(emailField, '');
      await tester.enterText(passwordField, '');
      await tester.enterText(confirmPasswordField, '');
      await tester.tap(submitButton);

      await tester.pumpAndSettle();

      // VERIFY
      verifyNever(mockFirebaseAuthHelper.signUpWithEmail(
          email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')));
      expect(find.text('Please enter some text'), findsWidgets);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      mockNavigatorObserver.resetTestObserver();
    });

    testWidgets('Sign up without family id', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      when(mockFirebaseAuthHelper.signUpWithEmail(email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      await tester.enterText(emailField, 'test@test.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.enterText(confirmPasswordField, 'wwwwww');
      await tester.tap(submitButton);

      await tester.pump();

      // VERIFY
      verify(mockFirebaseAuthHelper.signUpWithEmail(email: 'test@test.ir', password: 'wwwwww', familyId: null)).called(1);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      mockNavigatorObserver.resetTestObserver();
    });

    testWidgets('Sign up with family id', (WidgetTester tester) async {
      // SETUP
      _SETUP_DEVICE_RES(binding);

      final _formKeySignUp = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final confirmPasswordField = find.byKey(ValueKey('confirm_password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));
      final familyIdButton = find.byKey(ValueKey('family_id_button'));
      final familyIdCodeField = find.byKey(ValueKey('family_id_code_field'));

      when(mockFirebaseAuthHelper.signUpWithEmail(
              email: anyNamed('email'), password: anyNamed('password'), familyId: anyNamed('familyId')))
          .thenAnswer((_) async => Future.value(true));

      // RUN
      await tester.pumpWidget(makeWidgetTestable(SignUp(
        formKey: _formKeySignUp,
        pageController: pageController,
      )));

      // filling form
      await tester.enterText(emailField, 'test@test.ir');
      await tester.enterText(passwordField, 'wwwwww');
      await tester.enterText(confirmPasswordField, 'wwwwww');
      await tester.pump();

      // inserting family id
      await tester.tap(familyIdButton);
      await tester.pumpAndSettle();

      expect(find.text('Indicate your family ID below'), findsOneWidget);

      // not found
      when(mockFirestoreHelper.familyExists(familyId: anyNamed('familyId'))).thenAnswer((_) async => false);

      await tester.enterText(familyIdCodeField, 'cbcb');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();
      expect(find.textContaining('No family'), findsOneWidget);

      // found
      when(mockFirestoreHelper.familyExists(familyId: anyNamed('familyId'))).thenAnswer((_) async => true);

      await tester.enterText(familyIdCodeField, 'cbcb');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();

      final familyIdButtonText = fromRichTextToPlainText(
          find.descendant(of: familyIdButton, matching: find.byType(RichText)).evaluate().toList().first.widget as RichText);
      expect(familyIdButtonText?.contains('Valid family'), true);

      await tester.tap(submitButton);
      await tester.pump();

      // VERIFY
      verify(mockFirebaseAuthHelper.signUpWithEmail(email: 'test@test.ir', password: 'wwwwww', familyId: 'cbcb')).called(1);

      // RESET
      _RESET_DEVICE_RES(binding, tester);
      reset(mockFirebaseAuthHelper);
      reset(mockFirestoreHelper);
      mockNavigatorObserver.resetTestObserver();
    });
  });
}
