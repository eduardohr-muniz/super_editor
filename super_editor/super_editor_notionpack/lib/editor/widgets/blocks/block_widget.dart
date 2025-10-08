import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/block_content.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/block_controls.dart';

/// Wrapper for a single block with controls
class BlockWidget extends StatelessWidget {
  const BlockWidget({super.key, required this.block, required this.index, required this.isEditable, required this.isHovered, required this.onHoverChanged, required this.onBlockUpdated, required this.onShowMenu, this.allBlocks, this.onEnterPressed});

  final EditorBlock block;
  final int index;
  final bool isEditable;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final ValueChanged<EditorBlock> onBlockUpdated;
  final Function(Offset position, {bool isSlashCommand}) onShowMenu;
  final List<EditorBlock>? allBlocks;
  final VoidCallback? onEnterPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle and menu button (only in edit mode)
            if (isEditable)
              BlockControls(
                index: index,
                isVisible: isHovered,
                onMenuTap: () {
                  onShowMenu(Offset(120, 100 + (index * 50.0).clamp(0, 300)));
                },
              ),
            // Block content
            Expanded(
              child: BlockContent(
                block: block,
                index: index,
                isEditable: isEditable,
                onBlockUpdated: onBlockUpdated,
                onShowSlashMenu: () {
                  onShowMenu(Offset(120, 100 + (index * 50.0).clamp(0, 300)), isSlashCommand: true);
                },
                allBlocks: allBlocks,
                onEnterPressed: onEnterPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
