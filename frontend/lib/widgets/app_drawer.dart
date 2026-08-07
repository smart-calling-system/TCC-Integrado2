import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import 'helpers/logout_helper.dart';

class _DrawerItem {
  final IconData icone;
  final String titulo;
  final String rota;
  const _DrawerItem(this.icone, this.titulo, this.rota);
}

const List<_DrawerItem> _itens = [
  _DrawerItem(Icons.dashboard_outlined, AppStrings.dashboard, AppRoutes.dashboard),
  _DrawerItem(Icons.home_outlined, 'Início', AppRoutes.home),
  _DrawerItem(Icons.groups_outlined, AppStrings.alunos, AppRoutes.alunos),
  _DrawerItem(Icons.class_outlined, AppStrings.turmas, AppRoutes.turmas),
  _DrawerItem(Icons.menu_book_outlined, AppStrings.disciplinas, AppRoutes.disciplinas),
  _DrawerItem(Icons.event_available_outlined, AppStrings.presencas, AppRoutes.historico),
  _DrawerItem(Icons.face_outlined, AppStrings.reconhecimentoFacial, AppRoutes.reconhecimento),
  _DrawerItem(Icons.bar_chart_outlined, AppStrings.relatorios, AppRoutes.relatorios),
  _DrawerItem(Icons.sync_outlined, AppStrings.sincronizacao, AppRoutes.sincronizacao),
];

/// Menu lateral reutilizado por todas as telas internas do aplicativo,
/// dando acesso a qualquer seção em no máximo um toque (nenhuma tela fica
/// inacessível).
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usuario = context.watch<AuthProvider>().usuario;
    final rotaAtual = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Cabeçalho com os dados do usuário autenticado.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary,
                    child: Text(
                      usuario?.iniciais ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario?.nome ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          usuario?.cargo.name ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.perfil);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(AppStrings.perfil, style: TextStyle(color: scheme.primary)),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in _itens)
                    _Tile(
                      item: item,
                      selecionado: rotaAtual == item.rota,
                    ),
                ],
              ),
            ),

            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: scheme.onSurfaceVariant),
              title: const Text(AppStrings.configuracoes),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.configuracoes);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                AppStrings.sair,
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => confirmarELogout(context),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom > 0 ? 4 : 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${AppConstants.appName} • v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final _DrawerItem item;
  final bool selecionado;

  const _Tile({required this.item, required this.selecionado});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        item.icone,
        color: selecionado ? scheme.primary : scheme.onSurfaceVariant,
      ),
      title: Text(
        item.titulo,
        style: TextStyle(
          color: selecionado ? scheme.primary : null,
          fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selecionado,
      selectedTileColor: scheme.primary.withValues(alpha: 0.08),
      onTap: () {
        Navigator.of(context).pop();
        if (!selecionado) {
          Navigator.of(context).pushReplacementNamed(item.rota);
        }
      },
    );
  }
}
