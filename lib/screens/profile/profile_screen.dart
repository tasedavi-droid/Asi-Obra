import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/ao_button.dart';
import '../../widgets/common/ao_text_field.dart';
import '../../widgets/common/role_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool             _showUsers    = false;
  List<UserModel>  _users        = [];
  bool             _loadingUsers = false;

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    _users = await context.read<AuthProvider>().getAllUsers();
    setState(() { _loadingUsers = false; _showUsers = true; });
  }

  Future<void> _editName() async {
    final user = context.read<AuthProvider>().currentUser!;
    final ctrl = TextEditingController(text: user.name);
    final key  = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   const Text('Editar nome'),
        content: Form(key: key, child: AoTextField(
          label:    AppStrings.name,
          controller: ctrl,
          validator: Validators.required,
          textCapitalization: TextCapitalization.words,
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (!key.currentState!.validate()) return;
              Navigator.pop(ctx);
              await context.read<AuthProvider>()
                  .updateName(ctrl.text.trim());
              if (mounted) _showSnack(AppStrings.successSave);
            },
            child: const Text(AppStrings.save)),
        ],
      ),
    );
  }

  Future<void> _changeRole(UserModel user) async {
    UserRole? sel = user.role;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Permissão — ${user.name.split(' ').first}'),
        content: StatefulBuilder(builder: (ctx, set) => Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((r) => RadioListTile<UserRole>(
            title:          Text(r.label),
            value:          r,
            groupValue:     sel,
            onChanged:      (v) => set(() => sel = v),
            activeColor:    AppColors.vermelho,
            contentPadding: EdgeInsets.zero,
          )).toList(),
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (sel != null) {
                await context.read<AuthProvider>()
                    .updateRole(user.id, sel!);
                await _loadUsers();
              }
            },
            child: const Text(AppStrings.save)),
        ],
      ),
    );
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                _UserCard(user: user, onEditName: _editName),
                const SizedBox(height: 16),

                // Gerenciar usuários — somente admin
                if (auth.isAdmin) ...[
                  _UsersCard(
                    showUsers:     _showUsers,
                    loadingUsers:  _loadingUsers,
                    users:         _users,
                    currentUserId: user.id,
                    onToggle: _showUsers
                        ? () => setState(() => _showUsers = false)
                        : _loadUsers,
                    onChangeRole: _changeRole,
                    onToggleActive: (u, active) async {
                      await auth.setActive(u.id, active);
                      await _loadUsers();
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                AoButton(
                  label:    AppStrings.logout,
                  onPressed: () async {
                    await auth.logout();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.login);
                  },
                  variant: AoButtonVariant.danger,
                  icon:    Icons.logout_rounded,
                ),
              ],
            ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel    user;
  final VoidCallback onEditName;
  const _UserCard({required this.user, required this.onEditName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.vermelho.withOpacity(0.12),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: GoogleFonts.publicSans(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: AppColors.vermelho),
          ),
        ),
        const SizedBox(height: 12),
        Text(user.name,  style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RoleBadge(role: user.role),
          if (user.employeeCode != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color:        AppColors.perola.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4)),
              child: Text(user.employeeCode!,
                style: GoogleFonts.publicSans(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color)),
            ),
          ],
          const SizedBox(width: 8),
          // Badge de conta ativa/inativa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (user.isActive ? AppColors.success : AppColors.error)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(4)),
            child: Text(user.isActive ? 'Ativa' : 'Inativa',
              style: GoogleFonts.publicSans(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: user.isActive ? AppColors.success : AppColors.error)),
          ),
        ]),
        const SizedBox(height: 16),
        AoButton(
          label:    'Editar nome',
          onPressed: onEditName,
          variant:  AoButtonVariant.outlined,
          icon:     Icons.edit_outlined,
          height:   44,
        ),
      ]),
    );
  }
}

class _UsersCard extends StatelessWidget {
  final bool                         showUsers, loadingUsers;
  final List<UserModel>              users;
  final String                       currentUserId;
  final VoidCallback                 onToggle;
  final void Function(UserModel)     onChangeRole;
  final void Function(UserModel, bool) onToggleActive;

  const _UsersCard({
    required this.showUsers,
    required this.loadingUsers,
    required this.users,
    required this.currentUserId,
    required this.onToggle,
    required this.onChangeRole,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color:        Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(children: [
        ListTile(
          leading:   const Icon(Icons.people_outline, color: AppColors.vermelho),
          title:     const Text('Gerenciar usuários'),
          subtitle:  const Text('Alterar permissões e status da equipe'),
          trailing:  Icon(showUsers ? Icons.expand_less : Icons.expand_more),
          onTap:     onToggle,
        ),
        if (loadingUsers)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator()),
        if (showUsers) ...[
          const Divider(height: 1),
          ...users
              .where((u) => u.id != currentUserId)
              .map((u) => ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.vermelho.withOpacity(0.1),
                  child: Text(
                    u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                    style: GoogleFonts.publicSans(
                        color: AppColors.vermelho, fontSize: 13)),
                ),
                title: Text(u.name,
                  style: GoogleFonts.publicSans(
                      fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Text(u.email,
                  style: GoogleFonts.publicSans(fontSize: 11)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  // Toggle ativo/inativo
                  Switch(
                    value:     u.isActive,
                    onChanged: (v) => onToggleActive(u, v),
                    activeColor: AppColors.success,
                  ),
                  // Badge de role clicável
                  GestureDetector(
                    onTap: () => onChangeRole(u),
                    child: RoleBadge(role: u.role),
                  ),
                ]),
              )),
        ],
      ]),
    );
  }
}