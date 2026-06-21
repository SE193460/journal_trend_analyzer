import 'package:flutter/material.dart';
import '../services/openalex_service.dart';

class TopAuthorProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  List<Map<String, dynamic>> authors = [];
  int maxCount = 1;
  
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

      authors = await _service.fetchTopAuthors(cleaned);
      
      maxCount = authors.isNotEmpty
        ? authors
            .map((a) => (a['count'] as int?) ?? 0)
            .reduce((a, b) => a > b ? a : b)
        : 1;
        
    } catch (e) {
      errorMessage = "Error: $e";
      authors = [];
      maxCount = 1;
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    currentTopic = "";
    authors = [];
    maxCount = 1;
    notifyListeners();
  }
}
