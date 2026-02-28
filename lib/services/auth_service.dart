import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Coleção correta conforme Firebase rules ───────────────────
  CollectionReference get _users => _firestore.collection('usuarios');

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Gera código de crachá usando o contador do Firestore (config/employeeCounter)
  Future<String> _generateEmployeeCode() async {
    final counterRef = _firestore.collection('config').doc('employeeCounter');
    late String code;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(counterRef);
      int ultimo = 0;
      if (snap.exists) {
        ultimo = (snap.data() as Map<String, dynamic>)['ultimoCodigo'] ?? 0;
      }
      final proximo = ultimo + 1;
      tx.set(counterRef, {'ultimoCodigo': proximo}, SetOptions(merge: true));
      code = 'AO${proximo.toString().padLeft(4, '0')}';
    });

    return code;
  }

  // ── Cadastro ──────────────────────────────────────────────────
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
      role:         UserRole.leitor,
      employeeCode: code,
      isActive:     true,
      createdAt:    now,
    );

    await _users.doc(uid).set(user.toMap());
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
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw Exception('Usuário não encontrado');
    return UserModel.fromFirestore(doc);
  }

  // ── Verifica se e-mail existe na coleção usuarios ─────────────
  // Equivalente ao verificarEmailExiste() do desktop (Angular/AngularFire).
  // Usado antes de enviar o link de redefinição para evitar envio
  // para e-mails não cadastrados.
  Future<bool> verificarEmailExiste(String email) async {
    try {
      final snapshot = await _users
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ── Redefinição de senha ──────────────────────────────────────
  // 1. Chama verificarEmailExiste (igual ao desktop) antes de enviar
  // 2. Se não existe → lança exceção com mensagem traduzida
  // 3. Se existe → Firebase envia o e-mail (resetPassword do desktop)
  // 4. Registra token no campo passwordReset do usuário para auditoria
  Future<void> sendPasswordReset(String email) async {
    // 1. Verifica existência (verificarEmailExiste do desktop)
    final existe = await verificarEmailExiste(email);
    if (!existe) {
      throw Exception('email-not-found');
    }

    // 2. Envia link via Firebase Auth (resetPassword do desktop)
    await _auth.sendPasswordResetEmail(email: email.trim());

    // 3. Registra token de auditoria no Firestore
    try {
      final snap = await _users
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final code = 'RESET_${DateTime.now().millisecondsSinceEpoch}';
        await snap.docs.first.reference.update({'passwordReset': code});
      }
    } catch (_) {
      // Falha no registro de auditoria não interrompe o fluxo principal
    }
  }

  // ── Admin: listar todos ───────────────────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final snap = await _users.orderBy('name').get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  // ── Admin: alterar role ───────────────────────────────────────
  Future<void> updateRole(String userId, UserRole role) =>
      _users.doc(userId).update({'role': role.firestoreValue});

  // ── Admin: ativar/desativar ───────────────────────────────────
  Future<void> setActive(String userId, bool active) =>
      _users.doc(userId).update({'isActive': active});

  // ── Editar nome ───────────────────────────────────────────────
  Future<void> updateName(String userId, String name) =>
      _users.doc(userId).update({'name': name});
}