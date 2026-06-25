import '../models/publication.dart';

class ResearchDashboardSummary {
  final int totalPublications;
  final double averageCitationCount;
  final int? mostActiveYear;
  final String? topJournal;
  final String? topAuthor;
  final Publication? mostInfluentialPaper;
  final List<PublicationTrendPoint> publicationTrend;

  /// Number of papers actually fetched from the API for this search
  /// (capped by the search limit). This is the real "Papers Retrieved" count,
  /// not the total number of matching works on OpenAlex.
  final int papersRetrieved;

  ResearchDashboardSummary({
    required this.totalPublications,
    required this.averageCitationCount,
    this.mostActiveYear,
    this.topJournal,
    this.topAuthor,
    this.mostInfluentialPaper,
    required this.publicationTrend,
    this.papersRetrieved = 0,
  });
}
