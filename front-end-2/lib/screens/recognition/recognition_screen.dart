import 'dart:io'; // 👇 Import necessário para o arquivo fantasma
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/recognition_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/face_frame.dart';

/// Tela de Reconhecimento Facial (simulação — sem câmera real).
///
/// Exibe o círculo de enquadramento animado e o botão que dispara a
/// simulação. O resultado direciona para a tela de sucesso ou de erro.
class RecognitionScreen extends StatelessWidget {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecognitionController(),
      child: const _RecognitionView(),
    );
  }
}

class _RecognitionView extends StatelessWidget {
  const _RecognitionView();

  Future<void> _simular(BuildContext context) async {
    final controller = context.read<RecognitionController>();
    
    // 👇 A MÁGICA SALVADORA: Criamos um arquivo falso só pro Flutter compilar.
    // Depois, para o TCC ficar 100%, você pode usar o pacote 'image_picker' 
    // para trocar esse arquivo fantasma pela câmera real do celular!
    final arquivoFantasma = File('foto_fake.jpg');
    
    final sucesso = await controller.simularReconhecimento(arquivoFantasma);
    if (!context.mounted) return;

    if (sucesso) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.reconhecimentoSucesso,
        arguments: {
          'aluno': controller.alunoReconhecido,
          'horario': controller.horarioRegistro,
        },
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.reconhecimentoErro);
    }
  }

  @override
  Widget build(BuildContext context) {
    final processando = context.watch<RecognitionController>().processando;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: processando ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reconhecimento Facial',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Responsive.constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Círculo de enquadramento (simulação da câmera).
                FaceFrame(
                  size: Responsive.isTablet(context) ? 320 : 260,
                  processando: processando,
                ),
                const SizedBox(height: 40),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    processando
                        ? AppStrings.analisandoRosto
                        : AppStrings.posicioneSeuRosto,
                    key: ValueKey(processando),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  processando
                      ? 'Comparando com a base de alunos...'
                      : 'Mantenha o rosto dentro do círculo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const Spacer(flex: 3),
                AppButton(
                  label: AppStrings.simularReconhecimento,
                  icon: Icons.center_focus_strong_outlined,
                  loading: processando,
                  onPressed: () => _simular(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}