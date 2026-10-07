import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';
import 'providers/reading_settings_provider.dart';
import 'providers/recitation_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_animation_screen.dart';
import 'services/chalisa_service.dart';
import 'services/web_video_registrar.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerWebVideoPlugin();
  final chalisaService = ChalisaService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReadingSettingsProvider()),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => RecitationProvider()),
        Provider<ChalisaService>.value(value: chalisaService),
      ],
      child: HanumanChalisaApp(chalisaService: chalisaService),
    ),
  );
}

class HanumanChalisaApp extends StatelessWidget {
  final ChalisaService chalisaService;

  const HanumanChalisaApp({super.key, required this.chalisaService});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Hanuman Chalisaa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: OnboardingAnimationScreen(chalisaService: chalisaService),
    );
  }
}
