import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/ao_text_field.dart';

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _State();
}

class _State extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _type, _brand, _desc;
  bool get _editing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _name  = TextEditingController(text: widget.product?.name        ?? '');
    _type  = TextEditingController(text: widget.product?.type        ?? '');
    _brand = TextEditingController(text: widget.product?.brand       ?? '');
    _desc  = TextEditingController(text: widget.product?.description ?? '');
  }

  @override
  void dispose() { _name.dispose(); _type.dispose(); _brand.dispose(); _desc.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final prov = context.read<ProductProvider>();
    if (_editing) {
      await prov.update(
        p: widget.product!.copyWith(name: _name.text.trim(), type: _type.text.trim(),
          brand: _brand.text.trim(),
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim()),
        userId: auth.currentUser!.id, userName: auth.currentUser!.name);
    } else {
      await prov.create(
        name: _name.text.trim(), type: _type.text.trim(), brand: _brand.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        userId: auth.currentUser!.id, userName: auth.currentUser!.name);
    }
    if (!mounted) return;
    if (prov.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.successSave)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(prov.error!), backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov     = context.watch<ProductProvider>();
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final divColor = isDark ? _divEscuro : _divClaro;
    final lc       = isDark ? Colors.white70 : AppColors.lightTextTitle;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context), color: AppColors.vermelho),
        title: Text(_editing ? 'Editar Produto' : 'Cadastrar Produto',
          style: GoogleFonts.publicSans(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.vermelho)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, width: double.infinity, color: divColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
        child: Form(key: _form, child: Column(children: [
          _LF(label: 'Nome:', lc: lc,
            child: AoTextField(label: 'Nome*', controller: _name,
              validator: Validators.required,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next)),
          const SizedBox(height: 20),
          _LF(label: 'Tipo:', lc: lc,
            child: AoTextField(label: 'Tipo*', controller: _type,
              validator: Validators.required,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next)),
          const SizedBox(height: 20),
          _LF(label: 'Marca:', lc: lc,
            child: AoTextField(label: 'Marca*', controller: _brand,
              validator: Validators.required,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next)),
          const SizedBox(height: 20),
          _LF(label: 'Descrição:', lc: lc,
            child: AoTextField(label: 'Descrição*', controller: _desc,
              maxLines: 3, textCapitalization: TextCapitalization.sentences)),
          const SizedBox(height: 36),
          _PBtn(label: _editing ? 'Salvar alterações' : 'Cadastrar',
            onTap: prov.loading ? null : _save, loading: prov.loading),
          const SizedBox(height: 12),
          _OBtn(onTap: () => Navigator.pop(context)),
        ])),
      ),
    );
  }
}

class _LF extends StatelessWidget {
  final String label; final Color lc; final Widget child;
  const _LF({required this.label, required this.lc, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: lc)),
      const SizedBox(height: 8), child,
    ]);
}

class _PBtn extends StatelessWidget {
  final String label; final VoidCallback? onTap; final bool loading;
  const _PBtn({required this.label, this.onTap, this.loading = false});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vermelho, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
      icon: loading
          ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.save_outlined, size: 18),
      label: Text(label, style: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w600))));
}

class _OBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _OBtn({required this.onTap});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 52,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.vermelho,
        side: const BorderSide(color: AppColors.vermelho),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text('Cancelar', style: GoogleFonts.publicSans(
        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.vermelho))));
}