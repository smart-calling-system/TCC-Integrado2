import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/mock/mock_data.dart';
import '../../models/aluno.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/student_avatar.dart';

class RecognitionSuccessScreen extends StatelessWidget {
  const RecognitionSuccessScreen({super.key});

  void _voltarParaHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final args = ModalRoute.of(context)?.settings.arguments;
    final Aluno aluno = (args is Map && args['aluno'] is Aluno)
        ? args['aluno'] as Aluno
        : MockData.alunoPadrao;
    final DateTime horario = (args is Map && args['horario'] is DateTime)
        ? args['horario'] as DateTime
        : DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: Responsive.constrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, valor, child) =>
                      Transform.scale(scale: valor, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.entradaRegistrada,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hoje as ${AppFormatters.horaCompleta(horario)}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      StudentAvatar(aluno: aluno, size: 88),
                      const SizedBox(height: 16),
                      Text(
                        aluno.nome,
                        style: textTheme.titleLarge?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoItem(rotulo: 'RA', valor: aluno.ra),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(context).dividerTheme.color,
                          ),
                          Expanded(
                            child: _InfoItem(
                              rotulo: 'Turma',
                              valor: aluno.turma,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                AppButton(
                  label: AppStrings.voltar,
                  icon: Icons.home_outlined,
                  onPressed: () => _voltarParaHome(context),
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

class _InfoItem extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _InfoItem({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(rotulo, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          valor,
          style: textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
