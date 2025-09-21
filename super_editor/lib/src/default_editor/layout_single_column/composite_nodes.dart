import 'package:flutter/material.dart' show EdgeInsets;
import 'package:super_editor/src/core/document.dart';
import 'package:super_editor/src/default_editor/layout_single_column/layout_single_column.dart';

/// A view model for a [CompositeNode], which is a node that contains other nodes.
class CompositeNodeViewModel extends SingleColumnLayoutComponentViewModel {
  CompositeNodeViewModel({
    required super.nodeId,
    super.createdAt,
    super.padding = EdgeInsets.zero,
    super.maxWidth,
    required this.children,
  });

  final List<SingleColumnLayoutComponentViewModel> children;

  @override
  SingleColumnLayoutComponentViewModel copy() {
    return CompositeNodeViewModel(
      nodeId: nodeId,
      createdAt: createdAt,
      padding: padding,
      maxWidth: maxWidth,
      children: List.from(children),
    );
  }
}

/// A [DocumentNode] that contains other [DocumentNode]s.
///
/// A [CompositeNode] includes an iterable, content-order list of [children], however,
/// it has no knowledge about the visual orientation of those children. They might flow
/// in a column, row, table, or anything else. The only requirement is that all children
/// are iterable in a consistent content order, and that the first child is considered
/// the beginning of the content, and the last child is considered the end of the content.
///
/// This node includes sane default implementations for reporting beginning, ending, upstream,
/// and downstream positions within the [CompositeNode].
abstract class CompositeNode extends DocumentNode {
  CompositeNode({
    required this.id,
    super.metadata,
  });

  @override
  final String id;

  Iterable<DocumentNode> get children;

  DocumentNode getChildAt(int index) => children.elementAt(index);

  @override
  NodePosition get beginningPosition => CompositeNodePosition(
        children.first.id,
        children.first.beginningPosition,
      );

  @override
  NodePosition get endPosition => CompositeNodePosition(
        children.last.id,
        children.last.endPosition,
      );

  @override
  bool containsPosition(Object position) {
    if (position is! CompositeNodePosition) {
      return false;
    }

    for (final child in children) {
      if (child.id == position.childNodeId) {
        return child.containsPosition(position.childNodePosition);
      }
    }

    return false;
  }

  @override
  NodePosition selectUpstreamPosition(NodePosition position1, NodePosition position2) {
    if (position1 is! CompositeNodePosition) {
      throw Exception('Expected a _CompositeNodePosition for position1 but received a ${position1.runtimeType}');
    }
    if (position2 is! CompositeNodePosition) {
      throw Exception('Expected a _CompositeNodePosition for position2 but received a ${position2.runtimeType}');
    }

    final index1 = int.parse(position1.childNodeId);
    final index2 = int.parse(position2.childNodeId);

    if (index1 == index2) {
      return position1.childNodePosition ==
              getChildAt(index1).selectUpstreamPosition(position1.childNodePosition, position2.childNodePosition)
          ? position1
          : position2;
    }

    return index1 < index2 ? position1 : position2;
  }

  @override
  NodePosition selectDownstreamPosition(NodePosition position1, NodePosition position2) {
    final upstream = selectUpstreamPosition(position1, position2);
    return upstream == position1 ? position2 : position1;
  }

  @override
  NodeSelection computeSelection({required NodePosition base, required NodePosition extent}) {
    assert(base is CompositeNodePosition);
    assert(extent is CompositeNodePosition);

    return CompositeNodeSelection(
      base: base as CompositeNodePosition,
      extent: extent as CompositeNodePosition,
    );
  }
}

class CompositeNodeSelection implements NodeSelection {
  const CompositeNodeSelection.collapsed(CompositeNodePosition position)
      : base = position,
        extent = position;

  const CompositeNodeSelection({
    required this.base,
    required this.extent,
  });

  final CompositeNodePosition base;

  final CompositeNodePosition extent;
}

class CompositeNodePosition implements NodePosition {
  const CompositeNodePosition(this.childNodeId, this.childNodePosition);

  final String childNodeId;
  final NodePosition childNodePosition;

  CompositeNodePosition moveWithinChild(NodePosition newPosition) {
    return CompositeNodePosition(childNodeId, newPosition);
  }

  @override
  bool isEquivalentTo(NodePosition other) {
    return this == other;
  }

  @override
  String toString() => "[CompositeNodePosition] - $childNodeId -> $childNodePosition";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositeNodePosition &&
          runtimeType == other.runtimeType &&
          childNodeId == other.childNodeId &&
          childNodePosition == other.childNodePosition;

  @override
  int get hashCode => childNodeId.hashCode ^ childNodePosition.hashCode;
}
