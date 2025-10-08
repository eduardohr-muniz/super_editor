import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';
import 'package:super_editor_notionpack/editor/config/block_menu_options.dart';

/// Interactive menu list with keyboard navigation and search
class BlockMenuList extends StatefulWidget {
  const BlockMenuList({
    super.key,
    required this.onBlockSelected,
  });

  final ValueChanged<BlockType> onBlockSelected;

  @override
  State<BlockMenuList> createState() => _BlockMenuListState();
}

class _BlockMenuListState extends State<BlockMenuList> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  List<BlockMenuOption> get _filteredOptions {
    if (_searchQuery.isEmpty) {
      return blockMenuOptions;
    }
    return blockMenuOptions.where((option) {
      return option.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          option.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          option.searchTerms.any((term) => term.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  void _selectOption(BlockMenuOption option) {
    widget.onBlockSelected(option.type);
  }

  void _handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter) {
      _selectCurrent();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelectionUp();
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelectionDown();
    } else if (key == LogicalKeyboardKey.backspace) {
      _clearSearch();
    } else if (event.character != null && RegExp(r'[a-zA-Z0-9\s]').hasMatch(event.character!)) {
      _handleKeyEvent(event.character!.toLowerCase());
    }
  }

  void _handleKeyEvent(String char) {
    setState(() {
      _searchQuery += char;
      _selectedIndex = 0;
    });
  }

  void _moveSelectionUp() {
    setState(() {
      if (_selectedIndex > 0) {
        _selectedIndex--;
      }
    });
  }

  void _moveSelectionDown() {
    final options = _filteredOptions;
    if (_selectedIndex < options.length - 1) {
      setState(() {
        _selectedIndex++;
      });
    }
  }

  void _selectCurrent() {
    final options = _filteredOptions;
    if (options.isNotEmpty && _selectedIndex < options.length) {
      _selectOption(options[_selectedIndex]);
    }
  }

  void _clearSearch() {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _searchQuery = _searchQuery.substring(0, _searchQuery.length - 1);
        _selectedIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = _filteredOptions;

    return RawKeyboardListener(
      focusNode: _searchFocus,
      autofocus: true,
      onKey: _handleKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_searchQuery.isNotEmpty) _buildSearchIndicator(),
          Flexible(
            child: options.isEmpty ? _buildEmptyState() : _buildOptionsList(options),
          ),
          _buildKeyboardHints(),
        ],
      ),
    );
  }

  Widget _buildSearchIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: Colors.blue.shade700),
          SizedBox(width: 8),
          Text(
            'Search: $_searchQuery',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'No blocks found for "$_searchQuery"',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionsList(List<BlockMenuOption> options) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      padding: EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = index == _selectedIndex;

        return InkWell(
          onTap: () => _selectOption(option),
          onHover: (hovering) {
            if (hovering) {
              setState(() => _selectedIndex = index);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    option.icon,
                    size: 20,
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        option.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyboardHints() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildKeyHint('↑↓', 'Navigate'),
          SizedBox(width: 12),
          _buildKeyHint('Enter', 'Select'),
          SizedBox(width: 12),
          _buildKeyHint('Type', 'Search'),
        ],
      ),
    );
  }

  Widget _buildKeyHint(String key, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}

