import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  const RoleBadge({super.key, required this.role});

  Color get _color {
    switch (role) {
      case UserRole.administrador: return AppColors.roleAdmin;
      case UserRole.estoquista:    return AppColors.roleEstoquista;
      case UserRole.leitor:        return AppColors.roleLeitor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border:       Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        role.label,
        style: GoogleFonts.publicSans(
          fontSize: 11, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}