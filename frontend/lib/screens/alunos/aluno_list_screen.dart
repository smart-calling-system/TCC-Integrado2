import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/aluno_list_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../models/aluno.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_table.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips_bar.dart';
import '../../widgets/student_avatar.dart';

/// Tela de listagem de Alunos — busca, filtro por turma, cadastro,
/// edição e exclusão (com confirmação).
class AlunoListScreen extends StatelessWidget {
  const AlunoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlunoListController()..carregar(),
      child: const _AlunoListView(),
    );
  }
}

class _AlunoListView extends StatelessWidget {
  const _AlunoListView();

  Future<void> _remover(BuildContext context, Aluno aluno) async {
    final confirmou = await AppDialog.confirmar(
      context,
      titulo: AppStrings.confirmarExclusaoTitulo,
      mensagem: 'Deseja realmente excluir "${aluno.nome}"? Esta ação não '
          'pode ser desfeita.',
      textoConfirmar: AppStrings.excluir,
    );
    if (!confirmou || !context.mounted) return;
    await context.read<AlunoListController>().remover(aluno.id);
    if (context.mounted) {
      AppSnackbar.sucesso(context, AppStrings.registroExcluidoComSucesso);
    }
  }

  Future<void> _abrirFormulario(BuildContext context, {Aluno? aluno}) async {
    final salvou = await Navigator.of(context).pushNamed(
      AppRoutes.alunoForm,
      arguments: aluno,
    );
    if (salvou == true && context.mounted) {
      context.read<AlunoListController>().carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlunoListController>();
    final tablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.alunos)),
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
                  0,
                ),
                child: AppInput(
                  hint: AppStrings.buscar,
                  icon: Icons.search,
                  onChanged: controller.buscar,
                ),
              ),
              const SizedBox(height: 12),
              if (controller.turmasDisponiveis.isNotEmpty)
                FilterChipsBar<String?>(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.pagePadding(context).horizontal / 2,
                  ),
                  selecionado: controller.filtroTurma,
                  onSelecionar: controller.filtrarPorTurma,
                  itens: [
                    const FilterChipItem(label: 'Todas as turmas', value: null),
                    for (final turma in controller.turmasDisponiveis)
                      FilterChipItem(label: turma, value: turma),
                  ],
                ),
              const SizedBox(height: 4),
              Expanded(
                child: controller.carregando
                    ? const AppLoading(mensagem: AppStrings.carregando)
                    : controller.alunos.isEmpty
                        ? EmptyState(
                            mensagem: AppStrings.nenhumResultado,
                            acao: TextButton.icon(
                              onPressed: () => _abrirFormulario(context),
                              icon: const Icon(Icons.add),
                              label: const Text(AppStrings.novo),
                            ),
                          )
                        : tablet
                            ? _TabelaAlunos(
                                alunos: controller.alunos,
                                onEditar: (a) =>
                                    _abrirFormulario(context, aluno: a),
                                onExcluir: (a) => _remover(context, a),
                              )
                            : _ListaAlunos(
                                alunos: controller.alunos,
                                onEditar: (a) =>
                                    _abrirFormulario(context, aluno: a),
                                onExcluir: (a) => _remover(context, a),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaAlunos extends StatelessWidget {
  final List<Aluno> alunos;
  final ValueChanged<Aluno> onEditar;
  final ValueChanged<Aluno> onExcluir;

  const _ListaAlunos({
    required this.alunos,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: Responsive.pagePadding(context),
      itemCount: alunos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final aluno = alunos[index];
        return Dismissible(
          key: ValueKey(aluno.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            onExcluir(aluno);
            return false; // A remoção real é feita pelo controller.
          },
          child: AppCard(
            onTap: () => onEditar(aluno),
            child: Row(
              children: [
                StudentAvatar(aluno: aluno),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(aluno.nome,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text('RA ${aluno.ra} • ${aluno.turma}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.editar,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEditar(aluno),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabelaAlunos extends StatelessWidget {
  final List<Aluno> alunos;
  final ValueChanged<Aluno> onEditar;
  final ValueChanged<Aluno> onExcluir;

  const _TabelaAlunos({
    required this.alunos,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: AppTable(
        colunas: const [
          AppTableColumn('Aluno'),
          AppTableColumn('RA'),
          AppTableColumn('Turma'),
          AppTableColumn('Ações'),
        ],
        linhas: [
          for (final aluno in alunos)
            [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StudentAvatar(aluno: aluno, size: 36),
                  const SizedBox(width: 10),
                  Text(aluno.nome),
                ],
              ),
              Text(aluno.ra),
              Text(aluno.turma),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: AppStrings.editar,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => onEditar(aluno),
                  ),
                  IconButton(
                    tooltip: AppStrings.excluir,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => onExcluir(aluno),
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }
}
