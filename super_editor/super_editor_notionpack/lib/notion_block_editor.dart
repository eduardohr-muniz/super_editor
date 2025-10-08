import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Controllers and focus nodes for each block
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeBlocks();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(EditorBlock block) {
    if (!_controllers.containsKey(block.id)) {
      _controllers[block.id] = TextEditingController(text: block.content);
    }
    return _controllers[block.id]!;
  }

  FocusNode _getFocusNode(EditorBlock block) {
    if (!_focusNodes.containsKey(block.id)) {
      _focusNodes[block.id] = FocusNode();
    }
    return _focusNodes[block.id]!;
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
    final block = _blocks[index];
    setState(() {
      _blocks[index] = EditorBlock(id: block.id, type: newType, content: block.content);
    });

    // Focus the block after conversion
    Future.delayed(const Duration(milliseconds: 100), () {
      _getFocusNode(block).requestFocus();
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
    return Stack(
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
          GestureDetector(
            onTap: () {
              setState(() => _showBlockMenu = false);
            },
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    left: _blockMenuPosition.dx,
                    top: _blockMenuPosition.dy,
                    child: GestureDetector(
                      onTap: () {}, // Prevent clicks inside menu from closing it
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 320,
                          constraints: const BoxConstraints(maxHeight: 450),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(padding: const EdgeInsets.all(12), child: Text('Select block type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                              Divider(height: 1),
                              Flexible(
                                child: _BlockMenuList(
                                  menuForBlockIndex: _menuForBlockIndex!,
                                  isSlashCommand: _isSlashCommand,
                                  onBlockSelected: (type) {
                                    if (_isSlashCommand) {
                                      _convertBlock(_menuForBlockIndex!, type);
                                    } else {
                                      _addBlock(type, _menuForBlockIndex!);
                                    }
                                    setState(() {
                                      _showBlockMenu = false;
                                      _isSlashCommand = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
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
                              // Use a fixed position relative to the screen
                              _showMenuForBlock(index, Offset(120, 100 + (index * 50.0).clamp(0, 300)));
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
    final controller = _getController(block);
    final focusNode = _getFocusNode(block);

    // Update controller if block content changed externally
    if (controller.text != block.content) {
      controller.text = block.content;
      controller.selection = TextSelection.collapsed(offset: block.content.length);
    }

    Widget content = TextField(
      controller: controller,
      focusNode: focusNode,
      style: _getTextStyle(block.type),
      decoration: InputDecoration(border: InputBorder.none, hintText: _getPlaceholder(block.type), hintStyle: TextStyle(color: Colors.grey.shade400), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
      maxLines: null,
      onChanged: (value) {
        block.content = value;

        // Detect slash command
        if (value.endsWith('/') && value.length == 1) {
          // Show menu when user types "/"
          Future.microtask(() {
            // Position menu with fixed offset from left
            _showMenuForBlock(index, Offset(120, 100 + (index * 50.0).clamp(0, 300)), isSlashCommand: true);
            // Clear the "/" character
            controller.text = '';
            block.content = '';
          });
        }
      },
      onSubmitted: (value) {
        _addBlock(BlockType.paragraph, index);
        // Focus the next block
        Future.delayed(Duration(milliseconds: 100), () {
          final nextBlock = _blocks.length > index + 1 ? _blocks[index + 1] : null;
          if (nextBlock != null) {
            _getFocusNode(nextBlock).requestFocus();
          }
        });
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

/// Interactive block menu list with keyboard navigation and search
class _BlockMenuList extends StatefulWidget {
  const _BlockMenuList({required this.menuForBlockIndex, required this.isSlashCommand, required this.onBlockSelected});

  final int menuForBlockIndex;
  final bool isSlashCommand;
  final Function(BlockType) onBlockSelected;

  @override
  State<_BlockMenuList> createState() => _BlockMenuListState();
}

class _BlockMenuListState extends State<_BlockMenuList> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  List<BlockMenuOption> get _filteredOptions {
    if (_searchQuery.isEmpty) {
      return blockMenuOptions;
    }
    return blockMenuOptions.where((option) {
      return option.title.toLowerCase().contains(_searchQuery.toLowerCase()) || option.description.toLowerCase().contains(_searchQuery.toLowerCase()) || option.id.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _selectOption(BlockMenuOption option) {
    final type = _blockTypeFromMenuOption(option);
    widget.onBlockSelected(type);
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

  void _handleKeyEvent(String char) {
    setState(() {
      _searchQuery += char;
      _selectedIndex = 0; // Reset selection when searching
    });
  }

  void _moveSelectionUp() {
    setState(() {
      if (_selectedIndex > 0) {
        _selectedIndex--;
      }
    });
  }

  void _moveSelectionDown() {
    final options = _filteredOptions;
    if (_selectedIndex < options.length - 1) {
      setState(() {
        _selectedIndex++;
      });
    }
  }

  void _selectCurrent() {
    final options = _filteredOptions;
    if (options.isNotEmpty && _selectedIndex < options.length) {
      _selectOption(options[_selectedIndex]);
    }
  }

  void _clearSearch() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _searchQuery = _searchQuery.substring(0, _searchQuery.length - 1);
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = _filteredOptions;

    return RawKeyboardListener(
      focusNode: _searchFocus,
      autofocus: true,
      onKey: (event) {
        if (event is! RawKeyDownEvent) return;

        final key = event.logicalKey;

        if (key == LogicalKeyboardKey.enter) {
          _selectCurrent();
        } else if (key == LogicalKeyboardKey.arrowUp) {
          _moveSelectionUp();
        } else if (key == LogicalKeyboardKey.arrowDown) {
          _moveSelectionDown();
        } else if (key == LogicalKeyboardKey.backspace) {
          _clearSearch();
        } else if (event.character != null && RegExp(r'[a-zA-Z0-9\s]').hasMatch(event.character!)) {
          _handleKeyEvent(event.character!.toLowerCase());
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search indicator
          if (_searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.shade50, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [Icon(Icons.search, size: 16, color: Colors.blue.shade700), SizedBox(width: 8), Text('Search: $_searchQuery', style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w500))]),
            ),

          // Options list
          Flexible(
            child:
                options.isEmpty
                    ? Padding(padding: EdgeInsets.all(24), child: Text('No blocks found for "$_searchQuery"', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), textAlign: TextAlign.center))
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      padding: EdgeInsets.symmetric(vertical: 4),
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
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(color: isSelected ? Colors.blue.shade50 : Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Icon(option.icon, size: 20, color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(option.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.blue.shade700 : Colors.black87)),
                                      SizedBox(height: 2),
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

          // Keyboard hints
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200)), color: Colors.grey.shade50),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildKeyHint('↑↓', 'Navigate'), SizedBox(width: 12), _buildKeyHint('Enter', 'Select'), SizedBox(width: 12), _buildKeyHint('Type', 'Search')]),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyHint(String key, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
          child: Text(key, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
