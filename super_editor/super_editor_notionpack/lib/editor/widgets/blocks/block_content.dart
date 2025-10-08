import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/text_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/image_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/video_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/callout_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/quote_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/types/list_block.dart';

/// Routes to the appropriate block content widget based on block type
class BlockContent extends StatelessWidget {
  const BlockContent({
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
    switch (block.type) {
      case BlockType.image:
        return ImageBlock(
          block: block,
          isEditable: isEditable,
          onBlockUpdated: onBlockUpdated,
        );
        
      case BlockType.video:
        return VideoBlock(
          block: block,
          isEditable: isEditable,
          onBlockUpdated: onBlockUpdated,
        );
        
      case BlockType.calloutInfo:
      case BlockType.calloutWarning:
      case BlockType.calloutError:
      case BlockType.calloutSuccess:
        return CalloutBlock(
          block: block,
          isEditable: isEditable,
          onBlockUpdated: onBlockUpdated,
          onShowSlashMenu: onShowSlashMenu,
        );
        
      case BlockType.quote:
        return QuoteBlock(
          block: block,
          isEditable: isEditable,
          onBlockUpdated: onBlockUpdated,
          onShowSlashMenu: onShowSlashMenu,
        );
        
      case BlockType.bulletList:
      case BlockType.numberedList:
        return ListBlock(
          block: block,
          index: index,
          isEditable: isEditable,
          onBlockUpdated: onBlockUpdated,
          onShowSlashMenu: onShowSlashMenu,
        );
        
      case BlockType.divider:
        return Divider(thickness: 1);
        
      default:
        return TextBlock(
          block: block,
          isEditable: isEditable,
          onBlockUpdated: onBlockUpdated,
          onShowSlashMenu: onShowSlashMenu,
        );
    }
  }
}

