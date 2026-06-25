import 'package:flutter/material.dart';
import '../models/dashboard_summary.dart';
import '../services/openalex_service.dart';

class DashboardProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  ResearchDashboardSummary? dashboardSummary;
  bool isLoading = false;
  String errorMessage = "";
  String currentTopic = "";
  int selectedLimit = 50;

  /// True once the user has triggered at least one search. Used to decide
  /// whether the "Papers Retrieved" count should be shown at all.
  bool hasSearched = false;

  /// Real number of papers retrieved from the last successful search.
  /// Stays 0 until a search completes.
  int papersRetrieved = 0;

  Future<void> search(String keyword, {int? limit}) async {
    final cleaned = keyword.trim();
    if (cleaned.isEmpty) return;

    if (limit != null) {
      selectedLimit = limit;
    }

    try {
      isLoading = true;
      errorMessage = "";
      currentTopic = cleaned;
      hasSearched = true;
      notifyListeners();

      dashboardSummary = await _service.fetchResearchDashboardSummary(cleaned, selectedLimit);
      papersRetrieved = dashboardSummary?.papersRetrieved ?? 0;
    } catch (e) {
      errorMessage = "Error: $e";
      dashboardSummary = null;
      papersRetrieved = 0;
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    currentTopic = "";
    dashboardSummary = null;
    hasSearched = false;
    papersRetrieved = 0;
    notifyListeners();
  }
}
