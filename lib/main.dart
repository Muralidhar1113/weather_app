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
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final List<String> cities = ['Hyderabad', 'Srinagar']; // Multiple cities
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
      print(e);
      setState(() {
        weatherData[city] = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: weatherData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: cities.map((city) {
                final data = weatherData[city];
                if (data == null) {
                  return ListTile(
                    title: Text('$city Weather'),
                    subtitle: const Text('Failed to load data'),
                  );
                }
                // Show today + next 3 days
                final forecasts = data['list'].take(4).toList();
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$city Weather',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...forecasts.map((f) {
                          final dt = DateTime.fromMillisecondsSinceEpoch(
                              f['dt'] * 1000);
                          final temp = f['main']['temp'];
                          final description = f['weather'][0]['description'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                                '${dt.day}/${dt.month} ${dt.hour}:00 - $temp°C - $description'),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
