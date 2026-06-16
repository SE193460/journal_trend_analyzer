class Publication {

  final String title;
  final int year;
  final int citationCount;
  final String doi;
  final String journal;
  final List<String> authors;
  final String abstractText;

  Publication({
    required this.title,
    required this.year,
    required this.citationCount,
    required this.doi,
    required this.journal,
    required this.authors,
    required this.abstractText,
  });

  factory Publication.fromJson(Map<String,dynamic> json){
    
    List<String> parsedAuthors = [];
    if (json['authorships'] != null) {
      for (var authorData in json['authorships']) {
        if (authorData['author'] != null && authorData['author']['display_name'] != null) {
          parsedAuthors.add(authorData['author']['display_name']);
        }
      }
    }
    
    String reconstructedAbstract = "";
    if (json['abstract_inverted_index'] != null) {
      Map<String, dynamic> indexMap = json['abstract_inverted_index'];
      Map<int, String> wordsMap = {};
      indexMap.forEach((word, positions) {
        for (var pos in positions) {
          wordsMap[pos] = word;
        }
      });
      var sortedKeys = wordsMap.keys.toList()..sort();
      reconstructedAbstract = sortedKeys.map((k) => wordsMap[k]).join(" ");
    }

    return Publication(
      title: json['title'] ?? "",
      year: json['publication_year'] ?? 0,
      citationCount: json['cited_by_count'] ?? 0,
      doi: json['doi'] ?? "",
      journal: json['primary_location']
      ?['source']
      ?['display_name'] ?? "",
      authors: parsedAuthors,
      abstractText: reconstructedAbstract,
    );
  }
}