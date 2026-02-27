import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined, loading;

  const AuthButton({
    super.key,
    required this.label,
    this.onTap,
    this.outlined = false,
    this.loading  = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w600);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

    if (outlined) {
      return SizedBox(
        width: double.infinity, height: 52,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.vermelho,
            side: const BorderSide(color: AppColors.vermelho, width: 1.5),
            shape: shape),
          child: Text(label, style: style),
        ),
      );
    }
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vermelho,
          foregroundColor: Colors.white,
          elevation: 0, shape: shape),
        child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: style),
      ),
    );
  }
}