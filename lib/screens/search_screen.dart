import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
import '../widgets/publication_card.dart';

import 'trend_screen.dart';
import 'top_paper_screen.dart';
import 'dashboard_screen.dart';
import 'top_journal_screen.dart';
import 'top_author_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';
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

  void _onSearch() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a topic")),
      );
      return;
    }
    Provider.of<PublicationProvider>(context, listen: false).search(_controller.text);
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

    var provider = Provider.of<PublicationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: _buildDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: provider.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : (provider.publications.isEmpty && provider.errorMessage.isEmpty)
                    ? _buildEmptyState()
                    : _buildResultsList(provider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFF48FB1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text("Features Menu", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Color(0xFFF48FB1)),
            title: const Text("Search"),
            onTap: () { Navigator.pop(context); setState(() => _currentIndex = 0); },
          ),
          ListTile(
            leading: const Icon(Icons.trending_up, color: Color(0xFFF48FB1)),
            title: const Text("Trend Analysis"),
            onTap: () { Navigator.pop(context); setState(() => _currentIndex = 1); },
          ),
          ListTile(
            leading: const Icon(Icons.article, color: Color(0xFFF48FB1)),
            title: const Text("Top Papers"),
            onTap: () { Navigator.pop(context); setState(() => _currentIndex = 2); },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFFF48FB1)),
            title: const Text("Dashboard"),
            onTap: () { Navigator.pop(context); setState(() => _currentIndex = 3); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.book, color: Color(0xFFF48FB1)),
            title: const Text("Top Journals"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TopJournalScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFFF48FB1)),
            title: const Text("Top Authors"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TopAuthorScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _wrapWithBottomNav(Widget child) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFFF48FB1),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Trends"),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: "Papers"),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFF48FB1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 32),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Journal Trend Analyzer",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Explore research trends with OpenAlex",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSearchArea(),
          const SizedBox(height: 16),
          _buildTopicChips(),
        ],
      ),
    );
  }

  Widget _buildSearchArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _onSearch(),
        decoration: InputDecoration(
          hintText: "Search research topic",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFF48FB1)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFF48FB1), size: 18),
            onPressed: _onSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTopicChips() {
    final topics = ["Artificial Intelligence", "Data Science", "Cybersecurity", "Blockchain", "IoT"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: topics.map((topic) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(topic, style: const TextStyle(color: Color(0xFFF48FB1), fontSize: 12)),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => _onChipTapped(topic),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(Icons.auto_stories, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Enter a topic to begin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              "Search a research field to analyze publications, citations, journals, and authors.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 40),
            _buildFeatureShortcuts(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureShortcuts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Explore insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildShortcutCard("Trend Analysis", Icons.trending_up, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendScreen()))),
            _buildShortcutCard("Top Papers", Icons.article, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopPaperScreen()))),
            _buildShortcutCard("Top Journals", Icons.book, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopJournalScreen()))),
            _buildShortcutCard("Top Authors", Icons.person, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TopAuthorScreen()))),
            _buildShortcutCard("Dashboard", Icons.dashboard, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()))),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFF48FB1), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(PublicationProvider provider) {
    return Column(
      children: [
        if (provider.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(provider.errorMessage, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.publications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: PublicationCard(
                  publication: provider.publications[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
