import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atmos Weather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  Color _getBackgroundColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Colors.orangeAccent.shade200;
      case 'clouds':
        return Colors.blueGrey.shade300;
      case 'rain':
        return Colors.indigo.shade400;
      case 'snow':
        return Colors.lightBlue.shade100;
      case 'thunderstorm':
        return Colors.deepPurple.shade700;
      default:
        return Colors.blue.shade300;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _searchWeather() {
    if (_cityController.text.trim().isNotEmpty) {
      context.read<WeatherProvider>().fetchWeather(_cityController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final condition = weatherProvider.weather?.condition ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Bottom layer: AnimatedContainer based on weather
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            color: _getBackgroundColor(condition),
            width: double.infinity,
            height: double.infinity,
          ),

          // Middle Layer: BackdropFilter (Glassmorphism)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (weatherProvider.isLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else if (weatherProvider.errorMessage.isNotEmpty)
                        Text(
                          weatherProvider.errorMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        )
                      else if (weatherProvider.weather != null)
                        Column(
                          children: [
                            Text(
                              weatherProvider.weather!.cityName,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${weatherProvider.weather!.temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              weatherProvider.weather!.condition,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Humidity: ${weatherProvider.weather!.humidity}%',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Search for a city',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top layer: TextField for city search
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: TextField(
                controller: _cityController,
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter city name...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _searchWeather,
                  ),
                ),
                onSubmitted: (_) => _searchWeather(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
