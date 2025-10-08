import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/services/block_controller_manager.dart';

final _controllerManager = BlockControllerManager();

/// Image block with gallery picker and URL support
class ImageBlock extends StatelessWidget {
  const ImageBlock({
    super.key,
    required this.block,
    required this.isEditable,
    required this.onBlockUpdated,
  });

  final EditorBlock block;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;

  @override
  Widget build(BuildContext context) {
    final hasImage = (block.url != null && block.url!.isNotEmpty) || 
                     (block.localPath != null && block.localPath!.isNotEmpty);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(hasImage),
          if (isEditable) _buildImageControls(),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool hasImage) {
    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        child: block.localPath != null && block.localPath!.isNotEmpty
            ? Image.file(
                File(block.localPath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
              )
            : Image.network(
                block.url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingPlaceholder(loadingProgress);
                },
              ),
      );
    }
    
    return _buildEmptyPlaceholder();
  }

  Widget _buildImageControls() {
    final urlController = _controllerManager.getUrlController(block);
    
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  onBlockUpdated(block.copyWith(
                    localPath: image.path,
                    url: null,
                  ));
                }
              },
              icon: Icon(Icons.photo_library, size: 18),
              label: Text('Choose from Gallery', style: TextStyle(fontSize: 14)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.link, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: urlController,
                  autofocus: block.url == null && block.localPath == null,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Or paste image URL...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    onBlockUpdated(block.copyWith(
                      url: value,
                      localPath: null,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
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
          Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 8),
          Text(
            'Choose from gallery or paste URL',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 8),
          Text('Failed to load image', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ImageChunkEvent loadingProgress) {
    return Container(
      height: 200,
      color: Colors.grey.shade100,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }
}

