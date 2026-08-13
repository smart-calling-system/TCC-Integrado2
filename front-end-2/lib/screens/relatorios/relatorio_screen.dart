import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/relatorio_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/presenca.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips_bar.dart';
import '../../widgets/mini_bar_chart.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/student_avatar.dart';

/// Tela de Relatórios — filtros por período/turma/situação, gráfico,
/// lista de registros e exportação (simulada).
class RelatorioScreen extends StatelessWidget {
  const RelatorioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RelatorioController()..carregar(),
      child: const _RelatorioView(),
    );
  }
}

class _RelatorioView extends StatelessWidget {
  const _RelatorioView();

  Future<void> _exportar(BuildContext context) async {
    await context.read<RelatorioController>().exportar();
    if (context.mounted) {
      AppSnackbar.sucesso(context, AppStrings.relatorioExportado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RelatorioController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.relatorios),
        actions: [
          IconButton(
            tooltip: AppStrings.exportarSimulado,
            icon: controller.exportando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            onPressed: controller.exportando ? null : () => _exportar(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: controller.carregando
            ? const AppLoading(mensagem: AppStrings.carregando)
            : RefreshIndicator(
                onRefresh: () => context.read<RelatorioController>().carregar(),
                child: Responsive.constrained(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: Responsive.pagePadding(context),
                    children: [
                      const SectionHeader(titulo: 'Período'),
                      FilterChipsBar<PeriodoRelatorio>(
                        padding: EdgeInsets.zero,
                        selecionado: controller.periodo,
                        onSelecionar: (p) => context
                            .read<RelatorioController>()
                            .filtrarPorPeriodo(p!),
                        itens: [
                          for (final p in PeriodoRelatorio.values)
                            FilterChipItem(label: p.label, value: p),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (controller.turmasDisponiveis.isNotEmpty) ...[
                        const SectionHeader(titulo: 'Turma'),
                        FilterChipsBar<String?>(
                          padding: EdgeInsets.zero,
                          selecionado: controller.turma,
                          onSelecionar: (t) => context
                              .read<RelatorioController>()
                              .filtrarPorTurma(t),
                          itens: [
                            const FilterChipItem(label: 'Todas', value: null),
                            for (final t in controller.turmasDisponiveis)
                              FilterChipItem(label: t, value: t),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SectionHeader(titulo: 'Situação'),
                      FilterChipsBar<StatusPresenca?>(
                        padding: EdgeInsets.zero,
                        selecionado: controller.status,
                        onSelecionar: (s) => context
                            .read<RelatorioController>()
                            .filtrarPorStatus(s),
                        itens: [
                          const FilterChipItem(label: 'Todas', value: null),
                          for (final s in StatusPresenca.values)
                            FilterChipItem(label: s.label, value: s),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.totalPresentes}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: 24,
                                          color: AppColors.success,
                                        ),
                                  ),
                                  const Text('Presenças'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.totalFaltas}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: 24,
                                          color: AppColors.error,
                                        ),
                                  ),
                                  const Text('Faltas'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${controller.percentualPresenca.round()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(fontSize: 24),
                                  ),
                                  const Text('Frequência'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const SectionHeader(titulo: 'Presenças por dia'),
                      AppCard(
                        child: MiniBarChart(
                          valores: controller.serieDiaria,
                          rotulos: const [
                            'D-6',
                            'D-5',
                            'D-4',
                            'D-3',
                            'D-2',
                            'D-1',
                            'Hoje',
                          ],
                          cor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      SectionHeader(
                        titulo: 'Registros (${controller.registros.length})',
                      ),
                      const SizedBox(height: 8),
                      if (controller.registros.isEmpty)
                        const EmptyState(mensagem: AppStrings.nenhumResultado)
                      else
                        for (final registro in controller.registros)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              child: Row(
                                children: [
                                  StudentAvatar(
                                    aluno: registro.aluno,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          registro.aluno.nome,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        Text(
                                          AppFormatters.dataHora(registro.data),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: registro.status),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: AppStrings.exportarSimulado,
                        icon: Icons.ios_share,
                        variant: AppButtonVariant.outlined,
                        loading: controller.exportando,
                        onPressed: () => _exportar(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
