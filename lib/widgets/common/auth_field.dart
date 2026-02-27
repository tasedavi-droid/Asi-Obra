import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Campo de autenticação com efeito GLOW ao focar
class AuthField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboard;
  final TextInputAction action;
  final void Function(String)? onSubmit;
  final bool obscure;
  final Widget? suffix;
  final Color bg, border, textColor, hintColor, glowColor;

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
    required this.glowColor,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: _focused
            ? [
                // Glow principal
                BoxShadow(
                  color:        widget.glowColor.withOpacity(0.55),
                  blurRadius:   24,
                  spreadRadius: 2),
                // Halo secundário mais suave
                BoxShadow(
                  color:        widget.glowColor.withOpacity(0.20),
                  blurRadius:   48,
                  spreadRadius: 4),
              ]
            : [
                BoxShadow(
                  color:      Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset:     const Offset(0, 2)),
              ],
      ),
      child: TextFormField(
        focusNode:        _focus,
        controller:       widget.controller,
        validator:        widget.validator,
        keyboardType:     widget.keyboard,
        textInputAction:  widget.action,
        onFieldSubmitted: widget.onSubmit,
        obscureText:      widget.obscure,
        style: GoogleFonts.publicSans(fontSize: 14, color: widget.textColor),
        decoration: InputDecoration(
          hintText:  widget.hint,
          hintStyle: GoogleFonts.publicSans(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: widget.hintColor),
          suffixIcon: widget.suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: widget.suffix)
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          filled:         true,
          fillColor:      widget.bg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   BorderSide(color: widget.border, width: 1.2)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   BorderSide(
                color: widget.glowColor.withOpacity(0.85), width: 1.8)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.vermelho, width: 1.2)),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.vermelho, width: 1.8)),
        ),
      ),
    );
  }
}