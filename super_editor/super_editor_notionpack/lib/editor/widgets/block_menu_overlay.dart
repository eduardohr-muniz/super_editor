import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/block_menu_list.dart';

/// Overlay that shows the block type selection menu
class BlockMenuOverlay extends StatelessWidget {
  const BlockMenuOverlay({
    super.key,
    required this.position,
    required this.isSlashCommand,
    required this.onBlockSelected,
    required this.onDismiss,
  });

  final Offset position;
  final bool isSlashCommand;
  final ValueChanged<BlockType> onBlockSelected;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: GestureDetector(
                onTap: () {}, // Prevent clicks inside menu from closing it
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 320,
                    constraints: const BoxConstraints(maxHeight: 450),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Select block type',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        Divider(height: 1),
                        Flexible(
                          child: BlockMenuList(
                            onBlockSelected: onBlockSelected,
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
    );
  }
}

