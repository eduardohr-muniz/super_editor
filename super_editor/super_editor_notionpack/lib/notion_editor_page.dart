import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/notion_editor.dart';

/// Main page with Notion-like editor
class NotionEditorPage extends StatefulWidget {
  const NotionEditorPage({super.key});

  @override
  State<NotionEditorPage> createState() => _NotionEditorPageState();
}

class _NotionEditorPageState extends State<NotionEditorPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (optional - can be expanded later)
          Container(width: 240, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, border: Border(right: BorderSide(color: Theme.of(context).dividerColor, width: 1))), child: _buildSidebar()),

          // Main editor area
          Expanded(child: Column(children: [_buildTopBar(), Expanded(child: _buildEditor())])),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(16.0), child: Row(children: [Icon(Icons.note_outlined, size: 20), const SizedBox(width: 8), Text('NotionPack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])),
        Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              _buildSidebarItem(Icons.home_outlined, 'Home', isSelected: true),
              _buildSidebarItem(Icons.inbox_outlined, 'Inbox'),
              _buildSidebarItem(Icons.settings_outlined, 'Settings'),
              const SizedBox(height: 16),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Text('BLOCKS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
              _buildSidebarItem(Icons.text_fields, 'Text'),
              _buildSidebarItem(Icons.format_quote, 'Quote'),
              _buildSidebarItem(Icons.lightbulb_outline, 'Callout'),
              _buildSidebarItem(Icons.expand_more, 'Toggle'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
      child: ListTile(dense: true, leading: Icon(icon, size: 18), title: Text(label, style: TextStyle(fontSize: 13)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.menu), onPressed: () {}),
            const SizedBox(width: 8),
            Expanded(child: Text('Untitled Document', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            IconButton(icon: Icon(Icons.share_outlined), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return const NotionEditor(
      isEditable: true, // Change to false for view-only mode
    );
  }
}
