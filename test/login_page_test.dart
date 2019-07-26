import "package:flutter_test/flutter_test.dart";
import "package:flutter_app/Login/LogIn.dart";
import "package:flutter/material.dart";

void main() {
  Widget makeTesteableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets("email or password is empty", (WidgetTester tester) async {
    LogIn page = LogIn();

    await tester.pumpWidget(makeTesteableWidget(child: page));
    await tester.tap(find.byKey(Key("logIn")));
  });

  testWidgets("Non-empty email and password", (WidgetTester tester) async {
    LogIn page = LogIn();

    await tester.pumpWidget(makeTesteableWidget(child: page));
    await tester.tap(find.byKey(Key("logIn")));

    Finder emailField = find.byKey(Key("email"));
    await tester.enterText(emailField, "email");

    Finder passwordField = find.byKey(Key("password"));
    await tester.enterText(passwordField, "password");

    await tester.tap(find.byKey(Key("logIn")));
  });
}
