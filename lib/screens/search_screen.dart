import 'package:flutter/material.dart';

import '../l10n/locale_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/language_toggle.dart';

import 'trend_screen.dart';
import 'dashboard_screen.dart';
import 'top_journal_screen.dart';
import 'top_author_screen.dart';
import 'compare_topics_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // A single scaffold hosts the drawer for every tab so that Trends and
    // Compare can open the same sidebar from their header menu button.
    final Widget body;
    switch (_currentIndex) {
      case 1:
        body = TrendScreen(scaffoldKey: _scaffoldKey);
        break;
      case 2:
        body = CompareTopicsScreen(scaffoldKey: _scaffoldKey);
        break;
      default:
        body = DashboardScreen(scaffoldKey: _scaffoldKey);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: body,
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
            // Min height keeps the original look at normal font sizes but
            // lets the header grow (instead of overflowing) when the status
            // bar inset or large Android fonts make the content taller.
            constraints: const BoxConstraints(minHeight: 180),
            decoration: const BoxDecoration(gradient: AppGradients.brand),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  // Keep the title on a single row; FittedBox scales it down
                  // to fit narrow screens instead of wrapping or overflowing.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.s.appTitle,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _drawerTile(Icons.dashboard_rounded, context.s.menuDashboard, () => _goTo(0)),
          _drawerTile(Icons.trending_up_rounded, context.s.menuTrendAnalysis,
              () => _goTo(1)),
          _drawerTile(Icons.compare_arrows_rounded, context.s.menuCompare,
              () => _goTo(2)),
          const Divider(indent: 16, endIndent: 16),
          _drawerTile(Icons.menu_book_rounded, context.s.menuTopJournals, () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TopJournalScreen()));
          }),
          _drawerTile(Icons.people_alt_rounded, context.s.menuTopAuthors, () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TopAuthorScreen()));
          }),
          const Divider(indent: 16, endIndent: 16),
          // Language section — the EN/VI switch lives here under the menu.
          ListTile(
            leading:
                const Icon(Icons.language_rounded, color: AppColors.primary),
            title: Text(
              context.s.languageMenu,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.body),
            ),
            trailing: const LanguageToggle(onDark: false),
          ),
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
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: context.s.navDashboardShort),
          BottomNavigationBarItem(
              icon: const Icon(Icons.trending_up_rounded),
              label: context.s.navTrendsShort),
          BottomNavigationBarItem(
              icon: const Icon(Icons.compare_arrows_rounded),
              label: context.s.navCompareShort),
        ],
      ),
    );
  }
}
