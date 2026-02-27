import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/auth_field.dart';
import '../../widgets/common/auth_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _ob1 = true, _ob2 = true;

  @override
  void dispose() {
    _pass1Ctrl.dispose(); _pass2Ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Acesse o link enviado ao seu e-mail para confirmar a redefinição.',
          style: GoogleFonts.publicSans()),
        backgroundColor: AppColors.azulArdosia,
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final size    = MediaQuery.of(context).size;
    final email   = ModalRoute.of(context)?.settings.arguments as String? ?? '';

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

        // ── FAIXA TIJOLO COM GRADIENTE ─────────────────────────
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

                // Ícone cadeado com seta — maior
                Image.asset('assets/images/lock_refresh.png',
                  height: 110,
                  color: AppColors.vermelho,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.vermelho, size: 110)),
                const SizedBox(height: 16),

                // Título
                Text('Redefina sua senha',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: textColor)),
                const SizedBox(height: 8),

                // Subtítulo com e-mail
                if (email.isNotEmpty)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.publicSans(
                        fontSize: 13, fontWeight: FontWeight.w300,
                        height: 1.55, color: subColor),
                      children: [
                        const TextSpan(text: 'Link enviado para '),
                        TextSpan(text: email,
                          style: GoogleFonts.publicSans(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.vermelho)),
                        const TextSpan(
                          text: '\nDigite abaixo a nova senha desejada.'),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // Campos
                Form(
                  key: _formKey,
                  child: Column(children: [
                    AuthField(
                      hint: 'Digite sua nova senha',
                      controller: _pass1Ctrl,
                      validator: Validators.password,
                      obscure: _ob1,
                      action: TextInputAction.next,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _ob1 = !_ob1),
                        child: Icon(
                          _ob1 ? Icons.lock_outline : Icons.lock_open_outlined,
                          size: 18, color: hintColor)),
                      bg: fieldBg, border: fieldBorder,
                      textColor: textColor, hintColor: hintColor,
                      glowColor: glowColor),
                    const SizedBox(height: 14),
                    AuthField(
                      hint: 'Repita sua nova senha',
                      controller: _pass2Ctrl,
                      validator: Validators.confirmPassword(_pass1Ctrl.text),
                      obscure: _ob2,
                      action: TextInputAction.done,
                      onSubmit: (_) => _confirm(),
                      suffix: GestureDetector(
                        onTap: () => setState(() => _ob2 = !_ob2),
                        child: Icon(
                          _ob2 ? Icons.lock_outline : Icons.lock_open_outlined,
                          size: 18, color: hintColor)),
                      bg: fieldBg, border: fieldBorder,
                      textColor: textColor, hintColor: hintColor,
                      glowColor: glowColor),
                  ]),
                ),
                const SizedBox(height: 24),

                AuthButton(label: 'Redefinir Senha', onTap: _confirm),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}