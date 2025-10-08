/// Block types available in the editor
enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulletList,
  numberedList,
  quote,
  calloutInfo,
  calloutWarning,
  calloutError,
  calloutSuccess,
  toggle,
  divider,
  image,
  video,
}

/// Model representing a single block in the editor
class EditorBlock {
  EditorBlock({
    required this.id,
    required this.type,
    required this.content,
    this.url,
    this.localPath,
  });

  final String id;
  final BlockType type;
  String content;
  String? url; // For image URL and video blocks
  String? localPath; // For local image from gallery

  EditorBlock copyWith({
    String? id,
    BlockType? type,
    String? content,
    String? url,
    String? localPath,
  }) {
    return EditorBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
    );
  }
}

