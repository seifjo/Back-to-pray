import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import '../../core/services/qibla_service.dart';
import '../../core/theme/app_theme.dart';

/// Qibla Screen
/// Shows compass pointing to Kaaba direction
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final QiblaService _qiblaService = QiblaService();
  double? _qiblaDirection;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
  }

  Future<void> _calculateQibla() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final position = await _qiblaService.getCurrentLocation();
      final direction = await _qiblaService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _qiblaDirection = direction;
        _isLoading = false;
      });
    } catch (e) {
      String errorMessage = 'خطأ في حساب اتجاه القبلة';
      if (e.toString().contains('denied')) {
        errorMessage = 'تم رفض الإذن بالوصول للموقع. يرجى تفعيله من إعدادات الهاتف.';
      } else {
        errorMessage = 'خطأ: ${e.toString()}';
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calculateQibla,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _calculateQibla,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('جاري تفعيل البوصلة...'));
                    }

                    final compassHeading = snapshot.data!.heading;
                    if (compassHeading == null) {
                      return const Center(
                        child: Text('البوصلة غير متاحة على هذا الجهاز'),
                      );
                    }

                    // Calculate direction to rotate compass
                    final qiblaHeading = _qiblaDirection! - compassHeading;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Qibla info
                        const Text(
                          'اتجاه القبلة',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_qiblaDirection!.toStringAsFixed(1)}°',
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        
                        // Compass
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Compass circle
                            Transform.rotate(
                              angle: qiblaHeading * (math.pi / 180),
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryGreen,
                                    width: 4,
                                  ),
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.primaryGreen.withValues(alpha: 0.2),
                                      AppTheme.primaryGreen.withValues(alpha: 0.05),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.navigation,
                                  size: 120,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            // Kaaba icon
                            const Icon(
                              Icons.mosque,
                              size: 48,
                              color: AppTheme.accentGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Instructions
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text("قم بتدوير هاتفك حتى يشير السهم إلى اتجاه الكعبة المشرفة",
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
