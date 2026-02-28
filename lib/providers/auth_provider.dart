import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _svc = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String?    _error;

  AuthStatus get status      => _status;
  UserModel? get currentUser => _user;
  String?    get error       => _error;
  bool get isAuthenticated   => _status == AuthStatus.authenticated;
  bool get isAdmin           => _user?.isAdmin ?? false;
  bool get canEdit           => _user?.canEdit ?? false;

  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      _user   = await _svc.getUser();
      _status = AuthStatus.authenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _error  = null;
    notifyListeners();
    try {
      _user   = await _svc.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error  = _mapError(e.toString());
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _error  = null;
    notifyListeners();
    try {
      _user   = await _svc.register(
          name: name, email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _error  = _mapError(e.toString());
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _svc.logout();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Retorna null em caso de sucesso ou a mensagem de erro traduzida.
  // A ForgotPasswordScreen usa o retorno para decidir se navega ou mostra erro.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _svc.sendPasswordReset(email);
      return null; // sucesso
    } on Exception catch (e) {
      return _mapError(e.toString());
    }
  }

  Future<List<UserModel>> getAllUsers() => _svc.getAllUsers();

  Future<void> updateRole(String userId, UserRole role) =>
      _svc.updateRole(userId, role);

  Future<void> setActive(String userId, bool active) =>
      _svc.setActive(userId, active);

  Future<void> updateName(String name) async {
    if (_user == null) return;
    await _svc.updateName(_user!.id, name);
    _user = _user!.copyWith(name: name);
    notifyListeners();
  }

  String _mapError(String e) {
    if (e.contains('user-not-found') ||
        e.contains('wrong-password') ||
        e.contains('invalid-credential'))
      return 'E-mail ou senha incorretos.';
    if (e.contains('email-not-found'))
      return 'E-mail não encontrado. Verifique e tente novamente.';
    if (e.contains('email-already-in-use'))
      return 'Este e-mail já está cadastrado.';
    if (e.contains('weak-password'))
      return 'Senha muito fraca. Use pelo menos 6 caracteres.';
    if (e.contains('network-request-failed'))
      return 'Sem conexão. Verifique sua internet.';
    if (e.contains('desativada'))
      return 'Conta desativada. Entre em contato com o administrador.';
    return 'Erro inesperado. Tente novamente.';
  }
}