import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/vincular_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';

class VincularAlunoScreen extends StatelessWidget {
  const VincularAlunoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final fotoPath = args?['fotoPath'] as String?;

    if (fotoPath == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(child: Text('Erro: Nenhuma foto encontrada.', style: TextStyle(color: Colors.white))),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => VincularController(),
      child: _VincularAlunoView(foto: File(fotoPath)),
    );
  }
}

class _VincularAlunoView extends StatelessWidget {
  final File foto;
  
  const _VincularAlunoView({required this.foto});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VincularController>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Vincular Novo Rosto', style: TextStyle(fontSize: 18)),
      ),
      // 👇 USAMOS SafeArea e LayoutBuilder/SingleChildScrollView para liberar o SCROLL PERFEITO!
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Rosto Não Reconhecido',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Identificamos uma nova face. Selecione no banco de dados a qual aluno ela pertence.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      
                      // A Foto Capturada (Tamanho otimizado para não estourar a tela)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            foto,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dropdown de Alunos
                      if (controller.carregandoAlunos)
                        const Center(child: CircularProgressIndicator(color: Colors.white))
                      else if (controller.alunos.isEmpty)
                        const Center(child: Text('Nenhum aluno encontrado no Banco de Dados.', style: TextStyle(color: Colors.white70)))
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: AppColors.darkBackground,
                              isExpanded: true,
                              hint: const Text('Selecione o Aluno da Turma', style: TextStyle(color: Colors.white54)),
                              value: controller.alunoSelecionado,
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              items: controller.alunos.map((aluno) {
                                return DropdownMenuItem<String>(
                                  value: aluno['nome'], 
                                  child: Text(aluno['nome']!),
                                );
                              }).toList(),
                              onChanged: controller.processando ? null : controller.selecionarAluno,
                            ),
                          ),
                        ),
                        
                      const Spacer(), // Empurra o botão para baixo de forma inteligente com o scroll livre
                      const SizedBox(height: 24),

                      // Botão de Enviar
                      AppButton(
                        label: 'Cadastrar no Banco Facial',
                        icon: Icons.save_alt_rounded,
                        loading: controller.processando,
                        onPressed: controller.alunoSelecionado == null || controller.carregandoAlunos
                          ? null 
                          : () async {
                              final sucesso = await controller.vincularRostoNoPython(foto);
                              if (context.mounted) {
                                if (sucesso) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Rosto vinculado com sucesso!'), backgroundColor: Colors.green),
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Erro ao salvar rosto no servidor.'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}