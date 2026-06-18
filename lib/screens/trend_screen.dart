import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/publication_provider.dart';
import '../models/publication.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({super.key});

  @override
  State<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  String? _lastTopic;
  double? _startYear;
  double? _endYear;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrandedHeader(
            title: "Publication Trend",
            subtitle: provider.currentTopic.isNotEmpty
                ? "Research trend for “${provider.currentTopic}”"
                : "Papers published by year",
            icon: Icons.trending_up_rounded,
          ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(PublicationProvider provider) {
    if (provider.isLoading) {
      return StateView.loading(message: "Loading trend data…");
    }
    if (provider.errorMessage.isNotEmpty) {
      return StateView.error(
        provider.errorMessage,
        onRetry: () => provider.search(provider.currentTopic),
      );
    }

    List<PublicationTrendPoint> baseData = List.from(provider.trendData);
    final currentYear = DateTime.now().year;
    baseData.removeWhere((t) => t.year < 1900 || t.year > currentYear);
    baseData.sort((a, b) => a.year.compareTo(b.year));

    if (baseData.isEmpty) {
      return StateView.empty(
        icon: Icons.show_chart_rounded,
        title: "No trend data",
        message: "Search a topic to see how publications evolved over time.",
      );
    }

    double absoluteMin = baseData.first.year.toDouble();
    double absoluteMax = baseData.last.year.toDouble();
    if (absoluteMin == absoluteMax) {
      absoluteMin -= 1;
      absoluteMax += 1;
    }

    if (_lastTopic != provider.currentTopic ||
        _startYear == null ||
        _endYear == null) {
      _lastTopic = provider.currentTopic;
      _startYear = absoluteMin;
      _endYear = absoluteMax;
    }

    final trendData = baseData
        .where((t) =>
            t.year >= _startYear!.toInt() && t.year <= _endYear!.toInt())
        .toList();

    final spots = <FlSpot>[];
    int totalPapers = 0;
    int maxCount = 0;
    int peakYear = trendData.isNotEmpty ? trendData.first.year : _startYear!.toInt();

    for (var t in trendData) {
      totalPapers += t.count;
      if (t.count > maxCount) {
        maxCount = t.count;
        peakYear = t.year;
      }
      spots.add(FlSpot(t.year.toDouble(), t.count.toDouble()));
    }

    final firstYear =
        trendData.isNotEmpty ? trendData.first.year : _startYear!.toInt();
    final lastYear =
        trendData.isNotEmpty ? trendData.last.year : _endYear!.toInt();
    final yearRange = firstYear == lastYear ? "$firstYear" : "$firstYear–$lastYear";

    String insightText =
        "Publication activity peaked in $peakYear with ${_compact(maxCount)} papers.";
    if (trendData.isNotEmpty && firstYear != lastYear) {
      final firstCount = trendData.first.count;
      final lastCount = trendData.last.count;
      if (lastCount > firstCount && lastYear > peakYear - 2) {
        insightText += " Research activity has generally increased over time.";
      } else if (lastCount < maxCount && lastYear > peakYear) {
        insightText += " Research activity declined after its peak.";
      }
    } else if (trendData.isEmpty) {
      insightText = "No data available for the selected range.";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYearRangeSlider(absoluteMin, absoluteMax),
          const SizedBox(height: 16),
          _buildSummaryCards(totalPapers, peakYear, yearRange),
          const SizedBox(height: 16),
          if (spots.isNotEmpty)
            _buildChartCard(spots, firstYear, lastYear, maxCount)
          else
            const SectionCard(
              child: Center(
                child: Text("No data in this range.",
                    style: TextStyle(color: AppColors.muted)),
              ),
            ),
          const SizedBox(height: 16),
          _buildInsightSection(insightText),
        ],
      ),
    );
  }

  Widget _buildYearRangeSlider(double min, double max) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter by year",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_startYear!.toInt()} – ${_endYear!.toInt()}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.18),
              thumbColor: Colors.white,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              valueIndicatorColor: AppColors.primary,
              trackHeight: 4,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: RangeSlider(
              values: RangeValues(_startYear!, _endYear!),
              min: min,
              max: max,
              divisions: (max - min).toInt() > 0 ? (max - min).toInt() : 1,
              labels: RangeLabels(
                  _startYear!.toInt().toString(), _endYear!.toInt().toString()),
              onChanged: (values) => setState(() {
                _startYear = values.start;
                _endYear = values.end;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int total, int peakYear, String range) {
    return Row(
      children: [
        Expanded(
            child: _statCard("Total Papers", _compact(total),
                Icons.description_rounded, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard("Peak Year", "$peakYear",
                Icons.local_fire_department_rounded, AppColors.amber)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard("Year Range", range,
                Icons.date_range_rounded, AppColors.sky)),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
          ),
          const SizedBox(height: 2),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChartCard(
      List<FlSpot> spots, int firstYear, int lastYear, int maxCount) {
    final interval = max(1.0, ((lastYear - firstYear) / 4).floorToDouble());

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
              title: "Papers by publication year",
              icon: Icons.stacked_line_chart_rounded),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
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
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
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
                          return Text(_compact(value.toInt()),
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
                maxY: maxCount.toDouble() + (maxCount * 0.2),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBright, AppColors.primary],
                    ),
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.primary,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.22),
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
                              "${spot.x.toInt()} · ${_compact(spot.y.toInt())} papers",
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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

  Widget _buildInsightSection(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Insight",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(text,
                    style: const TextStyle(
                        color: AppColors.body, fontSize: 13.5, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }
}
