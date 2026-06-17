import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../models/publication.dart';
import 'detail_screen.dart';

class TopPaperScreen extends StatelessWidget {
  const TopPaperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<PublicationProvider>(context);

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(provider.errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.search(provider.currentTopic),
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    var papers = provider.topPapers;

    if (papers.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            "No papers found for this topic.",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: _buildHeader(provider.currentTopic),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildPaperCard(context, papers[index], index + 1);
                },
                childCount: papers.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Top Papers", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }

  Widget _buildHeader(String topic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Influential Papers",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          topic.isNotEmpty ? "Most cited research for: $topic" : "Highest cited papers",
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPaperCard(BuildContext context, Publication paper, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(publication: paper),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRankBadge(rank),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            "${paper.year}",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.format_quote, size: 14, color: Colors.blueAccent),
                          const SizedBox(width: 4),
                          Text(
                            "${paper.citationCount} Citations",
                            style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (paper.journal.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.menu_book, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                paper.journal,
                                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
    } else {
      badgeColor = Colors.blue.shade50;
    }

    Color textColor = (rank <= 3) ? Colors.white : Colors.blueAccent;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: rank <= 3
            ? [BoxShadow(color: badgeColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        "$rank",
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}