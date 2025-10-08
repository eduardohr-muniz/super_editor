import 'package:flutter/material.dart';

/// Drag handle and add button controls for a block
class BlockControls extends StatelessWidget {
  const BlockControls({
    super.key,
    required this.index,
    required this.isVisible,
    required this.onMenuTap,
  });

  final int index;
  final bool isVisible;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Add menu button
            InkWell(
              onTap: onMenuTap,
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.add, size: 16, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

