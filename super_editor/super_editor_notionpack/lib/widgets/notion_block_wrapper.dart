import 'package:flutter/material.dart';

/// Wraps each block with Notion-style controls (drag handle + menu button)
class NotionBlockWrapper extends StatefulWidget {
  const NotionBlockWrapper({super.key, required this.child, required this.onMenuPressed, this.onDragStart, this.onDragEnd});

  final Widget child;
  final VoidCallback onMenuPressed;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  @override
  State<NotionBlockWrapper> createState() => _NotionBlockWrapperState();
}

class _NotionBlockWrapperState extends State<NotionBlockWrapper> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Controls (drag + menu)
          SizedBox(
            width: 60,
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Row(
                children: [
                  // Drag handle
                  GestureDetector(
                    onPanStart: (_) => widget.onDragStart?.call(),
                    onPanEnd: (_) => widget.onDragEnd?.call(),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Container(width: 24, height: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.transparent), child: Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Add block button
                  InkWell(
                    onTap: widget.onMenuPressed,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(width: 24, height: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.transparent), child: Icon(Icons.add, size: 16, color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ),
          ),
          // The actual block content
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
