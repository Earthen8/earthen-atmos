import 'dart:math';
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

// ─────────────────────────────────────────────────────────────
//  WEATHER PARTICLE DATA MODEL
// ─────────────────────────────────────────────────────────────
class _Particle {
  double x, y, speed, size, opacity, drift;
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    this.drift = 0,
  });
}

// ─────────────────────────────────────────────────────────────
//  WEATHER BACKGROUND PAINTER
// ─────────────────────────────────────────────────────────────
class WeatherBackgroundPainter extends CustomPainter {
  final String condition;
  final double animValue; // 0.0 → 1.0 looping
  final List<_Particle> particles;

  WeatherBackgroundPainter({
    required this.condition,
    required this.animValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition.toLowerCase()) {
      case 'clear':
        _paintClear(canvas, size);
        break;
      case 'clouds':
        _paintCloudy(canvas, size);
        break;
      case 'rain':
        _paintRain(canvas, size);
        break;
      case 'snow':
        _paintSnow(canvas, size);
        break;
      case 'thunderstorm':
        _paintThunderstorm(canvas, size);
        break;
      default:
        _paintDefault(canvas, size);
    }
  }

  // ── CLEAR / SUNNY ──────────────────────────────────────────
  void _paintClear(Canvas canvas, Size size) {
    // Sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0B6EE0),
          const Color(0xFF44AAFF),
          const Color(0xFFFFC47A),
          const Color(0xFFFF8C42),
        ],
        stops: const [0.0, 0.4, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Sun orb
    final sunX = size.width * 0.72;
    final sunY = size.height * 0.18;
    final sunPulse = 1.0 + 0.04 * sin(animValue * 2 * pi);

    // Outer glow layers
    for (int i = 3; i >= 0; i--) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.04 + i * 0.02)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30.0 + i * 20);
      canvas.drawCircle(Offset(sunX, sunY), 60 * sunPulse + i * 30, glowPaint);
    }

    // Sun core
    final sunPaint = Paint()
      ..color = const Color(0xFFFFF176)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(sunX, sunY), 38 * sunPulse, sunPaint);
    canvas.drawCircle(
      Offset(sunX, sunY),
      30 * sunPulse,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Animated light rays
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi + animValue * 2 * pi * 0.12;
      final r1 = 55.0;
      final r2 = 110.0 + 20 * sin(animValue * 2 * pi + i);
      canvas.drawLine(
        Offset(sunX + r1 * cos(angle), sunY + r1 * sin(angle)),
        Offset(sunX + r2 * cos(angle), sunY + r2 * sin(angle)),
        rayPaint,
      );
    }

    // Floating light orbs (Frutiger Aero bubbles)
    for (final p in particles) {
      final py = (p.y - animValue * p.speed * size.height * 0.5) % size.height;
      final orbPaint = Paint()
        ..color = Colors.white.withOpacity(p.opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(p.x * size.width, py), p.size * 20, orbPaint);

      // Aero glint on orb
      canvas.drawCircle(
        Offset(p.x * size.width - p.size * 4, py - p.size * 4),
        p.size * 4,
        Paint()..color = Colors.white.withOpacity(p.opacity * 0.7),
      );
    }

    _paintHorizonGlow(canvas, size, const Color(0xFFFF8C42));
  }

  // ── CLOUDY ─────────────────────────────────────────────────
  void _paintCloudy(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A5568),
          const Color(0xFF718096),
          const Color(0xFF9FB3C8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Layered drifting clouds
    _drawCloud(canvas, size, 0.12, 0.15, 0.8, animValue * 0.04, 0);
    _drawCloud(canvas, size, 0.55, 0.10, 0.65, animValue * 0.025, 0.3);
    _drawCloud(canvas, size, 0.30, 0.28, 0.9, animValue * 0.035, 0.6);
    _drawCloud(canvas, size, 0.70, 0.35, 0.55, animValue * 0.045, 0.1);
    _drawCloud(canvas, size, -0.05, 0.42, 0.7, animValue * 0.03, 0.8);

    // Subtle light leak from above
    final lightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, -0.8),
        radius: 0.8,
        colors: [Colors.white.withOpacity(0.08), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), lightPaint);
  }

  void _drawCloud(
    Canvas canvas,
    Size size,
    double xFrac,
    double yFrac,
    double scale,
    double drift,
    double phase,
  ) {
    final cx =
        ((xFrac + drift + sin(animValue * 2 * pi + phase) * 0.015)) *
        size.width;
    final cy = yFrac * size.height;
    final r = scale * size.width * 0.22;

    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    final puffs = [
      Offset(cx, cy),
      Offset(cx - r * 0.55, cy + r * 0.2),
      Offset(cx + r * 0.55, cy + r * 0.2),
      Offset(cx - r * 0.3, cy - r * 0.25),
      Offset(cx + r * 0.3, cy - r * 0.25),
    ];
    final sizes = [r * 0.9, r * 0.7, r * 0.7, r * 0.6, r * 0.6];

    for (int i = 0; i < puffs.length; i++) {
      canvas.drawCircle(puffs[i], sizes[i], cloudPaint);
    }

    // Crisp highlight on top
    canvas.drawCircle(
      Offset(cx - r * 0.1, cy - r * 0.3),
      r * 0.4,
      Paint()..color = Colors.white.withOpacity(0.25),
    );
  }

  // ── RAIN ───────────────────────────────────────────────────
  void _paintRain(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1A1F3A),
          const Color(0xFF2D3561),
          const Color(0xFF3A4875),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Dark cloud layer at top
    _drawCloud(canvas, size, 0.05, 0.08, 0.75, animValue * 0.015, 0);
    _drawCloud(canvas, size, 0.50, 0.05, 0.85, animValue * 0.012, 0.5);
    _drawCloud(canvas, size, 0.85, 0.10, 0.65, animValue * 0.018, 0.2);

    // Override cloud paint to dark
    final darkCloudPaint = Paint()
      ..color = const Color(0xFF2A3050).withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.22),
      darkCloudPaint,
    );

    // Falling rain streaks
    final rainPaint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.35)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (final p in particles) {
      final py = (p.y + animValue * p.speed) % 1.0;
      final px = p.x + p.drift * animValue * 0.08;
      final startY = py * size.height;
      final endY = startY + p.size * size.height * 0.06;

      canvas.drawLine(
        Offset(px * size.width, startY),
        Offset((px - 0.01) * size.width, endY),
        rainPaint,
      );
    }

    // Puddle shimmer at bottom
    final shimmerPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.lightBlue.withOpacity(
                0.08 + 0.04 * sin(animValue * 2 * pi),
              ),
            ],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.75,
              size.width,
              size.height * 0.25,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25),
      shimmerPaint,
    );
  }

  // ── SNOW ───────────────────────────────────────────────────
  void _paintSnow(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6B9EC7),
          const Color(0xFFB8D4E8),
          const Color(0xFFE8F4FD),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Soft cloud wisps
    _drawCloud(canvas, size, 0.1, 0.12, 0.6, animValue * 0.01, 0);
    _drawCloud(canvas, size, 0.6, 0.08, 0.7, animValue * 0.008, 0.4);

    // Snowflakes (circles with glow)
    for (final p in particles) {
      final driftX = sin(animValue * 2 * pi + p.drift) * 0.04;
      final px = (p.x + driftX + animValue * p.drift * 0.02) % 1.0;
      final py = (p.y + animValue * p.speed * 0.4) % 1.0;

      final snowPaint = Paint()
        ..color = Colors.white.withOpacity(p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 1.5);
      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        p.size * 5,
        snowPaint,
      );
      // Sparkle core
      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        p.size * 2.5,
        Paint()..color = Colors.white.withOpacity(p.opacity + 0.2),
      );
    }

    // Snow ground accumulation at bottom
    final groundPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 1.02),
        width: size.width * 1.3,
        height: size.height * 0.15,
      ),
      groundPaint,
    );
  }

  // ── THUNDERSTORM ───────────────────────────────────────────
  void _paintThunderstorm(Canvas canvas, Size size) {
    // Base dark sky
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0D0D1A),
          const Color(0xFF1A1330),
          const Color(0xFF2D1B4E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Heavy rain (denser particles)
    final rainPaint = Paint()
      ..color = Colors.indigo.shade100.withOpacity(0.25)
      ..strokeWidth = 1.0;
    for (final p in particles) {
      final py = (p.y + animValue * p.speed * 1.4) % 1.0;
      final px = p.x + p.drift * animValue * 0.06;
      canvas.drawLine(
        Offset(px * size.width, py * size.height),
        Offset((px - 0.012) * size.width, (py + 0.05) * size.height),
        rainPaint,
      );
    }

    // Lightning flash: periodic bright overlay
    final flashPhase = (animValue * 3.7) % 1.0;
    if (flashPhase < 0.04 || (flashPhase > 0.06 && flashPhase < 0.09)) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(0.12 * (1 - flashPhase / 0.09))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);

      // Lightning bolt path
      if (flashPhase < 0.04) {
        final boltPaint = Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final bx = size.width * 0.6;
        final path = Path()
          ..moveTo(bx, size.height * 0.05)
          ..lineTo(bx - 18, size.height * 0.22)
          ..lineTo(bx + 10, size.height * 0.22)
          ..lineTo(bx - 22, size.height * 0.48);
        canvas.drawPath(path, boltPaint);

        // Glow around bolt
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFCCEEFF).withOpacity(0.4)
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
        );
      }
    }

    // Purple ambient glow
    final purplePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.8,
        colors: [
          const Color(
            0xFF7B2FBE,
          ).withOpacity(0.2 + 0.05 * sin(animValue * 2 * pi)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), purplePaint);
  }

  // ── DEFAULT / MIST ─────────────────────────────────────────
  void _paintDefault(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E3A5F),
          const Color(0xFF3D7AB5),
          const Color(0xFF7FB3D3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    for (final p in particles) {
      final pulse = 0.5 + 0.5 * sin(animValue * 2 * pi + p.drift);
      final orbPaint = Paint()
        ..color = Colors.white.withOpacity(p.opacity * 0.3 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 30);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * 80,
        orbPaint,
      );
    }

    _paintHorizonGlow(canvas, size, const Color(0xFF3D7AB5));
  }

  // ── SHARED HELPERS ─────────────────────────────────────────
  void _paintHorizonGlow(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, color.withOpacity(0.3)],
          ).createShader(
            Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(WeatherBackgroundPainter oldDelegate) =>
      oldDelegate.animValue != animValue || oldDelegate.condition != condition;
}

