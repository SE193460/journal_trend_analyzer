import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class TopJournalScreen extends StatelessWidget {
  const TopJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PublicationProvider>(context);

    final Map<String, int> journals = {};
    for (var p in provider.publications) {
      if (p.journal.isNotEmpty) {
        journals[p.journal] = (journals[p.journal] ?? 0) + 1;
      }
    }
    final sorted = journals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sorted.isNotEmpty ? sorted.first.value : 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BrandedHeader(
            title: "Top Journals",
            subtitle: provider.currentTopic.isNotEmpty
                ? "Most active journals for “${provider.currentTopic}”"
                : "Journals ranked by publications",
            icon: Icons.menu_book_rounded,
          ),
          Expanded(
            child: sorted.isEmpty
                ? StateView.empty(
                    icon: Icons.menu_book_rounded,
                    title: "No journals yet",
                    message:
                        "Search a topic first to rank journals by publication count.",
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = sorted[index];
                      return _journalCard(
                          index + 1, entry.key, entry.value, maxCount);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _journalCard(int rank, String name, int count, int maxCount) {
    final ratio = (count / maxCount).clamp(0.05, 1.0);
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          RankBadge(rank: rank),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.3)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: AppColors.primarySoft,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
                      color: AppColors.primary)),
              const Text("papers",
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
