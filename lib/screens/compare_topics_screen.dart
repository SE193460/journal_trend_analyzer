import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_provider.dart';
import '../models/topic_comparison.dart';
import '../models/topic_recommendation.dart';
import '../providers/compare_provider.dart';
import '../providers/recent_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Lets the user compare 2–3 research topics side by side using OpenAlex data.
class CompareTopicsScreen extends StatefulWidget {
  const CompareTopicsScreen({super.key});

  @override
  State<CompareTopicsScreen> createState() => _CompareTopicsScreenState();
}

class _CompareTopicsScreenState extends State<CompareTopicsScreen> {
  /// One controller per topic input. Starts with 2, can grow to a max of 3.
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  static const int _maxTopics = 3;
  static const int _minTopics = 2;

  /// Distinct accent color per topic column.
  static const List<Color> _topicColors = [
    AppColors.primary,
    AppColors.indigo,
    AppColors.emerald,
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTopic() {
    if (_controllers.length >= _maxTopics) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeTopic(int index) {
    if (_controllers.length <= _minTopics) return;
    setState(() {
      _controllers.removeAt(index).dispose();
    });
  }

  void _onCompare() {
    final topics = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (topics.length < _minTopics) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.s.compareValidationMin)),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<RecentProvider>().addComparison(topics);
    context.read<CompareProvider>().compare(topics);
  }

