import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/services/intro_audio.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';

/// Cinematic opening. The painted light stays behind the real Al Noor mark.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _length = Duration(milliseconds: 5000);

  late final AnimationController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    _controller = AnimationController(vsync: this, duration: _length)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finish();
      })
      ..forward();
    // Wait one frame so the platform channel is fully attached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAudio();
    });
  }

  Future<void> _startAudio() async {
    final settings = context.read<AppSettingsProvider>();
    if (!settings.isLoaded) await settings.load();
    if (!mounted || _finished || !settings.introSoundEnabled) return;
    await IntroAudio.instance.playIfAllowed();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_finished) return;
    if (state == AppLifecycleState.paused) {
      IntroAudio.instance.pause();
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      IntroAudio.instance.resume();
      if (!_finished) _controller.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final logoWidth = math.min(constraints.maxWidth * 0.72, 420.0);
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value * 5;
              final reveal = Curves.easeOutCubic
                  .transform(((t - 1.0) / 1.45).clamp(0.0, 1.0));
              final pulse = t > 2.2 ? math.sin((t - 2.2) * 2.5) : 0.0;
              final scale = (0.84 + 0.16 * reveal) * (1 + pulse * 0.012);
              final tilt = (1 - reveal) * 0.28;
              final burst = reveal * (0.45 + (t > 2 ? math.sin(t * 2.2) * 0.12 : 0));
              final shimmer = ((t - 1.7) / 1.8).clamp(0.0, 1.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _SplashScenePainter(time: t),
                  ),
                  Center(
                    child: Opacity(
                      opacity: reveal,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..rotateY(tilt)
                          ..scaleByDouble(scale, scale, 1, 1),
                        child: SizedBox(
                          width: logoWidth,
                          height: logoWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD978).withValues(alpha: burst),
                                      blurRadius: 48,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF39F0FF).withValues(alpha: 0.22 * reveal),
                                      blurRadius: 36,
                                    ),
                                  ],
                                ),
                                child: const SizedBox.expand(),
                              ),
                              child!,
                              if (t > 1.6 && t < 3.6)
                                IgnorePointer(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(logoWidth * 0.18),
                                    child: ShaderMask(
                                      blendMode: BlendMode.dstIn,
                                      shaderCallback: (rect) {
                                        return LinearGradient(
                                          begin: Alignment(-1.2 + shimmer * 2.4, -0.6),
                                          end: Alignment(-0.4 + shimmer * 2.4, 0.8),
                                          colors: const [
                                            Colors.transparent,
                                            Colors.white,
                                            Colors.transparent,
                                          ],
                                        ).createShader(rect);
                                      },
                                      child: const ColoredBox(
                                        color: Color(0x55FFFFFF),
                                        child: SizedBox.expand(),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (t >= 1)
                    SafeArea(
                      child: Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: TextButton(
                            onPressed: () {
                              IntroAudio.instance.stop();
                              _finish();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              minimumSize: const Size(48, 48),
                            ),
                            child: Text(context.tr('skip')),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            child: Image.asset(
              'assets/images/alnoor_logo.png',
              width: logoWidth,
              height: logoWidth,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          );
        },
      ),
    );
  }
}

class _SplashScenePainter extends CustomPainter {
  final double time;

  _SplashScenePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF000000));

    final center = size.center(Offset.zero);
    final glow = _fadeIn(time, 0.15, 1.1);
    canvas.drawCircle(
      center,
      size.shortestSide * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF1EC8FF).withValues(alpha: 0.22 * glow),
            const Color(0xFF0A2A55).withValues(alpha: 0.18 * glow),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: size.shortestSide * 0.42)),
    );

    _patterns(canvas, size, _fadeIn(time, 0, 1));
    final wave = _fadeIn(time, 1.5, 2.4);
    if (wave > 0) {
      _ribbon(canvas, size, phase: time * 0.55, clockwise: true, strength: wave, tint: const Color(0xFF39F6FF));
      _ribbon(canvas, size, phase: -time * 0.42, clockwise: false, strength: wave * 0.85, tint: const Color(0xFF1478FF));
      _ribbon(canvas, size, phase: time * 0.33 + 1.4, clockwise: true, strength: wave * 0.55, tint: const Color(0xFF7AF7FF));
    }
    _sparks(canvas, size, _fadeIn(time, 0.25, 1.1));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Colors.transparent, Color(0xCC000000)],
          stops: [0.55, 1],
        ).createShader(rect),
    );
  }

  void _patterns(Canvas canvas, Size size, double alpha) {
    if (alpha <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF1C6B78).withValues(alpha: 0.55 * alpha);
    const step = 78.0;
    for (double y = 24; y < size.height; y += step) {
      for (double x = 24; x < size.width; x += step) {
        final dx = (x / size.width - 0.5).abs();
        final dy = (y / size.height - 0.5).abs();
        if (dx < 0.28 && dy < 0.30) continue;
        _motif(canvas, Offset(x, y), 16, paint);
      }
    }
  }

  void _motif(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i - math.pi / 2;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _ribbon(
    Canvas canvas,
    Size size, {
    required double phase,
    required bool clockwise,
    required double strength,
    required Color tint,
  }) {
    final center = size.center(Offset.zero);
    final path = Path();
    const steps = 70;
    for (var i = 0; i <= steps; i++) {
      final u = i / steps;
      final angle = u * math.pi * 1.7 + phase + (clockwise ? 0 : math.pi);
      final breathe = math.sin(angle * 2.4 + time) * size.shortestSide * 0.035;
      final rx = size.width * (0.46 + (clockwise ? 0.04 : -0.02)) + breathe;
      final ry = size.height * 0.28 + breathe * 0.45;
      final point = Offset(
        center.dx + math.cos(angle) * rx,
        center.dy + math.sin(angle) * ry,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = tint.withValues(alpha: 0.16 * strength)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = tint.withValues(alpha: 0.72 * strength),
    );
  }

  void _sparks(Canvas canvas, Size size, double alpha) {
    if (alpha <= 0) return;
    for (var i = 0; i < 24; i++) {
      final seedX = _hash(i * 17);
      final seedY = _hash(i * 29 + 4);
      final speed = 0.012 + _hash(i * 7) * 0.02;
      final drift = (time * speed + (i.isEven ? seedX : -seedX)) * 18;
      final x = _wrap(seedX * size.width + drift, size.width);
      final y = _wrap(seedY * size.height - time * (12 + speed * 80), size.height);
      final radius = 1.1 + _hash(i * 3) * 1.8;
      final twinkle = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(time * 3 + i));
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = const Color(0xFFBFFBFF).withValues(alpha: alpha * twinkle)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  double _wrap(double value, double extent) {
    if (extent <= 0) return 0;
    final wrapped = value % extent;
    return wrapped < 0 ? wrapped + extent : wrapped;
  }

  double _hash(int n) {
    final v = math.sin(n * 12.9898) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _SplashScenePainter oldDelegate) {
    return oldDelegate.time != time;
  }
}

double _fadeIn(double time, double start, double end) {
  if (time <= start) return 0;
  if (time >= end) return 1;
  return Curves.easeOut.transform((time - start) / (end - start));
}
