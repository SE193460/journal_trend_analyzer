// Smoke test: the app boots to the splash screen and then into the main
// search screen without throwing.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal_trend_analyzer/l10n/locale_provider.dart';
import 'package:journal_trend_analyzer/main.dart';
import 'package:journal_trend_analyzer/providers/compare_provider.dart';
import 'package:journal_trend_analyzer/providers/publication_provider.dart';
import 'package:journal_trend_analyzer/providers/recent_provider.dart';
import 'package:journal_trend_analyzer/screens/search_screen.dart';
import 'package:journal_trend_analyzer/screens/splash_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('App boots to splash then into the app without exceptions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PublicationProvider()),
          ChangeNotifierProvider(create: (_) => CompareProvider()),
          ChangeNotifierProvider(create: (_) => RecentProvider()..load()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Let the splash timer fire and the fade transition into SearchScreen
    // complete.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(SearchScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
