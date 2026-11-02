import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme
/// Defines colors, typography, and styles for the Islamic app
class AppTheme {
  // Primary Colors - Islamic Green & Gold
  static const Color primaryGreen = Color(0xFF0D7377);
  static const Color secondaryGreen = Color(0xFF14FFEC);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentCyan = Color(0xFF14FFEC); // For achievements/rewards
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF16213E);

  // Prayer Time Colors
  static const Color fajrColor = Color(0xFF6B5B95);
  static const Color dhuhrColor = Color(0xFF88B04B);
  static const Color asrColor = Color(0xFFFF6F61);
  static const Color maghribColor = Color(0xFF5B5A56);
  static const Color ishaColor = Color(0xFF45B8AC);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textArabic = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFF6F3EE);
  static const Color lightSurface = Color(0xFFFFFCF8);
  static const Color lightInk = Color(0xFF1C2430);

  // Custom Typography
  static TextStyle quranArabic = GoogleFonts.amiri(
    fontSize: 32,
    height: 1.8,
    color: textArabic,
    fontWeight: FontWeight.w500,
  );

  /// Warm light theme that keeps the teal and gold identity.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGold,
      surface: lightSurface,
      error: Color(0xFFB42318),
      onPrimary: Colors.white,
      onSurface: lightInk,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: lightInk,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: lightSurface,
      margin: EdgeInsets.zero,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: lightSurface,
      indicatorColor: primaryGreen.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? primaryGreen : lightInk.withValues(alpha: 0.7),
        );
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(color: lightInk.withValues(alpha: 0.08)),
    iconTheme: const IconThemeData(color: lightInk),
  );

  /// Default Dark Theme (Ocean)
  static ThemeData darkTheme = _buildDarkTheme(
    primary: primaryGreen,
    secondary: secondaryGreen,
    background: darkBackground,
    surface: cardBackground,
  );

  /// Light theme tinted by a purchased color theme.
  static ThemeData lightThemeFor(String? themeId) {
    if (themeId == null || themeId.isEmpty) return lightTheme;
    final accent = getThemeById(themeId).colorScheme;
    return lightTheme.copyWith(
      primaryColor: accent.primary,
      colorScheme: ColorScheme.light(
        primary: accent.primary,
        secondary: accent.secondary,
        surface: lightSurface,
        error: const Color(0xFFB42318),
        onPrimary: Colors.white,
        onSurface: lightInk,
      ),
      appBarTheme: lightTheme.appBarTheme.copyWith(foregroundColor: lightInk),
    );
  }

  /// Get Theme by ID
  static ThemeData getThemeById(String? themeId) {
    switch (themeId) {
      case 'sunset':
        return _buildDarkTheme(
          primary: const Color(0xFFD9534F), // Red/Orange
          secondary: const Color(0xFFFFAD60), // Orange
          background: const Color(0xFF2C0E0E), // Red-Dark
          surface: const Color(0xFF4A1C1C), // Red-Card
        );
      case 'forest':
        return _buildDarkTheme(
          primary: const Color(0xFF2E7D32), // Green
          secondary: const Color(0xFF81C784), // Light Green
          background: const Color(0xFF1B3A1B), // Green-Dark
          surface: const Color(0xFF2E4F2E), // Green-Card
        );
      case 'purple':
        return _buildDarkTheme(
          primary: const Color(0xFF6A1B9A), // Purple
          secondary: const Color(0xFFE040FB), // Magenta
          background: const Color(0xFF1F0B2E), // Purple-Dark
          surface: const Color(0xFF351253), // Purple-Card
        );
      case 'gold':
        return _buildDarkTheme(
          primary: const Color(0xFFFFA000), // Amber
          secondary: const Color(0xFFFFD54F), // Light Amber
          background: const Color(0xFF2E2205), // Amber-Dark
          surface: const Color(0xFF4F3C0A), // Amber-Card
        );
      case 'moonlight':
        return _buildDarkTheme(
          primary: const Color(0xFF3F51B5), // Indigo
          secondary: const Color(0xFF7986CB), // Periwinkle
          background: const Color(0xFF0F1229), // Indigo-Dark
          surface: const Color(0xFF1F254B), // Indigo-Card
        );
      case 'ocean':
      default:
        return darkTheme;
    }
  }

  /// Helper to build dark themes
  static ThemeData _buildDarkTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? secondary : textSecondary,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08)),
    );
  }

  /// Get prayer color
  static Color getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return fajrColor;
      case 'الظهر':
        return dhuhrColor;
      case 'العصر':
        return asrColor;
      case 'المغرب':
        return maghribColor;
      case 'العشاء':
        return ishaColor;
      default:
        return primaryGreen;
    }
  }
}
