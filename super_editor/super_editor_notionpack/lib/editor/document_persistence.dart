import 'dart:convert';
import 'package:super_editor_notionpack/editor/models/editor_block.dart';

/// Helper class for saving and loading documents
class DocumentPersistence {
  /// Load document from JSON string
  static List<EditorBlock> loadFromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> blocksJson = json['blocks'] as List<dynamic>;

      return blocksJson.map((blockJson) => EditorBlock.fromJson(blockJson as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading document: $e');
      return [];
    }
  }

  /// Save document to JSON string
  static String saveToJson(List<EditorBlock> blocks) {
    final documentJson = {'version': '1.0', 'createdAt': DateTime.now().toIso8601String(), 'blocks': blocks.map((block) => block.toJson()).toList()};

    return JsonEncoder.withIndent('  ').convert(documentJson);
  }

  /// Example: Save to local storage / SharedPreferences
  static Future<void> saveToLocalStorage(List<EditorBlock> blocks, String documentId) async {
    final jsonString = saveToJson(blocks);
    // TODO: Implement with SharedPreferences or Hive
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('document_$documentId', jsonString);
    print('Would save to local storage: $jsonString');
  }

  /// Example: Load from local storage / SharedPreferences
  static Future<List<EditorBlock>> loadFromLocalStorage(String documentId) async {
    // TODO: Implement with SharedPreferences or Hive
    // final prefs = await SharedPreferences.getInstance();
    // final jsonString = prefs.getString('document_$documentId');
    // if (jsonString != null) {
    //   return loadFromJson(jsonString);
    // }
    return [];
  }

  /// Example: Save to database (SQLite, Firebase, etc.)
  static Future<void> saveToDatabase(List<EditorBlock> blocks, String documentId) async {
    final jsonString = saveToJson(blocks);

    // Example for SQLite:
    // final db = await database;
    // await db.insert('documents', {
    //   'id': documentId,
    //   'content': jsonString,
    //   'updated_at': DateTime.now().toIso8601String(),
    // });

    // Example for Firebase:
    // await FirebaseFirestore.instance
    //     .collection('documents')
    //     .doc(documentId)
    //     .set({
    //       'content': jsonString,
    //       'updatedAt': FieldValue.serverTimestamp(),
    //     });

    print('Would save to database: $jsonString');
  }

  /// Example: Load from database
  static Future<List<EditorBlock>> loadFromDatabase(String documentId) async {
    // Example for SQLite:
    // final db = await database;
    // final List<Map<String, dynamic>> maps = await db.query(
    //   'documents',
    //   where: 'id = ?',
    //   whereArgs: [documentId],
    // );
    // if (maps.isNotEmpty) {
    //   return loadFromJson(maps.first['content'] as String);
    // }

    // Example for Firebase:
    // final doc = await FirebaseFirestore.instance
    //     .collection('documents')
    //     .doc(documentId)
    //     .get();
    // if (doc.exists) {
    //   return loadFromJson(doc.data()!['content'] as String);
    // }

    return [];
  }
}
