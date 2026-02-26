import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Cabeçalho com logo e tagline usado nas telas de Login e Cadastro.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 52,
          errorBuilder: (_, __, ___) => Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color:        AppColors.vermelho,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.home_repair_service_rounded,
              color: AppColors.branco, size: 28,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AppStrings.appTagline,
          style: GoogleFonts.publicSans(
            fontSize:   22,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.perola : AppColors.azulEscuro02,
          ),
        ),
      ],
    );
  }
}