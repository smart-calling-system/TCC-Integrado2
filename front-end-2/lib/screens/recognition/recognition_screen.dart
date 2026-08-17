import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../../controllers/recognition_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/face_frame.dart';

/// Tela de Reconhecimento Facial Ao Vivo Integrada com Python!
class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _inicializarCameraAoVivo();
  }

  // 👇 LIGANDO A CÂMERA FRONTAL ASSIM QUE A TELA ABRE
  Future<void> _inicializarCameraAoVivo() async {
    try {
      final cameras = await availableCameras();
      
      // Pega a câmera frontal do Galaxy Tab
      final cameraFrontal = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        cameraFrontal,
        ResolutionPreset.high, // Alta resolução para a IA enxergar os detalhes
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Erro ao iniciar a câmera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // 👇 O GATILHO QUE "PUXA" O FRAME SILENCIOSAMENTE E MANDA PRO PYTHON
  Future<void> _capturarEReconhecer(BuildContext context) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final controller = context.read<RecognitionController>();
    
    try {
      // 👇 TEMPO PARA O FOCO AUTOMÁTICO DO TABLET (1 segundo)
      await Future.delayed(const Duration(seconds: 1));

      // Captura o frame atual da tela
      final xfile = await _cameraController!.takePicture();
      final fotoReal = File(xfile.path);

      // Envia os bytes pro backend processar
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
        // 👇 A MÁGICA ACONTECE AQUI! 
        // Em vez de erro, mandamos a foto para a tela de vínculo!
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.vincularAluno, // Precisamos garantir que essa rota exista
          arguments: {
            'fotoPath': fotoReal.path, // Passamos o caminho da foto
          },
        );
      }
    } catch (e) {
      debugPrint('Erro ao capturar foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecognitionController(),
      child: Consumer<RecognitionController>(
        builder: (context, controller, child) {
          final processando = controller.processando;

          return Scaffold(
            backgroundColor: Colors.black, // Fundo escuro atrás de tudo
            body: Stack(
              children: [
                // -----------------------------------------------------
                // 1. O FEED DA CÂMERA AO VIVO NO FUNDO
                // -----------------------------------------------------
                if (_isCameraInitialized && _cameraController != null)
                  Positioned.fill(
                    child: CameraPreview(_cameraController!),
                  )
                else
                  const Center(child: CircularProgressIndicator(color: Colors.white)),

                // -----------------------------------------------------
                // 2. MÁSCARA ESCURA PARA DAR DESTAQUE AO ROSTO
                // -----------------------------------------------------
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6), // Filtro fumê
                  ),
                ),

                // -----------------------------------------------------
                // 3. INTERFACE DE SCANNER POR CIMA
                // -----------------------------------------------------
                SafeArea(
                  child: Responsive.constrained(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: processando ? null : () => Navigator.of(context).pop(),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Terminal de Presença',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(flex: 2),
                        
                        // O Círculo animado da IA
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
                              ? 'Processando match facial na IA...'
                              : 'Mantenha o rosto dentro do círculo',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(flex: 3),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: AppButton(
                            label: 'Escanear e Marcar Presença', 
                            icon: Icons.document_scanner_outlined,
                            loading: processando,
                            onPressed: () => _capturarEReconhecer(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}