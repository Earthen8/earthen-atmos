import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
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

  // BACKGROUND LOGIC
  List<Color> _getBackgroundColors(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return [Colors.orange.shade400, Colors.deepOrange.shade800];
      case 'clouds':
        return [Colors.blueGrey.shade400, Colors.blueGrey.shade800];
      case 'rain':
        return [Colors.indigo.shade500, Colors.blueGrey.shade900];
      case 'snow':
        return [Colors.lightBlue.shade300, Colors.blue.shade700];
      case 'thunderstorm':
        return [Colors.deepPurple.shade600, Colors.black87];
      default:
        return [Colors.blue.shade400, Colors.blue.shade900];
    }
  }

  // ICON LOGIC
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
        return Icons.water_drop_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
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
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final condition = weatherProvider.weather?.condition ?? '';
    final bgColors = _getBackgroundColors(condition);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // BACKGROUND LAYER
          AnimatedContainer(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),

          // AMBIENT ORB 1: top-right glow
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1200),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // AMBIENT ORB 2: bottom-left glow
          Positioned(
            bottom: -100,
            left: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1200),
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // SCROLLABLE CONTENT LAYER
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                child: Column(
                  children: [
                    // GLASSMORPHISM CARD
                    ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.22),
                                Colors.white.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 40,
                                spreadRadius: 2,
                                offset: const Offset(0, 16),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.08),
                                blurRadius: 1,
                                spreadRadius: 0,
                                offset: const Offset(0, -1),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (weatherProvider.isLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 64),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              else if (weatherProvider.errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 48,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_off_rounded,
                                        size: 56,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        weatherProvider.errorMessage,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else if (weatherProvider.weather != null)
                                Column(
                                  children: [
                                    Icon(
                                      _getWeatherIcon(condition),
                                      size: 96,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      weatherProvider.weather!.cityName,
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${weatherProvider.weather!.temperature.toStringAsFixed(1)}°',
                                      style: const TextStyle(
                                        fontSize: 88,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.25,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            weatherProvider.weather!.condition,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    // STATS ROW
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.water_drop_rounded,
                                                color: Colors.white70,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${weatherProvider.weather!.humidity.toStringAsFixed(0)}% Humidity',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 48,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.travel_explore_rounded,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Search for a city\nto see the weather',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.6),
                                          height: 1.6,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 36),

                              // SEARCH INPUT
                              ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: TextField(
                                    controller: _cityController,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search city...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.2),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 20,
                                            horizontal: 24,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                        ),
                                        onPressed: _searchWeather,
                                      ),
                                    ),
                                    onSubmitted: (_) => _searchWeather(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // FIXED TOP LAYER: Atmos title pinned to the top of the screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Text(
                  'Atmos',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
