import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/publication_provider.dart';
import '../models/dashboard_summary.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrandedHeader(
            title: "Research Dashboard",
            subtitle: provider.currentTopic.isNotEmpty
                ? "Key insights for “${provider.currentTopic}”"
                : "Key research insights",
            icon: Icons.dashboard_rounded,
          ),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PublicationProvider provider) {
    if (provider.isLoading) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSkeletonKPIGrid(),
            const SizedBox(height: 16),
            _buildSkeletonCard(220),
            const SizedBox(height: 16),
            _buildSkeletonCard(180),
          ],
        ),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      return StateView.error(
        provider.errorMessage,
        onRetry: () => provider.search(provider.currentTopic),
      );
    }

    final summary = provider.dashboardSummary;
    if (summary == null) {
      return StateView.empty(
        icon: Icons.insights_rounded,
        title: "No dashboard yet",
        message: "Search for a topic to see key research insights.",
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPIGrid(summary),
          const SizedBox(height: 16),
          _buildMiniTrendChart(summary),
          const SizedBox(height: 16),
          _buildMostInfluentialCard(context, summary),
        ],
      ),
    );
  }

  // ─── KPI Grid ────────────────────────────────────────────

  Widget _buildKPIGrid(ResearchDashboardSummary summary) {
    final totalText = _formatNumber(summary.totalPublications);
    final avgText = summary.averageCitationCount.toStringAsFixed(1);
    final yearText =
        summary.mostActiveYear != null ? "${summary.mostActiveYear}" : "N/A";
    final journalText = summary.topJournal ?? "N/A";
    final authorText = summary.topAuthor ?? "N/A";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _kpiCard("Total Papers", totalText,
                    Icons.description_rounded, AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: _kpiCard("Avg Citations*", avgText, Icons.star_rounded,
                    AppColors.amber)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _kpiCard("Most Active Year", yearText,
                    Icons.calendar_today_rounded, AppColors.emerald)),
            const SizedBox(width: 12),
            Expanded(
                child: _kpiCard("Top Author", authorText, Icons.person_rounded,
                    AppColors.violet)),
          ],
        ),
        const SizedBox(height: 12),
        _wideKpiCard(
            "Top Journal", journalText, Icons.menu_book_rounded, AppColors.indigo),
        const SizedBox(height: 8),
        const Text(
          "* Average citations calculated from top 200 sampled papers",
          style: TextStyle(
              fontSize: 11, color: AppColors.faint, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _wideKpiCard(String title, String value, IconData icon, Color color) {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mini Trend Chart ────────────────────────────────────

  Widget _buildMiniTrendChart(ResearchDashboardSummary summary) {
    final trendData = summary.publicationTrend
        .where((t) => t.year >= 1900 && t.year <= DateTime.now().year)
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year));

    if (trendData.isEmpty) {
      return const SectionCard(
        child: Center(
            child: Text("No trend data available.",
                style: TextStyle(color: AppColors.muted))),
      );
    }

    final spots =
        trendData.map((t) => FlSpot(t.year.toDouble(), t.count.toDouble())).toList();
    final firstYear = trendData.first.year;
    final lastYear = trendData.last.year;
    final maxCount = trendData.map((t) => t.count).reduce(max);
    final interval = max(1.0, ((lastYear - firstYear) / 4).floorToDouble());

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: "Publication Trend",
              icon: Icons.show_chart_rounded),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 38),
            child: Text("Papers published per year",
                style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(value.toInt().toString(),
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 11)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: max(1, (maxCount / 4).floorToDouble()),
                      getTitlesWidget: (value, meta) {
                        if (value == value.toInt().toDouble()) {
                          return Text(_formatNumber(value.toInt()),
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: firstYear.toDouble(),
                maxX: lastYear.toDouble(),
                minY: 0,
                maxY: maxCount.toDouble() * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBright, AppColors.primary],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.20),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.ink,
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((spot) => LineTooltipItem(
                              "${spot.x.toInt()} · ${_formatNumber(spot.y.toInt())} papers",
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Most Influential Paper Card ─────────────────────────

  Widget _buildMostInfluentialCard(
      BuildContext context, ResearchDashboardSummary summary) {
    final paper = summary.mostInfluentialPaper;
    if (paper == null) {
      return const SectionCard(
        child: Center(
            child: Text("No influential paper data available.",
                style: TextStyle(color: AppColors.muted))),
      );
    }

    final authorsText = paper.authors.isNotEmpty
        ? paper.authors.take(3).join(", ") +
            (paper.authors.length > 3
                ? " +${paper.authors.length - 3} more"
                : "")
        : "Unknown authors";

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: "Most Influential Paper",
              icon: Icons.emoji_events_rounded,
              color: AppColors.amber),
          const SizedBox(height: 16),
          Text(paper.title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              MetaChip(
                  icon: Icons.format_quote_rounded,
                  label: "${_formatNumber(paper.citationCount)} Citations",
                  color: AppColors.primary),
              const SizedBox(width: 10),
              MetaChip(
                  icon: Icons.calendar_today_rounded,
                  label: "${paper.year}",
                  color: AppColors.emerald),
            ],
          ),
          const SizedBox(height: 12),
          Text(authorsText,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.muted, height: 1.4)),
          if (paper.journal.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 14, color: AppColors.faint),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(paper.journal,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.faint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(publication: paper))),
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text("Details"),
                ),
              ),
              if (paper.doi.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(paper.doi);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text("View Paper"),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Skeleton Loaders ────────────────────────────────────

  Widget _buildSkeletonKPIGrid() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _buildSkeletonCard(108)),
          const SizedBox(width: 12),
          Expanded(child: _buildSkeletonCard(108)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildSkeletonCard(108)),
          const SizedBox(width: 12),
          Expanded(child: _buildSkeletonCard(108)),
        ]),
      ],
    );
  }

  Widget _buildSkeletonCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  String _formatNumber(int number) {
    if (number >= 1000000) return "${(number / 1000000).toStringAsFixed(1)}M";
    if (number >= 1000) return "${(number / 1000).toStringAsFixed(1)}K";
    return "$number";
  }
}
