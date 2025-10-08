import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/notion_editor.dart';

/// Main page with Notion-like editor
class NotionEditorPage extends StatefulWidget {
  const NotionEditorPage({super.key});

  @override
  State<NotionEditorPage> createState() => _NotionEditorPageState();
}

class _NotionEditorPageState extends State<NotionEditorPage> {
  bool _isEditMode = true;
  String _saveStatus = '';

  @override
  void initState() {
    super.initState();
  }

  void _handleSave(Map<String, dynamic> documentJson) {
    // Convert to JSON string
    final jsonString = JsonEncoder.withIndent('  ').convert(documentJson);

    // Print to console for now (in production, send to database)
    print('💾 SAVING DOCUMENT:');
    print(jsonString);

    setState(() {
      _saveStatus = 'Saved at ${DateTime.now().toString().substring(11, 19)}';
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document saved! ${documentJson['blocks'].length} blocks'), duration: const Duration(seconds: 2), backgroundColor: Colors.green.shade700));

    // TODO: In production, send to your database:
    // await api.saveDocument(documentJson);
    // await database.insert('documents', documentJson);
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
            IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('Untitled Document', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), if (_saveStatus.isNotEmpty) Text(_saveStatus, style: TextStyle(fontSize: 11, color: Colors.grey.shade600))],
              ),
            ),
            // Toggle Edit/View Mode
            SegmentedButton<bool>(
              segments: const [ButtonSegment(value: true, icon: Icon(Icons.edit, size: 18), label: Text('Edit')), ButtonSegment(value: false, icon: Icon(Icons.visibility, size: 18), label: Text('View'))],
              selected: {_isEditMode},
              onSelectionChanged: (Set<bool> selection) {
                setState(() {
                  _isEditMode = selection.first;
                });
              },
              style: ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(width: 16),
            IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return NotionEditor(isEditable: _isEditMode, onSave: _handleSave);
  }
}
