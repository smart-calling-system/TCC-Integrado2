import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/turma_form_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../models/turma.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';

/// Tela de cadastro/edição de Turma.
class TurmaFormScreen extends StatelessWidget {
  final Turma? turma;

  const TurmaFormScreen({super.key, this.turma});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TurmaFormController(turmaParaEditar: turma),
      child: const _TurmaFormView(),
    );
  }
}

class _TurmaFormView extends StatelessWidget {
  const _TurmaFormView();

  Future<void> _salvar(BuildContext context) async {
    final controller = context.read<TurmaFormController>();
    final sucesso = await controller.salvar();
    if (!context.mounted) return;
    if (sucesso) {
      Navigator.of(context).pop(true);
      AppSnackbar.sucesso(context, AppStrings.cadastroSalvoComSucesso);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TurmaFormController>();

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
                    decoration: const InputDecoration(
                      labelText: 'Nome da turma (ex.: 3º DS)',
                      prefixIcon: Icon(Icons.class_outlined),
                    ),
                    validator: controller.validarObrigatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.serieController,
                    decoration: const InputDecoration(
                      labelText: 'Série',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: controller.validarObrigatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.salaController,
                    decoration: const InputDecoration(
                      labelText: 'Sala',
                      prefixIcon: Icon(Icons.meeting_room_outlined),
                    ),
                    validator: controller.validarObrigatorio,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TurnoTurma>(
                    value: controller.turno,
                    decoration: const InputDecoration(
                      labelText: 'Turno',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    items: [
                      for (final turno in TurnoTurma.values)
                        DropdownMenuItem(value: turno, child: Text(turno.label)),
                    ],
                    onChanged:
                        context.read<TurmaFormController>().selecionarTurno,
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
