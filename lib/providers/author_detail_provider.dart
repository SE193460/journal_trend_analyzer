import 'package:flutter/material.dart';
import '../models/author.dart';
import '../models/publication.dart';
import '../services/openalex_service.dart';

class AuthorDetailProvider extends ChangeNotifier {
  final OpenAlexService _service = OpenAlexService();

  AuthorDetail? author;
  List<Publication> publications = [];
  
  bool isLoading = false;
  String errorMessage = "";

  Future<void> fetchDetail(String authorId, String topic) async {
    try {
      isLoading = true;
      errorMessage = "";
      author = null;
      publications = [];
      notifyListeners();

      var futures = await Future.wait([
        _service.fetchAuthorDetail(authorId),
        _service.fetchAuthorPublications(authorId: authorId, topic: topic),
      ]);

      author = futures[0] as AuthorDetail;
      publications = futures[1] as List<Publication>;
    } catch (e) {
      errorMessage = "Error: $e";
      author = null;
      publications = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = "";
    author = null;
    publications = [];
    notifyListeners();
  }
}
