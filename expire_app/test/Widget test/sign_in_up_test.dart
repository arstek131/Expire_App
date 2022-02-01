/* dart */
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

/* mocks */
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import './sign_in_up_test.mocks.dart';

/* dependencies */
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

/* widgets */
import 'package:expire_app/widgets/sign_in.dart';

Widget makeWidgetTestable(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void _SETUP_DEVICE_RES(binding) {
  binding.window.physicalSizeTestValue = Size(1080, 2340);
  binding.window.devicePixelRatioTestValue = 1.0;
}

void _RESET_DEVICE_RES(binding, tester) {
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
}

@GenerateMocks([FirebaseAuthHelper])
void main() {
  final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized() as TestWidgetsFlutterBinding;

  MockFirebaseAuthHelper mockFirebaseAuthHelper = MockFirebaseAuthHelper();

  /*void setScreenSize({int width, int height}) {
    final dpi = tester.binding.window.devicePixelRatio;
    tester.binding.window.physicalSizeTestValue = Size(width * dpi, height * dpi);
  }*/

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
        mockFirebaseAuthHelper: mockFirebaseAuthHelper,
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
    });*/
  });
}
