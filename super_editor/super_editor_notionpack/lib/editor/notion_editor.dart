import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/block_list.dart';
import 'package:super_editor_notionpack/editor/widgets/block_menu_overlay.dart';

/// Main Notion-style editor widget with edit/view modes
class NotionEditor extends StatefulWidget {
  const NotionEditor({super.key, this.initialBlocks, this.isEditable = true, this.onBlocksChanged, this.onSave});

  final List<EditorBlock>? initialBlocks;
  final bool isEditable;
  final ValueChanged<List<EditorBlock>>? onBlocksChanged;
  final ValueChanged<Map<String, dynamic>>? onSave;

  @override
  State<NotionEditor> createState() => _NotionEditorState();
}

class _NotionEditorState extends State<NotionEditor> {
  late List<EditorBlock> _blocks;
  bool _showBlockMenu = false;
  Offset _blockMenuPosition = Offset.zero;
  int? _menuForBlockIndex;
  bool _isSlashCommand = false;

  @override
  void initState() {
    super.initState();
    _blocks = widget.initialBlocks ?? _getDefaultBlocks();
  }

  List<EditorBlock> _getDefaultBlocks() {
    return [EditorBlock(id: '1', type: BlockType.heading1, content: 'Welcome to NotionPack'), EditorBlock(id: '2', type: BlockType.paragraph, content: 'A Notion-style block editor')];
  }

  void _notifyChange() {
    widget.onBlocksChanged?.call(_blocks);
  }

  void _addBlock(BlockType type, int afterIndex) {
    setState(() {
      _blocks.insert(afterIndex + 1, EditorBlock(id: DateTime.now().millisecondsSinceEpoch.toString(), type: type, content: ''));
      _notifyChange();
    });
  }

  void _convertBlock(int index, BlockType newType) {
    final block = _blocks[index];
    setState(() {
      _blocks[index] = EditorBlock(id: block.id, type: newType, content: block.content, url: block.url, localPath: block.localPath);
      _notifyChange();
    });
  }

  void _updateBlock(int index, EditorBlock updatedBlock) {
    setState(() {
      _blocks[index] = updatedBlock;
      _notifyChange();
    });
  }

  void _reorderBlocks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final block = _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, block);
      _notifyChange();
    });
  }

  void _showMenuForBlock(int index, Offset position, {bool isSlashCommand = false}) {
    if (!widget.isEditable) return;

    setState(() {
      _showBlockMenu = true;
      _blockMenuPosition = position;
      _menuForBlockIndex = index;
      _isSlashCommand = isSlashCommand;
    });
  }

  void _hideMenu() {
    setState(() => _showBlockMenu = false);
  }

  void _createNewBlockOnEnter(int currentIndex) {
    final currentBlock = _blocks[currentIndex];

    setState(() {
      // Create new block of the same type (empty blocks auto-focus)
      final newBlock = EditorBlock(id: DateTime.now().millisecondsSinceEpoch.toString(), type: currentBlock.type, content: '');
      _blocks.insert(currentIndex + 1, newBlock);
      _notifyChange();
    });
  }

  void _saveDocument() {
    if (widget.onSave == null) return;

    print('💾 _saveDocument called');
    print('   Total blocks: ${_blocks.length}');

    // Serialize all blocks to JSON
    final blocks =
        _blocks.map((block) {
          final blockJson = block.toJson();
          print('   Block "${block.id}": has attributedContent? ${blockJson.containsKey('attributedContent')}');
          return blockJson;
        }).toList();

    final documentJson = {'version': '1.0', 'createdAt': DateTime.now().toIso8601String(), 'blocks': blocks};

    widget.onSave!(documentJson);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Handle Cmd+S / Ctrl+S to save
        if (event is KeyDownEvent) {
          final isSaveShortcut = (event.logicalKey == LogicalKeyboardKey.keyS) && (HardwareKeyboard.instance.isMetaPressed || HardwareKeyboard.instance.isControlPressed);

          if (isSaveShortcut) {
            _saveDocument();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          BlockList(blocks: _blocks, isEditable: widget.isEditable, onBlockUpdated: _updateBlock, onReorder: _reorderBlocks, onShowMenu: _showMenuForBlock, onEnterPressedAtIndex: _createNewBlockOnEnter),
          if (_showBlockMenu && _menuForBlockIndex != null && widget.isEditable)
            BlockMenuOverlay(
              position: _blockMenuPosition,
              isSlashCommand: _isSlashCommand,
              onBlockSelected: (type) {
                if (_isSlashCommand) {
                  _convertBlock(_menuForBlockIndex!, type);
                } else {
                  _addBlock(type, _menuForBlockIndex!);
                }
                _hideMenu();
              },
              onDismiss: _hideMenu,
            ),
        ],
      ),
    );
  }
}
