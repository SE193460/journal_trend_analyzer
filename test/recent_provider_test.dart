import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:journal_trend_analyzer/providers/recent_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Recent searches', () {
    test('ignores empty, dedups (case-insensitive, moves to top), newest first',
        () async {
      final p = RecentProvider();
      await p.addSearch('AI');
      await p.addSearch('   '); // ignored
      await p.addSearch('Machine Learning');
      await p.addSearch('ai'); // duplicate of "AI" -> moves to top

      expect(p.searches.length, 2);
      expect(p.searches.first.toLowerCase(), 'ai');
      expect(p.searches[1], 'Machine Learning');
    });

    test('caps at 5 most recent', () async {
      final p = RecentProvider();
      for (final t in ['a', 'b', 'c', 'd', 'e', 'f']) {
        await p.addSearch(t);
      }
      expect(p.searches.length, RecentProvider.maxSearches);
      expect(p.searches.first, 'f');
      expect(p.searches.contains('a'), isFalse);
    });

    test('remove and clear', () async {
      final p = RecentProvider();
      await p.addSearch('x');
      await p.addSearch('y');
      await p.removeSearch('x');
      expect(p.searches, ['y']);
      await p.clearSearches();
      expect(p.searches, isEmpty);
    });
  });

  group('Recent comparisons', () {
    test('rejects invalid sizes (needs 2–3 non-empty topics)', () async {
      final p = RecentProvider();
      await p.addComparison(['only-one']);
      await p.addComparison(['a', '', '  ']); // only 1 valid
      await p.addComparison(['a', 'b', 'c', 'd']); // too many
      expect(p.comparisons, isEmpty);
    });

    test('dedups order/case-insensitively and moves to top', () async {
      final p = RecentProvider();
      await p.addComparison(['AI', 'Data Science']);
      await p.addComparison(['Blockchain', 'IoT']);
      await p.addComparison(['data science', 'ai']); // same set as first

      expect(p.comparisons.length, 2);
      expect(p.comparisons.first.map((e) => e.toLowerCase()).toList(),
          ['data science', 'ai']);
    });

    test('caps at 3 most recent', () async {
      final p = RecentProvider();
      await p.addComparison(['a', 'b']);
      await p.addComparison(['c', 'd']);
      await p.addComparison(['e', 'f']);
      await p.addComparison(['g', 'h']);
      expect(p.comparisons.length, RecentProvider.maxComparisons);
      expect(p.comparisons.first, ['g', 'h']);
    });
  });
}
