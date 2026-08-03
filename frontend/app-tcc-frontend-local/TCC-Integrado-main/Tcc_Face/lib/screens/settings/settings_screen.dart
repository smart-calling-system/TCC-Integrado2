import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/section_header.dart';

/// Tela de Configurações — tema, idioma, versão e sobre o sistema.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _selecionarIdioma(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.idioma),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: RadioGroup<String>(
          groupValue: localeProvider.idioma,
          onChanged: (valor) {
            if (valor == null) return;
            localeProvider.selecionarIdioma(valor);
            Navigator.of(dialogContext).pop();
            // Seleção apenas visual nesta etapa do projeto.
            AppSnackbar.info(context, 'Idioma selecionado: $valor');
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final idioma in LocaleProvider.idiomasDisponiveis)
                RadioListTile<String>(
                  title: Text(idioma),
                  value: idioma,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarSobre(BuildContext context) {
    AppDialog.info(
      context,
      titulo: AppConstants.appName,
      icone: Icons.face_retouching_natural,
      conteudo: Text(
        '${AppConstants.appFullName}.\n\n'
        'Aplicativo utilizado nos tablets da escola para registrar a '
        'entrada e a saída dos alunos por reconhecimento facial, com '
        'suporte a operação offline e sincronização automática.\n\n'
        'Versão ${AppConstants.appVersion}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.configuracoes)),
      body: SafeArea(
        child: Responsive.constrained(
          child: ListView(
            padding: Responsive.pagePadding(context),
            children: [
              const SectionHeader(titulo: 'Aparência'),
              AppCard(
                padding: EdgeInsets.zero,
                child: SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: scheme.primary,
                  ),
                  title: const Text(AppStrings.temaEscuro),
                  subtitle: Text(
                    themeProvider.isDark ? 'Ativado' : 'Desativado',
                  ),
                  value: themeProvider.isDark,
                  onChanged: themeProvider.alternarTema,
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(titulo: 'Preferências'),
              AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(Icons.language, color: scheme.primary),
                  title: const Text(AppStrings.idioma),
                  subtitle: Text(localeProvider.idioma),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selecionarIdioma(context),
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(titulo: 'Sistema'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.verified_outlined,
                        color: scheme.primary,
                      ),
                      title: const Text(AppStrings.versao),
                      trailing: Text(
                        AppConstants.appVersion,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: scheme.primary,
                      ),
                      title: const Text(AppStrings.sobreOSistema),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _mostrarSobre(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
