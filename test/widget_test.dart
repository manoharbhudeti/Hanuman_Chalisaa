import 'package:flutter_test/flutter_test.dart';
import 'package:hanuman_chalisaa/main.dart';
import 'package:hanuman_chalisaa/providers/counter_provider.dart';
import 'package:hanuman_chalisaa/providers/reading_settings_provider.dart';
import 'package:hanuman_chalisaa/providers/recitation_provider.dart';
import 'package:hanuman_chalisaa/providers/theme_provider.dart';
import 'package:hanuman_chalisaa/services/chalisa_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Hanuman Chalisa App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final chalisaService = ChalisaService();

    await tester.pumpWidget(
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

    // Initial frame pump
    await tester.pump();
    expect(find.byType(HanumanChalisaApp), findsOneWidget);
  });
}
