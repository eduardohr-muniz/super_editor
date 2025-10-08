import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/services/block_controller_manager.dart';

final _controllerManager = BlockControllerManager();

/// List block (bullet or numbered)
class ListBlock extends StatelessWidget {
  const ListBlock({
    super.key,
    required this.block,
    required this.index,
    required this.isEditable,
    required this.onBlockUpdated,
    required this.onShowSlashMenu,
  });

  final EditorBlock block;
  final int index;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;
  final VoidCallback onShowSlashMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListMarker(),
        Expanded(
          child: isEditable ? _buildEditableContent() : _buildViewContent(),
        ),
      ],
    );
  }

  Widget _buildListMarker() {
    if (block.type == BlockType.bulletList) {
      return Padding(
        padding: EdgeInsets.only(top: 12, right: 8),
        child: Icon(Icons.circle, size: 6),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 8, right: 8),
        child: Text('${index + 1}.', style: TextStyle(fontSize: 14)),
      );
    }
  }

  Widget _buildEditableContent() {
    final controller = _controllerManager.getController(block);
    final focusNode = _controllerManager.getFocusNode(block);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'List item',
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
    return Text(block.content, style: TextStyle(fontSize: 16));
  }
}

