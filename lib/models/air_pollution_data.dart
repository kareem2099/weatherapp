class AirPollutionData {
  final int aqi;
  final Map<String, double> components;

  AirPollutionData({required this.aqi, required this.components});

  factory AirPollutionData.fromJson(Map<String, dynamic> json) {
    return AirPollutionData(
      aqi: json['list'][0]['main']['aqi'],
      components: Map.from(json['list'][0]['components']),
    );
  }

  @override
  String toString() {
    return 'AirPollutionData{aqi: $aqi, components: $components}';
  }
}
