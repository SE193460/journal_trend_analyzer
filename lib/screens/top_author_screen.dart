import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_provider.dart';
import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TopAuthorScreen extends StatelessWidget {
  const TopAuthorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicationProvider>(context);
    final authors = provider.topAuthors;

    final int maxCount = authors.isNotEmpty
        ? authors
            .map((a) => (a['count'] as int?) ?? 0)
            .reduce((a, b) => a > b ? a : b)
        : 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrandedHeader(
            title: context.s.topAuthorsTitle,
            subtitle: provider.currentTopic.isNotEmpty
                ? context.s.topAuthorsSubtitleForTopic(provider.currentTopic)
                : context.s.topAuthorsSubtitleDefault,
            icon: Icons.people_alt_rounded,
          ),
          Expanded(
            child: authors.isEmpty
                ? StateView.empty(
                    icon: Icons.people_alt_rounded,
                    title: context.s.noAuthorsTitle,
                    message: context.s.noAuthorsMessage,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    itemCount: authors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = authors[index];
                      final name = entry['name']?.toString() ?? "Unknown";
                      final count = (entry['count'] as int?) ?? 0;
                      return _authorCard(
                          context, index + 1, name, count, maxCount);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _authorCard(
      BuildContext context, int rank, String name, int count, int maxCount) {
    final ratio = (count / maxCount).clamp(0.05, 1.0);
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          RankBadge(rank: rank),
          const SizedBox(width: 12),
          _avatar(name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: AppColors.primarySoft,
                    valueColor: const AlwaysStoppedAnimation(AppColors.violet),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$count",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.violet)),
              Text(context.s.papersUnit,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name) {
    final initials = name.trim().isNotEmpty
        ? name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w[0])
            .join()
            .toUpperCase()
        : "?";
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(
              color: AppColors.violet,
              fontWeight: FontWeight.w800,
              fontSize: 13)),
    );
  }
}
