import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal_trend_analyzer/l10n/locale_provider.dart';
import 'package:journal_trend_analyzer/providers/publication_provider.dart';
import 'package:journal_trend_analyzer/providers/recent_provider.dart';
import 'package:journal_trend_analyzer/screens/search_screen.dart';

void main() {
  testWidgets('Recent searches dropdown shows on focus and hides while typing',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'recent_searches': ['AI', 'Machine Learning'],
    });
    final recent = RecentProvider();
    await recent.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PublicationProvider()),
          ChangeNotifierProvider<RecentProvider>.value(value: recent),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pump();

    // Hidden before focus.
    expect(find.text('Machine Learning'), findsNothing);

    // Focus the search field -> dropdown appears with the recent items.
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Machine Learning'), findsOneWidget);

    // Typing hides the dropdown.
    await tester.enterText(find.byType(TextField), 'rob');
    await tester.pump();
    expect(find.text('Machine Learning'), findsNothing);
  });
}
