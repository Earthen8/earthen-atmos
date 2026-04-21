class WeatherModel {
  final double temperature;
  final String condition;
  final double humidity;
  final String cityName;
  final double feelsLike;
  final double windSpeed;
  final double visibility;
  final double pressure;

  WeatherModel({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.cityName,
    required this.feelsLike,
    required this.windSpeed,
    required this.visibility,
    required this.pressure,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: _parseDouble(json['temperature']),
      condition: json['condition'] ?? 'Unknown',
      humidity: _parseDouble(json['humidity']),
      cityName: json['city_name'] ?? 'Unknown',
      feelsLike: _parseDouble(json['feels_like']),
      windSpeed: _parseDouble(json['wind_speed']),
      visibility: _parseDouble(json['visibility']),
      pressure: _parseDouble(json['pressure']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}
