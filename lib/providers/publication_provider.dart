import 'package:flutter/material.dart';
import '../models/publication.dart';
import '../services/openalex_service.dart';

class PublicationProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  List<Publication> publications = [];
  List<PublicationTrendPoint> trendData = [];
  
  bool isLoading = false;
  String errorMessage = "";
  String currentTopic = "";

  Future<void> search(String keyword) async {
    try {
      isLoading = true;
      errorMessage = "";
      currentTopic = keyword;
      notifyListeners();

      var futures = await Future.wait([
        _service.searchPublication(keyword),
        _service.fetchPublicationTrend(keyword),
      ]);

      publications = futures[0] as List<Publication>;
      trendData = futures[1] as List<PublicationTrendPoint>;

    } catch (e) {
      errorMessage = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}