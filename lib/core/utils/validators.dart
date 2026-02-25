import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final ok = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(v.trim());
    return ok ? null : AppStrings.invalidEmail;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return AppStrings.fieldRequired;
    return v.length < 6 ? AppStrings.passwordMin : null;
  }

  static String? Function(String?) confirmPassword(String? original) =>
      (String? v) {
        if (v == null || v.isEmpty) return AppStrings.fieldRequired;
        return v != original ? AppStrings.passwordMatch : null;
      };

  static String? positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final n = int.tryParse(v.trim());
    return (n == null || n <= 0) ? AppStrings.invalidQty : null;
  }

  static String? nonNegativeInt(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
    final n = int.tryParse(v.trim());
    return (n == null || n < 0) ? AppStrings.invalidQty : null;
  }

  static String? Function(String?) maxInt(int max) =>
      (String? v) {
        final base = positiveInt(v);
        if (base != null) return base;
        final n = int.tryParse(v!.trim())!;
        return n > max ? 'Máximo disponível: $max' : null;
      };
}