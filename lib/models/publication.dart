class Publication {

  final String title;
  final int year;
  final int citationCount;
  final String doi;
  final String journal;

  Publication({
    required this.title,
    required this.year,
    required this.citationCount,
    required this.doi,
    required this.journal,
  });

  factory Publication.fromJson(Map<String,dynamic> json){

    return Publication(
      title: json['title'] ?? "",
      year: json['publication_year'] ?? 0,
      citationCount: json['cited_by_count'] ?? 0,
      doi: json['doi'] ?? "",
      journal: json['primary_location']
      ?['source']
      ?['display_name'] ?? ""
    );
  }
}