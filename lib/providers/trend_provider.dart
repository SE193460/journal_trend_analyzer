import 'package:flutter/material.dart';
import '../models/publication.dart';
import '../services/openalex_service.dart';

class TrendProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  List<PublicationTrendPoint> trendData = [];
  List<Publication> topPapers = [];
  
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

      var futures = await Future.wait([
        _service.fetchPublicationTrend(cleaned),
        _service.fetchTopInfluentialPapers(cleaned),
      ]);

      trendData = futures[0] as List<PublicationTrendPoint>;
      topPapers = futures[1] as List<Publication>;
    } catch (e) {
      errorMessage = "Error: $e";
      trendData = [];
      topPapers = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    currentTopic = "";
    trendData = [];
    topPapers = [];
    notifyListeners();
  }
}
