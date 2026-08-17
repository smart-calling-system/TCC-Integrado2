import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/recognition_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/face_frame.dart';

/// Tela de Reconhecimento Facial com Captura Direta Segura.
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

  Future<void> _capturarEReconhecer(BuildContext context) async {
    final picker = ImagePicker();
    
    // Dispara a câmera frontal do Galaxy Tab de forma nativa e estável
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile == null) return;

    final fotoReal = File(pickedFile.path);
    final controller = context.read<RecognitionController>();
    
    // Envia o arquivo de imagem para o backend Python processar
    final sucesso = await controller.simularReconhecimento(fotoReal);
    
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
                      ? 'Enviando rosto para a Inteligência Artificial...'
                      : 'Mantenha o rosto centralizado',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const Spacer(flex: 3),
                AppButton(
                  label: 'Tirar Foto e Reconhecer',
                  icon: Icons.camera_alt_outlined,
                  loading: processando,
                  onPressed: () => _capturarEReconhecer(context),
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