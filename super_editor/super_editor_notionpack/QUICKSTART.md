# NotionPack - Quick Start Guide 🚀

## O que é NotionPack?

NotionPack é um editor rico similar ao Notion, construído com Flutter e Super Editor. Oferece uma interface limpa e moderna com suporte a blocos customizados, sidebar de navegação, e muito mais.

## ✨ Características Principais

### 1. **Blocos Customizados**

#### 📌 Callout (Destaque)
Blocos coloridos para destacar informações importantes:
- 💙 **Info** - Informações gerais (azul)
- 🧡 **Warning** - Avisos importantes (laranja)
- ❤️ **Error** - Erros e alertas (vermelho)
- 💚 **Success** - Confirmações (verde)

#### 🔽 Toggle (Expansível)
Blocos que podem ser expandidos ou recolhidos - perfeito para organizar conteúdo hierárquico.

#### 💬 Quote (Citação)
Blocos de citação estilizados com borda lateral e texto em itálico.

### 2. **Interface Notion-like**

- **Sidebar**: Navegação limpa com seções para Home, Inbox, Settings e lista de blocos
- **Top Bar**: Título do documento, botão de compartilhar e opções
- **Editor**: Editor de texto rico totalmente funcional baseado no Super Editor

### 3. **Drag Handles**

Ícones de arrasto que aparecem ao passar o mouse sobre os blocos (visual pronto, funcionalidade pode ser expandida).

## 🏃 Como Executar

```bash
# 1. Navegue até o diretório do projeto
cd super_editor/super_editor_notionpack

# 2. Instale as dependências
flutter pub get

# 3. Execute o app
flutter run -d macos      # Para macOS
flutter run -d chrome     # Para Web
flutter run -d windows    # Para Windows
```

## 📱 Plataformas Suportadas

- ✅ macOS
- ✅ Windows
- ✅ Linux
- ✅ Web
- ✅ iOS
- ✅ Android

## 🎨 Usando os Blocos

### Criando Blocos via Código

```dart
import 'package:super_editor_notionpack/blocks/custom_nodes.dart';

// Criar um Callout
final callout = CalloutNode(
  id: Editor.createNodeId(),
  text: AttributedText('💡 Dica importante!'),
  calloutType: CalloutType.info,
);

// Criar um Toggle
final toggle = ToggleNode(
  id: Editor.createNodeId(),
  text: AttributedText('Clique para expandir'),
  isExpanded: true,
);

// Criar um Quote
final quote = QuoteNode(
  id: Editor.createNodeId(),
  text: AttributedText('Ser ou não ser, eis a questão.'),
);
```

### Adicionando ao Documento

```dart
final document = MutableDocument(
  nodes: [
    callout,
    toggle,
    quote,
    // ... outros blocos
  ],
);
```

## 🔧 Personalização

### Mudar Cores dos Callouts

Edite `lib/blocks/custom_components.dart`, método `CalloutComponent.build()`:

```dart
switch (viewModel.calloutType) {
  case CalloutType.info:
    backgroundColor = Colors.blue.shade50;  // Mude aqui
    borderColor = Colors.blue.shade300;
    iconData = Icons.info_outline;
    break;
  // ... outros casos
}
```

### Customizar a Sidebar

Edite `lib/notion_editor_page.dart`, método `_buildSidebar()`:

```dart
Widget _buildSidebar() {
  return Column(
    children: [
      // Adicione seus próprios widgets aqui
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Meu App Custom'),
      ),
      // ... resto da sidebar
    ],
  );
}
```

### Alterar o Tema

Edite `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.purple,  // Sua cor aqui
    brightness: Brightness.light,
  ),
),
```

## 📁 Estrutura de Arquivos

```
lib/
├── main.dart                      # 🚪 Entrada do app
├── notion_editor_page.dart        # 📝 Página principal do editor
├── blocks/
│   ├── custom_nodes.dart          # 🧱 Definições dos blocos
│   └── custom_components.dart     # 🎨 Componentes visuais
├── slash_command/
│   └── slash_command_menu.dart    # ⌨️ Menu de comandos
└── widgets/
    └── block_drag_handle.dart     # 👆 Handle de arrasto
```

## 🎯 Próximos Passos Sugeridos

### Para Iniciantes

1. **Explore o código**: Comece por `lib/main.dart` e vá seguindo os imports
2. **Teste o app**: Execute e experimente adicionar diferentes blocos
3. **Modifique cores**: Tente mudar as cores dos callouts
4. **Adicione conteúdo**: Crie documentos de exemplo

### Para Desenvolvedores

1. **Implemente Slash Commands**: Conecte o menu ao teclado
2. **Adicione Novos Blocos**: Crie blocos de código, tabelas, etc.
3. **Implementar Drag & Drop**: Torne os blocos reordenáveis
4. **Adicione Persistência**: Salve documentos em banco de dados
5. **Colaboração**: Adicione edição colaborativa em tempo real

## 📚 Recursos Úteis

### Super Editor
- [Repositório GitHub](https://github.com/superlistapp/super_editor)
- [Documentação](https://supereditor.dev)
- [Exemplos](https://github.com/superlistapp/super_editor/tree/main/super_editor/example)

### Flutter
- [Documentação](https://flutter.dev/docs)
- [Cookbook](https://flutter.dev/docs/cookbook)
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

## 💡 Dicas e Truques

### Dica 1: IDs Únicos
Sempre use `Editor.createNodeId()` para gerar IDs únicos para os blocos:
```dart
final id = Editor.createNodeId();
```

### Dica 2: Metadata
Use metadata para adicionar propriedades customizadas aos blocos:
```dart
ParagraphNode(
  id: id,
  text: AttributedText('Texto'),
  metadata: {
    'custom_property': 'valor',
    'timestamp': DateTime.now(),
  },
);
```

### Dica 3: Estilos
Aplique estilos usando `AttributedText`:
```dart
AttributedText(
  'Texto com negrito',
  AttributedSpans(
    attributions: [
      SpanMarker(attribution: boldAttribution, offset: 0, markerType: SpanMarkerType.start),
      SpanMarker(attribution: boldAttribution, offset: 5, markerType: SpanMarkerType.end),
    ],
  ),
);
```

## 🐛 Solução de Problemas

### Erro: "Can't find super_editor"
```bash
flutter clean
flutter pub get
```

### Erro de Build no macOS
```bash
cd macos
pod install
cd ..
flutter run
```

### Hot Reload Não Funciona
Às vezes é necessário fazer um restart completo:
- Pressione `R` no terminal (não `r`)
- Ou pare e execute `flutter run` novamente

## 🤝 Contribuindo

Quer melhorar o NotionPack? Algumas ideias:

1. **Adicione mais tipos de blocos**
   - Bloco de código com syntax highlighting
   - Tabelas editáveis
   - Embed de vídeos/imagens
   - Gráficos e diagramas

2. **Melhore a UI**
   - Animações suaves
   - Dark mode completo
   - Temas customizáveis
   - Ícones personalizados

3. **Adicione funcionalidades**
   - Export para PDF/Markdown
   - Import de documentos
   - Busca no documento
   - Tags e categorias

## 📞 Suporte

- **Documentação Completa**: Veja `FEATURES.md`
- **Super Editor Issues**: [GitHub Issues](https://github.com/superlistapp/super_editor/issues)
- **Flutter Help**: [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

**Divirta-se construindo seu editor! 🎉**

*Construído com ❤️ usando Flutter e Super Editor*

