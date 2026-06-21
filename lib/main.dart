import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/locale_provider.dart';
import 'providers/compare_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/trend_provider.dart';
import 'providers/top_journal_provider.dart';
import 'providers/top_author_provider.dart';
import 'providers/author_detail_provider.dart';
import 'providers/publication_provider.dart';
import 'providers/recent_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PublicationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TrendProvider()),
        ChangeNotifierProvider(create: (_) => TopJournalProvider()),
        ChangeNotifierProvider(create: (_) => TopAuthorProvider()),
        ChangeNotifierProvider(create: (_) => AuthorDetailProvider()),
        ChangeNotifierProvider(create: (_) => CompareProvider()),
        ChangeNotifierProvider(create: (_) => RecentProvider()..load()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: context.s.appTitle,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
