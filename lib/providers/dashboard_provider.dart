import 'package:flutter/material.dart';
import '../models/dashboard_summary.dart';
import '../services/openalex_service.dart';

class DashboardProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  ResearchDashboardSummary? dashboardSummary;
  bool isLoading = false;
  String errorMessage = "";
  String currentTopic = "";

  Future<void> search(String keyword) async {
    final cleaned = keyword.trim();
    if (cleaned.isEmpty) return;

    try {
      isLoading = true;
      errorMessage = "";
      currentTopic = cleaned;
      notifyListeners();

      dashboardSummary = await _service.fetchResearchDashboardSummary(cleaned);
    } catch (e) {
      errorMessage = "Error: $e";
      dashboardSummary = null;
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    currentTopic = "";
    dashboardSummary = null;
    notifyListeners();
  }
}
