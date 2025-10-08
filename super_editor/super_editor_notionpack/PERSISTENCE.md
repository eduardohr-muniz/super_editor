# 💾 NotionPack - Sistema de Persistência

## Como Salvar Documentos

### 1. **Salvar com Cmd+S / Ctrl+S**

O editor detecta automaticamente quando você pressiona `Cmd+S` (Mac) ou `Ctrl+S` (Windows/Linux) e chama o callback `onSave`:

```dart
NotionEditor(
  onSave: (documentJson) {
    // Seu código para salvar
    print(JsonEncoder.withIndent('  ').convert(documentJson));
  },
)
```

### 2. **Formato JSON**

O documento é serializado neste formato:

```json
{
  "version": "1.0",
  "createdAt": "2025-10-08T12:00:00.000Z",
  "blocks": [
    {
      "id": "1",
      "type": "heading1",
      "content": "My Title",
      "isComplete": false,
      "attributedContent": {
        // Rich text formatting data (bold, italic, colors, links)
      }
    },
    {
      "id": "2",
      "type": "paragraph",
      "content": "Some text with formatting",
      "isComplete": false
    }
  ]
}
```

### 3. **Salvar em Banco de Dados**

#### **Opção A: Local (SharedPreferences)**

```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveDocument(Map<String, dynamic> documentJson) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(documentJson);
  await prefs.setString('my_document', jsonString);
}
```

#### **Opção B: SQLite**

```dart
import 'package:sqflite/sqflite.dart';

Future<void> saveDocument(Map<String, dynamic> documentJson) async {
  final db = await openDatabase('my_database.db');
  
  await db.insert(
    'documents',
    {
      'id': 'doc_id',
      'content': jsonEncode(documentJson),
      'updated_at': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
```

#### **Opção C: Firebase Firestore**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveDocument(Map<String, dynamic> documentJson) async {
  await FirebaseFirestore.instance
      .collection('documents')
      .doc('my_document_id')
      .set({
        'content': documentJson,
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
```

#### **Opção D: API REST**

```dart
import 'package:http/http.dart' as http;

Future<void> saveDocument(Map<String, dynamic> documentJson) async {
  final response = await http.post(
    Uri.parse('https://api.myapp.com/documents'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(documentJson),
  );
  
  if (response.statusCode == 200) {
    print('Document saved successfully!');
  }
}
```

## Como Carregar Documentos

### 1. **Carregar do Banco de Dados**

```dart
import 'package:super_editor_notionpack/editor/models/editor_block.dart';

// Load from SharedPreferences
Future<List<EditorBlock>> loadDocument() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('my_document');
  
  if (jsonString != null) {
    final json = jsonDecode(jsonString);
    final blocksJson = json['blocks'] as List<dynamic>;
    
    return blocksJson
        .map((blockJson) => EditorBlock.fromJson(blockJson))
        .toList();
  }
  
  return [];
}
```

### 2. **Usar no Editor**

```dart
class MyEditorPage extends StatefulWidget {
  @override
  State<MyEditorPage> createState() => _MyEditorPageState();
}

class _MyEditorPageState extends State<MyEditorPage> {
  List<EditorBlock>? _loadedBlocks;
  
  @override
  void initState() {
    super.initState();
    _loadDocument();
  }
  
  Future<void> _loadDocument() async {
    final blocks = await loadDocument();
    setState(() {
      _loadedBlocks = blocks;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_loadedBlocks == null) {
      return const CircularProgressIndicator();
    }
    
    return NotionEditor(
      initialBlocks: _loadedBlocks,
      onSave: (documentJson) {
        // Save to database
        saveDocument(documentJson);
      },
    );
  }
}
```

## ⚠️ IMPORTANTE: Formatação Rica

O campo `attributedContent` ainda está em desenvolvimento. Por enquanto, apenas o texto simples é preservado. 

Para salvar **formatações ricas** (bold, italic, colors, links), você pode:

1. **Opção Simples:** Salvar como HTML ou Markdown
2. **Opção Completa:** Serializar os `AttributedText` com todas as atribuições

### Exemplo de serialização de formatação:

```json
{
  "id": "1",
  "type": "paragraph",
  "content": "Hello world with link",
  "attributedContent": {
    "text": "Hello world with link",
    "spans": [
      {
        "start": 0,
        "end": 4,
        "attributions": ["bold"]
      },
      {
        "start": 12,
        "end": 15,
        "attributions": [
          {"type": "link", "url": "https://example.com"}
        ]
      }
    ]
  }
}
```

## 📚 Exemplos Prontos

Veja o arquivo `lib/editor/document_persistence.dart` para exemplos completos de:
- ✅ Save/Load com SharedPreferences
- ✅ Save/Load com SQLite
- ✅ Save/Load com Firebase
- ✅ Save/Load com API REST

## 🎯 Próximos Passos

1. Implementar serialização completa de `AttributedText`
2. Adicionar auto-save (a cada X segundos)
3. Adicionar histórico de versões (undo/redo persistente)
4. Sincronização em tempo real (Firebase/WebSockets)

