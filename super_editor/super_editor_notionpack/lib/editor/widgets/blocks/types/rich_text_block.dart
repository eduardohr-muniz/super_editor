import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _toolbarOverlay;
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();
    _textController = AttributedTextEditingController(text: AttributedText(widget.block.content));
    _focusNode = FocusNode();
    _textController.addListener(_handleTextChange);
    _textController.addListener(_handleSelectionChange);

    // Auto-focus if this is a new empty block
    if (widget.block.content.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _handleSelectionChange() {
    final selection = _textController.selection;

    if (!selection.isCollapsed && selection.isValid) {
      // Selection exists - show toolbar
      if (!_showToolbar) {
        setState(() => _showToolbar = true);
        _showFormattingToolbar();
      } else {
        _updateToolbarPosition();
      }
    } else {
      // No selection - hide toolbar
      if (_showToolbar) {
        setState(() => _showToolbar = false);
        _hideFormattingToolbar();
      }
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

  void _openLink(Uri? uri) async {
    if (uri == null) return;

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri);
      } else {
        // Show error if can't open
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot open link: ${uri.toString()}'), duration: const Duration(seconds: 2)));
        }
      }
    } catch (e) {
      // Error opening link
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening link: $e'), duration: const Duration(seconds: 2)));
      }
    }
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
    _hideFormattingToolbar();
    _textController.removeListener(_handleTextChange);
    _textController.removeListener(_handleSelectionChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFormattingToolbar() {
    _hideFormattingToolbar();

    final overlay = Overlay.of(context);
    _toolbarOverlay = OverlayEntry(builder: (context) => _buildFloatingToolbar());
    overlay.insert(_toolbarOverlay!);
  }

  void _updateToolbarPosition() {
    _toolbarOverlay?.markNeedsBuild();
  }

  void _hideFormattingToolbar() {
    _toolbarOverlay?.remove();
    _toolbarOverlay = null;
  }

  Widget _buildFloatingToolbar() {
    // Get the position of the text field
    final renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final textFieldPosition = renderBox.localToGlobal(Offset.zero);
    final textFieldSize = renderBox.size;

    // Position toolbar above the text field
    final toolbarPosition = Offset(textFieldPosition.dx + textFieldSize.width / 2, textFieldPosition.dy - 60);

    return Positioned(left: toolbarPosition.dx, top: toolbarPosition.dy, child: FractionalTranslation(translation: const Offset(-0.5, 0), child: _buildToolbar()));
  }

  Widget _buildToolbar() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToolbarButton(icon: Icons.format_bold, tooltip: 'Bold (Cmd+B)', onPressed: _toggleBold, isActive: _hasAttribution(boldAttribution)),
            const SizedBox(width: 4),
            _buildToolbarButton(icon: Icons.format_italic, tooltip: 'Italic (Cmd+I)', onPressed: _toggleItalic, isActive: _hasAttribution(italicsAttribution)),
            const SizedBox(width: 4),
            _buildToolbarButton(icon: Icons.format_underlined, tooltip: 'Underline (Cmd+U)', onPressed: _toggleUnderline, isActive: _hasAttribution(underlineAttribution)),
            const SizedBox(width: 4),
            _buildToolbarButton(icon: Icons.strikethrough_s, tooltip: 'Strikethrough', onPressed: _toggleStrikethrough, isActive: _hasAttribution(strikethroughAttribution)),
            Container(width: 1, height: 20, margin: const EdgeInsets.symmetric(horizontal: 8), color: Colors.grey.shade700),
            _buildToolbarButton(icon: Icons.link, tooltip: 'Add Link', onPressed: _addLink, isActive: _hasLinkAttribution()),
            const SizedBox(width: 4),
            _buildColorPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({required IconData icon, required String tooltip, required VoidCallback onPressed, bool isActive = false}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(width: 28, height: 28, decoration: BoxDecoration(color: isActive ? Colors.blue.shade700 : Colors.transparent, borderRadius: BorderRadius.circular(4)), child: Icon(icon, size: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildColorPicker() {
    return PopupMenuButton<Color>(
      icon: const Icon(Icons.palette, size: 16, color: Colors.white),
      tooltip: 'Text Color',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder:
          (context) => [
            _buildColorMenuItem('Black', Colors.black),
            _buildColorMenuItem('Red', Colors.red),
            _buildColorMenuItem('Orange', Colors.orange),
            _buildColorMenuItem('Yellow', Colors.yellow.shade700),
            _buildColorMenuItem('Green', Colors.green),
            _buildColorMenuItem('Blue', Colors.blue),
            _buildColorMenuItem('Purple', Colors.purple),
          ],
      onSelected: _applyColor,
    );
  }

  PopupMenuEntry<Color> _buildColorMenuItem(String label, Color color) {
    return PopupMenuItem(value: color, child: Row(children: [Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300))), const SizedBox(width: 8), Text(label)]));
  }

  void _toggleBold() {
    _textController.toggleSelectionAttributions([boldAttribution]);
  }

  void _toggleItalic() {
    _textController.toggleSelectionAttributions([italicsAttribution]);
  }

  void _toggleUnderline() {
    _textController.toggleSelectionAttributions([underlineAttribution]);
  }

  void _toggleStrikethrough() {
    _textController.toggleSelectionAttributions([strikethroughAttribution]);
  }

  void _applyColor(Color color) {
    final selection = _textController.selection;
    if (!selection.isCollapsed) {
      final range = SpanRange(selection.start, selection.end - 1);
      final newText = _textController.text.copy()..addAttribution(ColorAttribution(color), range);
      _textController.text = newText;
    }
  }

  void _addLink() {
    final selection = _textController.selection;
    if (selection.isCollapsed) return;

    // Show dialog to ask for URL
    showDialog(
      context: context,
      builder:
          (context) => _LinkDialog(
            onLinkAdded: (url) {
              final range = SpanRange(selection.start, selection.end - 1);
              final uri = Uri.tryParse(url);
              final newText = _textController.text.copy()..addAttribution(uri != null ? LinkAttribution.fromUri(uri) : LinkAttribution(url), range);
              _textController.text = newText;
            },
          ),
    );
  }

  bool _hasAttribution(Attribution attribution) {
    final selection = _textController.selection;
    if (selection.isCollapsed) return false;

    final range = SpanRange(selection.start, selection.end - 1);
    return _textController.text.getAttributionSpansInRange(attributionFilter: (attr) => attr == attribution, range: range).isNotEmpty;
  }

  bool _hasLinkAttribution() {
    final selection = _textController.selection;
    if (selection.isCollapsed) return false;

    final range = SpanRange(selection.start, selection.end - 1);
    return _textController.text.getAttributionSpansInRange(attributionFilter: (attr) => attr is LinkAttribution, range: range).isNotEmpty;
  }

  /// Build clickable TextSpan with links for read-only mode
  TextSpan _buildClickableTextSpan(AttributedText text) {
    if (text.text.isEmpty) {
      return TextSpan(text: '', style: _getBaseTextStyle());
    }

    final collapsedSpans = text.spans.collapseSpans(contentLength: text.text.length);
    final textSpans = <InlineSpan>[];

    for (final attributedSpan in collapsedSpans) {
      final spanText = text.text.substring(attributedSpan.start, attributedSpan.end + 1);
      final style = _textStyleBuilder(attributedSpan.attributions);

      // Check if this span has a link
      final linkAttr = attributedSpan.attributions.whereType<LinkAttribution>().firstOrNull;

      if (linkAttr != null) {
        // Create clickable link span
        textSpans.add(
          TextSpan(
            text: spanText,
            style: style,
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    _openLink(linkAttr.uri ?? Uri.tryParse(linkAttr.plainTextUri));
                  },
            mouseCursor: SystemMouseCursors.click,
          ),
        );
      } else {
        // Regular text span
        textSpans.add(TextSpan(text: spanText, style: style));
      }
    }

    return textSpans.length == 1 ? textSpans.first as TextSpan : TextSpan(children: textSpans, style: _getBaseTextStyle());
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) {
      // View-only mode with clickable links using TapGestureRecognizer
      return Text.rich(_buildClickableTextSpan(_textController.text), style: _getBaseTextStyle());
    }

    // Editable mode with SuperTextField
    // SuperTextField supports ALL rich text features: bold, italic, underline, colors, links, etc.
    // No scroll - expands automatically with content
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SuperTextField(
        key: _textFieldKey,
        textController: _textController,
        focusNode: _focusNode,
        textStyleBuilder: _textStyleBuilder,
        padding: EdgeInsets.symmetric(vertical: _getVerticalPadding(), horizontal: 4),
        selectionColor: Colors.blue.withOpacity(0.3),
        hintBehavior: HintBehavior.displayHintUntilFocus,
        hintBuilder: (context) => Text(_getPlaceholder(), style: TextStyle(color: Colors.grey.shade400)),
        // Custom keyboard handler to intercept Enter key
        keyboardHandlers: [_handleEnterKey, ...defaultTextFieldKeyboardHandlers.where((handler) => handler != DefaultSuperTextFieldKeyboardHandlers.insertNewlineWhenEnterIsPressed)],
        // Tap handlers for links
        tapHandlers: [_LinkTapHandler(onLinkTapped: _openLink)],
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

/// Tap handler for opening links when clicked
class _LinkTapHandler extends SuperTextFieldTapHandler {
  _LinkTapHandler({required this.onLinkTapped});

  final ValueChanged<Uri?> onLinkTapped;

  @override
  MouseCursor? mouseCursorForContentHover(SuperTextFieldGestureDetails details) {
    final linkAttribution = _getLinkAttribution(details);
    if (linkAttribution != null) {
      return SystemMouseCursors.click;
    }
    return null;
  }

  @override
  TapHandlingInstruction onTapUp(SuperTextFieldGestureDetails details) {
    final linkAttribution = _getLinkAttribution(details);
    if (linkAttribution != null) {
      onLinkTapped(linkAttribution.uri ?? Uri.tryParse(linkAttribution.plainTextUri));
      return TapHandlingInstruction.halt;
    }
    return TapHandlingInstruction.continueHandling;
  }

  LinkAttribution? _getLinkAttribution(SuperTextFieldGestureDetails details) {
    final textPosition = details.textLayout.getPositionNearestToOffset(details.textOffset);
    final attributions = details.textController.text.getAllAttributionsAt(textPosition.offset).whereType<LinkAttribution>();

    if (attributions.isEmpty) {
      return null;
    }

    return attributions.first;
  }
}

/// Dialog to add a link to selected text
class _LinkDialog extends StatefulWidget {
  const _LinkDialog({required this.onLinkAdded});

  final ValueChanged<String> onLinkAdded;

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Link'),
      content: TextField(
        controller: _urlController,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'https://example.com', labelText: 'URL', border: OutlineInputBorder()),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            widget.onLinkAdded(value);
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isNotEmpty) {
              widget.onLinkAdded(url);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Link'),
        ),
      ],
    );
  }
}
