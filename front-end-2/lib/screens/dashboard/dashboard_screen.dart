import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/dashboard_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/mini_bar_chart.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';

/// Dashboard — indicadores gerais, acesso rápido às seções e gráfico
/// mockado de presenças da semana. Tela inicial pós-login.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController()..carregar(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    final usuario = context.watch<AuthProvider>().usuario;
    final textTheme = Theme.of(context).textTheme;
    final tablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dashboard)),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: controller.carregando || controller.resumo == null
            ? const AppLoading(mensagem: AppStrings.carregando)
            : RefreshIndicator(
                onRefresh: () => context.read<DashboardController>().carregar(),
                child: Responsive.constrained(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: Responsive.pagePadding(context),
                    children: [
                      Text(
                        '${AppStrings.bemVindo}, '
                        '${usuario?.nome.split(' ').first ?? ''}!',
                        style: textTheme.headlineMedium?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appFullName,
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),

                      // ---------------------------------------- Indicadores
                      GridView.count(
                        crossAxisCount: tablet ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: tablet ? 1.3 : 1.15,
                        children: [
                          StatCard(
                            icone: Icons.groups_outlined,
                            valor: '${controller.resumo!.totalAlunos}',
                            rotulo: AppStrings.alunos,
                            cor: AppColors.primary,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.alunos),
                          ),
                          StatCard(
                            icone: Icons.class_outlined,
                            valor: '${controller.resumo!.totalTurmas}',
                            rotulo: AppStrings.turmas,
                            cor: AppColors.primaryDark,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.turmas),
                          ),
                          StatCard(
                            icone: Icons.check_circle_outline,
                            valor: '${controller.resumo!.presentesHoje}',
                            rotulo: 'Presentes hoje',
                            cor: AppColors.success,
                          ),
                          StatCard(
                            icone: Icons.cancel_outlined,
                            valor: '${controller.resumo!.faltasHoje}',
                            rotulo: 'Faltas hoje',
                            cor: AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ---------------------------------------- Frequência
                      AppCard(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value:
                                        controller.resumo!.frequenciaMedia /
                                        100,
                                    strokeWidth: 6,
                                    backgroundColor: AppColors.border,
                                    color: AppColors.success,
                                  ),
                                  Text(
                                    '${controller.resumo!.frequenciaMedia.round()}%',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Frequência média de hoje',
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${controller.resumo!.atrasadosHoje} '
                                    'aluno(s) chegaram atrasados',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---------------------------------------- Gráfico
                      const SectionHeader(
                        titulo: 'Presenças nos últimos 7 dias',
                      ),
                      AppCard(
                        child: MiniBarChart(
                          valores: controller.resumo!.presencasUltimos7Dias,
                          rotulos: const [
                            'Seg',
                            'Ter',
                            'Qua',
                            'Qui',
                            'Sex',
                            'Sáb',
                            'Dom',
                          ],
                          cor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---------------------------------------- Acessos rápidos
                      const SectionHeader(titulo: 'Acessos rápidos'),
                      GridView.count(
                        crossAxisCount: tablet ? 3 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _AcessoRapido(
                            icone: Icons.menu_book_outlined,
                            titulo: AppStrings.disciplinas,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.disciplinas),
                          ),
                          _AcessoRapido(
                            icone: Icons.bar_chart_outlined,
                            titulo: AppStrings.relatorios,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.relatorios),
                          ),
                          _AcessoRapido(
                            icone: Icons.face_outlined,
                            titulo: AppStrings.reconhecimentoFacial,
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.reconhecimento),
                          ),
                        ],
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

class _AcessoRapido extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _AcessoRapido({
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icone, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
