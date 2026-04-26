import 'package:flutter/material.dart';
import '../prayer_times/prayer_times_screen.dart';
import '../adhkar/adhkar_screen.dart';
import '../qibla/qibla_screen.dart';
import '../journeys/journeys_screen.dart';
import '../quran/quran_screen.dart';
import '../achievements/achievements_screen.dart';
import '../quran_race/quran_race_screen.dart';

/// Home Screen
/// Main navigation hub for the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Navigation pages
  final List<Widget> _pages = [
    const PrayerTimesScreen(),
    const QuranScreen(),
    const QuranRaceScreen(),
    const AdhkarScreen(),
    const QiblaScreen(),
    const JourneysScreen(),
    const AchievementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex > 5 ? 6 : _selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex > 5 ? 5 : _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time),
            label: 'الصلاة',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups),
            label: 'السباق',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'القبلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement),
            label: 'الرحلات',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 5 || _selectedIndex == 6 ? FloatingActionButton(
        onPressed: () => setState(() => _selectedIndex = _selectedIndex == 6 ? 5 : 6),
        tooltip: _selectedIndex == 6 ? 'الرجوع للرحلات' : 'الإنجازات',
        child: Icon(_selectedIndex == 6 ? Icons.arrow_back : Icons.emoji_events),
      ) : null,
    );
  }
}
