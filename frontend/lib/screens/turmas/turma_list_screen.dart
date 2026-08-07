import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/turma_list_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/turma.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';

/// Tela de listagem de Turmas — busca, cadastro, edição e exclusão.
class TurmaListScreen extends StatelessWidget {
  const TurmaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TurmaListController()..carregar(),
      child: const _TurmaListView(),
    );
  }
}

class _TurmaListView extends StatelessWidget {
  const _TurmaListView();

  Future<void> _remover(BuildContext context, Turma turma) async {
    final confirmou = await AppDialog.confirmar(
      context,
      titulo: AppStrings.confirmarExclusaoTitulo,
      mensagem: 'Deseja realmente excluir a turma "${turma.nome}"?',
      textoConfirmar: AppStrings.excluir,
    );
    if (!confirmou || !context.mounted) return;
    await context.read<TurmaListController>().remover(turma.id);
    if (context.mounted) {
      AppSnackbar.sucesso(context, AppStrings.registroExcluidoComSucesso);
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {Turma? turma}) async {
    final salvou = await Navigator.of(context)
        .pushNamed(AppRoutes.turmaForm, arguments: turma);
    if (salvou == true && context.mounted) {
      context.read<TurmaListController>().carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TurmaListController>();
    final tablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.turmas)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.novo),
      ),
      body: SafeArea(
        child: Responsive.constrained(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context).horizontal / 2,
                  12,
                  Responsive.pagePadding(context).horizontal / 2,
                  8,
                ),
                child: AppInput(
                  hint: AppStrings.buscar,
                  icon: Icons.search,
                  onChanged: controller.buscar,
                ),
              ),
              Expanded(
                child: controller.carregando
                    ? const AppLoading(mensagem: AppStrings.carregando)
                    : controller.turmas.isEmpty
                        ? EmptyState(
                            mensagem: AppStrings.nenhumResultado,
                            acao: TextButton.icon(
                              onPressed: () => _abrirFormulario(context),
                              icon: const Icon(Icons.add),
                              label: const Text(AppStrings.novo),
                            ),
                          )
                        : tablet
                            ? _TabelaTurmas(
                                turmas: controller.turmas,
                                onEditar: (t) =>
                                    _abrirFormulario(context, turma: t),
                                onExcluir: (t) => _remover(context, t),
                              )
                            : _ListaTurmas(
                                turmas: controller.turmas,
                                onEditar: (t) =>
                                    _abrirFormulario(context, turma: t),
                                onExcluir: (t) => _remover(context, t),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaTurmas extends StatelessWidget {
  final List<Turma> turmas;
  final ValueChanged<Turma> onEditar;
  final ValueChanged<Turma> onExcluir;

  const _ListaTurmas({
    required this.turmas,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: Responsive.pagePadding(context),
      itemCount: turmas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final turma = turmas[index];
        return AppCard(
          onTap: () => onEditar(turma),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.class_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(turma.nome, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${turma.serie} • ${turma.turno.label} • ${turma.sala}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppStrings.excluir,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onExcluir(turma),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabelaTurmas extends StatelessWidget {
  final List<Turma> turmas;
  final ValueChanged<Turma> onEditar;
  final ValueChanged<Turma> onExcluir;

  const _TabelaTurmas({
    required this.turmas,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: AppTable(
        colunas: const [
          AppTableColumn('Turma'),
          AppTableColumn('Série'),
          AppTableColumn('Turno'),
          AppTableColumn('Sala'),
          AppTableColumn('Ações'),
        ],
        linhas: [
          for (final turma in turmas)
            [
              Text(turma.nome),
              Text(turma.serie),
              Text(turma.turno.label),
              Text(turma.sala),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: AppStrings.editar,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => onEditar(turma),
                  ),
                  IconButton(
                    tooltip: AppStrings.excluir,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => onExcluir(turma),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}
