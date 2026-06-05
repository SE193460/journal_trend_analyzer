import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../widgets/publication_card.dart';

import 'trend_screen.dart';
import 'top_paper_screen.dart';
import 'dashboard_screen.dart';
import 'top_journal_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Journal Search")),

      body: Padding(
        padding: EdgeInsets.all(10),

        child: Column(
          children: [
            TextField(
              controller: controller,

              decoration: InputDecoration(hintText: "Enter topic"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                provider.search(controller.text);
              },

              child: Text("Search"),
            ),

            SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(builder: (_) => TrendScreen()),
                    );
                  },

                  child: Text("Trend"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(builder: (_) => TopPaperScreen()),
                    );
                  },

                  child: Text("Top Papers"),
                ),
              ],
            ),

            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(builder: (_) => TopJournalScreen()),
                    );
                  },

                  child: Text("Journal"),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,

                      MaterialPageRoute(builder: (_) => DashboardScreen()),
                    );
                  },

                  child: Text("Dashboard"),
                ),
              ],
            ),

            SizedBox(height: 20),

            SizedBox(height: 10),

            if (provider.isLoading) CircularProgressIndicator(),

            if (provider.errorMessage != "") Text(provider.errorMessage),

            Expanded(
              child: ListView.builder(
                itemCount: provider.publications.length,

                itemBuilder: (context, index) {
                  return PublicationCard(
                    publication: provider.publications[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
