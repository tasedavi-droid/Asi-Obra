import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/ao_button.dart';
import '../../widgets/common/ao_text_field.dart';
import '../../widgets/common/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
        email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      _showError(auth.error ?? AppStrings.errorGeneric);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      _showError('Digite seu e-mail para redefinir a senha.');
      return;
    }
    final ok = await context.read<AuthProvider>()
        .sendPasswordReset(_emailCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'E-mail de redefinição enviado!'
          : 'Erro ao enviar e-mail.')));
  }

  void _showError(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
          content: Text(msg), backgroundColor: AppColors.vermelho));

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    final overlayColor = isDark
        ? AppColors.azulEscuro02.withOpacity(0.82)
        : AppColors.offWhite01.withOpacity(0.78);

    return Scaffold(
      body: Stack(children: [
        // Fundo — textura de tijolo
        Positioned.fill(
          child: Image.asset(
            'assets/images/brick_wall.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: isDark ? AppColors.azulEscuro02 : AppColors.offWhite01),
          ),
        ),
        // Overlay semitransparente
        Positioned.fill(child: Container(color: overlayColor)),
        // Conteúdo
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 52),
                  const AuthHeader(),
                  const SizedBox(height: 40),
                  Text(AppStrings.login,
                    style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 24),
                  AoTextField(
                    label: AppStrings.email,
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  AoTextField(
                    label: AppStrings.password,
                    controller: _passCtrl,
                    validator: Validators.password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(AppStrings.forgotPassword,
                        style: GoogleFonts.publicSans(
                          fontSize: 13, color: AppColors.vermelho)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AoButton(
                    label: AppStrings.cadastrar,
                    onPressed: _login,
                    loading: isLoading,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.publicSans(fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                        children: [
                          const TextSpan(text: AppStrings.noAccount),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.register),
                              child: Text(AppStrings.doRegister,
                                style: GoogleFonts.publicSans(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: AppColors.vermelho)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}