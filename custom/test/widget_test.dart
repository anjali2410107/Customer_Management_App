import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom/main.dart';
import 'package:custom/repositories/customer_repository.dart';

void main() {
  testWidgets('App smoke test - renders LoginScreen', (WidgetTester tester) async {
    // Instantiate local mock repository for tests
    final mockRepository = LocalCustomerRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        customerRepository: mockRepository,
        initialTheme: ThemeMode.light,
        isLoggedIn: false,
        isFirebaseConnected: false,
      ),
    );

    // Verify that the login screen contents are rendered (e.g. Welcome Back text, Mobile Number field)
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login with Mobile'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}
