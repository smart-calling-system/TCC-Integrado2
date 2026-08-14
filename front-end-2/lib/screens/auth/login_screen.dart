import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/login_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

/// Tela de Login — autenticação do usuário.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          LoginController(authProvider: context.read<AuthProvider>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  Future<void> _entrar(BuildContext context) async {
    final controller = context.read<LoginController>();
    final sucesso = await controller.entrar();
    if (!context.mounted) return;
    if (sucesso) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Responsive.constrained(
          child: SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Entre para gerenciar as presenças da sua escola',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: controller.validarEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.senhaController,
                    obscureText: !controller.senhaVisivel,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _entrar(context),
                    decoration: InputDecoration(
                      labelText: AppStrings.senha,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.senhaVisivel
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: context
                            .read<LoginController>()
                            .alternarVisibilidadeSenha,
                      ),
                    ),
                    validator: controller.validarSenha,
                  ),

                  if (controller.erro != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.erro!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ],

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.esqueciSenha),
                      child: const Text(AppStrings.esqueciSenha),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: AppStrings.entrar,
                    loading: controller.carregando,
                    onPressed: () => _entrar(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}