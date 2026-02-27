import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.perola : AppColors.grafite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Image.asset(
          'assets/images/logo.png',
          height: 52,
          errorBuilder: (_, __, ___) => Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.vermelho,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_repair_service_rounded,
                color: AppColors.branco, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        // "Bem vindo ao" normal + "Asi & Obra!" em vermelho
        RichText(
          text: TextSpan(
            style: GoogleFonts.publicSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.25,
            ),
            children: [
              const TextSpan(text: 'Bem vindo ao\n'),
              TextSpan(
                text: 'Asi & Obra!',
                style: GoogleFonts.publicSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.vermelho,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}