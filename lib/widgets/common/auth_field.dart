import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Campo de texto para telas de autenticação (Login / Cadastro)
class AuthField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboard;
  final TextInputAction action;
  final void Function(String)? onSubmit;
  final bool obscure;
  final Widget? suffix;
  final Color bg, border, textColor, hintColor;

  const AuthField({
    super.key,
    required this.hint,
    required this.controller,
    required this.validator,
    this.keyboard  = TextInputType.text,
    this.action    = TextInputAction.next,
    this.onSubmit,
    this.obscure   = false,
    this.suffix,
    required this.bg,
    required this.border,
    required this.textColor,
    required this.hintColor,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller:       controller,
    validator:        validator,
    keyboardType:     keyboard,
    textInputAction:  action,
    onFieldSubmitted: onSubmit,
    obscureText:      obscure,
    style: GoogleFonts.publicSans(fontSize: 14, color: textColor),
    decoration: InputDecoration(
      hintText:  hint,
      hintStyle: GoogleFonts.publicSans(fontSize: 14, color: hintColor),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
          : null,
      suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      filled:         true,
      fillColor:      bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:   BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:   const BorderSide(color: AppColors.vermelho, width: 1.5)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:   const BorderSide(color: AppColors.vermelho)),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:   const BorderSide(color: AppColors.vermelho, width: 1.5)),
    ),
  );
}