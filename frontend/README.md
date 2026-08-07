# Tcc_Face — Frontend Flutter

Frontend do **Sistema de Controle de Presença Escolar Baseado em Reconhecimento Facial**.

Interface desenvolvida em Flutter (Material Design 3) com **dados mockados**, preparada
para futura integração com o backend (`attendance-api`).

## Como executar

O repositório contém a pasta `lib/` completa, `pubspec.yaml` e assets.
As pastas de plataforma (`android/`, `ios/`) devem ser geradas localmente uma única vez:

```bash
cd Tcc_Face

# 1. Gera as pastas de plataforma sem sobrescrever os arquivos existentes
flutter create . --org com.tccface --platforms android

# 2. Instala as dependências
flutter pub get

# 3. Executa (tablet/emulador Android recomendado)
flutter run
```

## Estrutura

```
lib/
├── core/
│   ├── theme/        # Tema global Material 3 (claro/escuro), paleta de cores
│   ├── constants/    # Constantes e textos centralizados (pt-BR)
│   └── utils/        # Formatadores de data/hora e utilitários de responsividade
├── models/           # Aluno, Presença, Horário, Notificação, Status de Sincronização
├── repositories/     # Camada de dados MOCKADOS (ponto único de troca pela API real)
├── providers/        # Estado global: tema, idioma, status de conexão
├── controllers/      # Lógica de tela: reconhecimento, histórico, sincronização
├── routes/           # Rotas nomeadas + transições animadas
├── screens/          # Splash, Home, Reconhecimento, Sucesso, Erro, Histórico, Sincronização, Configurações
├── widgets/          # Componentes reutilizáveis (botões, cards, inputs, dialogs, etc.)
└── main.dart
```

## Integração futura

Todos os pontos que consumirão a API real estão marcados com:

```dart
// TODO: Substituir dados mockados pela API quando o backend for integrado.
```

A troca acontece somente na camada `repositories/` — telas, controllers e widgets
não precisam ser alterados.
