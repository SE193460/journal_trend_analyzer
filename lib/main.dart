import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/locale_provider.dart';
import 'providers/compare_provider.dart';
import 'providers/publication_provider.dart';
import 'providers/recent_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PublicationProvider()),
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
