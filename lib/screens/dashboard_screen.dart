import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/publication_provider.dart';
import '../models/publication.dart';
import '../models/dashboard_summary.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSkeletonHeader(),
              const SizedBox(height: 24),
              _buildSkeletonKPIGrid(),
              const SizedBox(height: 24),
              _buildSkeletonCard(200),
              const SizedBox(height: 24),
              _buildSkeletonCard(160),
            ],
          ),
        ),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(provider.errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () => provider.search(provider.currentTopic),
                child: const Text("Retry", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    var summary = provider.dashboardSummary;
    if (summary == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            "Search for a topic to see the dashboard.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider.currentTopic),
            const SizedBox(height: 24),
            _buildKPIGrid(summary),
            const SizedBox(height: 24),
            _buildMiniTrendChart(summary),
            const SizedBox(height: 24),
            _buildMostInfluentialCard(context, summary),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Research Dashboard", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  // ─── Header ──────────────────────────────────────────────

  Widget _buildHeader(String topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Research Dashboard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          topic.isNotEmpty ? "Key insights for: $topic" : "Key research insights",
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  // ─── KPI Grid ────────────────────────────────────────────

  Widget _buildKPIGrid(ResearchDashboardSummary summary) {
    String totalText = _formatNumber(summary.totalPublications);
    String avgText = summary.averageCitationCount.toStringAsFixed(1);
    String yearText = summary.mostActiveYear != null ? "${summary.mostActiveYear}" : "N/A";
    String journalText = summary.topJournal ?? "N/A";
    String authorText = summary.topAuthor ?? "N/A";

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildKPICard("Total Papers", totalText, Icons.description_rounded, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard("Avg Citations*", avgText, Icons.star_rounded, Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKPICard("Most Active Year", yearText, Icons.calendar_today_rounded, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildKPICard("Top Author", authorText, Icons.person_rounded, Colors.purple)),
          ],
        ),
        const SizedBox(height: 12),
        _buildWideKPICard("Top Journal", journalText, Icons.menu_book_rounded, Colors.indigo),
        const SizedBox(height: 8),
        Text(
          "* Average citations calculated from top 200 sampled papers",
          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWideKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mini Trend Chart ────────────────────────────────────

  Widget _buildMiniTrendChart(ResearchDashboardSummary summary) {
    var trendData = summary.publicationTrend
        .where((t) => t.year >= 1900 && t.year <= DateTime.now().year)
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year));

    if (trendData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Center(child: Text("No trend data available.", style: TextStyle(color: Colors.black54))),
      );
    }

    List<FlSpot> spots = trendData.map((t) => FlSpot(t.year.toDouble(), t.count.toDouble())).toList();
    int firstYear = trendData.first.year;
    int lastYear = trendData.last.year;
    int maxCount = trendData.map((t) => t.count).reduce(max);
    double interval = max(1.0, ((lastYear - firstYear) / 4).floorToDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Publication Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text("Papers published per year", style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.black54, fontSize: 11)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: max(1, (maxCount / 4).floorToDouble()),
                      getTitlesWidget: (value, meta) {
                        if (value == value.toInt().toDouble()) {
                          return Text(_formatNumber(value.toInt()), style: const TextStyle(color: Colors.black54, fontSize: 11));
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
                    color: Colors.blueAccent,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.08)),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          "${spot.x.toInt()} · ${_formatNumber(spot.y.toInt())} papers",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
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

  Widget _buildMostInfluentialCard(BuildContext context, ResearchDashboardSummary summary) {
    var paper = summary.mostInfluentialPaper;
    if (paper == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Center(child: Text("No influential paper data available.", style: TextStyle(color: Colors.black54))),
      );
    }

    String authorsText = paper.authors.isNotEmpty
        ? paper.authors.take(3).join(", ") + (paper.authors.length > 3 ? " +${paper.authors.length - 3} more" : "")
        : "Unknown authors";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.emoji_events_rounded, color: Colors.amber[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Most Influential Paper", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            paper.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildChip(Icons.format_quote, "${_formatNumber(paper.citationCount)} Citations", Colors.blueAccent),
              const SizedBox(width: 12),
              _buildChip(Icons.calendar_today, "${paper.year}", Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Text(authorsText, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
          if (paper.journal.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.menu_book, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(paper.journal, style: TextStyle(fontSize: 13, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(publication: paper)));
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text("View Details"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (paper.doi.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(paper.doi);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text("View Paper"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ─── Skeleton Loaders ────────────────────────────────────

  Widget _buildSkeletonHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 200, height: 28, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 8),
        Container(width: 260, height: 18, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8))),
      ],
    );
  }

  Widget _buildSkeletonKPIGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(100)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonCard(100)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(100)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonCard(100)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    }
    return "$number";
  }
}