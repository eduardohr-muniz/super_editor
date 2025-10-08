import 'package:flutter/material.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';

/// Manages TextEditingControllers and FocusNodes for all blocks
/// Prevents recreation on rebuild and manages memory properly
class BlockControllerManager {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, TextEditingController> _urlControllers = {};

  TextEditingController getController(EditorBlock block) {
    if (!_controllers.containsKey(block.id)) {
      _controllers[block.id] = TextEditingController(text: block.content);
    }
    final controller = _controllers[block.id]!;
    
    // Update if content changed externally
    if (controller.text != block.content) {
      controller.text = block.content;
      controller.selection = TextSelection.collapsed(offset: block.content.length);
    }
    
    return controller;
  }

  FocusNode getFocusNode(EditorBlock block) {
    if (!_focusNodes.containsKey(block.id)) {
      _focusNodes[block.id] = FocusNode();
    }
    return _focusNodes[block.id]!;
  }

  TextEditingController getUrlController(EditorBlock block) {
    if (!_urlControllers.containsKey(block.id)) {
      _urlControllers[block.id] = TextEditingController(text: block.url ?? '');
    }
    final controller = _urlControllers[block.id]!;
    
    // Update if URL changed externally
    if (controller.text != (block.url ?? '')) {
      controller.text = block.url ?? '';
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
    
    return controller;
  }

  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var controller in _urlControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _controllers.clear();
    _urlControllers.clear();
    _focusNodes.clear();
  }
}

