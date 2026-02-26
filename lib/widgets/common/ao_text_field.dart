import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AoTextField extends StatelessWidget {
  final String                     label;
  final TextEditingController?     controller;
  final String? Function(String?)? validator;
  final TextInputType               keyboardType;
  final bool                       obscureText;
  final Widget?                    suffixIcon;
  final Widget?                    prefixIcon;
  final int                        maxLines;
  final int?                       maxLength;
  final bool                       readOnly;
  final VoidCallback?              onTap;
  final void Function(String)?     onChanged;
  final List<TextInputFormatter>?  inputFormatters;
  final TextCapitalization         textCapitalization;
  final TextInputAction?           textInputAction;
  final void Function(String)?     onFieldSubmitted;
  final FocusNode?                 focusNode;
  final String?                    initialValue;

  const AoTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType       = TextInputType.text,
    this.obscureText        = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines           = 1,
    this.maxLength,
    this.readOnly           = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:         controller,
      initialValue:       initialValue,
      validator:          validator,
      keyboardType:       keyboardType,
      obscureText:        obscureText,
      maxLines:           maxLines,
      maxLength:          maxLength,
      readOnly:           readOnly,
      onTap:              onTap,
      onChanged:          onChanged,
      inputFormatters:    inputFormatters,
      textCapitalization: textCapitalization,
      focusNode:          focusNode,
      textInputAction:    textInputAction,
      onFieldSubmitted:   onFieldSubmitted,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText:   label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}