import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/auth_field.dart';
import '../../widgets/common/auth_button.dart';
import '../../widgets/common/brick_header.dart';

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
    if (ok) Navigator.pushReplacementNamed(context, AppRoutes.home);
    else    _snack(auth.error ?? AppStrings.errorGeneric, error: true);
  }

  void _snack(String msg, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg, style: GoogleFonts.publicSans()),
          backgroundColor: error ? AppColors.vermelho : null));

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final themeP    = context.watch<ThemeProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    final bg          = isDark ? const Color(0xFF1B242B) : const Color(0xFFF4F0E5);
    final fieldBg     = isDark ? const Color(0xFF1F2B33) : Colors.white;
    final fieldBorder = isDark ? const Color(0xFF2E3E48) : const Color(0xFFE5E1D8);
    final textColor   = isDark ? const Color(0xFFEAE9E4) : const Color(0xFF121212);
    final hintColor   = isDark ? const Color(0xFF5A6E78) : const Color(0xFFADAA9F);
    const glowColor   = AppColors.vermelho;

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [

    
          BrickHeader(
            heightFactor: 0.26,
            topRight: GestureDetector(
              onTap: themeP.toggle,
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white.withOpacity(0.90), size: 18),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                    
                      Image.asset('assets/images/logo.png', height: 80,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.home_repair_service_rounded,
                          color: AppColors.vermelho, size: 80)),
                      const SizedBox(height: 2),

                      
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.publicSans(
                            fontSize: 26, fontWeight: FontWeight.w700,
                            height: 1.30, color: textColor),
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
                        glowColor: glowColor),
                      const SizedBox(height: 14),

                      
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
                        glowColor: glowColor),
                      const SizedBox(height: 24),

                      
                      AuthButton(label: 'Login',
                        onTap: isLoading ? null : _login, loading: isLoading),
                      const SizedBox(height: 12),

                      
                      AuthButton(label: 'Cadastrar', outlined: true,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.register)),
                      const SizedBox(height: 20),

                      
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                        child: Text('Esqueci minha senha',
                          style: GoogleFonts.publicSans(
                            fontSize: 13, color: AppColors.vermelho)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}