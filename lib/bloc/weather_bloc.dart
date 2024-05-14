import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherapp/models/air_pollution_data.dart';
import 'package:weatherapp/models/forecast_data.dart';
import 'weather_event.dart';
import 'weather_state.dart';
import 'package:weatherapp/api/weather_api_client.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherApiClient weatherApiClient;

  WeatherBloc(this.weatherApiClient) : super(WeatherInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        // Fetch current weather data
        final weatherData = await weatherApiClient.getWeatherData(
            event.latitude, event.longitude);

        // Fetch 3-hour forecast data
        final threeHourForecastResponse = await weatherApiClient
            .get3HourForecast(event.latitude, event.longitude);
        final List<ForecastData> threeHourForecastDataList =
            (threeHourForecastResponse['list'] as List)
                .map((item) => ForecastData.fromJson(item))
                .toList();

        // Fetch 5-day forecast data
        final fiveDayForecastResponse = await weatherApiClient.get5DayForecast(
            event.latitude, event.longitude);
        final List<ForecastData> fiveDayForecastDataList =
            (fiveDayForecastResponse['list'] as List)
                .map((item) => ForecastData.fromJson(item))
                .toList();
        // fetch air pollution data
        final airPollutionResponse = await weatherApiClient.getAirPollutionData(
            event.latitude, event.longitude);
        final AirPollutionData airPollutionData =
            AirPollutionData.fromJson(airPollutionResponse);
        emit(AirPollutionLoaded(airPollutionData));

        // Emit combined state with both 3-hour and 5-day forecasts
        emit(WeatherAndForecastLoaded(weatherData, threeHourForecastDataList,
            fiveDayForecastDataList, airPollutionData));
      } catch (e) {
        emit(WeatherError('Failed to fetch weather or forecast data'));
        emit(AirPollutionError('Failed to fetch air pollution data'));
      }
    });

    on<PermissionRequested>((event, emit) async {
      // Handle permission logic
      var status = await Permission.location.status;
      if (status.isGranted) {
        emit(WeatherInitial()); // Permission granted, ready to fetch weather
      } else {
        emit(WeatherError('Location permission denied'));
        // Optionally, you can add logic to request permission here
      }
    });
    on<RequestLocationPermission>((event, emit) async {
      final status = await Permission.location.status;
      if (status.isGranted) {
        // Location permission is granted, proceed to fetch the location
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        add(FetchWeather(
            position.latitude,
            position
                .longitude)); // Dispatch FetchWeather event with the current location
        add(FetchForecast(
            position.latitude,
            position
                .longitude)); // Dispatch FetchForecast event with the current location
      } else if (status.isDenied) {
        // Location permission is denied, request permissions
        final newStatus = await Permission.location.request();
        if (newStatus.isGranted) {
          // Permission granted, proceed to fetch the location
          final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          add(FetchWeather(
              position.latitude,
              position
                  .longitude)); // Dispatch FetchWeather event with the current location
          add(FetchForecast(
              position.latitude,
              position
                  .longitude)); // Dispatch FetchForecast event with the current location
        } else {
          // Permission is denied again, show a dialog and navigate to app settings
          emit(WeatherError('Location permission denied'));
          // You can use a platform-specific method to open app settings here
        }
      } else if (status.isPermanentlyDenied) {
        // The user opted to never again see the permission request dialog for this app
        // Show a dialog and navigate to app settings
        emit(WeatherError(
            'Location permission permanently denied, please enable it in app settings'));
        // You can use a platform-specific method to open app settings here
      }
    });
  }
}
