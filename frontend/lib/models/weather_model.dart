class WeatherModel {
  final double temperature;
  final String condition;
  final double humidity;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: _parseDouble(json['temperature']),
      condition: json['condition'] ?? 'Unknown',
      humidity: _parseDouble(json['humidity']),
      cityName: json['city_name'] ?? 'Unknown',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return 0.0;
    }
  }
}
