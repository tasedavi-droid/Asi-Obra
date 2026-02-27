import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/auth_field.dart';
import '../../widgets/common/auth_button.dart';

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
    final ok   = await auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      _snack(auth.error ?? AppStrings.errorGeneric, error: true);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.trim().isEmpty) {
      _snack('Digite seu e-mail primeiro.', error: true); return;
    }
    final ok = await context.read<AuthProvider>()
        .sendPasswordReset(_emailCtrl.text.trim());
    if (!mounted) return;
    _snack(ok ? 'E-mail enviado!' : 'Erro ao enviar.', error: !ok);
  }

  void _snack(String msg, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg),
              backgroundColor: error ? AppColors.vermelho : null));

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final size      = MediaQuery.of(context).size;

    final bg          = isDark ? const Color(0xFF172027) : const Color(0xFFF4F0E5);
    final fieldBg     = isDark ? const Color(0xFF1B242B) : Colors.white;
    final fieldBorder = isDark ? const Color(0xFF2C3E47) : const Color(0xFFE0DDD5);
    final textColor   = isDark ? const Color(0xFFEAE9E4) : const Color(0xFF121212);
    final hintColor   = isDark ? const Color(0xFF5A6A74) : const Color(0xFF9A9590);

    return Scaffold(
      backgroundColor: bg,
      body: Column(children: [

        // ── FAIXA DE TIJOLO COM GRADIENTE FADE ──────────────────
        SizedBox(
          height: size.height * 0.20,
          width: double.infinity,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/brick_wall.png', fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFA84020))),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [Colors.transparent, Colors.transparent, bg]))),
          ]),
        ),

        // ── CONTEÚDO ────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 52,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.home_repair_service_rounded,
                        color: AppColors.vermelho, size: 52)),
                  const SizedBox(height: 10),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.publicSans(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        height: 1.35, color: textColor),
                      children: [
                        const TextSpan(text: 'Bem vindo ao\n'),
                        const TextSpan(text: 'Asi & Obra!',
                          style: TextStyle(color: AppColors.vermelho)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  AuthField(
                    hint: 'Insira seu e-mail', controller: _emailCtrl,
                    validator: Validators.email,
                    keyboard: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    suffix: Icon(Icons.email_outlined, size: 18, color: hintColor),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor,
                  ),
                  const SizedBox(height: 12),

                  AuthField(
                    hint: 'Digite sua Senha', controller: _passCtrl,
                    validator: Validators.password,
                    obscure: _obscure, action: TextInputAction.done,
                    onSubmit: (_) => _login(),
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? Icons.lock_outline : Icons.lock_open_outlined,
                        size: 18, color: hintColor)),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor,
                  ),
                  const SizedBox(height: 20),

                  AuthButton(label: 'Login', onTap: isLoading ? null : _login, loading: isLoading),
                  const SizedBox(height: 10),
                  AuthButton(
                    label: 'Cadastrar', outlined: true,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.register)),
                  const SizedBox(height: 18),

                  GestureDetector(
                    onTap: _forgotPassword,
                    child: Text('Esqueci minha senha',
                      style: GoogleFonts.publicSans(
                          fontSize: 13, color: AppColors.vermelho)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}