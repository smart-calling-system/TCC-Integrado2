/// Constantes gerais do aplicativo.
class AppConstants {
  AppConstants._();

  static const String appName = 'FaceClass';
  static const String appFullName =
      'Sistema de Controle de Presença Escolar Baseado em Reconhecimento Facial';
  static const String appVersion = '1.0.0';

  /// Duração da splash screen antes de navegar para a Home.
  static const Duration splashDuration = Duration(milliseconds: 2800);

  /// Tempo simulado do "processamento" do reconhecimento facial.
  static const Duration recognitionDelay = Duration(milliseconds: 2200);

  /// Tempo simulado de carregamento de listas mockadas.
  static const Duration mockLoadDelay = Duration(milliseconds: 600);

  /// Breakpoint para considerar o dispositivo um tablet.
  static const double tabletBreakpoint = 600;

  /// Largura máxima do conteúdo em telas grandes (tablets).
  static const double maxContentWidth = 720;
}
