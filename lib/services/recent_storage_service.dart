import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for persisting the user's recent
/// searches and recent topic comparisons locally on the device.
///
/// All methods fail safe: any storage error returns an empty result / no-op so
/// the UI never crashes if persistence is unavailable.
class RecentStorageService {
  static const _kSearches = 'recent_searches';
  static const _kComparisons = 'recent_comparisons';

  Future<List<String>> loadSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_kSearches) ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSearches(List<String> searches) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kSearches, searches);
    } catch (_) {
      // ignore persistence errors
    }
  }

  /// Comparisons are stored as a JSON list of string lists.
  Future<List<List<String>>> loadComparisons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kComparisons);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map<List<String>>(
              (e) => (e as List).map((x) => x.toString()).toList())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveComparisons(List<List<String>> comparisons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kComparisons, jsonEncode(comparisons));
    } catch (_) {
      // ignore persistence errors
    }
  }
}
