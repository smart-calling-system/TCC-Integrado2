import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/disciplina_list_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../models/disciplina.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';

/// Tela de listagem de Disciplinas — busca, cadastro, edição e exclusão.
class DisciplinaListScreen extends StatelessWidget {
  const DisciplinaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DisciplinaListController()..carregar(),
      child: const _DisciplinaListView(),
    );
  }
}

class _DisciplinaListView extends StatelessWidget {
  const _DisciplinaListView();

  Future<void> _remover(BuildContext context, Disciplina disciplina) async {
    final confirmou = await AppDialog.confirmar(
      context,
      titulo: AppStrings.confirmarExclusaoTitulo,
      mensagem: 'Deseja realmente excluir a disciplina "${disciplina.nome}"?',
      textoConfirmar: AppStrings.excluir,
    );
    if (!confirmou || !context.mounted) return;
    await context.read<DisciplinaListController>().remover(disciplina.id);
    if (context.mounted) {
      AppSnackbar.sucesso(context, AppStrings.registroExcluidoComSucesso);
    }
  }

  Future<void> _abrirFormulario(
    BuildContext context, {
    Disciplina? disciplina,
  }) async {
    final salvou = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.disciplinaForm, arguments: disciplina);
    if (salvou == true && context.mounted) {
      context.read<DisciplinaListController>().carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DisciplinaListController>();
    final tablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.disciplinas)),
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
                    : controller.disciplinas.isEmpty
                    ? EmptyState(
                        mensagem: AppStrings.nenhumResultado,
                        acao: TextButton.icon(
                          onPressed: () => _abrirFormulario(context),
                          icon: const Icon(Icons.add),
                          label: const Text(AppStrings.novo),
                        ),
                      )
                    : tablet
                    ? _TabelaDisciplinas(
                        disciplinas: controller.disciplinas,
                        onEditar: (d) =>
                            _abrirFormulario(context, disciplina: d),
                        onExcluir: (d) => _remover(context, d),
                      )
                    : _ListaDisciplinas(
                        disciplinas: controller.disciplinas,
                        onEditar: (d) =>
                            _abrirFormulario(context, disciplina: d),
                        onExcluir: (d) => _remover(context, d),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaDisciplinas extends StatelessWidget {
  final List<Disciplina> disciplinas;
  final ValueChanged<Disciplina> onEditar;
  final ValueChanged<Disciplina> onExcluir;

  const _ListaDisciplinas({
    required this.disciplinas,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: Responsive.pagePadding(context),
      itemCount: disciplinas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final disciplina = disciplinas[index];
        return AppCard(
          onTap: () => onEditar(disciplina),
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
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disciplina.nome,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${disciplina.professor} • ${disciplina.cargaHoraria}h',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: AppStrings.excluir,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onExcluir(disciplina),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabelaDisciplinas extends StatelessWidget {
  final List<Disciplina> disciplinas;
  final ValueChanged<Disciplina> onEditar;
  final ValueChanged<Disciplina> onExcluir;

  const _TabelaDisciplinas({
    required this.disciplinas,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: AppTable(
        colunas: const [
          AppTableColumn('Disciplina'),
          AppTableColumn('Professor'),
          AppTableColumn('Carga horária', numerica: true),
          AppTableColumn('Ações'),
        ],
        linhas: [
          for (final disciplina in disciplinas)
            [
              Text(disciplina.nome),
              Text(disciplina.professor),
              Text('${disciplina.cargaHoraria}h'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: AppStrings.editar,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => onEditar(disciplina),
                  ),
                  IconButton(
                    tooltip: AppStrings.excluir,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => onExcluir(disciplina),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}
