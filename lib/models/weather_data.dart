class WeatherData {
  final String name;
  final double temp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double windDeg;
  final double windGust;
  final int pressure;
  final int seaLevel;
  final int grndLevel;
  final int visibility;
  final int clouds;
  final int sunrise;
  final int sunset;
  final String timezone;
  final double tempMin;
  final double tempMax;
  final double feelsLike;

  WeatherData({
    required this.name,
    required this.temp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.windGust,
    required this.pressure,
    required this.seaLevel,
    required this.grndLevel,
    required this.visibility,
    required this.clouds,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
  });

  // Factory method to create an instance of WeatherData from JSON
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      name: json['name'],
      temp: json['main']['temp'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
      windDeg: json['wind']['deg'],
      windGust: json['wind']['gust'] ?? 0.0, // Default to 0 if not present
      pressure: json['main']['pressure'],
      seaLevel: json['main']['sea_level'] ?? 0, // Default to 0 if not present
      grndLevel: json['main']['grnd_level'] ?? 0, // Default to 0 if not present
      visibility: json['visibility'],
      clouds: json['clouds']['all'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      timezone: json['timezone'].toString(),
      tempMin: json['main']['temp_min'],
      tempMax: json['main']['temp_max'],
      feelsLike: json['main']['feels_like'],
    );
  }

  @override
  String toString() {
    return 'WeatherData{name: $name, temp: $temp, description: $description, icon: $icon, humidity: $humidity, windSpeed: $windSpeed, windDeg: $windDeg, windGust: $windGust, pressure: $pressure, seaLevel: $seaLevel, grndLevel: $grndLevel, visibility: $visibility, clouds: $clouds, sunrise: $sunrise, sunset: $sunset, timezone: $timezone, tempMin: $tempMin, tempMax: $tempMax, feelsLike: $feelsLike}';
  }

  // Convert Kelvin to Celsius
  double get tempMinCelsius => tempMin - 273.15;
  double get tempMaxCelsius => tempMax - 273.15;
  double get feelsLikeCelsius => feelsLike - 273.15;
}
