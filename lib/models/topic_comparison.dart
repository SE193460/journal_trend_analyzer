import 'dashboard_summary.dart';

/// Pairs a research topic (the user's query term) with the
/// [ResearchDashboardSummary] fetched for it, so several topics can be
/// compared side by side.
class TopicComparison {
  final String topic;
  final ResearchDashboardSummary summary;

  TopicComparison({required this.topic, required this.summary});
}
