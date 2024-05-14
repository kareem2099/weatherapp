import 'package:intl/intl.dart';

class ForecastData {
  final String description;
  final String icon;
  final double tempMin;
  final double tempMax;
  final DateTime time; // Added field for time

  ForecastData({
    required this.description,
    required this.icon,
    required this.tempMin,
    required this.tempMax,
    required this.time, // Constructor parameter for time
  });

  // Updated factory method to include time
  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      tempMin: json['main']['temp_min'],
      tempMax: json['main']['temp_max'],
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000,
          isUtc: true), // Assuming 'dt' is the UNIX timestamp in seconds
    );
  }

  @override
  String toString() {
    return 'ForecastData{description: $description, icon: $icon, tempMin: $tempMin, tempMax: $tempMax, time: $time}';
  }

  // Convert Kelvin to Celsius
  double get tempMinCelsius => tempMin - 273.15;
  double get tempMaxCelsius => tempMax - 273.15;
  String get formattedTime => DateFormat('HH:mm').format(time);
}
