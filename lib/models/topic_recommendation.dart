import 'dart:math';

import 'topic_comparison.dart';

/// 0–100 scores computed for a single compared topic.
class TopicScore {
  final TopicComparison topic;
  final double publicationScore; // popularity (volume of work)
  final double citationScore; // academic impact
  final double recencyScore; // how recent the activity peak is
  final double finalScore; // average of the three

  TopicScore({
    required this.topic,
    required this.publicationScore,
    required this.citationScore,
    required this.recencyScore,
    required this.finalScore,
  });
}

/// The single recommended topic plus why it was picked.
class TopicRecommendation {
  final TopicScore topic;

  /// True when picked for academic impact (highest avg citations), false when
  /// picked as the best overall (highest final score).
  final bool byImpact;

  TopicRecommendation({required this.topic, required this.byImpact});
}

/// Pure, data-driven helper (no AI, no backend, no hard-coded data) that turns
/// the already-fetched OpenAlex comparison data into simple topic suggestions.
///
/// All scores are scaled to 0–100. Popularity and impact are normalized
/// against the strongest topic in the set, so the numbers are easy to read and
/// always relative to what is being compared.
class TopicRecommender {
  TopicRecommender._();

  /// Computes [TopicScore] for every topic.
  ///
  /// - Publication Score = totalPublications / maxTotalPublications * 100
  /// - Citation Score    = avgCitations / maxAvgCitations * 100
  /// - Recency Score      = 100 at [currentYear], decaying ~8 pts per year
  ///   (0 when the most-active year is missing/invalid)
  /// - Final Score        = average of the three
  static List<TopicScore> score(
    List<TopicComparison> topics, {
    required int currentYear,
  }) {
    if (topics.isEmpty) return [];

    final maxPub = topics
        .map((t) => t.summary.totalPublications)
        .fold<int>(0, max)
        .toDouble();
    final maxAvg = topics
        .map((t) => t.summary.averageCitationCount)
        .fold<double>(0.0, max);

    return topics.map((t) {
      final s = t.summary;
      final pub = maxPub > 0 ? (s.totalPublications / maxPub) * 100 : 0.0;
      final cit = maxAvg > 0 ? (s.averageCitationCount / maxAvg) * 100 : 0.0;
      final rec = _recencyScore(s.mostActiveYear, currentYear);
      final fin = (pub + cit + rec) / 3;
      return TopicScore(
        topic: t,
        publicationScore: pub.clamp(0, 100).toDouble(),
        citationScore: cit.clamp(0, 100).toDouble(),
        recencyScore: rec,
        finalScore: fin.clamp(0, 100).toDouble(),
      );
    }).toList();
  }

  static double _recencyScore(int? year, int currentYear) {
    if (year == null || year <= 0) return 0;
    final diff = currentYear - year;
    if (diff <= 0) return 100;
    return (100 - diff * 8).clamp(0, 100).toDouble();
  }

  /// Topic with the most publications ("easy to find sources").
  static TopicScore mostPopular(List<TopicScore> scores) => scores.reduce((a, b) =>
      a.topic.summary.totalPublications >= b.topic.summary.totalPublications
          ? a
          : b);

  /// Topic with the highest average citations ("high academic impact").
  static TopicScore mostInfluential(List<TopicScore> scores) =>
      scores.reduce((a, b) =>
          a.topic.summary.averageCitationCount >=
                  b.topic.summary.averageCitationCount
              ? a
              : b);

  /// Lowest publication count among topics that still have data (> 0);
  /// falls back to the overall lowest if none have data.
  static TopicScore narrower(List<TopicScore> scores) {
    final withData =
        scores.where((s) => s.topic.summary.totalPublications > 0).toList();
    final pool = withData.isNotEmpty ? withData : scores;
    return pool.reduce((a, b) =>
        a.topic.summary.totalPublications <= b.topic.summary.totalPublications
            ? a
            : b);
  }

  /// Topic with the highest final score.
  static TopicScore overallBest(List<TopicScore> scores) =>
      scores.reduce((a, b) => a.finalScore >= b.finalScore ? a : b);

  /// Picks the recommended topic with a simple rule:
  /// if the impact leader is strong (citation score ≥ 80) AND not too small
  /// (publication score ≥ 40), recommend it for academic impact; otherwise
  /// recommend the topic with the highest overall (final) score.
  static TopicRecommendation recommend(List<TopicScore> scores) {
    final impact = mostInfluential(scores);
    final byImpact =
        impact.citationScore >= 80 && impact.publicationScore >= 40;
    return TopicRecommendation(
      topic: byImpact ? impact : overallBest(scores),
      byImpact: byImpact,
    );
  }
}
