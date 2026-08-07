import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/disciplina_form_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../models/disciplina.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';

/// Tela de cadastro/edição de Disciplina.
class DisciplinaFormScreen extends StatelessWidget {
  final Disciplina? disciplina;

  const DisciplinaFormScreen({super.key, this.disciplina});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DisciplinaFormController(disciplinaParaEditar: disciplina),
      child: const _DisciplinaFormView(),
    );
  }
}

class _DisciplinaFormView extends StatelessWidget {
  const _DisciplinaFormView();

  Future<void> _salvar(BuildContext context) async {
    final controller = context.read<DisciplinaFormController>();
    final sucesso = await controller.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      Navigator.of(context).pop(true);
      AppSnackbar.sucesso(context, AppStrings.cadastroSalvoComSucesso);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DisciplinaFormController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.emEdicao ? AppStrings.editar : AppStrings.novo),
      ),
      body: SafeArea(
        child: Responsive.constrained(
          child: SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: controller.nomeController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome da disciplina',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: controller.validarObrigatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.professorController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Professor(a) responsável',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: controller.validarObrigatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.cargaHorariaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Carga horária (horas)',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    validator: controller.validarCargaHoraria,
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: AppStrings.salvar,
                    icon: Icons.check,
                    loading: controller.salvando,
                    onPressed: () => _salvar(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
