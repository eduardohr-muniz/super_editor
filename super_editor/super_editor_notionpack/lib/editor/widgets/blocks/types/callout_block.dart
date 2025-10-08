import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/text_block.dart';

/// Callout block with colored background and icon
class CalloutBlock extends StatelessWidget {
  const CalloutBlock({
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

  (Color bgColor, Color borderColor, IconData icon) _getStyles() {
    switch (block.type) {
      case BlockType.calloutInfo:
        return (Colors.blue.shade50, Colors.blue.shade300, Icons.info_outline);
      case BlockType.calloutWarning:
        return (Colors.orange.shade50, Colors.orange.shade300, Icons.warning_amber_outlined);
      case BlockType.calloutError:
        return (Colors.red.shade50, Colors.red.shade300, Icons.error_outline);
      case BlockType.calloutSuccess:
        return (Colors.green.shade50, Colors.green.shade300, Icons.check_circle_outline);
      default:
        return (Colors.grey.shade50, Colors.grey.shade300, Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, borderColor, icon) = _getStyles();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: TextBlock(
              block: block,
              isEditable: isEditable,
              onBlockUpdated: onBlockUpdated,
              onShowSlashMenu: onShowSlashMenu,
            ),
          ),
        ],
      ),
    );
  }
}

