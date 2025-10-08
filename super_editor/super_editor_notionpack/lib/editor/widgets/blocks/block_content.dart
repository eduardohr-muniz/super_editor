import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/rich_text_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/image_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/video_block.dart';

/// Routes to the appropriate block content widget based on block type
class BlockContent extends StatelessWidget {
  const BlockContent({super.key, required this.block, required this.index, required this.isEditable, required this.onBlockUpdated, required this.onShowSlashMenu});

  final EditorBlock block;
  final int index;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;
  final VoidCallback onShowSlashMenu;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case BlockType.image:
        return ImageBlock(block: block, isEditable: isEditable, onBlockUpdated: onBlockUpdated);

      case BlockType.video:
        return VideoBlock(block: block, isEditable: isEditable, onBlockUpdated: onBlockUpdated);

      case BlockType.divider:
        return const Divider(thickness: 1);

      // ALL text-based blocks use RichTextBlock with SuperEditor for rich text support
      // (bold, italic, underline, links, colors, etc.)
      default:
        return _wrapBlockWithDecorations(RichTextBlock(block: block, isEditable: isEditable, onBlockUpdated: onBlockUpdated, onShowSlashMenu: onShowSlashMenu));
    }
  }

  /// Wraps the block with appropriate decorations based on block type
  Widget _wrapBlockWithDecorations(Widget content) {
    switch (block.type) {
      // Quote block - add left border
      case BlockType.quote:
        return Container(padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4), decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade400, width: 4))), child: content);

      // List blocks - add bullet/number prefix
      case BlockType.bulletList:
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(top: 12, right: 8), child: Icon(Icons.circle, size: 6, color: Colors.grey.shade700)), Expanded(child: content)]);

      case BlockType.numberedList:
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(top: 8, right: 8), child: SizedBox(width: 24, child: Text('${index + 1}.', style: const TextStyle(fontSize: 14)))), Expanded(child: content)]);

      // Callout blocks - add colored background and icon
      case BlockType.calloutInfo:
      case BlockType.calloutWarning:
      case BlockType.calloutError:
      case BlockType.calloutSuccess:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _getCalloutColor(), borderRadius: BorderRadius.circular(8)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(_getCalloutIcon(), size: 20, color: _getCalloutIconColor()), const SizedBox(width: 12), Expanded(child: content)]),
        );

      // Task blocks - add checkbox
      case BlockType.task:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 8),
              child: Checkbox(value: block.isComplete, onChanged: isEditable ? (value) => onBlockUpdated(block.copyWith(isComplete: value)) : null, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
            ),
            Expanded(child: content),
          ],
        );

      // Default - no decoration
      default:
        return content;
    }
  }

  Color _getCalloutColor() {
    return switch (block.type) {
      BlockType.calloutInfo => Colors.blue.shade50,
      BlockType.calloutWarning => Colors.orange.shade50,
      BlockType.calloutError => Colors.red.shade50,
      BlockType.calloutSuccess => Colors.green.shade50,
      _ => Colors.grey.shade50,
    };
  }

  IconData _getCalloutIcon() {
    return switch (block.type) {
      BlockType.calloutInfo => Icons.info_outline,
      BlockType.calloutWarning => Icons.warning_amber_outlined,
      BlockType.calloutError => Icons.error_outline,
      BlockType.calloutSuccess => Icons.check_circle_outline,
      _ => Icons.info_outline,
    };
  }

  Color _getCalloutIconColor() {
    return switch (block.type) {
      BlockType.calloutInfo => Colors.blue,
      BlockType.calloutWarning => Colors.orange,
      BlockType.calloutError => Colors.red,
      BlockType.calloutSuccess => Colors.green,
      _ => Colors.grey,
    };
  }
}
