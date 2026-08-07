import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/aluno_form_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../models/aluno.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';

/// Tela de cadastro/edição de Aluno.
///
/// Recebe um [Aluno] opcional via argumentos de rota: quando presente,
/// o formulário abre em modo de edição.
class AlunoFormScreen extends StatelessWidget {
  final Aluno? aluno;

  const AlunoFormScreen({super.key, this.aluno});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlunoFormController(alunoParaEditar: aluno),
      child: const _AlunoFormView(),
    );
  }
}

class _AlunoFormView extends StatelessWidget {
  const _AlunoFormView();

  Future<void> _salvar(BuildContext context) async {
    final controller = context.read<AlunoFormController>();
    final sucesso = await controller.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      Navigator.of(context).pop(true);
      AppSnackbar.sucesso(context, AppStrings.cadastroSalvoComSucesso);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlunoFormController>();

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
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: controller.validarNome,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.raController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'RA (registro do aluno)',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      errorText: controller.erroRa,
                    ),
                    validator: controller.validarRa,
                  ),
                  const SizedBox(height: 16),
                  if (controller.carregandoTurmas)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: LinearProgressIndicator(),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: controller.turmaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Turma',
                        prefixIcon: Icon(Icons.class_outlined),
                      ),
                      items: [
                        for (final turma in controller.turmas)
                          DropdownMenuItem(value: turma, child: Text(turma)),
                      ],
                      onChanged:
                          context.read<AlunoFormController>().selecionarTurma,
                      validator: (valor) =>
                          valor == null ? AppStrings.campoObrigatorio : null,
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
