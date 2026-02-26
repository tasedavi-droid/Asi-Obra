import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Gera código de crachá sequencial — ex: AO0001, AO0002...
  Future<String> _generateEmployeeCode() async {
    final snap  = await _firestore.collection('users').get();
    final count = snap.docs.length + 1;
    return 'AO${count.toString().padLeft(4, '0')}';
  }

  // ── Cadastro ─────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final uid  = cred.user!.uid;
    final code = await _generateEmployeeCode();
    final now  = DateTime.now();

    final user = UserModel(
      id:           uid,
      name:         name,
      email:        email,
      role:         UserRole.leitor, // novos usuários sempre começam como Leitor
      employeeCode: code,
      isActive:     true,
      createdAt:    now,
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = await getUser();
    if (!user.isActive) {
      await _auth.signOut();
      throw Exception('Conta desativada. Entre em contato com o administrador.');
    }
    return user;
  }

  // ── Logout ────────────────────────────────────────────────────
  Future<void> logout() => _auth.signOut();

  // ── Buscar usuário logado ─────────────────────────────────────
  Future<UserModel> getUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Não autenticado');
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Usuário não encontrado');
    return UserModel.fromFirestore(doc);
  }

  // ── Redefinição de senha ──────────────────────────────────────
  // Envia e-mail e salva o código no Firestore (campo passwordReset)
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);

    final snap = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final code = 'RESET_${DateTime.now().millisecondsSinceEpoch}';
      await snap.docs.first.reference.update({'passwordReset': code});
    }
  }

  // Limpa o código de reset após nova senha definida
  Future<void> clearPasswordReset(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'passwordReset':   null,
      'passwordChanged': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Admin: listar todos os usuários ──────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final snap = await _firestore
        .collection('users')
        .orderBy('name')
        .get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  // ── Admin: alterar role ───────────────────────────────────────
  Future<void> updateRole(String userId, UserRole role) =>
      _firestore.collection('users').doc(userId).update({'role': role.name});

  // ── Admin: ativar/desativar conta ─────────────────────────────
  Future<void> setActive(String userId, bool active) =>
      _firestore.collection('users').doc(userId).update({'isActive': active});

  // ── Editar nome próprio ───────────────────────────────────────
  Future<void> updateName(String userId, String name) =>
      _firestore.collection('users').doc(userId).update({'name': name});
}