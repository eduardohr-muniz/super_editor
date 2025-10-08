# NotionPack Editor - Architecture

## 📁 Estrutura Profissional

```
lib/editor/
├── notion_editor.dart              # Widget principal do editor
├── models/
│   └── editor_block.dart           # Modelo de dados dos blocos
├── services/
│   └── block_controller_manager.dart  # Gerenciamento de controllers
├── config/
│   └── block_menu_options.dart     # Configuração dos tipos de blocos
└── widgets/
    ├── block_list.dart             # Lista reordenável de blocos
    ├── block_menu_overlay.dart     # Overlay do menu de seleção
    ├── block_menu_list.dart        # Lista interativa do menu
    ├── add_block_button.dart       # Botão entre blocos
    └── blocks/
        ├── block_widget.dart       # Wrapper de um bloco
        ├── block_controls.dart     # Controles (drag + menu)
        ├── block_content.dart      # Roteador de conteúdo
        └── types/
            ├── text_block.dart     # Blocos de texto/heading
            ├── rich_text_block.dart   # Texto rico com SuperEditor
            ├── image_block.dart    # Blocos de imagem
            ├── video_block.dart    # Blocos de vídeo
            ├── callout_block.dart  # Blocos de callout
            ├── quote_block.dart    # Blocos de citação
            └── list_block.dart     # Blocos de lista
```

## 🎯 Arquitetura em Camadas

### 1. **Model Layer** (`models/`)
- `EditorBlock` - Modelo de dados imutável com `copyWith()`
- Enum `BlockType` com todos os tipos suportados

### 2. **Service Layer** (`services/`)
- `BlockControllerManager` - Gerencia controllers persistentes
- Previne memory leaks e garante cursor estável

### 3. **Configuration** (`config/`)
- `BlockMenuOptions` - Lista de blocos disponíveis
- Configuração centralizada com search terms

### 4. **Widget Layer** (`widgets/`)
- **Core Widgets:**
  - `NotionEditor` - Widget principal com flag `isEditable`
  - `BlockList` - Lista reordenável
  - `BlockMenuOverlay` - Menu de seleção

- **Block Widgets:**
  - `BlockWidget` - Wrapper com controles
  - `BlockContent` - Router para tipo correto
  - `Block Types` - Componentes especializados

## 🎨 Flags de Modo

### `isEditable: true` (Modo Edição)
- ✅ Drag handles visíveis
- ✅ Botões "+" entre blocos
- ✅ Campos editáveis
- ✅ Slash commands
- ✅ Formatting toolbar

### `isEditable: false` (Modo Visualização)
- ✅ Sem controles
- ✅ Apenas renderização
- ✅ Performance otimizada
- ✅ Ideal para preview/export

## 🚀 Uso do Pacote

### Básico:
```dart
NotionEditor(
  isEditable: true,
)
```

### Avançado:
```dart
NotionEditor(
  isEditable: true,
  initialBlocks: myBlocks,
  onBlocksChanged: (blocks) {
    // Salvar no banco de dados
    saveToDatabase(blocks);
  },
)
```

## 📦 Componentização

Cada tipo de bloco é um componente independente:

1. **TextBlock** - Texto simples
2. **RichTextBlock** - Texto com formatação (SuperEditor)
3. **ImageBlock** - Galeria + URL
4. **VideoBlock** - YouTube embeds
5. **CalloutBlock** - 4 variações de cor
6. **QuoteBlock** - Citações
7. **ListBlock** - Listas ordenadas/não ordenadas

## 🎯 Próximos Passos

- [x] Componentização completa
- [x] Flag de edição/visualização
- [ ] Integrar RichTextBlock com toolbar
- [ ] Persistência (JSON serialization)
- [ ] Colaboração em tempo real
- [ ] Export para PDF/Markdown

