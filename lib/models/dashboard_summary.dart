import '../models/publication.dart';

class ResearchDashboardSummary {
  final int totalPublications;
  final double averageCitationCount;
  final int? mostActiveYear;
  final String? topJournal;
  final String? topAuthor;
  final Publication? mostInfluentialPaper;
  final List<PublicationTrendPoint> publicationTrend;

  ResearchDashboardSummary({
    required this.totalPublications,
    required this.averageCitationCount,
    this.mostActiveYear,
    this.topJournal,
    this.topAuthor,
    this.mostInfluentialPaper,
    required this.publicationTrend,
  });
}