// ─────────────────────────────────────────────────────────────
//  WEATHER BACKGROUND WIDGET
// ─────────────────────────────────────────────────────────────
class WeatherBackground extends StatefulWidget {
  final String condition;
  const WeatherBackground({super.key, required this.condition});

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _loopController;
  late List<_Particle> _particles;
  String _currentCondition = '';

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _currentCondition = widget.condition;
    _generateParticles(widget.condition);
  }

  @override
  void didUpdateWidget(WeatherBackground old) {
    super.didUpdateWidget(old);
    if (old.condition != widget.condition) {
      setState(() {
        _currentCondition = widget.condition;
        _generateParticles(widget.condition);
      });
    }
  }

  void _generateParticles(String condition) {
    final rng = Random();
    final cond = condition.toLowerCase();

    int count;
    if (cond == 'rain' || cond == 'thunderstorm') {
      count = 120;
    } else if (cond == 'snow') {
      count = 60;
    } else if (cond == 'clear') {
      count = 8;
    } else {
      count = 6;
    }

    _particles = List.generate(count, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        size: 0.3 + rng.nextDouble() * 0.7,
        opacity: 0.3 + rng.nextDouble() * 0.5,
        drift: (rng.nextDouble() - 0.5) * 2,
      );
    });
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1400),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: AnimatedBuilder(
        key: ValueKey(_currentCondition),
        animation: _loopController,
        builder: (context, _) {
          return CustomPaint(
            painter: WeatherBackgroundPainter(
              condition: _currentCondition,
              animValue: _loopController.value,
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  WEATHER SCREEN
// ─────────────────────────────────────────────────────────────
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

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

  Widget _buildStatsGrid(weather) {
    final stats = [
      (
        Icons.water_drop_rounded,
        'Humidity',
        '${weather.humidity.toStringAsFixed(0)}%',
      ),
      (
        Icons.thermostat_rounded,
        'Feels Like',
        '${weather.feelsLike.toStringAsFixed(1)}°',
      ),
      (
        Icons.air_rounded,
        'Wind',
        '${weather.windSpeed.toStringAsFixed(1)} m/s',
      ),
      (
        Icons.visibility_rounded,
        'Visibility',
        '${(weather.visibility / 1000).toStringAsFixed(1)} km',
      ),
      (
        Icons.compress_rounded,
        'Pressure',
        '${weather.pressure.toStringAsFixed(0)} hPa',
      ),
      (Icons.wb_cloudy_rounded, 'Condition', weather.condition),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final (icon, label, value) = stats[index];
        return _buildStatTile(icon, label, value);
      },
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white60, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final condition = weatherProvider.weather?.condition ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── ANIMATED BACKGROUND ──────────────────────────────
          Positioned.fill(child: WeatherBackground(condition: condition)),

          // ── AMBIENT ORB: top-right glow ──────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // ── AMBIENT ORB: bottom-left glow ────────────────────
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // ── SCROLLABLE CONTENT ───────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── GLASSMORPHISM CARD ─────────────
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
                                        padding: EdgeInsets.symmetric(
                                          vertical: 64,
                                        ),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else if (weatherProvider
                                        .errorMessage
                                        .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 48,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.cloud_off_rounded,
                                              size: 56,
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              weatherProvider.errorMessage,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
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
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 10,
                                                sigmaY: 10,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.18),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.25),
                                                  ),
                                                ),
                                                child: Text(
                                                  weatherProvider
                                                      .weather!
                                                      .condition,
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
                                          _buildStatsGrid(
                                            weatherProvider.weather!,
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
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Search for a city\nto see the weather',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white.withOpacity(
                                                  0.6,
                                                ),
                                                height: 1.6,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),

                                    const SizedBox(height: 36),

                                    // ── SEARCH INPUT ───────────
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
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 20,
                                                  horizontal: 24,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              borderSide: const BorderSide(
                                                color: Colors.white,
                                                width: 1.5,
                                              ),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.search_rounded,
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
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
                );
              },
            ),
          ),

          // ── ATMOS TITLE (pinned top) ──────────────────────────
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
