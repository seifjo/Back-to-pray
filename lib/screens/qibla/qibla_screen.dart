import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../core/services/prayer_time_service.dart';
import '../../core/services/qibla_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final QiblaService _qiblaService = QiblaService();
  final PrayerTimeService _locationStore = PrayerTimeService();
  double? _qiblaDirection;
  bool _isLoading = true;
  String? _error;
  bool _usedSavedLocation = false;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
  }

  Future<void> _calculateQibla({double? latitude, double? longitude}) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _usedSavedLocation = false;
    });
    try {
      double lat;
      double lon;
      if (latitude != null && longitude != null) {
        lat = latitude;
        lon = longitude;
        await _locationStore.saveLastLocation(lat, lon);
      } else {
        try {
          final position = await _qiblaService.getCurrentLocation();
          lat = position.latitude;
          lon = position.longitude;
          await _locationStore.saveLastLocation(lat, lon);
        } catch (_) {
          final saved = await _locationStore.getLastLocation();
          if (saved == null) rethrow;
          lat = saved['latitude']!;
          lon = saved['longitude']!;
          _usedSavedLocation = true;
        }
      }
      final direction = _qiblaService.bearingFrom(lat, lon);
      if (!mounted) return;
      setState(() {
        _qiblaDirection = direction;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'location';
        _isLoading = false;
      });
    }
  }

  Future<void> _manualLocation() async {
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final saved = await _locationStore.getLastLocation();
    if (saved != null) {
      latController.text = saved['latitude']!.toStringAsFixed(4);
      lonController.text = saved['longitude']!.toStringAsFixed(4);
    }
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('manualLocation')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: context.tr('latitude')),
            ),
            TextField(
              controller: lonController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: context.tr('longitude')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('applyLocation')),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) {
      latController.dispose();
      lonController.dispose();
      return;
    }
    final lat = double.tryParse(latController.text.trim());
    final lon = double.tryParse(lonController.text.trim());
    latController.dispose();
    lonController.dispose();
    if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('invalidCoordinates'))),
      );
      return;
    }
    await _calculateQibla(latitude: lat, longitude: lon);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('qiblaTitle')),
        actions: [
          IconButton(
            tooltip: context.tr('manualLocation'),
            onPressed: _manualLocation,
            icon: const Icon(Icons.edit_location_alt_outlined),
          ),
          IconButton(
            tooltip: context.tr('refresh'),
            onPressed: _calculateQibla,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _LocationMessage(onRetry: _calculateQibla, onManual: _manualLocation)
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _CompassMessage(message: context.tr('compassUnavailable'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: Text(context.tr('loading')));
                    }
                    final heading = snapshot.data!.heading;
                    if (heading == null) {
                      return _CompassMessage(message: context.tr('compassUnavailable'));
                    }
                    final qibla = _qiblaDirection!;
                    final difference = QiblaService.angularDifference(heading, qibla);
                    final aligned = QiblaService.isAligned(heading, qibla);
                    final accuracy = snapshot.data!.accuracy;
                    final needsCalibration = accuracy != null && (accuracy < 0 || accuracy > 25);
                    final needle = (qibla - heading) * (math.pi / 180);

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (_usedSavedLocation)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              context.tr('usingSavedLocation'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
                            ),
                          ),
                        _CompassDial(
                          needleRadians: needle,
                          aligned: aligned,
                          isDark: Theme.of(context).brightness == Brightness.dark,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          aligned ? context.tr('aligned') : context.tr('turnDevice'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: aligned ? 22 : 16,
                            fontWeight: FontWeight.w700,
                            color: aligned ? Colors.green : scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StatRow(
                          label: context.tr('qiblaDirection'),
                          value: '${qibla.toStringAsFixed(1)}°',
                        ),
                        _StatRow(
                          label: context.tr('currentHeading'),
                          value: '${heading.toStringAsFixed(1)}°',
                        ),
                        _StatRow(
                          label: context.tr('difference'),
                          value: '${difference.toStringAsFixed(1)}°',
                        ),
                        _StatRow(
                          label: context.tr('accuracy'),
                          value: accuracy == null
                              ? context.tr('unknown')
                              : '±${accuracy.abs().toStringAsFixed(0)}°',
                        ),
                        if (needsCalibration) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.tr('calibrating'),
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(context.tr('calibrateHelp')),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          context.tr('sensorHelp'),
                          style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _CompassDial extends StatelessWidget {
  final double needleRadians;
  final bool aligned;
  final bool isDark;

  const _CompassDial({
    required this.needleRadians,
    required this.aligned,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ring = aligned ? Colors.green : AppTheme.primaryGreen;
    return Center(
      child: AnimatedRotation(
        turns: needleRadians / (2 * math.pi),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF121A2B) : Colors.white,
            border: Border.all(color: ring, width: aligned ? 6 : 3),
            boxShadow: [
              BoxShadow(
                color: ring.withValues(alpha: aligned ? 0.35 : 0.15),
                blurRadius: aligned ? 28 : 12,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _QiblaNeedlePainter(color: ring),
            child: const Align(
              alignment: Alignment(0, -0.62),
              child: Icon(Icons.mosque, color: AppTheme.accentGold, size: 34),
            ),
          ),
        ),
      ),
    );
  }
}

class _QiblaNeedlePainter extends CustomPainter {
  final Color color;
  _QiblaNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tip = Offset(center.dx, center.dy - size.height * 0.38);
    final left = Offset(center.dx - 14, center.dy + 28);
    final right = Offset(center.dx + 14, center.dy + 28);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(center, 8, Paint()..color = AppTheme.accentGold);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        ],
      ),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onManual;
  const _LocationMessage({required this.onRetry, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined, size: 56),
          const SizedBox(height: 12),
          Text(context.tr('locationNeeded'), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(context.tr('locationPermissionHelp'), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(context.tr('retry'))),
          TextButton(onPressed: onManual, child: Text(context.tr('manualLocation'))),
        ],
      ),
    );
  }
}

class _CompassMessage extends StatelessWidget {
  final String message;
  const _CompassMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.explore_off_outlined, size: 56),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(context.tr('sensorHelp'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
