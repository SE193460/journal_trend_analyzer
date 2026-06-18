import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/publication_card.dart';

import 'trend_screen.dart';
import 'top_paper_screen.dart';
import 'dashboard_screen.dart';
import 'top_journal_screen.dart';
import 'top_author_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a research topic")),
      );
      return;
    }
    Provider.of<PublicationProvider>(context, listen: false)
        .search(_controller.text.trim());
    FocusScope.of(context).unfocus();
  }

  void _onChipTapped(String topic) {
    _controller.text = topic;
    _onSearch();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 1) return _wrapWithBottomNav(const TrendScreen());
    if (_currentIndex == 2) return _wrapWithBottomNav(const TopPaperScreen());
    if (_currentIndex == 3) return _wrapWithBottomNav(const DashboardScreen());

    final provider = Provider.of<PublicationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: provider.isLoading
                ? StateView.loading(message: "Analyzing publications…")
                : provider.errorMessage.isNotEmpty
                    ? StateView.error(
                        provider.errorMessage,
                        onRetry: () => provider.search(provider.currentTopic),
                      )
                    : provider.publications.isEmpty
                        ? _buildEmptyState()
                        : _buildResultsList(provider),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Drawer ──────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.card,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 180,
            decoration: const BoxDecoration(gradient: AppGradients.brand),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.insights_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Journal Trend\nAnalyzer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _drawerTile(Icons.search_rounded, "Search", () => _goTo(0)),
          _drawerTile(Icons.trending_up_rounded, "Trend Analysis", () => _goTo(1)),
          _drawerTile(Icons.article_rounded, "Top Papers", () => _goTo(2)),
          _drawerTile(Icons.dashboard_rounded, "Dashboard", () => _goTo(3)),
          const Divider(indent: 16, endIndent: 16),
          _drawerTile(Icons.menu_book_rounded, "Top Journals", () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TopJournalScreen()));
          }),
          _drawerTile(Icons.people_alt_rounded, "Top Authors", () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TopAuthorScreen()));
          }),
        ],
      ),
    );
  }

  void _goTo(int index) {
    Navigator.pop(context);
    setState(() => _currentIndex = index);
  }

  Widget _drawerTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.body),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  // ─── Bottom navigation ───────────────────────────────────

  Widget _wrapWithBottomNav(Widget child) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded), label: "Trends"),
          BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded), label: "Papers"),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => Material(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(Icons.menu_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Journal Trend Analyzer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Explore research trends with OpenAlex",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _buildSearchArea(),
              const SizedBox(height: 16),
              _buildTopicChips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _onSearch(),
        style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search a research topic…",
          hintStyle: const TextStyle(color: AppColors.faint),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _onSearch,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTopicChips() {
    final topics = [
      "Artificial Intelligence",
      "Data Science",
      "Cybersecurity",
      "Blockchain",
      "IoT",
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return Material(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _onChipTapped(topics[i]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: Text(
                  topics[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            const Text(
              "Start exploring research",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Search a topic to analyze publications, citations, journals and authors.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 32),
            _buildFeatureShortcuts(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureShortcuts() {
    final items = [
      _Shortcut("Trend Analysis", Icons.trending_up_rounded, AppColors.primary,
          () => const TrendScreen()),
      _Shortcut("Top Papers", Icons.article_rounded, AppColors.indigo,
          () => const TopPaperScreen()),
      _Shortcut("Top Journals", Icons.menu_book_rounded, AppColors.emerald,
          () => const TopJournalScreen()),
      _Shortcut("Top Authors", Icons.people_alt_rounded, AppColors.violet,
          () => const TopAuthorScreen()),
      _Shortcut("Dashboard", Icons.dashboard_rounded, AppColors.sky,
          () => const DashboardScreen()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Explore insights",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.6,
          children:
              items.map((s) => _buildShortcutCard(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildShortcutCard(_Shortcut s) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => s.builder())),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s.icon, color: s.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Results ─────────────────────────────────────────────

  Widget _buildResultsList(PublicationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            "${provider.publications.length} results for “${provider.currentTopic}”",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: provider.publications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child:
                    PublicationCard(publication: provider.publications[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Shortcut {
  final String title;
  final IconData icon;
  final Color color;
  final Widget Function() builder;
  _Shortcut(this.title, this.icon, this.color, this.builder);
}
