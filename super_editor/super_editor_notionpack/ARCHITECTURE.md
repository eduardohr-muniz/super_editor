# NotionPack - Arquitetura Profissional

## 🏗️ Estrutura do Projeto

```
lib/
├── notion_pack.dart                    # Export principal do pacote
├── main.dart                           # Entry point do app demo
├── notion_editor_page.dart             # Página com sidebar
│
└── editor/                             # 📦 PACOTE PRINCIPAL
    ├── notion_editor.dart              # Widget editor principal
    ├── README.md                       # Documentação técnica
    │
    ├── models/                         # 📊 CAMADA DE DADOS
    │   └── editor_block.dart           # Modelo EditorBlock + BlockType enum
    │
    ├── services/                       # ⚙️ CAMADA DE SERVIÇOS
    │   └── block_controller_manager.dart  # Gerencia controllers persistentes
    │
    ├── config/                         # ⚙️ CONFIGURAÇÃO
    │   └── block_menu_options.dart     # Opções do menu de blocos
    │
    └── widgets/                        # 🎨 CAMADA DE UI
        ├── block_list.dart             # Lista reordenável
        ├── block_menu_overlay.dart     # Overlay do menu
        ├── block_menu_list.dart        # Menu interativo
        ├── add_block_button.dart       # Botão discreto entre blocos
        │
        └── blocks/                     # 🧱 COMPONENTES DE BLOCOS
            ├── block_widget.dart       # Wrapper geral
            ├── block_controls.dart     # Drag + menu button
            ├── block_content.dart      # Router de tipos
            │
            └── types/                  # 📝 TIPOS DE BLOCOS
                ├── text_block.dart         # Texto simples
                ├── rich_text_block.dart    # Texto rico (SuperEditor)
                ├── image_block.dart        # Imagem (galeria + URL)
                ├── video_block.dart        # Vídeo YouTube
                ├── callout_block.dart      # Callouts (4 cores)
                ├── quote_block.dart        # Citações
                └── list_block.dart         # Listas (bullet/numbered)
```

## 🎯 Princípios de Arquitetura

### 1. **Separação de Responsabilidades**
- **Models**: Dados puros, sem lógica de UI
- **Services**: Lógica de negócio compartilhada
- **Widgets**: Apenas UI e interação

### 2. **Componentização**
- Cada tipo de bloco é um componente independente
- Reutilizável e testável
- Fácil adicionar novos tipos

### 3. **Performance**
- Controllers persistem entre rebuilds
- Dispose adequado previne memory leaks
- AnimatedOpacity para transições suaves

### 4. **Flexibilidade**
- Flag `isEditable` para modo edição/visualização
- Callbacks opcionais (`onBlocksChanged`)
- Blocos iniciais customizáveis

## 📦 Como Usar o Pacote

### Instalação

```yaml
dependencies:
  super_editor_notionpack:
    path: ../super_editor_notionpack
```

### Uso Básico

```dart
import 'package:notion_pack/notion_pack.dart';

// Editor simples
NotionEditor(
  isEditable: true,
)

// Com configuração
NotionEditor(
  isEditable: true,
  initialBlocks: [
    EditorBlock(
      id: '1',
      type: BlockType.heading1,
      content: 'My Document',
    ),
  ],
  onBlocksChanged: (blocks) {
    // Salvar alterações
    print('${blocks.length} blocks');
  },
)
```

### Modo Visualização

```dart
NotionEditor(
  isEditable: false,  // Somente leitura
  initialBlocks: savedBlocks,
)
```

## 🧱 Tipos de Blocos Disponíveis

### Texto
- `paragraph` - Parágrafo normal
- `heading1` - Título grande (32px)
- `heading2` - Título médio (24px)
- `heading3` - Título pequeno (18px)

### Listas
- `bulletList` - Lista com marcadores
- `numberedList` - Lista numerada

### Especiais
- `quote` - Citação com borda lateral
- `calloutInfo` - Destaque azul
- `calloutWarning` - Destaque laranja
- `calloutError` - Destaque vermelho
- `calloutSuccess` - Destaque verde
- `toggle` - Bloco expansível
- `divider` - Linha horizontal

### Mídia
- `image` - Imagem (galeria ou URL)
- `video` - Vídeo do YouTube

## ✨ Funcionalidades

### 1. **Slash Commands** (/)
- Digite `/` em qualquer bloco
- Menu aparece automaticamente
- Busca em tempo real (ex: "h1", "call", "img")
- Navegação com teclado (↑↓, Enter)

### 2. **Drag & Drop**
- Arraste o ícone ⋮⋮ para reordenar
- Visual feedback durante arrasto
- Sem ícone no lado direito

