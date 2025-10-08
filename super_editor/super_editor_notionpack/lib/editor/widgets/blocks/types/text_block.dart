import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/services/block_controller_manager.dart';

final _controllerManager = BlockControllerManager();

/// Text block for paragraphs and headings
class TextBlock extends StatelessWidget {
  const TextBlock({
    super.key,
    required this.block,
    required this.isEditable,
    required this.onBlockUpdated,
    required this.onShowSlashMenu,
  });

  final EditorBlock block;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;
  final VoidCallback onShowSlashMenu;

  TextStyle _getTextStyle() {
    switch (block.type) {
      case BlockType.heading1:
        return TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      case BlockType.heading2:
        return TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      case BlockType.heading3:
        return TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
      default:
        return TextStyle(fontSize: 16);
    }
  }

  String _getPlaceholder() {
    switch (block.type) {
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      default:
        return 'Type something or / for commands...';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditable) {
      return Text(block.content, style: _getTextStyle());
    }

    final controller = _controllerManager.getController(block);
    final focusNode = _controllerManager.getFocusNode(block);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: _getTextStyle(),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: _getPlaceholder(),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      maxLines: null,
      onChanged: (value) {
        // Detect slash command
        if (value.endsWith('/') && value.length == 1) {
          Future.microtask(() {
            onShowSlashMenu();
            controller.text = '';
            onBlockUpdated(block.copyWith(content: ''));
          });
        } else {
          onBlockUpdated(block.copyWith(content: value));
        }
      },
    );
  }
}

