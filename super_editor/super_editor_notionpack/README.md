# NotionPack - Notion-like Editor for Flutter

Um editor rico em recursos similar ao Notion, construído com Super Editor.

## 🚀 Funcionalidades

### Blocos Customizados
- **Callout Blocks** - Destaque informações importantes com diferentes tipos (info, warning, error, success)
- **Toggle Blocks** - Blocos expansíveis/recolhíveis para organizar conteúdo
- **Quote Blocks** - Blocos de citação estilizados
- **Heading Blocks** - Suporte para H1, H2, H3
- **List Blocks** - Listas ordenadas e não ordenadas
- **Divider Blocks** - Separadores horizontais

### Slash Commands
Digite `/` em qualquer lugar do documento para abrir o menu de comandos e inserir rapidamente diferentes tipos de blocos.

### Interface Notion-like
- Sidebar com navegação e opções de blocos
- Barra superior com título do documento e ações
- Editor limpo e minimalista
- Suporte para temas claro e escuro

## 🛠️ Estrutura do Projeto

```
lib/
├── main.dart                          # Entrada do app
├── notion_editor_page.dart            # Página principal com editor
├── blocks/
│   ├── custom_nodes.dart              # Definição dos nodes customizados
│   └── custom_components.dart         # Componentes visuais dos nodes
└── slash_command/
    ├── slash_command_listener.dart    # Listener para "/" key
    └── slash_command_menu.dart        # Menu de seleção de blocos
```

## 🎨 Blocos Disponíveis

### CalloutNode
Blocos de destaque com ícones e cores:
- **Info** (azul) - Para informações gerais
- **Warning** (laranja) - Para avisos importantes
- **Error** (vermelho) - Para erros e alertas críticos
- **Success** (verde) - Para confirmações e sucessos

### ToggleNode
Blocos que podem ser expandidos/recolhidos para organizar conteúdo hierárquico.

### QuoteNode
Blocos de citação estilizados com borda lateral e texto em itálico.

## 📦 Como Usar

### Executar o projeto

```bash
cd super_editor/super_editor_notionpack
flutter pub get
flutter run
```

### Criar um novo bloco customizado

1. **Defina o Node** em `blocks/custom_nodes.dart`:

```dart
class MyCustomNode extends TextNode {
  MyCustomNode({
    required super.id,
    required super.text,
    super.metadata,
  }) {
    initAddToMetadata({'blockType': const NamedAttribution('mycustom')});
  }
  
  // Implementar métodos de cópia e comparação
}
```

2. **Crie o Component** em `blocks/custom_components.dart`:

```dart
class MyCustomComponentBuilder implements ComponentBuilder {
  // Implementar createViewModel e createComponent
}
```

3. **Registre o Component** em `notion_editor_page.dart`:

```dart
componentBuilders: [
  MyCustomComponentBuilder(),
  ...customComponentBuilders,
  ...defaultComponentBuilders,
],
```

4. **Adicione ao Slash Menu** em `slash_command/slash_command_menu.dart`:

```dart
enum BlockType {
  // ... existing types
  myCustom,
}
```

## 🎯 Próximos Passos

- [ ] Implementar drag & drop para reorganizar blocos
- [ ] Adicionar mais tipos de blocos (tabelas, código, imagens)
- [ ] Implementar colaboração em tempo real
- [ ] Adicionar suporte a templates
- [ ] Implementar sistema de páginas/subpáginas
- [ ] Adicionar search/busca no documento
- [ ] Implementar histórico de mudanças (undo/redo melhorado)

## 📚 Recursos

- [Super Editor Documentation](https://github.com/superlistapp/super_editor)
- [Flutter Documentation](https://flutter.dev/docs)
- [Notion Documentation](https://www.notion.so/help)

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## 📄 Licença

Este projeto é open source e está disponível sob a mesma licença do Super Editor.
