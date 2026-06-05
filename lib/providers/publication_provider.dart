import 'package:flutter/material.dart';
import '../models/publication.dart';
import '../services/openalex_service.dart';

class PublicationProvider extends ChangeNotifier {

  final OpenAlexService _service = OpenAlexService();

  List<Publication> publications = [];

  bool isLoading = false;

  String errorMessage = "";

  Future<void> search(String keyword) async {

    try {

      isLoading = true;
      errorMessage = "";

      notifyListeners();

      publications =
          await _service.searchPublication(keyword);

    } catch (e) {

      errorMessage = "Error: $e";

    }

    isLoading = false;

    notifyListeners();
  }
}