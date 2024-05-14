import 'package:weatherapp/models/air_pollution_data.dart';
import 'package:weatherapp/models/forecast_data.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Map<String, dynamic> weatherData;

  WeatherLoaded(this.weatherData);
}

class ForecastLoaded extends WeatherState {
  final List<ForecastData> forecastDataList;

  ForecastLoaded(this.forecastDataList);
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);
}

class AirPollutionError extends WeatherState {
  final String message;

  AirPollutionError(this.message);
}

class WeatherAndForecastLoaded extends WeatherState {
  final Map<String, dynamic> weatherData;
  final List<ForecastData> forecastDataList;
  final List<ForecastData> fiveDaysForecastDataList;
  final AirPollutionData airQualityData;

  WeatherAndForecastLoaded(this.weatherData, this.forecastDataList,
      this.fiveDaysForecastDataList, this.airQualityData);
}

class AirQualityLoaded extends WeatherState {
  final AirPollutionData airQualityData;

  AirQualityLoaded(this.airQualityData);
}
