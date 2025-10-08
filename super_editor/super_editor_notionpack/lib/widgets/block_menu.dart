import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_notionpack/blocks/custom_nodes.dart';

/// Block menu that appears when user clicks "+" or types "/"
class BlockMenu extends StatefulWidget {
  const BlockMenu({super.key, required this.editor, required this.composer, required this.document, required this.onBlockSelected, required this.onDismiss});

  final Editor editor;
  final DocumentComposer composer;
  final Document document;
  final VoidCallback onDismiss;
  final Function(BlockMenuOption) onBlockSelected;

  @override
  State<BlockMenu> createState() => _BlockMenuState();
}

class _BlockMenuState extends State<BlockMenu> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<BlockMenuOption> get _filteredOptions {
    if (_searchQuery.isEmpty) {
      return blockMenuOptions;
    }
    return blockMenuOptions.where((option) {
      return option.title.toLowerCase().contains(_searchQuery.toLowerCase()) || option.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _selectOption(BlockMenuOption option) {
    widget.onBlockSelected(option);
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final options = _filteredOptions;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: 'Search blocks...',
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _selectedIndex = 0;
                  });
                },
                onSubmitted: (_) {
                  if (options.isNotEmpty) {
                    _selectOption(options[_selectedIndex]);
                  }
                },
              ),
            ),

            const Divider(height: 1),

            // Block options
            if (options.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Text('No blocks found', style: TextStyle(color: Colors.grey.shade600)))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = index == _selectedIndex;

                    return InkWell(
                      onTap: () => _selectOption(option),
                      onHover: (hovering) {
                        if (hovering) {
                          setState(() => _selectedIndex = index);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(color: isSelected ? Colors.blue.shade50 : Colors.transparent),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Icon(option.icon, size: 20, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(option.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.blue.shade700 : Colors.black87)),
                                  const SizedBox(height: 2),
                                  Text(option.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
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

/// Block menu option
class BlockMenuOption {
  const BlockMenuOption({required this.id, required this.title, required this.description, required this.icon, required this.createNode});

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DocumentNode Function(String nodeId) createNode;
}

/// Available block options
final blockMenuOptions = <BlockMenuOption>[
  BlockMenuOption(id: 'paragraph', title: 'Paragraph', description: 'Plain text block', icon: Icons.text_fields, createNode: (id) => ParagraphNode(id: id, text: AttributedText(''))),
  BlockMenuOption(id: 'heading1', title: 'Heading 1', description: 'Large section heading', icon: Icons.title, createNode: (id) => ParagraphNode(id: id, text: AttributedText(''), metadata: {'blockType': header1Attribution})),
  BlockMenuOption(id: 'heading2', title: 'Heading 2', description: 'Medium section heading', icon: Icons.title, createNode: (id) => ParagraphNode(id: id, text: AttributedText(''), metadata: {'blockType': header2Attribution})),
  BlockMenuOption(id: 'heading3', title: 'Heading 3', description: 'Small section heading', icon: Icons.title, createNode: (id) => ParagraphNode(id: id, text: AttributedText(''), metadata: {'blockType': header3Attribution})),
  BlockMenuOption(id: 'bullet-list', title: 'Bullet List', description: 'Create a bullet list', icon: Icons.format_list_bulleted, createNode: (id) => ListItemNode.unordered(id: id, text: AttributedText(''))),
  BlockMenuOption(id: 'numbered-list', title: 'Numbered List', description: 'Create a numbered list', icon: Icons.format_list_numbered, createNode: (id) => ListItemNode.ordered(id: id, text: AttributedText(''))),
  BlockMenuOption(id: 'quote', title: 'Quote', description: 'Capture a quote', icon: Icons.format_quote, createNode: (id) => QuoteNode(id: id, text: AttributedText(''))),
  BlockMenuOption(id: 'callout-info', title: 'Callout - Info', description: 'Highlight information', icon: Icons.info_outline, createNode: (id) => CalloutNode(id: id, text: AttributedText(''), calloutType: CalloutType.info)),
  BlockMenuOption(id: 'callout-warning', title: 'Callout - Warning', description: 'Show a warning', icon: Icons.warning_amber_outlined, createNode: (id) => CalloutNode(id: id, text: AttributedText(''), calloutType: CalloutType.warning)),
  BlockMenuOption(id: 'callout-error', title: 'Callout - Error', description: 'Show an error', icon: Icons.error_outline, createNode: (id) => CalloutNode(id: id, text: AttributedText(''), calloutType: CalloutType.error)),
  BlockMenuOption(id: 'callout-success', title: 'Callout - Success', description: 'Show success message', icon: Icons.check_circle_outline, createNode: (id) => CalloutNode(id: id, text: AttributedText(''), calloutType: CalloutType.success)),
  BlockMenuOption(id: 'toggle', title: 'Toggle', description: 'Expandable block', icon: Icons.expand_more, createNode: (id) => ToggleNode(id: id, text: AttributedText(''), isExpanded: true)),
  BlockMenuOption(id: 'divider', title: 'Divider', description: 'Horizontal line', icon: Icons.horizontal_rule, createNode: (id) => HorizontalRuleNode(id: id)),
];

/// Insert a block at the current cursor position
void insertBlockFromMenu({required Editor editor, required DocumentComposer composer, required BlockMenuOption option}) {
  final selection = composer.selection;
  if (selection == null) return;

  final nodeId = selection.extent.nodeId;
  final newNodeId = Editor.createNodeId();
  final newNode = option.createNode(newNodeId);

  editor.execute([
    InsertNodeAfterNodeRequest(existingNodeId: nodeId, newNode: newNode),
    ChangeSelectionRequest(DocumentSelection.collapsed(position: DocumentPosition(nodeId: newNodeId, nodePosition: newNode.beginningPosition)), SelectionChangeType.placeCaret, SelectionReason.userInteraction),
  ]);
}
