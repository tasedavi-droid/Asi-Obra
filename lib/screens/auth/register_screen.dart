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
  bool _obscure1   = true;
  bool _obscure2   = true;

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
        content: Text(auth.error ?? AppStrings.errorGeneric),
        backgroundColor: AppColors.vermelho));
    }
  }

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
                  Text(AppStrings.register,
                    style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 24),
                  // Nome
                  AoTextField(
                    label: AppStrings.name,
                    controller: _nameCtrl,
                    validator: Validators.required,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  // E-mail
                  AoTextField(
                    label: AppStrings.email,
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  // Senha
                  AoTextField(
                    label: AppStrings.password,
                    controller: _passCtrl,
                    validator: Validators.password,
                    obscureText: _obscure1,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Confirmar senha
                  AoTextField(
                    label: AppStrings.confirmPassword,
                    controller: _pass2Ctrl,
                    validator: Validators.confirmPassword(_passCtrl.text),
                    obscureText: _obscure2,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoBox(),
                  const SizedBox(height: 24),
                  AoButton(
                    label: AppStrings.criarConta,
                    onPressed: _register,
                    loading: isLoading,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.publicSans(fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                        children: [
                          const TextSpan(text: AppStrings.hasAccount),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(AppStrings.doLogin,
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

class _InfoBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.azulArdosia.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: AppColors.azulArdosia.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, size: 16, color: AppColors.azulArdosia),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Novas contas recebem acesso de Leitor. '
            'Um Administrador poderá alterar suas permissões.',
            style: GoogleFonts.publicSans(
              fontSize: 12, fontWeight: FontWeight.w300,
              color: AppColors.azulArdosia),
          ),
        ),
      ]),
    );
  }
}