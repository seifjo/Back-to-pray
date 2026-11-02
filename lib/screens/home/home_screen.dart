import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/adhkar_progress_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../adhkar/adhkar_screen.dart';
import '../more/more_features_screen.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';
import '../quran/quran_screen.dart';

/// Home Screen
/// Main navigation hub for the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  /// Lean bottom bar: Prayer, Quran, Adhkar, Qibla, More.
  /// Race and Journeys open from More Features.
  final List<Widget> _pages = const [
    PrayerTimesScreen(),
    QuranScreen(),
    AdhkarScreen(),
    QiblaScreen(),
    MoreFeaturesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdhkarProgressProvider>().ensureToday();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AdhkarProgressProvider>().ensureToday();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (context.read<AppSettingsProvider>().hapticEnabled) {
            HapticFeedback.selectionClick();
          }
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.access_time),
            label: context.tr('navPrayer'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book),
            label: context.tr('navQuran'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories),
            label: context.tr('navAdhkar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore),
            label: context.tr('navQibla'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.apps_rounded),
            label: context.tr('navMore'),
          ),
        ],
      ),
    );
  }
}
