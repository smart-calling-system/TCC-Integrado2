import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/sync_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/sync_status.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/status_indicator.dart';

/// Tela de Sincronização — status de Internet, Servidor e Banco local,
/// registros pendentes e ação de sincronizar (tudo apenas visual).
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SyncController()..carregar(),
      child: const _SyncView(),
    );
  }
}

class _SyncView extends StatelessWidget {
  const _SyncView();

  Future<void> _sincronizar(BuildContext context) async {
    await context.read<SyncController>().sincronizar();
    if (context.mounted) {
      AppSnackbar.sucesso(context, AppStrings.sincronizacaoConcluida);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SyncController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text(AppStrings.sincronizacao)),
      body: SafeArea(
        child: controller.carregando || controller.status == null
            ? const AppLoading(mensagem: AppStrings.carregando)
            : Responsive.constrained(
                child: ListView(
                  padding: Responsive.pagePadding(context),
                  children: [
                    // ------------------------------------ Registros pendentes
                    AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: controller.status!.registrosPendentes
                                  .toDouble(),
                            ),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, valor, _) => Text(
                              valor.round().toString(),
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: 56,
                                color: controller.status!.registrosPendentes >
                                        0
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.registrosPendentes,
                            style: textTheme.bodyMedium,
                          ),
                          if (controller.status!.ultimaSincronizacao !=
                              null) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${AppStrings.ultimaSincronizacao}: '
                              '${AppFormatters.dataHora(controller.status!.ultimaSincronizacao!)}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ------------------------------------ Itens de conexão
                    _ItemConexao(
                      icone: Icons.wifi,
                      titulo: AppStrings.internet,
                      descricao: 'Conexão de rede do tablet',
                      estado: controller.status!.internet,
                    ),
                    const SizedBox(height: 12),
                    _ItemConexao(
                      icone: Icons.dns_outlined,
                      titulo: AppStrings.servidor,
                      descricao: 'Servidor de presença (attendance-api)',
                      estado: controller.status!.servidor,
                    ),
                    const SizedBox(height: 12),
                    _ItemConexao(
                      icone: Icons.storage_outlined,
                      titulo: AppStrings.bancoLocal,
                      descricao: 'Registros armazenados no dispositivo',
                      estado: controller.status!.bancoLocal,
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      label: controller.sincronizando
                          ? AppStrings.sincronizando
                          : AppStrings.sincronizar,
                      icon: Icons.sync,
                      loading: controller.sincronizando,
                      onPressed: () => _sincronizar(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Card de um item verificado na sincronização (Internet/Servidor/Banco).
class _ItemConexao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final EstadoConexao estado;

  const _ItemConexao({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icone, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(descricao, style: textTheme.bodySmall),
              ],
            ),
          ),
          StatusIndicator(
            label: estado.label,
            ativo: estado == EstadoConexao.conectado,
            verificando: estado == EstadoConexao.verificando,
          ),
        ],
      ),
    );
  }
}
