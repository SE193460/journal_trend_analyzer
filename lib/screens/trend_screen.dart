import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/publication_provider.dart';
import '../models/publication.dart';

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
    var provider = Provider.of<PublicationProvider>(context);

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
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
              Text(provider.errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.search(provider.currentTopic),
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    List<PublicationTrendPoint> baseData = List.from(provider.trendData);
    final currentYear = DateTime.now().year;
    baseData.removeWhere((t) => t.year < 1900 || t.year > currentYear);
    baseData.sort((a, b) => a.year.compareTo(b.year));

    if (baseData.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            "No publication trend data found for this topic.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    double absoluteMin = baseData.first.year.toDouble();
    double absoluteMax = baseData.last.year.toDouble();
    
    if (absoluteMin == absoluteMax) {
      absoluteMin -= 1;
      absoluteMax += 1;
    }

    if (_lastTopic != provider.currentTopic || _startYear == null || _endYear == null) {
      _lastTopic = provider.currentTopic;
      _startYear = absoluteMin;
      _endYear = absoluteMax;
    }

    List<PublicationTrendPoint> trendData = baseData.where((t) {
      return t.year >= _startYear!.toInt() && t.year <= _endYear!.toInt();
    }).toList();

    List<FlSpot> spots = [];
    int totalPapers = 0;
    int maxCount = 0;
    int peakYear = trendData.isNotEmpty ? trendData.first.year : _startYear!.toInt();

    if (trendData.isNotEmpty) {
      for (var t in trendData) {
        totalPapers += t.count;
        if (t.count > maxCount) {
          maxCount = t.count;
          peakYear = t.year;
        }
        spots.add(FlSpot(t.year.toDouble(), t.count.toDouble()));
      }
    }

    int firstYear = trendData.isNotEmpty ? trendData.first.year : _startYear!.toInt();
    int lastYear = trendData.isNotEmpty ? trendData.last.year : _endYear!.toInt();
    String yearRange = firstYear == lastYear ? "$firstYear" : "$firstYear - $lastYear";

    String insightText = "Publication activity peaked in $peakYear with $maxCount papers.";
    if (trendData.isNotEmpty && firstYear != lastYear) {
      int firstCount = trendData.first.count;
      int lastCount = trendData.last.count;
      if (lastCount > firstCount && lastYear > peakYear - 2) {
        insightText += " Research activity has generally increased over time.";
      } else if (lastCount < maxCount && lastYear > peakYear) {
        insightText += " Research activity declined after its peak.";
      }
    } else if (trendData.isEmpty) {
       insightText = "No data available for the selected range.";
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
            _buildYearRangeSlider(absoluteMin, absoluteMax),
            const SizedBox(height: 24),
            _buildSummaryCards(totalPapers, peakYear, yearRange),
            const SizedBox(height: 24),
            if (spots.isNotEmpty) _buildChartCard(spots, firstYear, lastYear, maxCount),
            if (spots.isEmpty) const Center(child: Text("No data in this range.", style: TextStyle(color: Colors.black54))),
            const SizedBox(height: 24),
            _buildInsightSection(insightText),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Publication Trend", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  Widget _buildHeader(String topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Publication Trend",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          topic.isNotEmpty ? "Research trend for: $topic" : "Number of papers published by year",
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildYearRangeSlider(double min, double max) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter by Year:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              Text("${_startYear!.toInt()} - ${_endYear!.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blueAccent,
              inactiveTrackColor: Colors.blueAccent.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.blueAccent.withOpacity(0.1),
              valueIndicatorColor: Colors.blueAccent,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: RangeSlider(
              values: RangeValues(_startYear!, _endYear!),
              min: min,
              max: max,
              divisions: (max - min).toInt() > 0 ? (max - min).toInt() : 1,
              labels: RangeLabels(_startYear!.toInt().toString(), _endYear!.toInt().toString()),
              onChanged: (RangeValues values) {
                setState(() {
                  _startYear = values.start;
                  _endYear = values.end;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int total, int peakYear, String range) {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Total Papers", "$total")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Peak Year", "$peakYear")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("Year Range", range)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<FlSpot> spots, int firstYear, int lastYear, int maxCount) {
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
          const Text(
            "Papers by Publication Year",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200], strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.black54, fontSize: 12)),
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
                          return Text(value.toInt().toString(), style: const TextStyle(color: Colors.black54, fontSize: 12));
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
                maxY: maxCount.toDouble() + (maxCount * 0.2), // 20% padding top
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blueAccent,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          "${spot.x.toInt()} · ${spot.y.toInt()} papers",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildInsightSection(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}