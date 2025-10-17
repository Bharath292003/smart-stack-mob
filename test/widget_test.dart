// This is a basic Flutter widget test for Smart-Stack app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_stack/login_page.dart';
import 'package:smart_stack/home_page.dart';

void main() {
  testWidgets('Login page widget test', (WidgetTester tester) async {
    // Test the login page directly
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Verify that login page elements are present
    expect(find.text('Smart-Stack'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.phone), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Test the login page directly
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Try to login without entering any data
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify validation messages appear
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your phone number'), findsOneWidget);
  });

  testWidgets('Login form input test', (WidgetTester tester) async {
    // Test the login page directly
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Enter text in name field
    await tester.enterText(find.byType(TextFormField).first, 'John Doe');
    await tester.pump();

    // Enter text in phone field
    await tester.enterText(find.byType(TextFormField).last, '1234567890');
    await tester.pump();

    // Verify text was entered
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
  });

  testWidgets('Home page widget test', (WidgetTester tester) async {
    // Test the home page directly
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(
        userName: 'Test User',
        phoneNumber: '1234567890',
      ),
    ));

    // Verify that home page elements are present
    expect(find.text('Smart-Stack'), findsWidgets);
    expect(find.text('Business Cards'), findsOneWidget);
    expect(find.text('Personal Cards'), findsOneWidget);
    expect(find.text('Other Cards'), findsOneWidget);
    expect(find.text('Scan Card'), findsOneWidget);
  });
}
