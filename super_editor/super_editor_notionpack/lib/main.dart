import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/notion_editor_page.dart';

void main() {
  runApp(const NotionPackApp());
}

class NotionPackApp extends StatelessWidget {
  const NotionPackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notion Pack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.light), scaffoldBackgroundColor: Colors.white, useMaterial3: true),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade900, brightness: Brightness.dark), scaffoldBackgroundColor: Colors.grey.shade900, useMaterial3: true),
      themeMode: ThemeMode.light,
      home: const NotionEditorPage(),
    );
  }
}
