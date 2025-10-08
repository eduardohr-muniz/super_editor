import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/widgets/block_menu.dart';

/// A true Notion-style block editor with reorderable blocks
class NotionBlockEditor extends StatefulWidget {
  const NotionBlockEditor({super.key});

  @override
  State<NotionBlockEditor> createState() => _NotionBlockEditorState();
}

class _NotionBlockEditorState extends State<NotionBlockEditor> {
  final List<EditorBlock> _blocks = [];
  int? _hoveredBlockIndex;
  bool _showBlockMenu = false;
  Offset _blockMenuPosition = Offset.zero;
  int? _menuForBlockIndex;
  bool _isSlashCommand = false;

  @override
  void initState() {
    super.initState();
    _initializeBlocks();
  }

  void _initializeBlocks() {
    _blocks.addAll([
      EditorBlock(id: '1', type: BlockType.heading1, content: 'Welcome to NotionPack'),
      EditorBlock(id: '2', type: BlockType.paragraph, content: 'This is a real Notion-style block editor with drag and drop!'),
      EditorBlock(id: '3', type: BlockType.calloutInfo, content: '💡 Each block can be dragged to reorder'),
      EditorBlock(id: '4', type: BlockType.heading2, content: 'Features:'),
      EditorBlock(id: '5', type: BlockType.bulletList, content: 'Drag handles on hover'),
      EditorBlock(id: '6', type: BlockType.bulletList, content: '+ button to add new blocks'),
      EditorBlock(id: '7', type: BlockType.bulletList, content: 'Reorderable with drag and drop'),
    ]);
  }

  void _addBlock(BlockType type, int afterIndex) {
    setState(() {
      _blocks.insert(afterIndex + 1, EditorBlock(id: DateTime.now().millisecondsSinceEpoch.toString(), type: type, content: ''));
    });
  }

  void _convertBlock(int index, BlockType newType) {
    setState(() {
      final block = _blocks[index];
      _blocks[index] = EditorBlock(id: block.id, type: newType, content: block.content);
    });
  }

