import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class TopAuthorScreen extends StatelessWidget {
  const TopAuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    var authorsData = provider.topAuthors;

    return Scaffold(
      appBar: AppBar(
        title: Text("Top Authors"),
      ),
      body: ListView.builder(
        itemCount: authorsData.length,
        itemBuilder: (context, index) {
          var entry = authorsData[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text(entry['name']),
            trailing: Text("${entry['count']} papers"),
          );
        },
      ),
    );
  }
}
