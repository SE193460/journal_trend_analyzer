import 'package:flutter/material.dart';

import '../models/publication.dart';

class DetailScreen extends StatelessWidget {
  final Publication publication;

  const DetailScreen({
    super.key,
    required this.publication,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publication.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text("Authors: ${publication.authors.join(', ')}", style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              Text("Year: ${publication.year}"),
              Text("Citations: ${publication.citationCount}"),
              Text("Journal: ${publication.journal}"),
              Text("DOI: ${publication.doi}"),
              SizedBox(height: 20),
              Text("Abstract", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(
                publication.abstractText.isNotEmpty 
                  ? publication.abstractText 
                  : "No abstract available.",
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}