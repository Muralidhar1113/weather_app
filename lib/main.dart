import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final List<String> cities = ['Hyderabad', 'Srinagar'];
  final String apiKey = 'f1e9cb482047d69861791d38a0951d94';
  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    for (var city in cities) {
      fetchWeather(city);
    }
  }

  Future<void> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          weatherData[city] = data;
        });
      } else {
        throw Exception('Failed to fetch weather for $city');
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        weatherData[city] = null;
      });
    }
  }

  String getBackground(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return 'https://i.ibb.co/2s9BfZ2/sunny.jpg';
      case 'clouds':
        return 'https://i.ibb.co/2n5z3kH/cloudy.jpg';
      case 'rain':
      case 'drizzle':
        return 'https://i.ibb.co/QmXgM8D/rainy.jpg';
      case 'snow':
        return 'https://i.ibb.co/W6h2j5p/snow.jpg';
      default:
        return 'https://i.ibb.co/2s9BfZ2/sunny.jpg';
    }
  }

  Color getTextColor(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return Colors.black87;
      default:
        return Colors.white;
    }
  }

  // Get one forecast per day
  List<dynamic> getDailyForecasts(dynamic data) {
    Map<String, dynamic> dailyForecasts = {};
    for (var f in data['list']) {
      final dt = DateTime.fromMillisecondsSinceEpoch(f['dt'] * 1000);
      final day = "${dt.year}-${dt.month}-${dt.day}";
      if (!dailyForecasts.containsKey(day) && dt.isAfter(DateTime.now())) {
        dailyForecasts[day] = f;
      }
    }
    return dailyForecasts.values.take(3).toList(); // next 3 days
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final city = cities[0]; // show first city for demo
    final data = weatherData[city];

    if (data == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('$city: Failed to load weather'),
          ),
        ),
      );
    }

    final current = data['list'][0];
    final temp = current['main']['temp'].round();
    final mainWeather = current['weather'][0]['main'];
    final description = current['weather'][0]['description'];
    final icon = current['weather'][0]['icon'];
    final bg = getBackground(mainWeather);
    final textColor = getTextColor(mainWeather);

    final forecasts = getDailyForecasts(data);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Full-screen background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(bg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withAlpha(150),
                  Colors.transparent,
                  Colors.black.withAlpha(150),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    city,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.network(
                    "https://openweathermap.org/img/wn/$icon@2x.png",
                    width: 80,
                  ),
                  Text(
                    "$temp°C",
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    description.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor.withAlpha(200),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Next Days",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: forecasts.length,
                      itemBuilder: (context, index) {
                        final f = forecasts[index];
                        final dt = DateTime.fromMillisecondsSinceEpoch(f['dt'] * 1000);
                        final fTemp = f['main']['temp'].round();
                        final fIcon = f['weather'][0]['icon'];
                        final fMain = f['weather'][0]['main'];

                        return Container(
                          width: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][dt.weekday % 7],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Image.network(
                                "https://openweathermap.org/img/wn/$fIcon.png",
                                width: 40,
                              ),
                              Text(
                                "$fTemp°C",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                fMain,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
