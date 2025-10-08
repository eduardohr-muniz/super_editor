# NotionPack - Features & Implementation Guide

## ✨ Implemented Features

### 1. Custom Block Types

#### Callout Blocks
- **File**: `lib/blocks/custom_nodes.dart` (CalloutNode)
- **Component**: `lib/blocks/custom_components.dart` (CalloutComponent)
- **Types**:
  - Info (blue)
  - Warning (orange)
  - Error (red)
  - Success (green)
- **Features**: Icon indicators, colored backgrounds, bordered containers

#### Toggle Blocks
- **File**: `lib/blocks/custom_nodes.dart` (ToggleNode)
- **Component**: `lib/blocks/custom_components.dart` (ToggleComponent)
- **Features**: Expandable/collapsible with arrow icons
- **Status**: Currently shows expand/collapse icon (functionality can be enhanced)

#### Quote Blocks
- **File**: `lib/blocks/custom_nodes.dart` (QuoteNode)
- **Component**: `lib/blocks/custom_components.dart` (QuoteComponent)
- **Features**: Left border, italic text, gray styling

### 2. Notion-like UI

#### Sidebar
- **Location**: `lib/notion_editor_page.dart` (_buildSidebar)
- **Features**:
  - App branding
  - Navigation items (Home, Inbox, Settings)
  - Block type showcase section
  - Modern, minimalist design

#### Top Bar
- **Location**: `lib/notion_editor_page.dart` (_buildTopBar)
- **Features**:
  - Document title
  - Share button
  - More options menu
  - Clean, professional appearance

#### Editor
- **SuperEditor Integration**: Full-featured rich text editing
- **Custom Stylesheet**: Applies consistent styling to all block types
- **Responsive Layout**: Adapts to different screen sizes

### 3. Drag Handles (Visual)
- **File**: `lib/widgets/block_drag_handle.dart`
- **Features**:
  - Appears on hover
  - Drag indicator icon
  - Smooth opacity animations
  - Ready for drag-and-drop integration

## 🚀 How to Run

```bash
cd super_editor/super_editor_notionpack
flutter pub get
flutter run -d macos  # or any other platform
```

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── notion_editor_page.dart            # Main editor page with UI
├── blocks/
│   ├── custom_nodes.dart              # Custom document nodes
│   └── custom_components.dart         # Visual components for nodes
├── slash_command/
│   └── slash_command_menu.dart        # Slash command menu (infrastructure)
└── widgets/
    └── block_drag_handle.dart         # Drag handle widget
```

## 🎨 Customization Guide

### Adding a New Block Type

1. **Create the Node** in `lib/blocks/custom_nodes.dart`:
```dart
class MyCustomNode extends TextNode {
  MyCustomNode({
    required super.id,
    required super.text,
    super.metadata,
    // Add custom properties
  }) {
    initAddToMetadata({'blockType': const NamedAttribution('mycustom')});
  }
  
  // Implement copy methods, equality, hashCode
}
```

2. **Create the Component** in `lib/blocks/custom_components.dart`:
```dart
class MyCustomComponentBuilder implements ComponentBuilder {
  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
    if (node is! MyCustomNode) return null;
    
    return MyCustomComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      text: node.text,
      // Add other required properties
    );
  }
  
  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! MyCustomComponentViewModel) return null;
    
    return MyCustomComponent(
      key: componentContext.componentKey,
      viewModel: componentViewModel,
    );
  }
}
```

3. **Register the Builder** in `lib/blocks/custom_components.dart`:
```dart
final customComponentBuilders = <ComponentBuilder>[
  MyCustomComponentBuilder(), // Add your builder
  const CalloutComponentBuilder(),
  const ToggleComponentBuilder(),
  const QuoteComponentBuilder(),
];
```

4. **Add Styling** in `lib/notion_editor_page.dart` (_buildStylesheet):
```dart
StyleRule(
  const BlockSelector('mycustom'),
  (document, node) {
    return {
      Styles.padding: const CascadingPadding.all(16),
      // Add other styles
    };
  },
),
```

### Modifying Styles

All block styling is centralized in `notion_editor_page.dart` in the `_buildStylesheet()` method:

```dart
Stylesheet _buildStylesheet() {
  return defaultStylesheet.copyWith(
    addRulesAfter: [
      // Your custom style rules here
    ],
  );
}
```

### Changing UI Colors/Theme

Modify the theme in `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yourColor,
    brightness: Brightness.light,
  ),
  // Add more theme customizations
),
```

## 🔧 Advanced Features (Future Enhancements)

### Slash Commands
Infrastructure is in place (`lib/slash_command/slash_command_menu.dart`). To activate:
1. Implement keyboard listener for "/" key
2. Show `SlashCommandMenu` widget as overlay
3. Connect `insertBlock()` function to user selection

### Drag & Drop Reordering
1. Use `BlockDragHandle` widget (already created)
2. Implement `Draggable` and `DragTarget` widgets
3. Update document node order on drop
4. Add visual feedback during drag

### Collaboration
- Integrate with a backend (Firebase, Supabase, etc.)
- Use Operational Transformation (OT) or CRDT for conflict resolution
- Add user cursors and presence indicators
- Implement real-time document syncing

### Templates
- Create predefined document structures
- Allow users to save custom templates
- Quick template selection on document creation

## 📚 Super Editor Resources

- [Super Editor Repository](https://github.com/superlistapp/super_editor)
- [Super Editor Documentation](https://supereditor.dev)
- [Flutter Documentation](https://flutter.dev/docs)

## 🐛 Known Limitations

1. Slash commands menu is implemented but not yet integrated with keyboard input
2. Toggle blocks show expand/collapse icon but don't actually hide content
3. Drag handles are visual only - actual reordering needs implementation
4. No persistence layer (documents are in-memory only)

## 💡 Tips

- Use `Editor.createNodeId()` to generate unique node IDs
- Always extend the appropriate base class (TextNode, BlockNode, etc.)
- Follow the existing pattern for view models (mutable properties with setters)
- Use `internalCopy()` method for proper view model copying
- Test with different text directions (LTR/RTL)

## 🎯 Next Steps

1. **Implement Slash Commands**: Connect keyboard input to slash menu
2. **Add More Block Types**: Tables, code blocks, images, embeds
3. **Enhance Toggle Blocks**: Actually hide/show nested content
4. **Implement Drag & Drop**: Make blocks reorderable
5. **Add Persistence**: Save/load documents to/from storage
6. **Keyboard Shortcuts**: Add more productivity shortcuts
7. **Export Options**: PDF, Markdown, HTML export
8. **Mobile Support**: Optimize for touch interactions

---

**Built with ❤️ using Super Editor**

