import 'package:flutter/material.dart';

/// A visual drag handle that appears next to blocks, similar to Notion's UI
class BlockDragHandle extends StatefulWidget {
  const BlockDragHandle({super.key, required this.child, this.onDragStart, this.onDragEnd});

  final Widget child;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  @override
  State<BlockDragHandle> createState() => _BlockDragHandleState();
}

class _BlockDragHandleState extends State<BlockDragHandle> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          AnimatedOpacity(
            opacity: _isHovering ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 24,
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(onPanStart: (_) => widget.onDragStart?.call(), onPanEnd: (_) => widget.onDragEnd?.call(), child: MouseRegion(cursor: SystemMouseCursors.grab, child: Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400))),
            ),
          ),
          // The actual block content
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

/// Wraps a document component with drag handle functionality
Widget wrapWithDragHandle(Widget component, {VoidCallback? onDragStart, VoidCallback? onDragEnd}) {
  return BlockDragHandle(onDragStart: onDragStart, onDragEnd: onDragEnd, child: component);
}
