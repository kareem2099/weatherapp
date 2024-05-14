import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weatherapp/bloc/weather_bloc.dart';
import 'package:weatherapp/bloc/weather_event.dart';
import 'package:weatherapp/bloc/weather_state.dart';
import 'package:weatherapp/screens/weather_screen.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  @override
  void initState() {
    super.initState();
    // Request location permission when the app starts
    BlocProvider.of<WeatherBloc>(context, listen: false)
        .add(RequestLocationPermission());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state is WeatherError &&
              state.message.contains('permission denied')) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Location Permission'),
                  content: Text(state.message),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Open Settings'),
                      onPressed: () {
                        openAppSettings(); // Opens app settings for the user to change permission
                        Navigator.of(context).pop(); // Closes the dialog
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        builder: (context, state) {
          if (state is WeatherInitial) {
            return const Center(child: Text('Please wait...'));
          } else if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherAndForecastLoaded) {
            // Use a custom widget that takes both weatherData and forecastDataList
            return CombinedWeatherForecastScreen(
              weatherData: state.weatherData,
              forecastDataList: state.forecastDataList,
              fiveDayForecastDataList: state.fiveDaysForecastDataList,
              airQualityData: state.airQualityData,
            );
          } else if (state is WeatherError) {
            return Center(child: Text(state.message));
          }
          return Container(); // Placeholder for other states
        },
      ),
    );
  }
}