  /// Fills the inputs with a saved comparison and runs it again.
  void _applyComparison(List<String> topics) {
    final clean = topics.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    if (clean.length < _minTopics) return;

    setState(() {
      while (_controllers.length < clean.length) {
        _controllers.add(TextEditingController());
      }
      while (_controllers.length > clean.length &&
          _controllers.length > _minTopics) {
        _controllers.removeLast().dispose();
      }
      for (var i = 0; i < _controllers.length; i++) {
        _controllers[i].text = i < clean.length ? clean[i] : '';
      }
    });
    _onCompare();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompareProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrandedHeader(
            title: context.s.compareTitle,
            subtitle: context.s.compareSubtitle,
            icon: Icons.compare_arrows_rounded,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputCard(),
                  _buildRecentComparisons(),
                  const SizedBox(height: 20),
                  _buildResultsArea(provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input ───────────────────────────────────────────────

  Widget _buildInputCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
              title: context.s.compareInputTitle, icon: Icons.edit_note_rounded),
          const SizedBox(height: 16),
          for (var i = 0; i < _controllers.length; i++)
            Padding(
              key: ValueKey(_controllers[i]),
              padding: const EdgeInsets.only(bottom: 12),
              child: _topicField(i),
            ),
          if (_controllers.length < _maxTopics)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addTopic,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(context.s.compareAddTopic),
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onCompare,
              icon: const Icon(Icons.compare_arrows_rounded, size: 18),
              label: Text(context.s.compareButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topicField(int index) {
    final color = _topicColors[index % _topicColors.length];
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text("${index + 1}",
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _controllers[index],
            textInputAction: index == _controllers.length - 1
                ? TextInputAction.search
                : TextInputAction.next,
            onSubmitted: (_) => _onCompare(),
            style: const TextStyle(
                color: AppColors.ink, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.background,
              hintText: context.s.compareTopicHint(index + 1),
              hintStyle: const TextStyle(color: AppColors.faint),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
              ),
            ),
          ),
        ),
        if (_controllers.length > _minTopics)
          IconButton(
            tooltip: context.s.compareRemoveTopic,
            onPressed: () => _removeTopic(index),
            icon: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.faint),
          ),
      ],
    );
  }

  // ─── Recent comparisons ──────────────────────────────────

  Widget _buildRecentComparisons() {
    final recents = context.watch<RecentProvider>().comparisons;
    if (recents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SectionCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded,
                    size: 18, color: AppColors.muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(context.s.recentComparisonsTitle,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink)),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<RecentProvider>().clearComparisons(),
                  child: Text(context.s.clearAll,
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final c in recents) _recentComparisonTile(c),
          ],
        ),
      ),
    );
  }

  Widget _recentComparisonTile(List<String> topics) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _applyComparison(topics),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.compare_arrows_rounded,
                      size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    topics.join("  •  "),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        height: 1.3),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<RecentProvider>().removeComparison(topics),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.faint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Result states ───────────────────────────────────────

  Widget _buildResultsArea(CompareProvider provider) {
    if (provider.isLoading) {
      return _inlineState(
        const SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
              strokeWidth: 3, color: AppColors.primary),
        ),
        context.s.compareLoading,
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      return _inlineState(
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cloud_off_rounded,
              size: 34, color: AppColors.danger),
        ),
        context.s.somethingWentWrong,
        subtitle: provider.errorMessage,
        action: ElevatedButton.icon(
          onPressed: _onCompare,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(context.s.tryAgain),
        ),
      );
    }

    if (provider.results.isEmpty) {
      return _inlineState(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.compare_arrows_rounded,
              size: 40, color: AppColors.primary),
        ),
        context.s.compareEmptyTitle,
        subtitle: context.s.compareEmptyMessage,
      );
    }

    return _buildResults(provider.results);
  }

  Widget _inlineState(Widget leading, String title,
      {String? subtitle, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13.5),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 22),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // ─── Results ─────────────────────────────────────────────

  Widget _buildResults(List<TopicComparison> results) {
    final pubWinner =
        _maxIndex(results.map((r) => r.summary.totalPublications.toDouble()));
    final avgWinner =
        _maxIndex(results.map((r) => r.summary.averageCitationCount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWinnerCards(results, pubWinner, avgWinner),
        const SizedBox(height: 16),
        _buildBarChartCard(results),
        const SizedBox(height: 16),
        _buildComparisonTable(results, pubWinner, avgWinner),
        const SizedBox(height: 16),
        _buildRecommendations(results),
      ],
    );
  }

  // ─── Topic suggestions ───────────────────────────────────

  Widget _buildRecommendations(List<TopicComparison> results) {
    final scores = TopicRecommender.score(
      results,
      currentYear: DateTime.now().year,
    );
    if (scores.isEmpty) return const SizedBox.shrink();

    final popular = TopicRecommender.mostPopular(scores);
    final impact = TopicRecommender.mostInfluential(scores);
    final narrower = TopicRecommender.narrower(scores);
    final recommendation = TopicRecommender.recommend(scores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
            title: context.s.recoTitle, icon: Icons.lightbulb_rounded),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Text(context.s.recoSubtitle,
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        ),
        const SizedBox(height: 14),
        _suggestionCard(
          icon: Icons.menu_book_rounded,
          color: AppColors.primary,
          category: context.s.recoCatPopular,
          label: context.s.recoLabelPopular,
          topic: popular.topic.topic,
          reason: context.s.recoReasonPopular(popular.topic.topic),
        ),
        const SizedBox(height: 12),
        _suggestionCard(
          icon: Icons.auto_awesome_rounded,
          color: AppColors.amber,
          category: context.s.recoCatImpact,
          label: context.s.recoLabelImpact,
          topic: impact.topic.topic,
          reason: context.s.recoReasonImpact(impact.topic.topic),
        ),
        const SizedBox(height: 12),
        _suggestionCard(
          icon: Icons.travel_explore_rounded,
          color: AppColors.indigo,
          category: context.s.recoCatNarrower,
          label: context.s.recoLabelNarrower,
          topic: narrower.topic.topic,
          reason: context.s.recoReasonNarrower(narrower.topic.topic),
        ),
        const SizedBox(height: 16),
        _recommendedCard(recommendation),
      ],
    );
  }

  Widget _suggestionCard({
    required IconData icon,
    required Color color,
    required String category,
    required String label,
    required String topic,
    required String reason,
  }) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
                const SizedBox(height: 3),
                Text(topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.25)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
                const SizedBox(height: 8),
                Text(reason,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.muted, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedCard(TopicRecommendation rec) {
    final score = rec.topic;
    final reason = rec.byImpact
        ? context.s.recoRecommendedByImpact(score.topic.topic)
        : context.s.recoRecommendedByOverall(score.topic.topic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.brand(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(context.s.recoRecommendedTitle,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("${score.finalScore.round()}/100",
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(score.topic.topic,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 8),
          Text(reason,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13.5, height: 1.5)),
          const SizedBox(height: 16),
          _scoreBar(context.s.scorePopularity, score.publicationScore),
          const SizedBox(height: 10),
          _scoreBar(context.s.scoreImpact, score.citationScore),
          const SizedBox(height: 10),
          _scoreBar(context.s.scoreRecency, score.recencyScore),
        ],
      ),
    );
  }

  Widget _scoreBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            Text("${value.round()}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerCards(
      List<TopicComparison> results, int pubWinner, int avgWinner) {
    // IntrinsicHeight gives both cards the same height. It is safe here
    // because the Row sits in a vertically-scrolling column with a *bounded*
    // width; using CrossAxisAlignment.stretch without it would force an
    // infinite height inside the scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Expanded(
          child: _winnerCard(
            label: context.s.compareMostPublications,
            topic: results[pubWinner].topic,
            value: _compact(results[pubWinner].summary.totalPublications),
            icon: Icons.description_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _winnerCard(
            label: context.s.compareHighestAvgCitations,
            topic: results[avgWinner].topic,
            value: results[avgWinner]
                .summary
                .averageCitationCount
                .toStringAsFixed(1),
            icon: Icons.star_rounded,
            color: AppColors.amber,
          ),
        ),
        ],
      ),
    );
  }

  Widget _winnerCard({
    required String label,
    required String topic,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(topic,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.25)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ─── Bar chart ───────────────────────────────────────────

  Widget _buildBarChartCard(List<TopicComparison> results) {
    final maxPub = results
        .map((r) => r.summary.totalPublications)
        .fold<int>(0, (a, b) => max(a, b));
    final maxY = (maxPub <= 0 ? 1.0 : maxPub.toDouble()) * 1.25;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
              title: context.s.compareChartTitle,
              icon: Icons.bar_chart_rounded),
          const SizedBox(height: 24),
          SizedBox(
            height: 210,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= results.length) {
                          return const Text('');
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: 70,
                            child: Text(
                              _short(results[i].topic),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 10.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: max(1, (maxY / 4).floorToDouble()),
                      getTitlesWidget: (value, meta) {
                        if (value == value.toInt().toDouble()) {
                          return Text(_compact(value.toInt()),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.ink,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                      "${results[group.x].topic}\n${_compact(rod.toY.toInt())}",
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < results.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: results[i].summary.totalPublications.toDouble(),
                          color: _topicColors[i % _topicColors.length],
                          width: 26,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Comparison table ────────────────────────────────────

  Widget _buildComparisonTable(
      List<TopicComparison> results, int pubWinner, int avgWinner) {
    const labelWidth = 120.0;
    const colWidth = 150.0;
    final n = results.length;

    String yearText(TopicComparison r) =>
        r.summary.mostActiveYear?.toString() ?? "—";
    String journalText(TopicComparison r) =>
        (r.summary.topJournal?.isNotEmpty ?? false)
            ? r.summary.topJournal!
            : "—";
    String authorText(TopicComparison r) =>
        (r.summary.topAuthor?.isNotEmpty ?? false)
            ? r.summary.topAuthor!
            : "—";
    String paperText(TopicComparison r) {
      final p = r.summary.mostInfluentialPaper;
      return (p != null && p.title.isNotEmpty) ? p.title : "—";
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
              title: context.s.compareTableTitle,
              icon: Icons.table_chart_rounded),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: labelWidth + colWidth * n,
              child: Table(
                border: TableBorder.all(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                columnWidths: {
                  0: const FixedColumnWidth(labelWidth),
                  for (var i = 1; i <= n; i++)
                    i: const FixedColumnWidth(colWidth),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Header row: topic names
                  TableRow(
                    decoration: const BoxDecoration(color: AppColors.background),
                    children: [
                      _cell(const SizedBox.shrink()),
                      for (var i = 0; i < n; i++)
                        _cell(Text(results[i].topic,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color:
                                    _topicColors[i % _topicColors.length]))),
                    ],
                  ),
                  _metricRow(context.s.mTotalPublications,
                      [for (final r in results) _compact(r.summary.totalPublications)],
                      winnerIndex: pubWinner),
                  _metricRow(context.s.mAvgCitations,
                      [for (final r in results) r.summary.averageCitationCount.toStringAsFixed(1)],
                      winnerIndex: avgWinner),
                  _metricRow(context.s.mMostActiveYear,
                      [for (final r in results) yearText(r)]),
                  _metricRow(context.s.mTopJournal,
                      [for (final r in results) journalText(r)]),
                  _metricRow(context.s.mTopAuthor,
                      [for (final r in results) authorText(r)]),
                  _metricRow(context.s.mMostInfluential,
                      [for (final r in results) paperText(r)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A metric row: a fixed label cell + one value cell per topic.
  TableRow _metricRow(String label, List<String> values, {int? winnerIndex}) {
    return TableRow(
      children: [
        _cell(
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted)),
          bg: AppColors.background,
        ),
        for (var i = 0; i < values.length; i++)
          _cell(
            Text(values[i],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight:
                      winnerIndex == i ? FontWeight.w800 : FontWeight.w500,
                  color: winnerIndex == i
                      ? _topicColors[i % _topicColors.length]
                      : AppColors.ink,
                )),
            bg: winnerIndex == i
                ? _topicColors[i % _topicColors.length].withValues(alpha: 0.10)
                : null,
          ),
      ],
    );
  }

  /// A single table cell. When [bg] is set, the cell is filled to the full row
  /// height so the highlight color covers the whole cell.
  Widget _cell(Widget child, {Color? bg}) {
    final content = Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (bg == null) return content;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: content,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  int _maxIndex(Iterable<double> values) {
    final list = values.toList();
    var best = 0;
    for (var i = 1; i < list.length; i++) {
      if (list[i] > list[best]) best = i;
    }
    return best;
  }

  String _short(String s) =>
      s.length <= 14 ? s : "${s.substring(0, 13)}…";

  String _compact(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }
}
