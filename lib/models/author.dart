class TopAuthor {
  final String id;
  final String name;
  final int worksCount;
  final int? citedByCount;

  TopAuthor({
    required this.id,
    required this.name,
    required this.worksCount,
    this.citedByCount,
  });

  factory TopAuthor.fromJson(Map<String, dynamic> json) {
    String rawId = json['key']?.toString() ?? "";
    String authorId = rawId.split('/').last;

    return TopAuthor(
      id: authorId,
      name: json['key_display_name']?.toString() ?? "Unknown",
      worksCount: json['count'] ?? 0,
      citedByCount: json['cited_by_count'], // Might not be available in group_by
    );
  }
}

class AuthorDetail {
  final String id;
  final String name;
  final String? institution;
  final int worksCount;
  final int citedByCount;
  final int? hIndex;
  final int? i10Index;
  final String? orcid;

  AuthorDetail({
    required this.id,
    required this.name,
    this.institution,
    required this.worksCount,
    required this.citedByCount,
    this.hIndex,
    this.i10Index,
    this.orcid,
  });

  factory AuthorDetail.fromJson(Map<String, dynamic> json) {
    String rawId = json['id']?.toString() ?? "";
    String authorId = rawId.split('/').last;

    String? institutionName;
    if (json['last_known_institution'] != null) {
      institutionName = json['last_known_institution']['display_name'];
    }

    return AuthorDetail(
      id: authorId,
      name: json['display_name']?.toString() ?? "Unknown",
      institution: institutionName,
      worksCount: json['works_count'] ?? 0,
      citedByCount: json['cited_by_count'] ?? 0,
      hIndex: json['summary_stats']?['h_index'],
      i10Index: json['summary_stats']?['i10_index'],
      orcid: json['ids']?['orcid'],
    );
  }
}
