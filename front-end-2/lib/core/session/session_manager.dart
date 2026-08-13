import 'session_state.dart';

class SessionManager {
  SessionState _state = const SessionState();

  SessionState get state => _state;

  Future<void> save(SessionState state) async {
    _state = state;
  }

  Future<void> clear() async {
    _state = const SessionState();
  }
}
