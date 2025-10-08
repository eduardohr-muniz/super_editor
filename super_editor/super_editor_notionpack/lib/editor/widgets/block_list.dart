import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/widgets/blocks/block_widget.dart';
import 'package:super_editor_notionpack/editor/widgets/add_block_button.dart';

/// Reorderable list of blocks
class BlockList extends StatefulWidget {
  const BlockList({super.key, required this.blocks, required this.isEditable, required this.onBlockUpdated, required this.onReorder, required this.onShowMenu, this.onEnterPressedAtIndex});

  final List<EditorBlock> blocks;
  final bool isEditable;
  final Function(int index, EditorBlock block) onBlockUpdated;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index, Offset position, {bool isSlashCommand}) onShowMenu;
  final Function(int index)? onEnterPressedAtIndex;

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  int? _hoveredBlockIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
              itemCount: widget.blocks.length,
              onReorder: widget.isEditable ? widget.onReorder : (_, __) {},
              proxyDecorator: (child, index, animation) {
                return Material(elevation: 6, borderRadius: BorderRadius.circular(8), child: child);
              },
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final block = widget.blocks[index];
                return Column(
                  key: ValueKey(block.id),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add button between blocks
                    if (index > 0 && widget.isEditable)
                      AddBlockButton(
                        isHovered: _hoveredBlockIndex == index + 1000,
                        onHoverChanged: (hovering) {
                          setState(() {
                            _hoveredBlockIndex = hovering ? index + 1000 : null;
                          });
                        },
                        onTap: () {
                          widget.onShowMenu(index - 1, Offset(120, 100 + ((index - 1) * 50.0).clamp(0, 300)));
                        },
                      ),
                    // The block itself
                    BlockWidget(
                      block: block,
                      index: index,
                      isEditable: widget.isEditable,
                      isHovered: _hoveredBlockIndex == index,
                      onHoverChanged: (hovering) {
                        setState(() {
                          _hoveredBlockIndex = hovering ? index : null;
                        });
                      },
                      onBlockUpdated: (updatedBlock) {
                        widget.onBlockUpdated(index, updatedBlock);
                      },
                      onShowMenu: (position, {isSlashCommand = false}) {
                        widget.onShowMenu(index, position, isSlashCommand: isSlashCommand);
                      },
                      onEnterPressed: () {
                        widget.onEnterPressedAtIndex?.call(index);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          // Add button at the end
          if (widget.isEditable)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: AddBlockButton(
                isHovered: _hoveredBlockIndex == widget.blocks.length + 1000,
                onHoverChanged: (hovering) {
                  setState(() {
                    _hoveredBlockIndex = hovering ? widget.blocks.length + 1000 : null;
                  });
                },
                onTap: () {
                  widget.onShowMenu(widget.blocks.length - 1, Offset(120, 100 + ((widget.blocks.length - 1) * 50.0).clamp(0, 300)));
                },
              ),
            ),
        ],
      ),
    );
  }
}
