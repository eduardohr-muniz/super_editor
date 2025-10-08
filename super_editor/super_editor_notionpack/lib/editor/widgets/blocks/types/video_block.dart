import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/services/block_controller_manager.dart';

final _controllerManager = BlockControllerManager();

/// YouTube video block with clickable thumbnail
class VideoBlock extends StatelessWidget {
  const VideoBlock({
    super.key,
    required this.block,
    required this.isEditable,
    required this.onBlockUpdated,
  });

  final EditorBlock block;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;

  String? _extractVideoId(String url) {
    final patterns = [
      r'youtube\.com/watch\?v=([a-zA-Z0-9_-]{11})',
      r'youtu\.be/([a-zA-Z0-9_-]{11})',
      r'youtube\.com/embed/([a-zA-Z0-9_-]{11})',
      r'youtube\.com/shorts/([a-zA-Z0-9_-]{11})',
    ];

    for (final pattern in patterns) {
      final regex = RegExp(pattern);
      final match = regex.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final videoId = block.url != null ? _extractVideoId(block.url!) : null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (videoId != null)
            _buildVideoThumbnail(videoId, block.url!)
          else
            _buildEmptyPlaceholder(),
          if (isEditable) _buildUrlField(),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoId, String videoUrl) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(videoUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // YouTube thumbnail
              Image.network(
                'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to medium quality
                  return Image.network(
                    'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Final fallback
                      return Container(
                        color: Colors.black87,
                        child: Center(
                          child: Icon(Icons.video_library, size: 64, color: Colors.white54),
                        ),
                      );
                    },
                  );
                },
              ),
              // Dark overlay
              Container(color: Colors.black.withOpacity(0.3)),
              // Play button
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.play_arrow, size: 42, color: Colors.white),
                  ),
                ),
              ),
              // Hint text
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Click to watch on YouTube',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_outline, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 8),
          Text('Add YouTube URL below', style: TextStyle(color: Colors.grey.shade600)),
          SizedBox(height: 4),
          Text(
            'e.g., https://youtube.com/watch?v=...',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlField() {
    final urlController = _controllerManager.getUrlController(block);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.link, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: urlController,
              autofocus: true,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Paste YouTube URL...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                onBlockUpdated(block.copyWith(url: value));
              },
            ),
          ),
        ],
      ),
    );
  }
}

