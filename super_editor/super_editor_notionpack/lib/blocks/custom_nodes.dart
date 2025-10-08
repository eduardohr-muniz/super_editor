import 'package:flutter/foundation.dart';
import 'package:super_editor/super_editor.dart';

/// Enum for callout types
enum CalloutType { info, warning, error, success }

/// A callout node similar to Notion's callout blocks
@immutable
class CalloutNode extends TextNode {
  CalloutNode({required super.id, required super.text, super.metadata, this.calloutType = CalloutType.info}) {
    initAddToMetadata({'blockType': const NamedAttribution('callout')});
  }

  final CalloutType calloutType;

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is CalloutNode && calloutType == other.calloutType && text == other.text;
  }

  CalloutNode copyCalloutWith({String? id, AttributedText? text, Map<String, dynamic>? metadata, CalloutType? calloutType}) {
    return CalloutNode(id: id ?? this.id, text: text ?? this.text, metadata: metadata ?? this.metadata, calloutType: calloutType ?? this.calloutType);
  }

  @override
  CalloutNode copyTextNodeWith({String? id, AttributedText? text, Map<String, dynamic>? metadata}) {
    return copyCalloutWith(id: id, text: text, metadata: metadata);
  }

  @override
  CalloutNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return copyCalloutWith(metadata: newMetadata);
  }

  @override
  CalloutNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return copyCalloutWith(metadata: {...metadata, ...newProperties});
  }

  @override
  CalloutNode copy() {
    return CalloutNode(id: id, text: text.copyText(0), metadata: Map.from(metadata), calloutType: calloutType);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || super == other && other is CalloutNode && runtimeType == other.runtimeType && calloutType == other.calloutType;

  @override
  int get hashCode => super.hashCode ^ calloutType.hashCode;
}

/// A toggle node that can be expanded/collapsed (like Notion's toggle blocks)
@immutable
class ToggleNode extends TextNode {
  ToggleNode({required super.id, required super.text, super.metadata, this.isExpanded = true}) {
    initAddToMetadata({'blockType': const NamedAttribution('toggle')});
  }

  final bool isExpanded;

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is ToggleNode && isExpanded == other.isExpanded && text == other.text;
  }

  ToggleNode copyToggleWith({String? id, AttributedText? text, Map<String, dynamic>? metadata, bool? isExpanded}) {
    return ToggleNode(id: id ?? this.id, text: text ?? this.text, metadata: metadata ?? this.metadata, isExpanded: isExpanded ?? this.isExpanded);
  }

  @override
  ToggleNode copyTextNodeWith({String? id, AttributedText? text, Map<String, dynamic>? metadata}) {
    return copyToggleWith(id: id, text: text, metadata: metadata);
  }

  @override
  ToggleNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return copyToggleWith(metadata: newMetadata);
  }

  @override
  ToggleNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return copyToggleWith(metadata: {...metadata, ...newProperties});
  }

  @override
  ToggleNode copy() {
    return ToggleNode(id: id, text: text.copyText(0), metadata: Map.from(metadata), isExpanded: isExpanded);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || super == other && other is ToggleNode && runtimeType == other.runtimeType && isExpanded == other.isExpanded;

  @override
  int get hashCode => super.hashCode ^ isExpanded.hashCode;
}

/// A quote node for displaying quotes
@immutable
class QuoteNode extends TextNode {
  QuoteNode({required super.id, required super.text, super.metadata}) {
    initAddToMetadata({'blockType': const NamedAttribution('quote')});
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is QuoteNode && text == other.text;
  }

  QuoteNode copyQuoteWith({String? id, AttributedText? text, Map<String, dynamic>? metadata}) {
    return QuoteNode(id: id ?? this.id, text: text ?? this.text, metadata: metadata ?? this.metadata);
  }

  @override
  QuoteNode copyTextNodeWith({String? id, AttributedText? text, Map<String, dynamic>? metadata}) {
    return copyQuoteWith(id: id, text: text, metadata: metadata);
  }

  @override
  QuoteNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return copyQuoteWith(metadata: newMetadata);
  }

  @override
  QuoteNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return copyQuoteWith(metadata: {...metadata, ...newProperties});
  }

  @override
  QuoteNode copy() {
    return QuoteNode(id: id, text: text.copyText(0), metadata: Map.from(metadata));
  }

  @override
  bool operator ==(Object other) => identical(this, other) || super == other && other is QuoteNode && runtimeType == other.runtimeType;
}
