import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart'; // make sure this path points to your main.dart

void main() {
  // Ensure Flutter engine is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WeatherPage loads correctly', (WidgetTester tester) async {
    // Build the WeatherPage inside a MaterialApp
    await tester.pumpWidget(const MaterialApp(
      home: WeatherPage(),
    ));

    // ✅ Check if the AppBar title appears
    expect(find.text('Weather App'), findsOneWidget);

    // ✅ Check if a loading indicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
