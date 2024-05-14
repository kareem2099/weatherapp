import 'package:weatherapp/bloc/weather_state.dart';
import 'package:weatherapp/models/air_pollution_data.dart';

abstract class WeatherEvent {}

class FetchWeather extends WeatherEvent {
  final double latitude;
  final double longitude;

  FetchWeather(this.latitude, this.longitude);
}

class FetchForecast extends WeatherEvent {
  final double latitude;
  final double longitude;

  FetchForecast(this.latitude, this.longitude);
}

class FetchAirPollution extends WeatherEvent {
  final double latitude;
  final double longitude;

  FetchAirPollution(this.latitude, this.longitude);
}

class AirPollutionLoaded extends WeatherState {
  final AirPollutionData airPollutionData;

  AirPollutionLoaded(this.airPollutionData);
}

class PermissionRequested extends WeatherEvent {}

class RequestLocationPermission extends WeatherEvent {}
