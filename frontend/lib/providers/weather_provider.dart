import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? weather;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchWeather(String city) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // Using 10.0.2.2 for Android emulator, change to localhost for web/iOS
      final Uri url = Uri.parse(
        'http://127.0.0.1:8000/api/weather/?city=$city',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weather = WeatherModel.fromJson(data);
      } else {
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? 'Failed to fetch weather data';
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
