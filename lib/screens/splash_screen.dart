import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'weather_home_screen.dart'; // Your main screen after the splash screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5), () {});
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WeatherHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if it's morning or night
    bool isMorning = DateTime.now().hour > 6 && DateTime.now().hour < 18;

    // Choose the correct asset based on the time of day
    String assetPath = isMorning
        ? 'assets/json/weather_morning.json'
        : 'assets/json/weather_night.json';

    return Scaffold(
      body: Center(
        child: Lottie.asset(assetPath),
      ),
    );
  }
}
