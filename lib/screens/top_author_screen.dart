import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class TopAuthorScreen extends StatelessWidget {
  const TopAuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    Map<String, int> authors = {};

    for (var p in provider.publications) {
      for (var author in p.authors) {
        if (author.isNotEmpty) {
          authors[author] = (authors[author] ?? 0) + 1;
        }
      }
    }

    var sortedAuthors = authors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text("Top Authors"),
      ),
      body: ListView.builder(
        itemCount: sortedAuthors.length,
        itemBuilder: (context, index) {
          var entry = sortedAuthors[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text(entry.key),
            trailing: Text("${entry.value} papers"),
          );
        },
      ),
    );
  }
}
