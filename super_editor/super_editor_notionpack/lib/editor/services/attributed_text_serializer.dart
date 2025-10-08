import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// Serializes and deserializes AttributedText to/from JSON
/// Preserves ALL formatting: bold, italic, underline, strikethrough, colors, links, etc.
class AttributedTextSerializer {
  /// Convert AttributedText to JSON
  static Map<String, dynamic> toJson(AttributedText text) {
    print('🔄 AttributedTextSerializer.toJson called');
    print('   Text: "${text.text}"');

    final attributions = <Map<String, dynamic>>[];

    // Get all attribution spans
    final spans = text.spans.collapseSpans(contentLength: text.text.length);
    print('   Number of spans: ${spans.length}');

    for (final span in spans) {
      print('   Span ${span.start}-${span.end}: ${span.attributions.length} attributions');
      for (final attribution in span.attributions) {
        print('      Attribution: $attribution');
        final attributionData = _serializeAttribution(attribution, span.start, span.end);
        if (attributionData != null) {
          attributions.add(attributionData);
          print('      ✅ Serialized: $attributionData');
        } else {
          print('      ⚠️ Could not serialize: $attribution');
        }
      }
    }

    print('   Total attributions serialized: ${attributions.length}');
    return {'text': text.text, 'attributions': attributions};
  }

  /// Convert JSON back to AttributedText
  static AttributedText fromJson(Map<String, dynamic> json) {
    final text = json['text'] as String? ?? '';
    final attributionsJson = json['attributions'] as List<dynamic>? ?? [];

    final attributedText = AttributedText(text);

    for (final attrJson in attributionsJson) {
      final attrMap = attrJson as Map<String, dynamic>;
      final attribution = _deserializeAttribution(attrMap);

      if (attribution != null) {
        final start = attrMap['start'] as int;
        final end = attrMap['end'] as int;

        attributedText.addAttribution(attribution, SpanRange(start, end));
      }
    }

    return attributedText;
  }

  /// Serialize a single attribution to JSON
  static Map<String, dynamic>? _serializeAttribution(Attribution attribution, int start, int end) {
    if (attribution == boldAttribution) {
      return {'type': 'bold', 'start': start, 'end': end};
    } else if (attribution == italicsAttribution) {
      return {'type': 'italic', 'start': start, 'end': end};
    } else if (attribution == underlineAttribution) {
      return {'type': 'underline', 'start': start, 'end': end};
    } else if (attribution == strikethroughAttribution) {
      return {'type': 'strikethrough', 'start': start, 'end': end};
    } else if (attribution is ColorAttribution) {
      return {
        'type': 'color',
        'start': start,
        'end': end,
        'value': attribution.color.value, // Save as int (ARGB)
      };
    } else if (attribution is LinkAttribution) {
      return {'type': 'link', 'start': start, 'end': end, 'url': attribution.plainTextUri};
    }

    // Unknown attribution - skip
    return null;
  }

  /// Deserialize a single attribution from JSON
  static Attribution? _deserializeAttribution(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'bold':
        return boldAttribution;
      case 'italic':
        return italicsAttribution;
      case 'underline':
        return underlineAttribution;
      case 'strikethrough':
        return strikethroughAttribution;
      case 'color':
        final colorValue = json['value'] as int;
        return ColorAttribution(Color(colorValue));
      case 'link':
        final url = json['url'] as String;
        return LinkAttribution(url);
      default:
        return null;
    }
  }
}
