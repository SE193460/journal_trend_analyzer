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
      notifyListeners();

      dashboardSummary = await _service.fetchResearchDashboardSummary(cleaned, selectedLimit);
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
