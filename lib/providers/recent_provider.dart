import 'package:flutter/foundation.dart';

import '../services/recent_storage_service.dart';

/// Holds the user's recent searches (max 5) and recent topic comparisons
/// (max 3), persisted locally via [RecentStorageService].
///
/// Business rules:
/// - never store empty/invalid entries,
/// - no duplicates (case-insensitive) — an existing entry is moved to the top,
/// - newest first, capped to the maximum count.
class RecentProvider extends ChangeNotifier {
  final RecentStorageService _storage;

  RecentProvider({RecentStorageService? storage})
      : _storage = storage ?? RecentStorageService();

  static const int maxSearches = 5;
  static const int maxComparisons = 3;

  List<String> _searches = [];
  List<List<String>> _comparisons = [];

  List<String> get searches => List.unmodifiable(_searches);
  List<List<String>> get comparisons =>
      _comparisons.map((c) => List<String>.unmodifiable(c)).toList();

  /// Loads persisted data into memory. Call once at startup.
  Future<void> load() async {
    _searches = await _storage.loadSearches();
    _comparisons = await _storage.loadComparisons();
    notifyListeners();
  }

  // ─── Recent searches ─────────────────────────────────────

  Future<void> addSearch(String topic) async {
    final value = topic.trim();
    if (value.isEmpty) return;

    _searches.removeWhere((s) => s.toLowerCase() == value.toLowerCase());
    _searches.insert(0, value);
    if (_searches.length > maxSearches) {
      _searches = _searches.sublist(0, maxSearches);
    }
    notifyListeners();
    await _storage.saveSearches(_searches);
  }

  Future<void> removeSearch(String topic) async {
    _searches.removeWhere((s) => s == topic);
    notifyListeners();
    await _storage.saveSearches(_searches);
  }

  Future<void> clearSearches() async {
    _searches = [];
    notifyListeners();
    await _storage.saveSearches(_searches);
  }

  // ─── Recent comparisons ──────────────────────────────────

  Future<void> addComparison(List<String> topics) async {
    final cleaned =
        topics.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    // Only valid comparison sets (2–3 topics) are stored.
    if (cleaned.length < 2 || cleaned.length > 3) return;

    final key = _comparisonKey(cleaned);
    _comparisons.removeWhere((c) => _comparisonKey(c) == key);
    _comparisons.insert(0, cleaned);
    if (_comparisons.length > maxComparisons) {
      _comparisons = _comparisons.sublist(0, maxComparisons);
    }
    notifyListeners();
    await _storage.saveComparisons(_comparisons);
  }

  Future<void> removeComparison(List<String> topics) async {
    final key = _comparisonKey(topics);
    _comparisons.removeWhere((c) => _comparisonKey(c) == key);
    notifyListeners();
    await _storage.saveComparisons(_comparisons);
  }

  Future<void> clearComparisons() async {
    _comparisons = [];
    notifyListeners();
    await _storage.saveComparisons(_comparisons);
  }

  /// Order-insensitive, case-insensitive key so the same set of topics is
  /// treated as one comparison regardless of order/casing.
  String _comparisonKey(List<String> topics) {
    final normalized = topics.map((t) => t.trim().toLowerCase()).toList()
      ..sort();
    return normalized.join('|');
  }
}
