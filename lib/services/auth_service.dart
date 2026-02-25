import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; 
  
  User? get currentFirebaseUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> _generateEmployeeCode() async {
    final snap = await _firestore.collection( 'users').get();
    final count = snap.docs.length + 1;
    return 'AO${count.toString().padLeft(4, '0')}';
 }

 Future<UserModel> register({
   required String name,
   required String email,
    required String password,
 }) async {
   final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);}
   final uid = cred.user!.uid;
   final code = await _generateEmployeeCode();
   final now = DateTime.now();

    final userModel = UserModel(
      id: uid,
      name: name,
      email: email,
      role: UserRole.leitor,
      employeeCode: code,
      createdAt: now,
    );
    await _firestore.collection('users').doc(uid).set(userModel.toMap());
    return user;
  }
