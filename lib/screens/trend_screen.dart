import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/publication_provider.dart';

class TrendScreen extends StatelessWidget {
  const TrendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    Map<int, int> yearCount = {};
    for (var p in provider.publications) {
      if (p.year > 0) {
        yearCount[p.year] = (yearCount[p.year] ?? 0) + 1;
      }
    }

    List<int> sortedYears = yearCount.keys.toList()..sort();
    
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    int maxCount = 0;
    
    for (int year in sortedYears) {
      int count = yearCount[year]!;
      if (count > maxCount) maxCount = count;
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Trend Analysis"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: sortedYears.isEmpty 
          ? Center(child: Text("No data available"))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount.toDouble() + 1,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < sortedYears.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(sortedYears[value.toInt()].toString(), style: TextStyle(fontSize: 10)),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == value.toInt().toDouble()) {
                          return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                        }
                        return Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
      ),
    );
  }
}