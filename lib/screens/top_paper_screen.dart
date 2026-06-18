import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../models/publication.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class TopPaperScreen extends StatelessWidget {
  const TopPaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrandedHeader(
            title: "Top Influential Papers",
            subtitle: provider.currentTopic.isNotEmpty
                ? "Most cited research for “${provider.currentTopic}”"
                : "Highest cited papers",
            icon: Icons.workspace_premium_rounded,
          ),
          Expanded(child: _buildBody(context, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PublicationProvider provider) {
    if (provider.isLoading) {
      return StateView.loading(message: "Ranking papers…");
    }
    if (provider.errorMessage.isNotEmpty) {
      return StateView.error(
        provider.errorMessage,
        onRetry: () => provider.search(provider.currentTopic),
      );
    }

    final papers = provider.topPapers;
    if (papers.isEmpty) {
      return StateView.empty(
        icon: Icons.article_rounded,
        title: "No papers found",
        message: "Search a topic to discover its most cited papers.",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      itemCount: papers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildPaperCard(context, papers[index], index + 1),
    );
  }

  Widget _buildPaperCard(BuildContext context, Publication paper, int rank) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => DetailScreen(publication: paper))),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RankBadge(rank: rank),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paper.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            height: 1.35)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        MetaChip(
                            icon: Icons.calendar_today_rounded,
                            label: "${paper.year}",
                            color: AppColors.emerald),
                        const SizedBox(width: 8),
                        MetaChip(
                            icon: Icons.format_quote_rounded,
                            label: "${_compact(paper.citationCount)} cites",
                            color: AppColors.primary),
                      ],
                    ),
                    if (paper.journal.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 14, color: AppColors.faint),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(paper.journal,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12.5, color: AppColors.muted)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }
}
