import 'package:flutter/material.dart';
import '../services/chalisa_service.dart';
import 'counter_screen.dart';
import 'meaning_screen.dart';
import 'reading_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ChalisaService chalisaService;

  const HomeScreen({super.key, required this.chalisaService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ReadingScreen(chalisaService: widget.chalisaService),
      MeaningScreen(chalisaService: widget.chalisaService),
      const CounterScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Read (పఠనం)',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Meaning (భావం)',
          ),
          NavigationDestination(
            icon: Icon(Icons.flare_outlined),
            selectedIcon: Icon(Icons.flare_rounded),
            label: 'Counter (జాప్)',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
