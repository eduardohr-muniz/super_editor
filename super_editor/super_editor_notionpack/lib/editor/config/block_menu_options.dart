import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';

/// Configuration for a block menu option
class BlockMenuOption {
  const BlockMenuOption({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.searchTerms = const [],
  });

  final BlockType type;
  final String title;
  final String description;
  final IconData icon;
  final List<String> searchTerms;
}

/// All available block menu options
final List<BlockMenuOption> blockMenuOptions = [
  BlockMenuOption(
    type: BlockType.paragraph,
    title: 'Paragraph',
    description: 'Plain text block',
    icon: Icons.text_fields,
    searchTerms: ['text', 'p'],
  ),
  BlockMenuOption(
    type: BlockType.heading1,
    title: 'Heading 1',
    description: 'Large section heading',
    icon: Icons.title,
    searchTerms: ['h1', 'heading', 'title'],
  ),
  BlockMenuOption(
    type: BlockType.heading2,
    title: 'Heading 2',
    description: 'Medium section heading',
    icon: Icons.title,
    searchTerms: ['h2', 'heading'],
  ),
  BlockMenuOption(
    type: BlockType.heading3,
    title: 'Heading 3',
    description: 'Small section heading',
    icon: Icons.title,
    searchTerms: ['h3', 'heading'],
  ),
  BlockMenuOption(
    type: BlockType.bulletList,
    title: 'Bullet List',
    description: 'Create a bullet list',
    icon: Icons.format_list_bulleted,
    searchTerms: ['ul', 'bullet', 'list'],
  ),
  BlockMenuOption(
    type: BlockType.numberedList,
    title: 'Numbered List',
    description: 'Create a numbered list',
    icon: Icons.format_list_numbered,
    searchTerms: ['ol', 'numbered', 'list'],
  ),
  BlockMenuOption(
    type: BlockType.quote,
    title: 'Quote',
    description: 'Capture a quote',
    icon: Icons.format_quote,
    searchTerms: ['quote', 'blockquote'],
  ),
  BlockMenuOption(
    type: BlockType.calloutInfo,
    title: 'Callout - Info',
    description: 'Highlight information',
    icon: Icons.info_outline,
    searchTerms: ['callout', 'info', 'note'],
  ),
  BlockMenuOption(
    type: BlockType.calloutWarning,
    title: 'Callout - Warning',
    description: 'Show a warning',
    icon: Icons.warning_amber_outlined,
    searchTerms: ['callout', 'warning', 'caution'],
  ),
  BlockMenuOption(
    type: BlockType.calloutError,
    title: 'Callout - Error',
    description: 'Show an error',
    icon: Icons.error_outline,
    searchTerms: ['callout', 'error', 'danger'],
  ),
  BlockMenuOption(
    type: BlockType.calloutSuccess,
    title: 'Callout - Success',
    description: 'Show success message',
    icon: Icons.check_circle_outline,
    searchTerms: ['callout', 'success', 'done'],
  ),
  BlockMenuOption(
    type: BlockType.toggle,
    title: 'Toggle',
    description: 'Expandable block',
    icon: Icons.expand_more,
    searchTerms: ['toggle', 'collapse', 'expand'],
  ),
  BlockMenuOption(
    type: BlockType.divider,
    title: 'Divider',
    description: 'Horizontal line',
    icon: Icons.horizontal_rule,
    searchTerms: ['divider', 'hr', 'line'],
  ),
  BlockMenuOption(
    type: BlockType.image,
    title: 'Image',
    description: 'Embed from gallery or URL',
    icon: Icons.image_outlined,
    searchTerms: ['image', 'img', 'photo', 'picture'],
  ),
  BlockMenuOption(
    type: BlockType.video,
    title: 'Video',
    description: 'Embed a YouTube video',
    icon: Icons.video_library_outlined,
    searchTerms: ['video', 'youtube', 'embed'],
  ),
];

