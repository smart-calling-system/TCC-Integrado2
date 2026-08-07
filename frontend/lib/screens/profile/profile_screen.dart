import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/helpers/logout_helper.dart';
import '../../widgets/section_header.dart';

/// Tela de Perfil — editar dados pessoais, trocar senha (fake) e sair.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ProfileController(authProvider: context.read<AuthProvider>()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _salvarPerfil(BuildContext context) async {
    final sucesso = await context.read<ProfileController>().salvarPerfil();
    if (context.mounted && sucesso) {
      AppSnackbar.sucesso(context, 'Perfil atualizado com sucesso');
    }
  }

  Future<void> _trocarSenha(BuildContext context) async {
    final sucesso = await context.read<ProfileController>().trocarSenha();
    if (context.mounted && sucesso) {
      AppSnackbar.sucesso(context, 'Senha alterada com sucesso');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.perfil)),
      body: SafeArea(
        child: Responsive.constrained(
          child: ListView(
            padding: Responsive.pagePadding(context),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    usuario?.iniciais ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  usuario?.cargo.name ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(titulo: 'Dados pessoais'),
              AppCard(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: controller.nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: controller.validarObrigatorio,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: AppStrings.email,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: controller.validarEmail,
                      ),
                      const SizedBox(height: 18),
                      AppButton(
                        label: AppStrings.salvar,
                        loading: controller.salvandoPerfil,
                        onPressed: () => _salvarPerfil(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(titulo: 'Alterar senha'),
              AppCard(
                child: Form(
                  key: controller.formSenhaKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: controller.senhaAtualController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha atual',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: controller.validarObrigatorio,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: controller.novaSenhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Nova senha',
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                        ),
                        validator: controller.validarObrigatorio,
                      ),
                      if (controller.erroSenha != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          controller.erroSenha!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 18),
                      AppButton(
                        label: 'Trocar senha',
                        variant: AppButtonVariant.outlined,
                        loading: controller.trocandoSenha,
                        onPressed: () => _trocarSenha(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: TextButton.icon(
                  onPressed: () => confirmarELogout(context),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    AppStrings.sair,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
