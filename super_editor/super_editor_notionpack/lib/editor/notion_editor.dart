import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/block_list.dart';
import 'package:super_editor_notionpack/editor/widgets/block_menu_overlay.dart';

/// Main Notion-style editor widget with edit/view modes
class NotionEditor extends StatefulWidget {
  const NotionEditor({
    super.key,
    this.initialBlocks,
    this.isEditable = true,
    this.onBlocksChanged,
  });

  final List<EditorBlock>? initialBlocks;
  final bool isEditable;
  final ValueChanged<List<EditorBlock>>? onBlocksChanged;

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
    return [
      EditorBlock(id: '1', type: BlockType.heading1, content: 'Welcome to NotionPack'),
      EditorBlock(id: '2', type: BlockType.paragraph, content: 'A Notion-style block editor'),
    ];
  }

  void _notifyChange() {
    widget.onBlocksChanged?.call(_blocks);
  }

  void _addBlock(BlockType type, int afterIndex) {
    setState(() {
      _blocks.insert(
        afterIndex + 1,
        EditorBlock(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          content: '',
        ),
      );
      _notifyChange();
    });
  }

  void _convertBlock(int index, BlockType newType) {
    final block = _blocks[index];
    setState(() {
      _blocks[index] = EditorBlock(
        id: block.id,
        type: newType,
        content: block.content,
        url: block.url,
        localPath: block.localPath,
      );
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlockList(
          blocks: _blocks,
          isEditable: widget.isEditable,
          onBlockUpdated: _updateBlock,
          onReorder: _reorderBlocks,
          onShowMenu: _showMenuForBlock,
        ),
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
    );
  }
}

