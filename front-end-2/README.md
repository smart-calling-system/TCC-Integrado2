# FaceClass - Frontend Flutter

Frontend do Sistema de Controle de Presenca Escolar baseado em Reconhecimento Facial.

## Estado Atual

Esta versao funciona isoladamente, sem depender do backend Node.js ou da API Python. A arquitetura foi preparada para a integracao futura, mas nenhuma chamada HTTP real esta ativa nesta etapa.

## Como Instalar

```bash
flutter pub get
```

## Como Executar

Flutter Web para desenvolvimento:

```bash
flutter run -d chrome
```

Android, quando o SDK/dispositivo estiver disponivel:

```bash
flutter devices
flutter run -d <device-id>
```

## Qualidade

```bash
dart format .
flutter analyze
flutter test
```

## Estrutura

- `lib/core/network`: configuracao futura da API, endpoints reais, client e exceptions.
- `lib/core/session`: estado e gerenciamento de sessao.
- `lib/data/dto`: DTOs alinhados ao contrato atual do backend.
- `lib/data/mock`: data sources mock isolados para desenvolvimento sem servidor.
- `lib/data/local`: banco local SQLite e fila offline.
- `lib/models`: modelos de dominio usados pelas telas.
- `lib/repositories`: fronteira consumida por controllers/providers.
- `lib/controllers`: estado das telas.
- `lib/screens`: telas Flutter.
- `test`: testes de smoke e fila offline.

## Modo Mock

O app usa `MockDataSource` por padrao para permitir demonstracao sem backend. Credenciais de desenvolvimento existem somente em `lib/data/mock/mock_data.dart`:

- `professor@escola.com`
- `123456`

Essas credenciais nao pertencem ao repository e nao devem ser tratadas como regra real de autenticacao.

## Persistencia Offline

A fila offline usa SQLite em Android/desktop via `sync_queue`. No Flutter Web, a factory condicional usa fila em memoria para manter o app executavel em desenvolvimento, ja que `sqflite` nao e o armazenamento web oficial.

- `local_id`
- `operation`
- `payload_json`
- `created_at`
- `attempts`
- `status`
- `last_attempt_at`
- `error_message`

Estados: `pending`, `syncing`, `synced`, `error`.

## API Futura

Os endpoints estao centralizados em `ApiEndpoints` e usam o prefixo real `/api/v1`. A integracao permanece desligada por `API_INTEGRATION_ENABLED=false`.

Exemplo futuro:

```bash
flutter run --dart-define=API_INTEGRATION_ENABLED=true --dart-define=API_BASE_URL=http://localhost:3000
```

## Limitacoes Atuais

- Nenhuma integracao real com backend/Python foi realizada.
- Reconhecimento facial permanece em data source mock.
- Sincronizacao mostra a fila local real, mas nao envia lote ao servidor.
- Dashboard React citado pela auditoria nao foi implementado dentro deste projeto Flutter.
