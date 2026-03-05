import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/inventory_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/ao_text_field.dart';

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

class InventoryFormScreen extends StatefulWidget {
  final InventoryModel? item;
  const InventoryFormScreen({super.key, this.item});
  @override
  State<InventoryFormScreen> createState() => _State();
}

class _State extends State<InventoryFormScreen> {
  final _form        = GlobalKey<FormState>();
  final _batchCtrl   = TextEditingController();
  final _initQtyCtrl = TextEditingController();
  final _currQtyCtrl = TextEditingController();
  final _expiCtrl    = TextEditingController();
  ProductModel? _product;
  DateTime?     _expiDate;
  bool get _editing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _batchCtrl.text   = widget.item!.batchNumber;
      _initQtyCtrl.text = widget.item!.initialQuantity.toString();
      _currQtyCtrl.text = widget.item!.currentQuantity.toString();
      _expiDate = widget.item!.expirationDate;
      if (_expiDate != null) _expiCtrl.text = DateFormatter.date(_expiDate);
    }
  }

  @override
  void dispose() {
    _batchCtrl.dispose(); _initQtyCtrl.dispose();
    _currQtyCtrl.dispose(); _expiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context,
      initialDate: _expiDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (d != null) setState(() { _expiDate = d; _expiCtrl.text = DateFormatter.date(d); });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (!_editing && _product == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecione um produto.'), backgroundColor: AppColors.vermelho));
      return;
    }
    final auth = context.read<AuthProvider>();
    final prov = context.read<InventoryProvider>();
    if (_editing) {
      await prov.update(
        item: widget.item!.copyWith(
          batchNumber: _batchCtrl.text.trim(),
          initialQuantity: int.tryParse(_initQtyCtrl.text) ?? 0,
          currentQuantity: int.tryParse(_currQtyCtrl.text) ?? 0,
          expirationDate: _expiDate),
        userId: auth.currentUser!.id, userName: auth.currentUser!.name);
    } else {
      await prov.create(
        productId: _product!.id, productName: _product!.name,
        batchNumber: _batchCtrl.text.trim(),
        initialQuantity: int.tryParse(_initQtyCtrl.text) ?? 0,
        expirationDate: _expiDate,
        userId: auth.currentUser!.id, userName: auth.currentUser!.name);
    }
    if (!mounted) return;
    if (prov.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.successSave)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(prov.error!), backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov     = context.watch<InventoryProvider>();
    final products = context.watch<ProductProvider>().products;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final divColor = isDark ? _divEscuro : _divClaro;
    final lc       = isDark ? Colors.white70 : AppColors.lightTextTitle;

    if (_editing && _product == null && products.isNotEmpty) {
      _product = products.firstWhere(
          (p) => p.id == widget.item!.productId, orElse: () => products.first);
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context), color: AppColors.vermelho),
        title: Text(_editing ? 'Editar Lote' : 'Cadastrar Lote',
          style: GoogleFonts.publicSans(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.vermelho)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, width: double.infinity, color: divColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
        child: Form(key: _form, child: Column(children: [
          _LF(label: 'Produto:', lc: lc,
            child: !_editing
                ? DropdownButtonFormField<ProductModel>(
                    value: _product,
                    decoration: const InputDecoration(hintText: 'Produto*'),
                    items: products.map((p) => DropdownMenuItem(
                      value: p, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (p) => setState(() => _product = p),
                    validator: (v) => v == null ? AppStrings.fieldRequired : null)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    child: Row(children: [
                      Expanded(child: Text(widget.item!.productName ?? '—',
                        style: GoogleFonts.publicSans(fontSize: 14,
                          color: isDark ? Colors.white : AppColors.lightTextTitle))),
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.azulArdosia),
                    ]))),
          const SizedBox(height: 20),
          _LF(label: 'Número do lote:', lc: lc,
            child: AoTextField(label: 'Número do lote*', controller: _batchCtrl,
              validator: Validators.required,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next)),
          const SizedBox(height: 20),
          _LF(label: 'Quantidade inicial:', lc: lc,
            child: AoTextField(label: 'Quantidade inicial*', controller: _initQtyCtrl,
              validator: Validators.positiveInt, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next)),
          const SizedBox(height: 20),
          if (_editing) ...[
            _LF(label: 'Quantidade atual:', lc: lc,
              child: AoTextField(label: 'Quantidade atual*', controller: _currQtyCtrl,
                validator: Validators.nonNegativeInt, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next)),
            const SizedBox(height: 20),
          ],
          _LF(label: 'Data de validade:', lc: lc,
            child: AoTextField(
              label: 'Data de Validade', controller: _expiCtrl,
              readOnly: true, onTap: _pickDate,
              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              suffixIcon: _expiDate != null
                  ? IconButton(icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() { _expiDate = null; _expiCtrl.clear(); }))
                  : null)),
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