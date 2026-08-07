import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/forgot_password_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

/// Tela "Esqueci minha senha" — envio simulado de link de recuperação.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordController(
        authProvider: context.read<AuthProvider>(),
      ),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ForgotPasswordController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.recuperarSenha)),
      body: SafeArea(
        child: Responsive.constrained(
          child: SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: controller.enviado
                ? _Sucesso(email: controller.emailController.text)
                : Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Icon(Icons.lock_reset,
                            size: 56, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Informe o e-mail cadastrado para receber o link '
                          'de recuperação de senha.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: AppStrings.email,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: controller.validarEmail,
                        ),
                        if (controller.erro != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            controller.erro!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        AppButton(
                          label: AppStrings.enviarLinkRecuperacao,
                          loading: controller.carregando,
                          onPressed: () =>
                              context.read<ForgotPasswordController>().enviar(),
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

class _Sucesso extends StatelessWidget {
  final String email;
  const _Sucesso({required this.email});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.mark_email_read_outlined,
              size: 64, color: AppColors.success),
          const SizedBox(height: 20),
          Text(
            AppStrings.emailRecuperacaoEnviado,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            email,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          AppButton(
            label: AppStrings.voltar,
            variant: AppButtonVariant.outlined,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
