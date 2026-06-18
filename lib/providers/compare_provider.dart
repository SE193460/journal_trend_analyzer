import 'package:flutter/material.dart';

import '../models/topic_comparison.dart';
import '../services/openalex_service.dart';

/// Fetches and holds dashboard summaries for 2–3 research topics so they can
/// be compared. Reuses [OpenAlexService.fetchResearchDashboardSummary].
class CompareProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  bool isLoading = false;
  String errorMessage = "";
  List<TopicComparison> results = [];

  /// Fetches a dashboard summary for each topic in parallel.
  ///
  /// [topics] is expected to already be validated by the UI (2–3 non-empty
  /// entries); empties are defensively filtered here as well.
  Future<void> compare(List<String> topics) async {
    final cleaned = topics
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (cleaned.length < 2) return;

    try {
      isLoading = true;
      errorMessage = "";
      results = [];
      notifyListeners();

      final summaries = await Future.wait(
        cleaned.map((t) => _service.fetchResearchDashboardSummary(t)),
      );

      results = [
        for (var i = 0; i < cleaned.length; i++)
          TopicComparison(topic: cleaned[i], summary: summaries[i]),
      ];
    } catch (e) {
      errorMessage = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    results = [];
    notifyListeners();
  }
}