  void _showMenuForBlock(int index, Offset position, {bool isSlashCommand = false}) {
    setState(() {
      _showBlockMenu = true;
      _blockMenuPosition = position;
      _menuForBlockIndex = index;
      _isSlashCommand = isSlashCommand;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showBlockMenu) {
          setState(() => _showBlockMenu = false);
        }
      },
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              itemCount: _blocks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final block = _blocks.removeAt(oldIndex);
                  _blocks.insert(newIndex, block);
                });
              },
              proxyDecorator: (child, index, animation) {
                return Material(elevation: 6, borderRadius: BorderRadius.circular(8), child: child);
              },
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final block = _blocks[index];
                return _buildBlock(context, block, index);
              },
            ),
          ),
          if (_showBlockMenu && _menuForBlockIndex != null)
            Positioned(
              left: _blockMenuPosition.dx,
              top: _blockMenuPosition.dy,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 320,
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(padding: const EdgeInsets.all(12), child: Text('Select block type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                      Divider(height: 1),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          children:
                              blockMenuOptions.map((option) {
                                return ListTile(
                                  dense: true,
                                  leading: Icon(option.icon, size: 20),
                                  title: Text(option.title, style: TextStyle(fontSize: 14)),
                                  subtitle: Text(option.description, style: TextStyle(fontSize: 12)),
                                  onTap: () {
                                    final type = _blockTypeFromMenuOption(option);
                                    if (_isSlashCommand) {
                                      // Convert current block
                                      _convertBlock(_menuForBlockIndex!, type);
                                    } else {
                                      // Add new block after current
                                      _addBlock(type, _menuForBlockIndex!);
                                    }
                                    setState(() {
                                      _showBlockMenu = false;
                                      _isSlashCommand = false;
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  BlockType _blockTypeFromMenuOption(BlockMenuOption option) {
    switch (option.id) {
      case 'heading1':
        return BlockType.heading1;
      case 'heading2':
        return BlockType.heading2;
      case 'heading3':
        return BlockType.heading3;
      case 'bullet-list':
        return BlockType.bulletList;
      case 'numbered-list':
        return BlockType.numberedList;
      case 'quote':
        return BlockType.quote;
      case 'callout-info':
        return BlockType.calloutInfo;
      case 'callout-warning':
        return BlockType.calloutWarning;
      case 'callout-error':
        return BlockType.calloutError;
      case 'callout-success':
        return BlockType.calloutSuccess;
      case 'toggle':
        return BlockType.toggle;
      case 'divider':
        return BlockType.divider;
      default:
        return BlockType.paragraph;
    }
  }

  Widget _buildBlock(BuildContext context, EditorBlock block, int index) {
    return MouseRegion(
      key: ValueKey(block.id),
      onEnter: (_) => setState(() => _hoveredBlockIndex = index),
      onExit: (_) => setState(() => _hoveredBlockIndex = null),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle and menu button
            SizedBox(
              width: 60,
              child: AnimatedOpacity(
                opacity: _hoveredBlockIndex == index ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: MouseRegion(cursor: SystemMouseCursors.grab, child: Container(width: 24, height: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)), child: Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400))),
                    ),
                    const SizedBox(width: 4),
                    Builder(
                      builder:
                          (context) => InkWell(
                            onTap: () {
                              final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                              if (renderBox != null && renderBox.hasSize) {
                                final position = renderBox.localToGlobal(Offset.zero);
                                _showMenuForBlock(index, Offset(position.dx + 60, position.dy));
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(width: 24, height: 24, child: Icon(Icons.add, size: 16, color: Colors.grey.shade600)),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            // Block content
            Expanded(child: _buildBlockContent(block, index)),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockContent(EditorBlock block, int index) {
    final controller = TextEditingController(text: block.content);

    Widget content = TextField(
      controller: controller,
      style: _getTextStyle(block.type),
      decoration: InputDecoration(border: InputBorder.none, hintText: _getPlaceholder(block.type), hintStyle: TextStyle(color: Colors.grey.shade400), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
      maxLines: null,
      onChanged: (value) {
        block.content = value;

        // Detect slash command
        if (value.endsWith('/') && value.length == 1) {
          // Show menu when user types "/"
          Future.microtask(() {
            final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
            if (renderBox != null && renderBox.hasSize) {
              final position = renderBox.localToGlobal(Offset.zero);
              _showMenuForBlock(index, Offset(position.dx + 100, position.dy + 40), isSlashCommand: true);
              // Clear the "/" character
              controller.text = '';
              block.content = '';
            }
          });
        }
      },
      onSubmitted: (value) {
        _addBlock(BlockType.paragraph, index);
      },
    );

    // Wrap with decorations based on block type
    switch (block.type) {
      case BlockType.calloutInfo:
      case BlockType.calloutWarning:
      case BlockType.calloutError:
      case BlockType.calloutSuccess:
        Color bgColor, borderColor;
        IconData icon;
        switch (block.type) {
          case BlockType.calloutInfo:
            bgColor = Colors.blue.shade50;
            borderColor = Colors.blue.shade300;
            icon = Icons.info_outline;
            break;
          case BlockType.calloutWarning:
            bgColor = Colors.orange.shade50;
            borderColor = Colors.orange.shade300;
            icon = Icons.warning_amber_outlined;
            break;
          case BlockType.calloutError:
            bgColor = Colors.red.shade50;
            borderColor = Colors.red.shade300;
            icon = Icons.error_outline;
            break;
          case BlockType.calloutSuccess:
            bgColor = Colors.green.shade50;
            borderColor = Colors.green.shade300;
            icon = Icons.check_circle_outline;
            break;
          default:
            bgColor = Colors.grey.shade50;
            borderColor = Colors.grey.shade300;
            icon = Icons.info_outline;
        }
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgColor, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [Icon(icon, color: borderColor, size: 20), SizedBox(width: 12), Expanded(child: content)]),
        );
      case BlockType.quote:
        return Container(padding: EdgeInsets.only(left: 16, top: 8, bottom: 8), decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade400, width: 4))), child: content);
      case BlockType.bulletList:
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: EdgeInsets.only(top: 12, right: 8), child: Icon(Icons.circle, size: 6)), Expanded(child: content)]);
      case BlockType.numberedList:
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: EdgeInsets.only(top: 8, right: 8), child: Text('${index + 1}.', style: TextStyle(fontSize: 14))), Expanded(child: content)]);
      case BlockType.divider:
        return Divider(thickness: 1);
      default:
        return content;
    }
  }

  TextStyle _getTextStyle(BlockType type) {
    switch (type) {
      case BlockType.heading1:
        return TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      case BlockType.heading2:
        return TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      case BlockType.heading3:
        return TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
      case BlockType.quote:
        return TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey.shade700);
      default:
        return TextStyle(fontSize: 16);
    }
  }

  String _getPlaceholder(BlockType type) {
    switch (type) {
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      case BlockType.quote:
        return 'Quote';
      default:
        return 'Type something...';
    }
  }
}

/// Editor block model
class EditorBlock {
  EditorBlock({required this.id, required this.type, required this.content});

  final String id;
  final BlockType type;
  String content;
}

/// Block types
enum BlockType { paragraph, heading1, heading2, heading3, bulletList, numberedList, quote, calloutInfo, calloutWarning, calloutError, calloutSuccess, toggle, divider }
