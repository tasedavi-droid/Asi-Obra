import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/auth_field.dart';
import '../../widgets/common/auth_button.dart';
import '../../widgets/common/brick_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent    = false;   // exibe estado de sucesso inline

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth  = context.read<AuthProvider>();
    final error = await auth.sendPasswordReset(_emailCtrl.text.trim());

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      // Sucesso — mostra estado de confirmação sem navegar para nova tela
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error, style: GoogleFonts.publicSans()),
        backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;

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

        BrickHeader(
          heightFactor: 0.26,
          topLeft: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white.withOpacity(0.90), size: 20)),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),

                // Ícone cadeado
                Image.asset('assets/images/lock.png',
                  height: 110, color: AppColors.vermelho,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.vermelho, size: 110)),
                const SizedBox(height: 16),

                Text('Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: textColor)),
                const SizedBox(height: 8),

                Text(
                  'Insira seu e-mail e enviaremos um link\npara você voltar a acessar a sua conta.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(
                    fontSize: 13, fontWeight: FontWeight.w300,
                    height: 1.55, color: subColor)),
                const SizedBox(height: 28),

                // ── Estado de sucesso (após envio) ────────────
                if (_sent) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.green.withOpacity(0.35))),
                    child: Column(children: [
                      const Icon(Icons.mark_email_read_outlined,
                          color: Colors.green, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        'E-mail enviado para\n${_emailCtrl.text}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.publicSans(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: Colors.green.shade700)),
                      const SizedBox(height: 6),
                      Text(
                        'Verifique sua caixa de entrada e clique no link para redefinir sua senha.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.publicSans(
                          fontSize: 12, fontWeight: FontWeight.w300,
                          color: subColor, height: 1.5)),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  AuthButton(
                    label: 'Voltar ao login',
                    onTap: () => Navigator.pop(context)),
                ]

                // ── Formulário de e-mail ───────────────────────
                else ...[
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
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}