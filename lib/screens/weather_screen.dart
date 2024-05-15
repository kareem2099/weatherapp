import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherapp/bloc/weather_bloc.dart';
import 'package:weatherapp/bloc/weather_event.dart';
import 'package:weatherapp/models/air_pollution_data.dart';
import 'package:weatherapp/models/forecast_data.dart';
import 'package:weatherapp/models/weather_data.dart';
import 'package:intl/intl.dart';

import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class CombinedWeatherForecastScreen extends StatefulWidget {
  final Map<String, dynamic> weatherData;
  final List<ForecastData> forecastDataList;
  final List<ForecastData> fiveDayForecastDataList;
  final AirPollutionData airQualityData;

  const CombinedWeatherForecastScreen({
    Key? key,
    required this.weatherData,
    required this.forecastDataList,
    required this.fiveDayForecastDataList,
    required this.airQualityData,
  }) : super(key: key);

  @override
  State<CombinedWeatherForecastScreen> createState() =>
      _CombinedWeatherForecastScreenState();
}

class _CombinedWeatherForecastScreenState
    extends State<CombinedWeatherForecastScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _toggleExpansion(bool isExpanded) {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController?.forward();
      } else {
        _animationController?.reverse();
      }
    });
  }

  Color getAqiColor(int aqi) {
    if (aqi <= 50) {
      return Colors.green; // Good
    } else if (aqi <= 100) {
      return Colors.yellow; // Moderate
    } else if (aqi <= 150) {
      return Colors.orange; // Unhealthy for Sensitive Groups
    } else if (aqi <= 200) {
      return Colors.red; // Unhealthy
    } else if (aqi <= 300) {
      return Colors.purple; // Very Unhealthy
    } else {
      return Colors.brown; // Hazardous
    }
  }

  Color getColorForComponent(double value) {
    if (value <= 50) {
      return Colors.green; // Good
    } else if (value <= 100) {
      return Colors.yellow; // Moderate
    } else if (value <= 150) {
      return Colors.orange; // Unhealthy for Sensitive Groups
    } else if (value <= 200) {
      return Colors.red; // Unhealthy
    } else if (value <= 300) {
      return Colors.purple; // Very Unhealthy
    } else {
      return Colors.brown; // Hazardous
    }
  }

  String getAqiDescription(int aqi) {
    if (aqi <= 50) {
      return 'Air Quality Index (AQI): $aqi - Breathing like a superhero!';
    } else if (aqi <= 100) {
      return 'Air Quality Index (AQI): $aqi - Pretty good, but let\'s not push our luck!';
    } else if (aqi <= 150) {
      return 'Air Quality Index (AQI): $aqi - Sensitive noses beware!';
    } else if (aqi <= 200) {
      return 'Air Quality Index (AQI): $aqi - Not great, not terrible. Well, maybe a little terrible.';
    } else if (aqi <= 300) {
      return 'Air Quality Index (AQI): $aqi - Time to break out the masks!';
    } else {
      return 'Air Quality Index (AQI): $aqi - You shall not breathe!';
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh(BuildContext context) async {
    try {
      // Get the current location
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return; // Check if the widget is still in the tree

      // Dispatch FetchWeather event with the current location
      BlocProvider.of<WeatherBloc>(context).add(
        FetchWeather(position.latitude, position.longitude),
      );

      // Wait for the state to be updated based on the new weather data
      await Future.delayed(
          const Duration(seconds: 2)); // Adjust the delay as needed

      // Inform the refresh controller that the refresh has completed
      _refreshController.refreshCompleted();
    } catch (e) {
      // Handle the error, perhaps by showing an error message to the user
      _refreshController.refreshFailed();
    }
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assuming WeatherData and ForecastData have the necessary fields
    final WeatherData currentWeather = WeatherData.fromJson(widget.weatherData);
    final double tempCelsius =
        currentWeather.temp - 273.15; // Convert from Kelvin to Celsius
    // Limit the forecast data list to 8 items
    final limitedForecastDataList = widget.forecastDataList.take(8).toList();
    final limitedFiveDayForecastDataList =
        widget.fiveDayForecastDataList.take(8).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(currentWeather.name),
        backgroundColor: Colors.transparent,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              // Get the current location
              Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high)
                  .then((Position position) {
                // Dispatch FetchWeather event with the current location
                BlocProvider.of<WeatherBloc>(context).add(
                  FetchWeather(position.latitude, position.longitude),
                );
              }).catchError((e) {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: () => _onRefresh(context),
          header: CustomHeader(
            builder: (BuildContext context, RefreshStatus? mode) {
              Widget body;
              if (mode == RefreshStatus.refreshing ||
                  mode == RefreshStatus.idle) {
                body = Center(
                  child: Image.asset(
                    'assets/gif/1.webp',
                    width: 100, // Set your desired width
                    height: 100, // Set your desired height
                  ),
                );
              } else {
                body = Container();
              }
              return Center(child: body);
            },
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${tempCelsius.toStringAsFixed(2)} °C',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              currentWeather.description,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Humidity: ${currentWeather.humidity}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'H: ${currentWeather.tempMaxCelsius.toStringAsFixed(2)}°c',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'L: ${currentWeather.tempMinCelsius.toStringAsFixed(2)}°c',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Image.network(
                        'http://openweathermap.org/img/w/${currentWeather.icon}.png',
                        width: 100,
                        height: 100,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: limitedForecastDataList.length,
                    itemBuilder: (context, index) {
                      final ForecastData forecast =
                          limitedForecastDataList[index];
                      String displayTime =
                          index == 0 ? 'Now' : forecast.formattedTime;
                      return SizedBox(
                        width: 100,
                        height: 50,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Text(displayTime),
                                Text(forecast.description),
                                Image.network(
                                  'http://openweathermap.org/img/w/${forecast.icon}.png',
                                  width: 50,
                                  height: 60,
                                ),
                                Text(
                                  'H: ${forecast.tempMinCelsius.toStringAsFixed(2)}°c',
                                ),
                                Text(
                                  'L: ${forecast.tempMaxCelsius.toStringAsFixed(2)}°c',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: limitedFiveDayForecastDataList.length,
                  itemBuilder: (context, index) {
                    final ForecastData dailyForecast =
                        limitedFiveDayForecastDataList[index];
                    return Card(
                      color: Colors.teal,
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              DateFormat('EEEE').format(dailyForecast.time),
                              style: const TextStyle(color: Colors.white),
                            ),
                            Image.network(
                              'http://openweathermap.org/img/w/${dailyForecast.icon}.png',
                              width: 50,
                              height: 30,
                            ),
                          ],
                        ),
                        title: Text(
                          dailyForecast.description,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'High: ${dailyForecast.tempMaxCelsius.toStringAsFixed(1)}°C',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Low: ${dailyForecast.tempMinCelsius.toStringAsFixed(1)}°C',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.info_outline, color: Colors.black),
                  title: Container(
                    padding: const EdgeInsets.all(20.0),
                    color: getAqiColor(widget.airQualityData
                        .aqi), // This will be a soothing color based on the AQI
                    child: Text(
                      getAqiDescription(widget.airQualityData.aqi),
                      style: TextStyle(
                        fontSize: 12, // Smaller font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onExpansionChanged: _toggleExpansion,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation!,
                      child: Column(
                        children: widget.airQualityData.components.entries
                            .map((entry) {
                          final component = entry.key;
                          final value = entry.value;
                          final color = getColorForComponent(
                              value); // This will be a soothing color based on the component value

                          return ListTile(
                            title: Text(
                              '$component: $value',
                              style: TextStyle(
                                fontSize:
                                    10, // Even smaller font size for the list tile
                                color: Colors
                                    .black, // Ensuring readability against the tile color
                              ),
                            ),
                            tileColor: color,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 1.5),
                  children: [
                    _buildWeatherCard(
                        'Feels Like',
                        '${currentWeather.feelsLikeCelsius.toStringAsFixed(2)}°C',
                        '🌡️'),
                    _buildWeatherCard(
                        'Pressure', '${currentWeather.pressure} hPa', '🧬'),
                    _buildWeatherCard(
                        'Humidity', '${currentWeather.humidity}%', '💧'),
                    _buildWeatherCard(
                        'Sea Level', '${currentWeather.seaLevel} hPa', '🌊'),
                    _buildWeatherCard('Ground Level',
                        '${currentWeather.grndLevel} hPa', '🏞️'),
                    _buildWeatherCard('Visibility',
                        '${currentWeather.visibility / 1000} km', '👓'),
                    _buildWeatherCard(
                        'Wind Speed', '${currentWeather.windSpeed} m/s', '💨'),
                    _buildWeatherCard(
                        'Wind Direction', '${currentWeather.windDeg}°', '🧭'),
                    _buildWeatherCard(
                        'Wind Gust', '${currentWeather.windGust} m/s', '🌪️'),
                    _buildWeatherCard(
                        'Cloudiness', '${currentWeather.clouds}%', '☁️'),
                    _buildWeatherCard(
                        'Sunrise',
                        DateFormat('hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                currentWeather.sunrise * 1000)),
                        '🌅'),
                    _buildWeatherCard(
                        'Sunset',
                        DateFormat('hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                currentWeather.sunset * 1000)),
                        '🌇'),
                    _buildWeatherCard(
                        'Timezone', currentWeather.timezone, '🕒'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildWeatherCard(String title, String value, String unicodeIcon) {
  return Card(
    color: Colors.orangeAccent, // A warm, comfortable color for the background
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(unicodeIcon,
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.brown)), // Dark color for the icon
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)), // Dark color for the title
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.black)), // Dark color for the value
        ],
      ),
    ),
  );
}
