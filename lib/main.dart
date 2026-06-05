import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/publication_provider.dart';
import 'screens/search_screen.dart';

void main() {

  runApp(

    ChangeNotifierProvider(

      create: (_) => PublicationProvider(),

      child: const MyApp(),

    )

  );

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Journal Trend Analyzer",

      home: SearchScreen(),

    );

  }

}