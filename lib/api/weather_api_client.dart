import 'package:dio/dio.dart';
import 'package:weatherapp/api/const.dart';

class WeatherApiClient {
  final String baseUrl;
  final String apiKey;
  late final Dio dio;

  WeatherApiClient({required this.baseUrl, required this.apiKey});

  Future<Map<String, dynamic>> getWeatherData(
      double latitude, double longitude) async {
    final dio = Dio(); // Create a Dio instance
    final url = '$baseUrl/weather';
    final parameters = {
      'lat': latitude,
      'lon': longitude,
      'appid': weatherApiKey,
    };
    try {
      final response = await dio.get(
        url,
        queryParameters: parameters,
      );
      return response.data;
    } catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> get3HourForecast(
      double latitude, double longitude) async {
    final dio = Dio(); // Create a Dio instance
    final url = '$baseUrl/forecast';
    final parameters = {
      'lat': latitude,
      'lon': longitude,
      'appid': weatherApiKey,
    };
    try {
      final response = await dio.get(
        url,
        queryParameters: parameters,
      );
      return response.data;
    } catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> get5DayForecast(
      double latitude, double longitude) async {
    final dio = Dio(); // Create a Dio instance
    final url = '$baseUrl/forecast';
    final parameters = {
      'lat': latitude,
      'lon': longitude,
      'appid': weatherApiKey,
    };
    try {
      final response = await dio.get(
        url,
        queryParameters: parameters,
      );
      return response.data;
    } catch (e) {
      return _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAirPollutionData(
      double latitude, double longitude) async {
    final dio = Dio();
    final url = '$baseUrl/air_pollution';
    final parameters = {
      'lat': latitude,
      'lon': longitude,
      'appid': weatherApiKey,
    };
    try {
      final response = await dio.get(url, queryParameters: parameters);
      return response.data;
    } catch (e) {
      return _handleDioError(e);
    }
  }

  Map<String, dynamic> _handleDioError(dynamic e) {
    String errorMessage;
    DioExceptionType errorType;
    if (e is DioException) {
      errorType = e.type;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage =
              'Received invalid status code: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request to API was cancelled';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'unknown error';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'SSL/TLS certificate validation failed';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Network connection error';
      }
    } else {
      errorMessage = 'An unexpected error occurred: $e';
      errorType = DioExceptionType.unknown;
    }
    throw WeatherApiException(errorMessage, errorType);
  }

  void dispose() {
    dio.close(); // Cancel ongoing Dio requests
  }
}

class WeatherApiException implements Exception {
  final String message;
  final DioExceptionType errorType;
  WeatherApiException(this.message, this.errorType);
}
