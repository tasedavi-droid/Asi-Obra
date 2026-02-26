import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

enum AoButtonVariant { primary, outlined, ghost, danger }

class AoButton extends StatelessWidget {
  final String          label;
  final VoidCallback?   onPressed;
  final AoButtonVariant variant;
  final bool            loading;
  final IconData?       icon;
  final double          height;

  const AoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AoButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

    Widget child = loading
        ? SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AoButtonVariant.primary ||
                     variant == AoButtonVariant.danger
                  ? AppColors.branco
                  : theme.colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label,
                style: GoogleFonts.publicSans(
                  fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          );

    switch (variant) {
      case AoButtonVariant.primary:
        return SizedBox(
          width: double.infinity, height: height,
          child: ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(shape: shape),
            child: child));
      case AoButtonVariant.outlined:
        return SizedBox(
          width: double.infinity, height: height,
          child: OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(shape: shape),
            child: child));
      case AoButtonVariant.ghost:
        return SizedBox(
          width: double.infinity, height: height,
          child: TextButton(
            onPressed: loading ? null : onPressed,
            style: TextButton.styleFrom(shape: shape),
            child: child));
      case AoButtonVariant.danger:
        return SizedBox(
          width: double.infinity, height: height,
          child: ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
              foregroundColor: AppColors.branco,
              shape: shape),
            child: child));
    }
  }
}