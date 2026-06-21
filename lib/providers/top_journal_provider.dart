import 'package:flutter/material.dart';

import '../services/openalex_service.dart';

class TopJournalProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  List<MapEntry<String, int>> journals = [];
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

      final publications = await _service.searchPublication(cleaned);
      
      final Map<String, int> counts = {};
      for (var p in publications) {
        if (p.journal.isNotEmpty) {
          counts[p.journal] = (counts[p.journal] ?? 0) + 1;
        }
      }
      
      journals = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      maxCount = journals.isNotEmpty ? journals.first.value : 1;
      
    } catch (e) {
      errorMessage = "Error: $e";
      journals = [];
      maxCount = 1;
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    currentTopic = "";
    journals = [];
    maxCount = 1;
    notifyListeners();
  }
}
