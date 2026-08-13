import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/horario.dart';
import '../../models/notificacao.dart';
import '../../providers/app_status_provider.dart';
import '../../repositories/escola_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_indicator.dart';

/// Tela Inicial — data, hora, status de conexão e atalhos principais.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EscolaRepository _escolaRepository = EscolaRepository();
  late DateTime _agora;
  Timer? _relogio;

  // Criada uma única vez: se fosse chamada dentro de build(), o relógio
  // (que atualiza o estado a cada segundo) recriaria esse Future a cada
  // tick, fazendo o card de "Próxima aula" voltar ao loading sem parar.
  late final Future<Horario> _proximaAulaFuture = _escolaRepository
      .buscarProximaAula();

  @override
  void initState() {
    super.initState();
    _agora = DateTime.now();
    // Relógio em tempo real exibido no painel principal.
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _agora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  void _abrirNotificacoes() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _NotificacoesSheet(repository: _escolaRepository),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final online = context.watch<AppStatusProvider>().online;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppConstants.appName),
          ],
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.notificacoes,
            onPressed: _abrirNotificacoes,
            icon: const Badge(
              backgroundColor: AppColors.error,
              smallSize: 8,
              child: Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Responsive.constrained(
          child: ListView(
            padding: Responsive.pagePadding(context),
            children: [
              // ------------------------------------------------ Painel data/hora
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppFormatters.dataCompleta(_agora),
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        // Toque alterna Online/Offline (simulação visual).
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => context
                              .read<AppStatusProvider>()
                              .alternarConexao(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: StatusIndicator(
                              label: online
                                  ? AppStrings.online
                                  : AppStrings.offline,
                              ativo: online,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppFormatters.horaCompleta(_agora),
                      style: textTheme.headlineMedium?.copyWith(fontSize: 44),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------- Ações principais
              AppButton(
                label: AppStrings.iniciarReconhecimento,
                icon: Icons.face_outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.reconhecimento),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: AppStrings.historico,
                icon: Icons.history,
                variant: AppButtonVariant.outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.historico),
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------- Acesso rápido
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icone: Icons.sync,
                      titulo: AppStrings.sincronizacao,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.sincronizacao),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icone: Icons.settings_outlined,
                      titulo: AppStrings.configuracoes,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.configuracoes),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // -------------------------------------------------- Próxima aula
              const SectionHeader(titulo: AppStrings.proximaAula),
              FutureBuilder<Horario>(
                future: _proximaAulaFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const AppCard(
                      child: SizedBox(
                        height: 56,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    );
                  }
                  final aula = snapshot.data!;
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                aula.disciplina,
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${aula.professor} • ${aula.sala}',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              aula.horaInicio,
                              style: textTheme.titleMedium?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                            Text(aula.horaFim, style: textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de acesso rápido (Sincronização / Configurações).
class _QuickAction extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        children: [
          Icon(icone, color: scheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet com as notificações mockadas do sistema.
class _NotificacoesSheet extends StatelessWidget {
  final EscolaRepository repository;

  const _NotificacoesSheet({required this.repository});

  IconData _icone(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.alerta:
        return Icons.warning_amber_outlined;
      case TipoNotificacao.sucesso:
        return Icons.check_circle_outline;
      case TipoNotificacao.info:
        return Icons.info_outline;
    }
  }

  Color _cor(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.alerta:
        return AppColors.warning;
      case TipoNotificacao.sucesso:
        return AppColors.success;
      case TipoNotificacao.info:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.notificacoes, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            FutureBuilder<List<Notificacao>>(
              future: repository.buscarNotificacoes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final itens = snapshot.data!;
                return Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: itens.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = itens[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_icone(n.tipo), color: _cor(n.tipo)),
                        title: Text(n.titulo, style: textTheme.titleMedium),
                        subtitle: Text(n.mensagem, style: textTheme.bodySmall),
                        trailing: Text(
                          AppFormatters.hora(n.dataHora),
                          style: textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