### 3. **Botões Entre Blocos**
- Aparecem discretamente no hover
- Cinza, pequenos, não invasivos
- Adicionam bloco exatamente onde você quer

### 4. **Rich Text** (em desenvolvimento)
- Seleção de texto mostra toolbar
- Bold, Italic, Underline, Strikethrough
- Cores de texto
- Powered by SuperEditor

### 5. **Mídia Inteligente**
- **Imagem**: Galeria OU URL
- **Vídeo**: Thumbnail + click para abrir YouTube
- Loading states e error handling

## 🔧 Extendendo o Pacote

### Adicionar Novo Tipo de Bloco

1. **Adicione ao enum**:
```dart
// editor/models/editor_block.dart
enum BlockType {
  // ... existing
  myCustomBlock,
}
```

2. **Crie o componente**:
```dart
// editor/widgets/blocks/types/my_custom_block.dart
class MyCustomBlock extends StatelessWidget {
  // ... implementação
}
```

3. **Registre no router**:
```dart
// editor/widgets/blocks/block_content.dart
case BlockType.myCustomBlock:
  return MyCustomBlock(...);
```

4. **Adicione ao menu**:
```dart
// editor/config/block_menu_options.dart
BlockMenuOption(
  type: BlockType.myCustomBlock,
  title: 'My Custom',
  description: 'Description',
  icon: Icons.star,
  searchTerms: ['custom', 'my'],
),
```

## 🎨 Personalização

### Cores do Callout
```dart
// editor/widgets/blocks/types/callout_block.dart
case BlockType.calloutInfo:
  return (
    Colors.blue.shade50,      // Background
    Colors.blue.shade300,     // Border
    Icons.info_outline        // Icon
  );
```

### Estilos de Texto
```dart
// editor/widgets/blocks/types/text_block.dart
case BlockType.heading1:
  return TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
```

## 📊 Fluxo de Dados

```
NotionEditor (State Management)
    ↓
BlockList (Reorderable)
    ↓
BlockWidget (Controls + Content)
    ↓
BlockContent (Router)
    ↓
Specific Block Type (TextBlock, ImageBlock, etc)
    ↓
BlockControllerManager (Persistent Controllers)
```

## 🔄 Ciclo de Vida

1. **Inicialização**
   - NotionEditor cria lista de blocos
   - BlockControllerManager inicializado

2. **Renderização**
   - BlockList mapeia blocos
   - BlockContent roteia para componente correto
   - Controllers reutilizados (não recriados)

3. **Atualização**
   - onBlockUpdated chama setState no NotionEditor
   - onBlocksChanged notifica parent
   - Apenas blocos modificados rebuildam

4. **Dispose**
   - BlockControllerManager limpa todos os controllers
   - Sem memory leaks

## 🚀 Performance

### Otimizações Implementadas

1. **Controller Persistence** ✅
   - Controllers não são recriados a cada rebuild
   - Cursor mantém posição

2. **Lazy Initialization** ✅
   - Controllers criados apenas quando necessário
   - Map lookup O(1)

3. **Partial Updates** ✅
   - Apenas blocos alterados sofrem rebuild
   - Estado local em cada componente

4. **Animated Opacity** ✅
   - Transições suaves sem rebuilds pesados

## 📝 Convenções de Código

### Nomenclatura
- **Widgets**: PascalCase (BlockWidget)
- **Arquivos**: snake_case (block_widget.dart)
- **Variáveis privadas**: _underscorePrefixed

### Organização
- Um widget por arquivo
- Arquivos pequenos e focados
- Imports agrupados (dart, flutter, package, local)

## 🐛 Debugging

### Logs Úteis
```dart
// Em video_block.dart
print('YouTube URL: ${block.url}');
print('Extracted Video ID: $videoId');
```

### DevTools
- Widget Inspector para ver hierarquia
- Performance overlay para identificar rebuilds
- Network tab para ver carregamento de imagens

## 📚 Dependências

- `flutter` - Framework
- `super_editor` - Rich text engine
- `url_launcher` - Abrir YouTube
- `image_picker` - Galeria de imagens

## 🎯 Roadmap

- [x] Componentização completa
- [x] Flag edição/visualização
- [x] 15 tipos de blocos
- [x] Drag & drop
- [x] Slash commands
- [x] Keyboard navigation
- [x] Image + Video blocks
- [ ] Rich text toolbar integrado
- [ ] Serialização JSON
- [ ] Persistência local
- [ ] Colaboração real-time
- [ ] Export PDF/Markdown
- [ ] Undo/Redo
- [ ] Templates
- [ ] Mobile support otimizado

---

**Built with ❤️ as a professional Flutter package**

