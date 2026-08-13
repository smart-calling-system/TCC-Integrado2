import '../../models/usuario.dart';

class SessionState {
  final Usuario? usuario;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const SessionState({
    this.usuario,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  bool get isAuthenticated => usuario != null;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
