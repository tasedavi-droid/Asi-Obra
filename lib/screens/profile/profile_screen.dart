import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/ao_text_field.dart';
import '../../widgets/common/role_badge.dart';

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final auth    = context.read<AuthProvider>();
    final ctrl    = TextEditingController(text: auth.currentUser?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2730) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding:   const EdgeInsets.fromLTRB(20, 24, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Text('Editar nome', style: GoogleFonts.publicSans(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.lightTextTitle)),
        content: Form(key: formKey,
          child: AoTextField(label: 'Nome', controller: ctrl,
            validator: Validators.required,
            textCapitalization: TextCapitalization.words)),
        actions: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  await context.read<AuthProvider>().updateName(ctrl.text.trim());
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nome atualizado!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vermelho, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0),
                child: Text('Salvar', style: GoogleFonts.publicSans(
                  fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vermelho,
                  side: const BorderSide(color: AppColors.vermelho),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('Cancelar', style: GoogleFonts.publicSans(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.vermelho)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final user   = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg         = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg     = isDark ? AppColors.darkCard       : Colors.white;
    final border     = isDark ? AppColors.darkBorder     : AppColors.lightBorder;
    final divColor   = isDark ? _divEscuro               : _divClaro;
    final nameColor  = isDark ? Colors.white              : AppColors.lightTextTitle;
    final emailColor = isDark ? AppColors.darkTextBody    : AppColors.lightTextBody;
    final avatarBg   = isDark ? const Color(0xFF3A4A54)   : const Color(0xFFCDC8BE);
    final avatarTxt  = isDark ? Colors.white60             : AppColors.azulArdosia;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.vermelho))
            : Column(children: [

                Container(
                  width: double.infinity, color: bg,
                  padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo.png',
                        width: 56, height: 56, fit: BoxFit.contain,
                        color: AppColors.vermelho,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.home_repair_service_rounded,
                          color: AppColors.vermelho, size: 56)),
                      const SizedBox(height: 6),
                      Text('Perfil', style: GoogleFonts.publicSans(
                        fontSize: 26, fontWeight: FontWeight.w700,
                        color: AppColors.vermelho)),
                    ],
                  ),
                ),
                Container(height: 2, width: double.infinity, color: divColor),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    children: [

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border)),
                        child: Column(children: [

                          CircleAvatar(
                            radius: 46,
                            backgroundColor: avatarBg,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: GoogleFonts.publicSans(
                                fontSize: 34, fontWeight: FontWeight.w700,
                                color: avatarTxt)),
                          ),
                          const SizedBox(height: 14),

                          Text(user.name, style: GoogleFonts.publicSans(
                            fontSize: 16, fontWeight: FontWeight.w700, color: nameColor)),
                          const SizedBox(height: 4),
                          Text(user.email, style: GoogleFonts.publicSans(
                            fontSize: 13, color: emailColor)),
                          const SizedBox(height: 14),

                          Wrap(
                            spacing: 6, runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children: [
                              RoleBadge(role: user.role),
                              if (user.employeeCode != null)
                                _Badge(
                                  label: user.employeeCode!,
                                  bg: isDark ? const Color(0xFF2A3940) : Colors.transparent,
                                  color: isDark ? Colors.white70 : AppColors.azulArdosia,
                                  borderColor: isDark ? AppColors.darkBorder : AppColors.azulArdosia),
                              _Badge(
                                label: user.isActive ? 'Ativa' : 'Inativa',
                                bg: (user.isActive ? AppColors.success : AppColors.error)
                                    .withOpacity(0.12),
                                color: user.isActive ? AppColors.success : AppColors.error,
                                borderColor: user.isActive ? AppColors.success : AppColors.error),
                            ],
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity, height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () => _editName(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.vermelho,
                                side: const BorderSide(color: AppColors.vermelho),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                              icon: const Icon(Icons.edit_outlined, size: 16,
                                color: AppColors.vermelho),
                              label: Text('Editar nome', style: GoogleFonts.publicSans(
                                fontSize: 14, fontWeight: FontWeight.w500,
                                color: AppColors.vermelho)),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity, height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await auth.logout();
                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.vermelho,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: Text('Sair', style: GoogleFonts.publicSans(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color bg, color, borderColor;
  const _Badge({required this.label, required this.bg, required this.color,
    required this.borderColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4),
      border: Border.all(color: borderColor)),
    child: Text(label, style: GoogleFonts.publicSans(
      fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );
}