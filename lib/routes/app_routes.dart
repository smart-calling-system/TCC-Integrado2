import 'package:flutter/material.dart';

import '../models/aluno.dart';
import '../models/disciplina.dart';
import '../models/turma.dart';
import '../screens/alunos/aluno_form_screen.dart';
import '../screens/alunos/aluno_list_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/disciplinas/disciplina_form_screen.dart';
import '../screens/disciplinas/disciplina_list_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/recognition/recognition_error_screen.dart';
import '../screens/recognition/recognition_screen.dart';
import '../screens/recognition/recognition_success_screen.dart';
import '../screens/relatorios/relatorio_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/sync/sync_screen.dart';
import '../screens/turmas/turma_form_screen.dart';
import '../screens/turmas/turma_list_screen.dart';

/// Rotas nomeadas do aplicativo.
///
/// Toda a navegação passa por aqui, o que centraliza os nomes das rotas,
/// os argumentos e as transições animadas entre telas.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String esqueciSenha = '/esqueci-senha';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String alunos = '/alunos';
  static const String alunoForm = '/alunos/form';
  static const String turmas = '/turmas';
  static const String turmaForm = '/turmas/form';
  static const String disciplinas = '/disciplinas';
  static const String disciplinaForm = '/disciplinas/form';
  static const String reconhecimento = '/reconhecimento';
  static const String reconhecimentoSucesso = '/reconhecimento/sucesso';
  static const String reconhecimentoErro = '/reconhecimento/erro';
  static const String historico = '/historico';
  static const String relatorios = '/relatorios';
  static const String sincronizacao = '/sincronizacao';
  static const String configuracoes = '/configuracoes';
  static const String perfil = '/perfil';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen(), settings);
      case login:
        return _fade(const LoginScreen(), settings);
      case esqueciSenha:
        return _slide(const ForgotPasswordScreen(), settings);
      case dashboard:
        return _fade(const DashboardScreen(), settings);
      case home:
        return _fade(const HomeScreen(), settings);
      case alunos:
        return _slide(const AlunoListScreen(), settings);
      case alunoForm:
        return _slideUp(
          AlunoFormScreen(aluno: settings.arguments as Aluno?),
          settings,
        );
      case turmas:
        return _slide(const TurmaListScreen(), settings);
      case turmaForm:
        return _slideUp(
          TurmaFormScreen(turma: settings.arguments as Turma?),
          settings,
        );
      case disciplinas:
        return _slide(const DisciplinaListScreen(), settings);
      case disciplinaForm:
        return _slideUp(
          DisciplinaFormScreen(disciplina: settings.arguments as Disciplina?),
          settings,
        );
      case reconhecimento:
        return _slideUp(const RecognitionScreen(), settings);
      case reconhecimentoSucesso:
        return _fade(const RecognitionSuccessScreen(), settings);
      case reconhecimentoErro:
        return _fade(const RecognitionErrorScreen(), settings);
      case historico:
        return _slide(const HistoryScreen(), settings);
      case relatorios:
        return _slide(const RelatorioScreen(), settings);
      case sincronizacao:
        return _slide(const SyncScreen(), settings);
      case configuracoes:
        return _slide(const SettingsScreen(), settings);
      case perfil:
        return _slide(const ProfileScreen(), settings);
      default:
        return _fade(const LoginScreen(), settings);
    }
  }

  /// Transição de fade (telas de resultado, splash e login).
  static PageRouteBuilder _fade(Widget page, RouteSettings settings) =>
      PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      );

  /// Transição horizontal padrão (navegação entre seções).
  static PageRouteBuilder _slide(Widget page, RouteSettings settings) =>
      PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curva =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curva),
            child: FadeTransition(opacity: curva, child: child),
          );
        },
      );

  /// Transição vertical (abertura de formulários e do fluxo de
  /// reconhecimento).
  static PageRouteBuilder _slideUp(Widget page, RouteSettings settings) =>
      PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curva =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curva),
            child: FadeTransition(opacity: curva, child: child),
          );
        },
      );
}
