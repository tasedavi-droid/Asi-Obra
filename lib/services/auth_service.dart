import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Gera código de funcionário sequencial — ex: AO0001
  Future<String> _generateEmployeeCode() async {
    final snap  = await _firestore.collection('users').get();
    final count = snap.docs.length + 1;
    return 'AO${count.toString().padLeft(4, '0')}';
  }

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
      createdAt:    now,
    );
    await _firestore.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return await getUser();
  }

  Future<void> logout() => _auth.signOut();

  Future<UserModel> getUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Não autenticado');
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Usuário não encontrado');
    return UserModel.fromFirestore(doc);
  }

  /// Envia e-mail de redefinição e salva o código no Firestore 
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);

    // Registra no documento do usuário que uma redefinição foi solicitada
    final snap = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final resetCode = 'RESET_${DateTime.now().millisecondsSinceEpoch}';
      await snap.docs.first.reference.update({
        'passwordReset': resetCode,
      });
    }
  }

  /// Limpa o código de reset após a senha ser redefinida com sucesso
  Future<void> clearPasswordReset(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'passwordReset': null,
    });
  }

  Future<List<UserModel>> getAllUsers() async {
    final snap = await _firestore.collection('users').orderBy('name').get();
    return snap.docs.map(UserModel.fromFirestore).toList();
  }

  Future<void> updateRole(String userId, UserRole role) =>
      _firestore.collection('users').doc(userId).update({'role': role.name});

  Future<void> updateName(String userId, String name) =>
      _firestore.collection('users').doc(userId).update({'name': name});
}