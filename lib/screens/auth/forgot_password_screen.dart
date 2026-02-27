import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/auth_field.dart';
import '../../widgets/common/auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _loading   = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok   = await auth.sendPasswordReset(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pushReplacementNamed(
        context, AppRoutes.resetPassword,
        arguments: _emailCtrl.text.trim(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('E-mail não encontrado. Verifique e tente novamente.'),
        backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final size    = MediaQuery.of(context).size;

    final bg          = isDark ? const Color(0xFF1B242B) : const Color(0xFFF4F0E5);
    final fieldBg     = isDark ? const Color(0xFF1F2B33) : Colors.white;
    final fieldBorder = isDark ? const Color(0xFF2E3E48) : const Color(0xFFE5E1D8);
    final textColor   = isDark ? const Color(0xFFEAE9E4) : const Color(0xFF121212);
    final hintColor   = isDark ? const Color(0xFF5A6E78) : const Color(0xFFADAA9F);
    final subColor    = isDark ? const Color(0xFF7A8F9A) : const Color(0xFF6B6860);
    const glowColor   = AppColors.vermelho;

    return Scaffold(
      backgroundColor: bg,
      body: Column(children: [

        // ── FAIXA TIJOLO COM GRADIENTE + VOLTAR ────────────────
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

        // ── CONTEÚDO CENTRALIZADO ──────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),

                // Ícone cadeado — maior
                Image.asset('assets/images/lock.png',
                  height: 110,
                  color: AppColors.vermelho,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.vermelho, size: 110)),
                const SizedBox(height: 16),

                // Título
                Text('Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: textColor)),
                const SizedBox(height: 8),

                // Subtítulo
                Text(
                  'Insira seu e-mail e enviaremos um link\npara você voltar a acessar a sua conta.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 13, fontWeight: FontWeight.w300,
                    height: 1.55, color: subColor)),
                const SizedBox(height: 28),

                // Campo e-mail
                Form(
                  key: _formKey,
                  child: AuthField(
                    hint: 'Insira seu e-mail',
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboard: TextInputType.emailAddress,
                    action: TextInputAction.done,
                    onSubmit: (_) => _send(),
                    suffix: Icon(Icons.email_outlined, size: 18, color: hintColor),
                    bg: fieldBg, border: fieldBorder,
                    textColor: textColor, hintColor: hintColor,
                    glowColor: glowColor,
                  ),
                ),
                const SizedBox(height: 20),

                AuthButton(
                  label: 'Enviar link',
                  onTap: _loading ? null : _send,
                  loading: _loading),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}