import 'package:flutter/material.dart';

import '../models/publication.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;

  const PublicationCard({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    final authors = publication.authors.isNotEmpty
        ? publication.authors.take(3).join(", ") +
            (publication.authors.length > 3
                ? " +${publication.authors.length - 3}"
                : "")
        : "Unknown authors";

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(publication: publication),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publication.title.isNotEmpty
                    ? publication.title
                    : "Untitled work",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 14, color: AppColors.faint),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      authors,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              if (publication.journal.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        size: 14, color: AppColors.faint),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        publication.journal,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _badge(
                    Icons.calendar_today_rounded,
                    publication.year > 0 ? "${publication.year}" : "—",
                    AppColors.emerald,
                  ),
                  const SizedBox(width: 8),
                  _badge(
                    Icons.format_quote_rounded,
                    "${_compact(publication.citationCount)} cites",
                    AppColors.primary,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.faint, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }
}
