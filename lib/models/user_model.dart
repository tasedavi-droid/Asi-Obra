import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { leitor, estoquista, administrador }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.leitor:        return 'Leitor';
      case UserRole.estoquista:    return 'Estoquista';
      case UserRole.administrador: return 'Administrador';
    }
  }

  static UserRole fromString(String? v) {
    switch (v) {
      case 'estoquista':    return UserRole.estoquista;
      case 'administrador': return UserRole.administrador;
      default:              return UserRole.leitor;
    }
  }
}

class UserModel {
  final String    id;
  final String    name;
  final String    email;
  final UserRole  role;
  final String?   employeeCode;
  final DateTime? passwordChanged;
  final String?   passwordReset; 
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.employeeCode,
    this.passwordChanged,
    this.passwordReset,
    this.createdAt,
  });

  bool get isAdmin      => role == UserRole.administrador;
  bool get isEstoquista => role == UserRole.estoquista || isAdmin;
  bool get canEdit      => role != UserRole.leitor;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      id:              doc.id,
      name:            d['name']          ?? '',
      email:           d['email']         ?? '',
      role:            UserRoleX.fromString(d['role']),
      employeeCode:    d['employeeCode'],
      passwordChanged: (d['passwordChanged'] as Timestamp?)?.toDate(),
      passwordReset:   d['passwordReset'],
      createdAt:       (d['createdAt']       as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    final pc = passwordChanged;
    final ca = createdAt;
    return {
      'name':            name,
      'email':           email,
      'role':            role.name,
      'employeeCode':    employeeCode,
      'passwordChanged': pc != null ? Timestamp.fromDate(pc) : null,
      'passwordReset':   passwordReset,
      'createdAt':       ca != null ? Timestamp.fromDate(ca) : null,
    };
  }

  UserModel copyWith({
    String?    id,
    String?    name,
    String?    email,
    UserRole?  role,
    String?    employeeCode,
    DateTime?  passwordChanged,
    String?    passwordReset,
    DateTime?  createdAt,
  }) => UserModel(
    id:              id              ?? this.id,
    name:            name            ?? this.name,
    email:           email           ?? this.email,
    role:            role            ?? this.role,
    employeeCode:    employeeCode    ?? this.employeeCode,
    passwordChanged: passwordChanged ?? this.passwordChanged,
    passwordReset:   passwordReset   ?? this.passwordReset,
    createdAt:       createdAt       ?? this.createdAt,
  );
}