import 'package:flutter/material.dart';

import '../screens/history/history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/recognition/recognition_error_screen.dart';
import '../screens/recognition/recognition_screen.dart';
import '../screens/recognition/recognition_success_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/sync/sync_screen.dart';

/// Rotas nomeadas do aplicativo.
///
/// Toda a navegação passa por aqui, o que centraliza os nomes das rotas,
/// os argumentos e as transições animadas entre telas.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String reconhecimento = '/reconhecimento';
  static const String reconhecimentoSucesso = '/reconhecimento/sucesso';
  static const String reconhecimentoErro = '/reconhecimento/erro';
  static const String historico = '/historico';
  static const String sincronizacao = '/sincronizacao';
  static const String configuracoes = '/configuracoes';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen(), settings);
      case home:
        return _fade(const HomeScreen(), settings);
      case reconhecimento:
        return _slideUp(const RecognitionScreen(), settings);
      case reconhecimentoSucesso:
        return _fade(const RecognitionSuccessScreen(), settings);
      case reconhecimentoErro:
        return _fade(const RecognitionErrorScreen(), settings);
      case historico:
        return _slide(const HistoryScreen(), settings);
      case sincronizacao:
        return _slide(const SyncScreen(), settings);
      case configuracoes:
        return _slide(const SettingsScreen(), settings);
      default:
        return _fade(const HomeScreen(), settings);
    }
  }

  /// Transição de fade (telas de resultado e splash).
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

  /// Transição vertical (abertura do fluxo de reconhecimento).
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
