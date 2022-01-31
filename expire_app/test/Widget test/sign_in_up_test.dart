import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:expire_app/widgets/sign_in.dart';

void main() {
  Widget applyMaterialApp(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('[Sign in]', () {
    testWidgets('Correct email and password', (WidgetTester tester) async {
      // SETUP
      final _formKeySignIn = GlobalKey<FormState>();
      final pageController = PageController(initialPage: 0);

      final emailField = find.byKey(ValueKey('email_field'));
      final passwordField = find.byKey(ValueKey('password_field'));
      final submitButton = find.byKey(ValueKey('submit_button'));

      // RUN
      await tester.pumpWidget(applyMaterialApp(SignIn(formKey: _formKeySignIn, pageController: pageController)));

      // VERIFY
    });
  });
}
