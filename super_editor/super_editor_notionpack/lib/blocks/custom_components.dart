import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_notionpack/blocks/custom_nodes.dart';

/// List of custom component builders for our custom nodes
final customComponentBuilders = <ComponentBuilder>[const CalloutComponentBuilder(), const ToggleComponentBuilder(), const QuoteComponentBuilder()];

/// Component builder for CalloutNode
class CalloutComponentBuilder implements ComponentBuilder {
  const CalloutComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
    if (node is! CalloutNode) {
      return null;
    }

    final textDirection = getParagraphDirection(node.text.toPlainText());

    return CalloutComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      padding: EdgeInsets.zero,
      maxWidth: double.infinity,
      text: node.text,
      textDirection: textDirection,
      textAlignment: textDirection == TextDirection.ltr ? TextAlign.left : TextAlign.right,
      textStyleBuilder: noStyleBuilder,
      calloutType: node.calloutType,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext, SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! CalloutComponentViewModel) {
      return null;
    }

    return CalloutComponent(key: componentContext.componentKey, viewModel: componentViewModel);
  }
}

/// View model for callout component
class CalloutComponentViewModel extends SingleColumnLayoutComponentViewModel with TextComponentViewModel {
  CalloutComponentViewModel({
    required super.nodeId,
    required super.createdAt,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    required this.text,
    required this.textStyleBuilder,
    this.inlineWidgetBuilders = const [],
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    required this.calloutType,
    this.selection,
    required this.selectionColor,
    this.highlightWhenEmpty = false,
  });

  @override
  AttributedText text;

  @override
  AttributionStyleBuilder textStyleBuilder;

  @override
  InlineWidgetBuilderChain inlineWidgetBuilders;

  @override
  TextDirection textDirection;

  @override
  TextAlign textAlignment;

  final CalloutType calloutType;

  @override
  TextSelection? selection;

  @override
  Color selectionColor;

  @override
  bool highlightWhenEmpty;

  @override
  CalloutComponentViewModel copy() {
    return internalCopy(
          CalloutComponentViewModel(
            nodeId: nodeId,
            createdAt: createdAt,
            maxWidth: maxWidth,
            padding: padding,
            text: text,
            textStyleBuilder: textStyleBuilder,
            inlineWidgetBuilders: inlineWidgetBuilders,
            textDirection: textDirection,
            textAlignment: textAlignment,
            calloutType: calloutType,
            selection: selection,
            selectionColor: selectionColor,
            highlightWhenEmpty: highlightWhenEmpty,
          ),
        )
        as CalloutComponentViewModel;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is CalloutComponentViewModel && runtimeType == other.runtimeType && nodeId == other.nodeId && text == other.text && calloutType == other.calloutType;

  @override
  int get hashCode => nodeId.hashCode ^ text.hashCode ^ calloutType.hashCode;
}

/// Visual component for callout blocks
class CalloutComponent extends StatelessWidget {
  const CalloutComponent({super.key, required this.viewModel});

  final CalloutComponentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    IconData iconData;

    switch (viewModel.calloutType) {
      case CalloutType.info:
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade300;
        iconData = Icons.info_outline;
        break;
      case CalloutType.warning:
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        iconData = Icons.warning_amber_outlined;
        break;
      case CalloutType.error:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        iconData = Icons.error_outline;
        break;
      case CalloutType.success:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        iconData = Icons.check_circle_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: backgroundColor, border: Border.all(color: borderColor, width: 1), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: borderColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextComponent(
              text: viewModel.text,
              textStyleBuilder: viewModel.textStyleBuilder,
              textAlign: viewModel.textAlignment,
              textDirection: viewModel.textDirection,
              textSelection: viewModel.selection,
              selectionColor: viewModel.selectionColor,
              highlightWhenEmpty: viewModel.highlightWhenEmpty,
            ),
          ),
        ],
      ),
    );
  }
}

/// Component builder for ToggleNode
class ToggleComponentBuilder implements ComponentBuilder {
  const ToggleComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
    if (node is! ToggleNode) {
      return null;
    }

    final textDirection = getParagraphDirection(node.text.toPlainText());

    return ToggleComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      padding: EdgeInsets.zero,
      maxWidth: double.infinity,
      text: node.text,
      textDirection: textDirection,
      textAlignment: textDirection == TextDirection.ltr ? TextAlign.left : TextAlign.right,
      textStyleBuilder: noStyleBuilder,
      isExpanded: node.isExpanded,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext, SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! ToggleComponentViewModel) {
      return null;
    }

    return ToggleComponent(key: componentContext.componentKey, viewModel: componentViewModel);
  }
}

/// View model for toggle component
class ToggleComponentViewModel extends SingleColumnLayoutComponentViewModel with TextComponentViewModel {
  ToggleComponentViewModel({
    required super.nodeId,
    required super.createdAt,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    required this.text,
    required this.textStyleBuilder,
    this.inlineWidgetBuilders = const [],
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    required this.isExpanded,
    this.selection,
    required this.selectionColor,
    this.highlightWhenEmpty = false,
  });

  @override
  AttributedText text;

  @override
  AttributionStyleBuilder textStyleBuilder;

