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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _ob1 = true, _ob2 = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(
      name:     _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? AppStrings.errorGeneric,
            style: GoogleFonts.publicSans()),
        backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final size      = MediaQuery.of(context).size;

    final bg          = isDark ? const Color(0xFF1B242B) : const Color(0xFFF4F0E5);
    final fieldBg     = isDark ? const Color(0xFF1F2B33) : Colors.white;
    final fieldBorder = isDark ? const Color(0xFF2E3E48) : const Color(0xFFE5E1D8);
    final textColor   = isDark ? const Color(0xFFEAE9E4) : const Color(0xFF121212);
    final hintColor   = isDark ? const Color(0xFF5A6E78) : const Color(0xFFADAA9F);
    const glowColor   = AppColors.vermelho;

    return Scaffold(
      backgroundColor: bg,
      body: Column(children: [
        SizedBox(
          height: size.height * 0.30,
          width: double.infinity,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/brick_wall.png', fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFFA84020))),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  stops: const [0.0, 0.30, 0.75, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    bg.withOpacity(0.70),
                    bg,
                  ]))),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withOpacity(0.90), size: 20)),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 80,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.home_repair_service_rounded,
                      color: AppColors.vermelho, size: 80)),
                  const SizedBox(height: 6),
                  Text('Cadastro',
                    style: GoogleFonts.publicSans(
                      fontSize: 26, fontWeight: FontWeight.w700,
                      color: textColor)),
                  const SizedBox(height: 20),

                  AuthField(hint: 'Digite seu nome', controller: _nameCtrl,
                    validator: Validators.required, action: TextInputAction.next,
                    suffix: Icon(Icons.person_outline, size: 18, color: hintColor),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor, glowColor: glowColor),
                  const SizedBox(height: 14),

                  AuthField(hint: 'Insira seu e-mail', controller: _emailCtrl,
                    validator: Validators.email,
                    keyboard: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    suffix: Icon(Icons.email_outlined, size: 18, color: hintColor),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor, glowColor: glowColor),
                  const SizedBox(height: 14),

                  AuthField(hint: 'Digite sua Senha', controller: _passCtrl,
                    validator: Validators.password,
                    obscure: _ob1, action: TextInputAction.next,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _ob1 = !_ob1),
                      child: Icon(_ob1 ? Icons.lock_outline : Icons.lock_open_outlined,
                        size: 18, color: hintColor)),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor, glowColor: glowColor),
                  const SizedBox(height: 14),

                  AuthField(hint: 'Repita sua Senha', controller: _pass2Ctrl,
                    validator: Validators.confirmPassword(_passCtrl.text),
                    obscure: _ob2, action: TextInputAction.done,
                    onSubmit: (_) => _register(),
                    suffix: GestureDetector(
                      onTap: () => setState(() => _ob2 = !_ob2),
                      child: Icon(_ob2 ? Icons.lock_outline : Icons.lock_open_outlined,
                        size: 18, color: hintColor)),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor, glowColor: glowColor),
                  const SizedBox(height: 24),

                  AuthButton(label: 'Criar conta',
                    onTap: isLoading ? null : _register, loading: isLoading),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.publicSans(
                          fontSize: 13, color: hintColor),
                        children: [
                          const TextSpan(text: 'Já possui uma conta? '),
                          TextSpan(text: 'Realize o login',
                            style: GoogleFonts.publicSans(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: AppColors.vermelho)),
                        ],
                      ),
                    ),
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