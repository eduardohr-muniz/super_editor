/// Block types available in the editor
enum BlockType { paragraph, heading1, heading2, heading3, bulletList, numberedList, task, quote, calloutInfo, calloutWarning, calloutError, calloutSuccess, toggle, divider, image, video }

/// Model representing a single block in the editor
class EditorBlock {
  EditorBlock({required this.id, required this.type, required this.content, this.url, this.localPath, this.isComplete = false, this.attributedContent});

  final String id;
  final BlockType type;
  String content;
  String? url; // For image URL and video blocks
  String? localPath; // For local image from gallery
  bool isComplete; // For task blocks
  Map<String, dynamic>? attributedContent; // Rich text formatting data

  EditorBlock copyWith({String? id, BlockType? type, String? content, String? url, String? localPath, bool? isComplete, Map<String, dynamic>? attributedContent}) {
    return EditorBlock(id: id ?? this.id, type: type ?? this.type, content: content ?? this.content, url: url ?? this.url, localPath: localPath ?? this.localPath, isComplete: isComplete ?? this.isComplete, attributedContent: attributedContent ?? this.attributedContent);
  }

  /// Convert block to JSON (preserves all formatting)
  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type.name, 'content': content, if (url != null) 'url': url, if (localPath != null) 'localPath': localPath, 'isComplete': isComplete, if (attributedContent != null) 'attributedContent': attributedContent};
  }

  /// Create block from JSON
  factory EditorBlock.fromJson(Map<String, dynamic> json) {
    return EditorBlock(
      id: json['id'] as String,
      type: BlockType.values.firstWhere((e) => e.name == json['type'], orElse: () => BlockType.paragraph),
      content: json['content'] as String,
      url: json['url'] as String?,
      localPath: json['localPath'] as String?,
      isComplete: json['isComplete'] as bool? ?? false,
      attributedContent: json['attributedContent'] as Map<String, dynamic>?,
    );
  }
}
