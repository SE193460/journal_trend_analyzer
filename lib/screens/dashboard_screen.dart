import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    int total = provider.publications.length;
    double avgCitation = 0;
    int mostActiveYear = 0;
    String topJournal = "N/A";
    String topAuthor = "N/A";
    String mostInfluentialPaper = "N/A";

    if (total > 0) {
      avgCitation = provider.publications.map((e) => e.citationCount).reduce((a, b) => a + b) / total;

      var highestCitationPaper = provider.publications.reduce((curr, next) => curr.citationCount > next.citationCount ? curr : next);
      mostInfluentialPaper = highestCitationPaper.title;

      Map<int, int> yearCount = {};
      for (var p in provider.publications) {
        if (p.year > 0) {
          yearCount[p.year] = (yearCount[p.year] ?? 0) + 1;
        }
      }
      if (yearCount.isNotEmpty) {
        mostActiveYear = yearCount.entries.reduce((curr, next) => curr.value > next.value ? curr : next).key;
      }

      Map<String, int> journals = {};
      for (var p in provider.publications) {
        if (p.journal.isNotEmpty) {
          journals[p.journal] = (journals[p.journal] ?? 0) + 1;
        }
      }
      if (journals.isNotEmpty) {
        topJournal = journals.entries.reduce((curr, next) => curr.value > next.value ? curr : next).key;
      }

      Map<String, int> authors = {};
      for (var p in provider.publications) {
        for (var a in p.authors) {
          if (a.isNotEmpty) {
            authors[a] = (authors[a] ?? 0) + 1;
          }
        }
      }
      if (authors.isNotEmpty) {
        topAuthor = authors.entries.reduce((curr, next) => curr.value > next.value ? curr : next).key;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Dashboard", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard("Total Papers", "$total", Icons.description_rounded, Colors.blue),
                  _buildStatCard("Avg Citations", avgCitation.toStringAsFixed(1), Icons.star_rounded, Colors.orange),
                  _buildStatCard("Active Year", mostActiveYear > 0 ? "$mostActiveYear" : "N/A", Icons.calendar_today_rounded, Colors.green),
                  _buildStatCard("Top Author", topAuthor.length > 15 ? topAuthor.substring(0, 15) + "..." : topAuthor, Icons.person_rounded, Colors.purple),
                ],
              ),
              SizedBox(height: 32),
              Text(
                "Key Insights",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 16),
              _buildInsightListTile("Top Journal", topJournal, Icons.book_rounded, Colors.indigo),
              SizedBox(height: 12),
              _buildInsightListTile("Most Influential Paper", mostInfluentialPaper, Icons.emoji_events_rounded, Colors.amber[700]!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightListTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}