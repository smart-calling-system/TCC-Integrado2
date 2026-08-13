import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

/// Tela de Erro do reconhecimento — face não reconhecida.
class RecognitionErrorScreen extends StatelessWidget {
  const RecognitionErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Responsive.constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Ícone de erro com animação de escala.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, valor, child) =>
                      Transform.scale(scale: valor, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.errorSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.face_retouching_off_outlined,
                      color: AppColors.error,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.faceNaoReconhecida,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Não foi possível identificar o aluno.\nVerifique o enquadramento e a iluminação.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const Spacer(flex: 3),
                AppButton(
                  label: AppStrings.tentarNovamente,
                  icon: Icons.refresh,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.reconhecimento),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: AppStrings.voltarAoInicio,
                  variant: AppButtonVariant.outlined,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
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
