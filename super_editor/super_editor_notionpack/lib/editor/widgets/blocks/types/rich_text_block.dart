import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';

/// Rich text block using SuperEditor for advanced text editing
/// Supports bold, italic, underline, strikethrough, colors, etc.
class RichTextBlock extends StatefulWidget {
  const RichTextBlock({
    super.key,
    required this.block,
    required this.isEditable,
    required this.onBlockUpdated,
    required this.onShowSlashMenu,
  });

  final EditorBlock block;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;
  final VoidCallback onShowSlashMenu;

  @override
  State<RichTextBlock> createState() => _RichTextBlockState();
}

class _RichTextBlockState extends State<RichTextBlock> {
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    _document = MutableDocument(
      nodes: [
        ParagraphNode(
          id: 'rich-text-${widget.block.id}',
          text: _parseContentToAttributedText(widget.block.content),
          metadata: _getMetadataForBlockType(),
        ),
      ],
    );

    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(document: _document, composer: _composer);

    // Listen for changes
    _document.addListener(_handleDocumentChange);
    _composer.selectionNotifier.addListener(_handleSelectionChange);
  }

  void _handleSelectionChange() {
    setState(() {}); // Rebuild to show/hide toolbar
  }

  AttributedText _parseContentToAttributedText(String content) {
    // TODO: Parse stored format (could be markdown, HTML, or custom format)
    return AttributedText(content);
  }

  Map<String, dynamic> _getMetadataForBlockType() {
    switch (widget.block.type) {
      case BlockType.heading1:
        return {'blockType': header1Attribution};
      case BlockType.heading2:
        return {'blockType': header2Attribution};
      case BlockType.heading3:
        return {'blockType': header3Attribution};
      default:
        return {};
    }
  }

  void _handleDocumentChange(DocumentChangeLog changeLog) {
    final node = _document.getNodeById('rich-text-${widget.block.id}');
    if (node is TextNode) {
      final newContent = node.text.text;
      if (newContent != widget.block.content) {
        widget.onBlockUpdated(widget.block.copyWith(content: newContent));
      }

      // Detect slash command
      if (newContent.endsWith('/') && newContent.length == 1) {
        Future.microtask(() {
          widget.onShowSlashMenu();
          _editor.execute([
            DeleteContentRequest(
              documentRange: DocumentSelection(
                base: DocumentPosition(
                  nodeId: 'rich-text-${widget.block.id}',
                  nodePosition: const TextNodePosition(offset: 0),
                ),
                extent: DocumentPosition(
                  nodeId: 'rich-text-${widget.block.id}',
                  nodePosition: const TextNodePosition(offset: 1),
                ),
              ),
            ),
          ]);
        });
      }
    }
  }

  @override
  void dispose() {
    _document.removeListener(_handleDocumentChange);
    _composer.selectionNotifier.removeListener(_handleSelectionChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) {
      // View-only mode
      final node = _document.getNodeById('rich-text-${widget.block.id}');
      if (node is TextNode) {
        return Text.rich(
          node.text.computeTextSpan(_textStyleBuilder),
          style: _getBaseTextStyle(),
        );
      }
      return Text(widget.block.content);
    }

    // Editable mode with formatting toolbar
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rich text editor
        IntrinsicHeight(
          child: SuperEditor(
            editor: _editor,
            document: _document,
            composer: _composer,
            focusNode: _focusNode,
            stylesheet: _buildStylesheet(),
          ),
        ),
        // Formatting toolbar (appears on selection)
        if (_composer.selection != null && !_composer.selection!.isCollapsed)
          _buildFormattingToolbar(),
      ],
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 4,
        children: [
          _buildFormatButton(Icons.format_bold, 'Bold', boldAttribution),
          _buildFormatButton(Icons.format_italic, 'Italic', italicsAttribution),
          _buildFormatButton(Icons.format_underlined, 'Underline', underlineAttribution),
          _buildFormatButton(Icons.strikethrough_s, 'Strike', strikethroughAttribution),
          SizedBox(width: 8),
          _buildColorButton(),
        ],
      ),
    );
  }

  Widget _buildFormatButton(IconData icon, String tooltip, Attribution attribution) {
    final isActive = _composer.preferences.currentAttributions.contains(attribution);
    
    return IconButton(
      icon: Icon(icon, size: 18),
      tooltip: tooltip,
      onPressed: () {
        if (isActive) {
          _composer.preferences.removeStyle(attribution);
        } else {
          _composer.preferences.addStyle(attribution);
        }
        setState(() {});
      },
      style: IconButton.styleFrom(
        backgroundColor: isActive ? Colors.blue.shade100 : Colors.transparent,
        foregroundColor: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
        padding: EdgeInsets.all(8),
        minimumSize: Size(32, 32),
      ),
    );
  }

  Widget _buildColorButton() {
    return PopupMenuButton<Color>(
      icon: Icon(Icons.color_lens, size: 18),
      tooltip: 'Text Color',
      itemBuilder: (context) => [
        _buildColorMenuItem('Black', Colors.black),
        _buildColorMenuItem('Red', Colors.red),
        _buildColorMenuItem('Orange', Colors.orange),
        _buildColorMenuItem('Yellow', Colors.yellow.shade700),
        _buildColorMenuItem('Green', Colors.green),
        _buildColorMenuItem('Blue', Colors.blue),
        _buildColorMenuItem('Purple', Colors.purple),
      ],
      onSelected: (color) {
        _composer.preferences.addStyle(ColorAttribution(color));
        setState(() {});
      },
    );
  }

  PopupMenuEntry<Color> _buildColorMenuItem(String label, Color color) {
    return PopupMenuItem(
      value: color,
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Stylesheet _buildStylesheet() {
    return defaultStylesheet.copyWith(
      addRulesAfter: [
        if (widget.block.type == BlockType.heading1)
          StyleRule(
            BlockSelector.all,
            (doc, node) => {
              Styles.textStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            },
          ),
        if (widget.block.type == BlockType.heading2)
          StyleRule(
            BlockSelector.all,
            (doc, node) => {
              Styles.textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            },
          ),
        if (widget.block.type == BlockType.heading3)
          StyleRule(
            BlockSelector.all,
            (doc, node) => {
              Styles.textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            },
          ),
      ],
    );
  }

  TextStyle _textStyleBuilder(Set<Attribution> attributions) {
    TextStyle style = _getBaseTextStyle();

    for (final attribution in attributions) {
      if (attribution == boldAttribution) {
        style = style.copyWith(fontWeight: FontWeight.bold);
      } else if (attribution == italicsAttribution) {
        style = style.copyWith(fontStyle: FontStyle.italic);
      } else if (attribution == underlineAttribution) {
        style = style.copyWith(decoration: TextDecoration.underline);
      } else if (attribution == strikethroughAttribution) {
        style = style.copyWith(decoration: TextDecoration.lineThrough);
      } else if (attribution is ColorAttribution) {
        style = style.copyWith(color: attribution.color);
      }
    }

    return style;
  }

  TextStyle _getBaseTextStyle() {
    switch (widget.block.type) {
      case BlockType.heading1:
        return TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      case BlockType.heading2:
        return TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      case BlockType.heading3:
        return TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
      default:
        return TextStyle(fontSize: 16);
    }
  }
}

