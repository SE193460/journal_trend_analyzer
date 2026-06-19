import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal_trend_analyzer/l10n/locale_provider.dart';
import 'package:journal_trend_analyzer/models/dashboard_summary.dart';
import 'package:journal_trend_analyzer/models/publication.dart';
import 'package:journal_trend_analyzer/models/topic_comparison.dart';
import 'package:journal_trend_analyzer/providers/compare_provider.dart';
import 'package:journal_trend_analyzer/providers/recent_provider.dart';
import 'package:journal_trend_analyzer/screens/compare_topics_screen.dart';

ResearchDashboardSummary _summary(int total, double avg) {
  return ResearchDashboardSummary(
    totalPublications: total,
    averageCitationCount: avg,
    mostActiveYear: 2021,
    topJournal: "Nature Machine Intelligence and Robotics Review",
    topAuthor: "Jane Q. Researcher",
    mostInfluentialPaper: Publication(
      title: "A very long influential paper title that should wrap nicely",
      year: 2020,
      citationCount: 1234,
      doi: "",
      journal: "Nature",
      authors: const ["A", "B"],
      abstractText: "",
    ),
    publicationTrend: [
      PublicationTrendPoint(year: 2019, count: 10),
      PublicationTrendPoint(year: 2020, count: 30),
      PublicationTrendPoint(year: 2021, count: 50),
    ],
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('CompareTopicsScreen results render on a narrow phone screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final compare = CompareProvider();
    compare.results = [
      TopicComparison(topic: "Artificial Intelligence", summary: _summary(120000, 18.4)),
      TopicComparison(topic: "Data Science", summary: _summary(54000, 22.1)),
      TopicComparison(topic: "Cybersecurity", summary: _summary(30000, 9.7)),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CompareProvider>.value(value: compare),
          ChangeNotifierProvider(create: (_) => RecentProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(home: CompareTopicsScreen()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
