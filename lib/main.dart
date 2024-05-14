import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weatherapp/screens/splash_screen.dart';
import 'package:weatherapp/api/weather_api_client.dart';
import 'package:weatherapp/bloc/weather_bloc.dart';
import 'package:weatherapp/api/const.dart';

void main() {
  final weatherApiClient = WeatherApiClient(
    baseUrl: 'https://api.openweathermap.org/data/2.5',
    apiKey: weatherApiKey,
  );
  runApp(
    BlocProvider(
      create: (context) => WeatherBloc(weatherApiClient),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
