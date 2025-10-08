import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_notionpack/blocks/custom_nodes.dart';

/// Block types that can be inserted via slash commands
enum BlockType { text, heading1, heading2, heading3, bulletList, numberedList, quote, callout, toggle, divider }

/// Extension to get block type metadata
extension BlockTypeExtension on BlockType {
  String get name {
    switch (this) {
      case BlockType.text:
        return 'Text';
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      case BlockType.bulletList:
        return 'Bullet List';
      case BlockType.numberedList:
        return 'Numbered List';
      case BlockType.quote:
        return 'Quote';
      case BlockType.callout:
        return 'Callout';
      case BlockType.toggle:
        return 'Toggle';
      case BlockType.divider:
        return 'Divider';
    }
  }

  String get description {
    switch (this) {
      case BlockType.text:
        return 'Plain text paragraph';
      case BlockType.heading1:
        return 'Large section heading';
      case BlockType.heading2:
        return 'Medium section heading';
      case BlockType.heading3:
        return 'Small section heading';
      case BlockType.bulletList:
        return 'Create a bullet list';
      case BlockType.numberedList:
        return 'Create a numbered list';
      case BlockType.quote:
        return 'Capture a quote';
      case BlockType.callout:
        return 'Make text stand out';
      case BlockType.toggle:
        return 'Toggle to hide/show content';
      case BlockType.divider:
        return 'Divide blocks with a line';
    }
  }

  IconData get icon {
    switch (this) {
      case BlockType.text:
        return Icons.text_fields;
      case BlockType.heading1:
        return Icons.title;
      case BlockType.heading2:
        return Icons.title;
      case BlockType.heading3:
        return Icons.title;
      case BlockType.bulletList:
        return Icons.format_list_bulleted;
      case BlockType.numberedList:
        return Icons.format_list_numbered;
      case BlockType.quote:
        return Icons.format_quote;
      case BlockType.callout:
        return Icons.lightbulb_outline;
      case BlockType.toggle:
        return Icons.expand_more;
      case BlockType.divider:
        return Icons.horizontal_rule;
    }
  }
}

/// Slash command menu widget
class SlashCommandMenu extends StatefulWidget {
  const SlashCommandMenu({super.key, required this.editor, required this.document, required this.composer, required this.position, required this.onBlockSelected, required this.onDismiss});

  final Editor editor;
  final Document document;
  final DocumentComposer composer;
  final Offset position;
  final Function(BlockType) onBlockSelected;
  final VoidCallback onDismiss;

  @override
  State<SlashCommandMenu> createState() => _SlashCommandMenuState();
}

class _SlashCommandMenuState extends State<SlashCommandMenu> {
  final int _selectedIndex = 0;
  final String _searchQuery = '';

  final List<BlockType> _allBlockTypes = BlockType.values;

  List<BlockType> get _filteredBlockTypes {
    if (_searchQuery.isEmpty) {
      return _allBlockTypes;
    }

    return _allBlockTypes.where((type) {
      return type.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTypes = _filteredBlockTypes;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [Icon(Icons.search, size: 18, color: Colors.grey.shade600), const SizedBox(width: 8), Text('Type to filter blocks...', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))]),
            ),

            // Block type list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredTypes.length,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemBuilder: (context, index) {
                  final blockType = filteredTypes[index];
                  final isSelected = index == _selectedIndex;

                  return InkWell(
                    onTap: () => widget.onBlockSelected(blockType),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: isSelected ? Colors.blue.shade50 : Colors.transparent),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Icon(blockType.icon, size: 18, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text(blockType.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.blue.shade700 : Colors.black87)), Text(blockType.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inserts a block of the given type at the current cursor position
void insertBlock({required Editor editor, required Document document, required DocumentComposer composer, required BlockType blockType}) {
  final selection = composer.selection;
  if (selection == null || !selection.isCollapsed) {
    return;
  }

  final nodeId = selection.extent.nodeId;
  final node = document.getNodeById(nodeId);

  if (node == null) {
    return;
  }

  // Create the new node based on block type
  DocumentNode newNode;
  final newNodeId = Editor.createNodeId();

  switch (blockType) {
    case BlockType.text:
      newNode = ParagraphNode(id: newNodeId, text: AttributedText(''));
      break;
    case BlockType.heading1:
      newNode = ParagraphNode(id: newNodeId, text: AttributedText(''), metadata: {'blockType': header1Attribution});
      break;
    case BlockType.heading2:
      newNode = ParagraphNode(id: newNodeId, text: AttributedText(''), metadata: {'blockType': header2Attribution});
      break;
    case BlockType.heading3:
      newNode = ParagraphNode(id: newNodeId, text: AttributedText(''), metadata: {'blockType': header3Attribution});
      break;
    case BlockType.bulletList:
      newNode = ListItemNode.unordered(id: newNodeId, text: AttributedText(''));
      break;
    case BlockType.numberedList:
      newNode = ListItemNode.ordered(id: newNodeId, text: AttributedText(''));
      break;
    case BlockType.quote:
      newNode = QuoteNode(id: newNodeId, text: AttributedText(''));
      break;
    case BlockType.callout:
      newNode = CalloutNode(id: newNodeId, text: AttributedText(''), calloutType: CalloutType.info);
      break;
    case BlockType.toggle:
      newNode = ToggleNode(id: newNodeId, text: AttributedText(''), isExpanded: true);
      break;
    case BlockType.divider:
      newNode = HorizontalRuleNode(id: newNodeId);
      break;
  }

  // If current node is empty, replace it; otherwise, insert after
  if (node is TextNode && node.text.text.isEmpty) {
    editor.execute([
      ReplaceNodeRequest(existingNodeId: nodeId, newNode: newNode),
      ChangeSelectionRequest(DocumentSelection.collapsed(position: DocumentPosition(nodeId: newNodeId, nodePosition: newNode.beginningPosition)), SelectionChangeType.placeCaret, SelectionReason.userInteraction),
    ]);
  } else {
    editor.execute([
      InsertNodeAfterNodeRequest(existingNodeId: nodeId, newNode: newNode),
      ChangeSelectionRequest(DocumentSelection.collapsed(position: DocumentPosition(nodeId: newNodeId, nodePosition: newNode.beginningPosition)), SelectionChangeType.placeCaret, SelectionReason.userInteraction),
    ]);
  }
}
