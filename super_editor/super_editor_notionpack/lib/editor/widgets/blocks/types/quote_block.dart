import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/services/block_controller_manager.dart';

final _controllerManager = BlockControllerManager();

/// Quote block with left border
class QuoteBlock extends StatelessWidget {
  const QuoteBlock({
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade400, width: 4),
        ),
      ),
      child: isEditable ? _buildEditableContent() : _buildViewContent(),
    );
  }

  Widget _buildEditableContent() {
    final controller = _controllerManager.getController(block);
    final focusNode = _controllerManager.getFocusNode(block);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade700,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Quote',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      maxLines: null,
      onChanged: (value) {
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

  Widget _buildViewContent() {
    return Text(
      block.content,
      style: TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade700,
      ),
    );
  }
}