  @override
  InlineWidgetBuilderChain inlineWidgetBuilders;

  @override
  TextDirection textDirection;

  @override
  TextAlign textAlignment;

  final bool isExpanded;

  @override
  TextSelection? selection;

  @override
  Color selectionColor;

  @override
  bool highlightWhenEmpty;

  @override
  ToggleComponentViewModel copy() {
    return internalCopy(
          ToggleComponentViewModel(
            nodeId: nodeId,
            createdAt: createdAt,
            maxWidth: maxWidth,
            padding: padding,
            text: text,
            textStyleBuilder: textStyleBuilder,
            inlineWidgetBuilders: inlineWidgetBuilders,
            textDirection: textDirection,
            textAlignment: textAlignment,
            isExpanded: isExpanded,
            selection: selection,
            selectionColor: selectionColor,
            highlightWhenEmpty: highlightWhenEmpty,
          ),
        )
        as ToggleComponentViewModel;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is ToggleComponentViewModel && runtimeType == other.runtimeType && nodeId == other.nodeId && text == other.text && isExpanded == other.isExpanded;

  @override
  int get hashCode => nodeId.hashCode ^ text.hashCode ^ isExpanded.hashCode;
}

/// Visual component for toggle blocks
class ToggleComponent extends StatelessWidget {
  const ToggleComponent({super.key, required this.viewModel});

  final ToggleComponentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(viewModel.isExpanded ? Icons.arrow_drop_down : Icons.arrow_right, size: 24, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Expanded(
            child: TextComponent(
              text: viewModel.text,
              textStyleBuilder: viewModel.textStyleBuilder,
              textAlign: viewModel.textAlignment,
              textDirection: viewModel.textDirection,
              textSelection: viewModel.selection,
              selectionColor: viewModel.selectionColor,
              highlightWhenEmpty: viewModel.highlightWhenEmpty,
            ),
          ),
        ],
      ),
    );
  }
}

/// Component builder for QuoteNode
class QuoteComponentBuilder implements ComponentBuilder {
  const QuoteComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
    if (node is! QuoteNode) {
      return null;
    }

    final textDirection = getParagraphDirection(node.text.toPlainText());

    return QuoteComponentViewModel(
      nodeId: node.id,
      createdAt: node.metadata[NodeMetadata.createdAt],
      padding: EdgeInsets.zero,
      maxWidth: double.infinity,
      text: node.text,
      textDirection: textDirection,
      textAlignment: textDirection == TextDirection.ltr ? TextAlign.left : TextAlign.right,
      textStyleBuilder: noStyleBuilder,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(SingleColumnDocumentComponentContext componentContext, SingleColumnLayoutComponentViewModel componentViewModel) {
    if (componentViewModel is! QuoteComponentViewModel) {
      return null;
    }

    return QuoteComponent(key: componentContext.componentKey, viewModel: componentViewModel);
  }
}

/// View model for quote component
class QuoteComponentViewModel extends SingleColumnLayoutComponentViewModel with TextComponentViewModel {
  QuoteComponentViewModel({
    required super.nodeId,
    required super.createdAt,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    required this.text,
    required this.textStyleBuilder,
    this.inlineWidgetBuilders = const [],
    this.textDirection = TextDirection.ltr,
    this.textAlignment = TextAlign.left,
    this.selection,
    required this.selectionColor,
    this.highlightWhenEmpty = false,
  });

  @override
  AttributedText text;

  @override
  AttributionStyleBuilder textStyleBuilder;

  @override
  InlineWidgetBuilderChain inlineWidgetBuilders;

  @override
  TextDirection textDirection;

  @override
  TextAlign textAlignment;

  @override
  TextSelection? selection;

  @override
  Color selectionColor;

  @override
  bool highlightWhenEmpty;

  @override
  QuoteComponentViewModel copy() {
    return internalCopy(
          QuoteComponentViewModel(
            nodeId: nodeId,
            createdAt: createdAt,
            maxWidth: maxWidth,
            padding: padding,
            text: text,
            textStyleBuilder: textStyleBuilder,
            inlineWidgetBuilders: inlineWidgetBuilders,
            textDirection: textDirection,
            textAlignment: textAlignment,
            selection: selection,
            selectionColor: selectionColor,
            highlightWhenEmpty: highlightWhenEmpty,
          ),
        )
        as QuoteComponentViewModel;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is QuoteComponentViewModel && runtimeType == other.runtimeType && nodeId == other.nodeId && text == other.text;

  @override
  int get hashCode => nodeId.hashCode ^ text.hashCode;
}

/// Visual component for quote blocks
class QuoteComponent extends StatelessWidget {
  const QuoteComponent({super.key, required this.viewModel});

  final QuoteComponentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.grey.shade400, width: 4))),
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: TextComponent(
        text: viewModel.text,
        textStyleBuilder: (attributions) {
          return viewModel.textStyleBuilder(attributions).copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade700, fontSize: 16);
        },
        textAlign: viewModel.textAlignment,
        textDirection: viewModel.textDirection,
        textSelection: viewModel.selection,
        selectionColor: viewModel.selectionColor,
        highlightWhenEmpty: viewModel.highlightWhenEmpty,
      ),
    );
  }
}
