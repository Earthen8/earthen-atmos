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
      // Connect to the Django backend
      // Using 10.0.2.2 for Android emulator, change to localhost for web/iOS
      // Assuming django runs on port 8000
      final Uri url = Uri.parse('http://127.0.0.1:8000/api/weather/?city=$city');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weather = WeatherModel.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        errorMessage = errorData['error'] ?? 'Failed to fetch weather data';
      }
    } catch (e) {
      errorMessage = 'Could not connect to the server';
    }

    isLoading = false;
    notifyListeners();
  }
}
