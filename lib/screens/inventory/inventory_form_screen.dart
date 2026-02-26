import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../widgets/common/ao_button.dart';
import '../../widgets/common/ao_text_field.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryModel? item;
  const InventoryFormScreen({super.key, this.item});
  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
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
    final d = await showDatePicker(
      context:     context,
      initialDate: _expiDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate:   DateTime.now(),
      lastDate:    DateTime(2100),
    );
    if (d != null) {
      setState(() { _expiDate = d; _expiCtrl.text = DateFormatter.date(d); });
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (!_editing && _product == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selecione um produto.'),
          backgroundColor: AppColors.vermelho));
      return;
    }

    final auth = context.read<AuthProvider>();
    final prov = context.read<InventoryProvider>();

    if (_editing) {
      await prov.update(
        item: widget.item!.copyWith(
          batchNumber:     _batchCtrl.text.trim(),
          initialQuantity: int.tryParse(_initQtyCtrl.text) ?? 0,
          currentQuantity: int.tryParse(_currQtyCtrl.text) ?? 0,
          expirationDate:  _expiDate,
        ),
        userId:   auth.currentUser!.id,
        userName: auth.currentUser!.name,
      );
    } else {
      await prov.create(
        productId:       _product!.id,
        productName:     _product!.name,
        batchNumber:     _batchCtrl.text.trim(),
        initialQuantity: int.tryParse(_initQtyCtrl.text) ?? 0,
        expirationDate:  _expiDate,
        userId:          auth.currentUser!.id,
        userName:        auth.currentUser!.name,
      );
    }

    if (!mounted) return;
    if (prov.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.successSave)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(prov.error!),
          backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov     = context.watch<InventoryProvider>();
    final products = context.watch<ProductProvider>().products;

    if (_editing && _product == null && products.isNotEmpty) {
      _product = products.firstWhere(
          (p) => p.id == widget.item!.productId,
          orElse: () => products.first);
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(_editing
              ? AppStrings.editInventory
              : AppStrings.addInventory)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _form, child: Column(children: [
          // Produto
          if (!_editing)
            DropdownButtonFormField<ProductModel>(
              value:     _product,
              decoration: const InputDecoration(hintText: 'Produto *'),
              items: products.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (p) => setState(() => _product = p),
              validator: (v) =>
                  v == null ? AppStrings.fieldRequired : null,
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder : AppColors.lightBorder)),
              child: Row(children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 18, color: AppColors.azulArdosia),
                const SizedBox(width: 8),
                Text(widget.item!.productName ?? '—',
                    style: Theme.of(context).textTheme.bodyLarge),
              ]),
            ),
          const SizedBox(height: 14),

          AoTextField(
            label:      '${AppStrings.batchNumber} *',
            controller: _batchCtrl,
            validator:  Validators.required,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          AoTextField(
            label:           '${AppStrings.initialQuantity} *',
            controller:      _initQtyCtrl,
            validator:       Validators.positiveInt,
            keyboardType:    TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          if (_editing) ...[
            AoTextField(
              label:           '${AppStrings.currentQuantity} *',
              controller:      _currQtyCtrl,
              validator:       Validators.nonNegativeInt,
              keyboardType:    TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
          ],

          AoTextField(
            label:      AppStrings.expirationDate,
            controller: _expiCtrl,
            readOnly:   true,
            onTap:      _pickDate,
            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            suffixIcon: _expiDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () => setState(
                        () { _expiDate = null; _expiCtrl.clear(); }))
                : null,
          ),
          const SizedBox(height: 28),

          AoButton(
            label:    AppStrings.save,
            onPressed: _save,
            loading:  prov.loading,
            icon:     Icons.save_outlined,
          ),
          const SizedBox(height: 12),
          AoButton(
            label:    AppStrings.cancel,
            onPressed: () => Navigator.pop(context),
            variant:  AoButtonVariant.outlined,
          ),
        ])),
      ),
    );
  }
}