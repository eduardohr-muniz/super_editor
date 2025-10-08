import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';

/// Rich text block using SuperTextField for Notion-style editing
/// Supports bold, italic, underline, strikethrough, colors, links, etc.
/// Enter key creates a new block below
class RichTextBlock extends StatefulWidget {
  const RichTextBlock({super.key, required this.block, required this.isEditable, required this.onBlockUpdated, required this.onShowSlashMenu, this.onEnterPressed});

  final EditorBlock block;
  final bool isEditable;
  final ValueChanged<EditorBlock> onBlockUpdated;
  final VoidCallback onShowSlashMenu;
  final VoidCallback? onEnterPressed;

  @override
  State<RichTextBlock> createState() => _RichTextBlockState();
}

class _RichTextBlockState extends State<RichTextBlock> {
  late AttributedTextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = AttributedTextEditingController(text: AttributedText(widget.block.content));
    _focusNode = FocusNode();
    _textController.addListener(_handleTextChange);

    // Auto-focus if this is a new empty block
    if (widget.block.content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  /// Custom keyboard handler that intercepts Enter key to create new blocks
  TextFieldKeyboardHandlerResult _handleEnterKey({required SuperTextFieldContext textFieldContext, required KeyEvent keyEvent}) {
    if (keyEvent is! KeyDownEvent && keyEvent is! KeyRepeatEvent) {
      return TextFieldKeyboardHandlerResult.notHandled;
    }

    if (keyEvent.logicalKey != LogicalKeyboardKey.enter && keyEvent.logicalKey != LogicalKeyboardKey.numpadEnter) {
      return TextFieldKeyboardHandlerResult.notHandled;
    }

    // Create new block below
    widget.onEnterPressed?.call();

    // Return handled to prevent Enter from inserting a newline
    return TextFieldKeyboardHandlerResult.handled;
  }

  void _handleTextChange() {
    final newContent = _textController.text.text;
    if (newContent != widget.block.content) {
      widget.onBlockUpdated(widget.block.copyWith(content: newContent));
    }

    // Detect slash command
    if (newContent == '/' || (newContent.endsWith('/') && newContent.length == 1)) {
      Future.microtask(() {
        if (!mounted) return;
        widget.onShowSlashMenu();
        _textController.text = AttributedText('');
      });
    }
  }

  @override
  void didUpdateWidget(RichTextBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update content if block changed externally
    if (oldWidget.block.content != widget.block.content && _textController.text.text != widget.block.content) {
      _textController.text = AttributedText(widget.block.content);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) {
      // View-only mode
      return Text.rich(_textController.text.computeTextSpan(_textStyleBuilder), style: _getBaseTextStyle());
    }

    // Editable mode with SuperTextField
    // SuperTextField supports ALL rich text features: bold, italic, underline, colors, links, etc.
    // No scroll - expands automatically with content
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SuperTextField(
        textController: _textController,
        focusNode: _focusNode,
        textStyleBuilder: _textStyleBuilder,
        padding: EdgeInsets.symmetric(vertical: _getVerticalPadding(), horizontal: 4),
        selectionColor: Colors.blue.withOpacity(0.3),
        hintBehavior: HintBehavior.displayHintUntilFocus,
        hintBuilder: (context) => Text(_getPlaceholder(), style: TextStyle(color: Colors.grey.shade400)),
        // Custom keyboard handler to intercept Enter key
        keyboardHandlers: [_handleEnterKey, ...defaultTextFieldKeyboardHandlers.where((handler) => handler != DefaultSuperTextFieldKeyboardHandlers.insertNewlineWhenEnterIsPressed)],
      ),
    );
  }

  double _getVerticalPadding() {
    return switch (widget.block.type) {
      BlockType.heading1 => 8.0,
      BlockType.heading2 => 6.0,
      BlockType.heading3 => 4.0,
      _ => 2.0,
    };
  }

  String _getPlaceholder() {
    return switch (widget.block.type) {
      BlockType.heading1 => 'Heading 1',
      BlockType.heading2 => 'Heading 2',
      BlockType.heading3 => 'Heading 3',
      BlockType.quote => 'Quote',
      BlockType.bulletList => 'List item',
      BlockType.numberedList => 'List item',
      BlockType.task => 'Task',
      BlockType.calloutInfo => 'Info...',
      BlockType.calloutWarning => 'Warning...',
      BlockType.calloutError => 'Error...',
      BlockType.calloutSuccess => 'Success...',
      _ => 'Type / for commands...',
    };
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
      } else if (attribution is LinkAttribution) {
        style = style.copyWith(color: Colors.blue, decoration: TextDecoration.underline);
      }
    }

    return style;
  }

  TextStyle _getBaseTextStyle() {
    return switch (widget.block.type) {
      BlockType.heading1 => const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2, color: Colors.black),
      BlockType.heading2 => const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2, color: Colors.black),
      BlockType.heading3 => const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2, color: Colors.black),
      BlockType.quote => TextStyle(fontSize: 16, height: 1.5, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
      _ => const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
    };
  }
}
