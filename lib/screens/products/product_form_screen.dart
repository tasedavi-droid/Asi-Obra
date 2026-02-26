import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/ao_button.dart';
import '../../widgets/common/ao_text_field.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form  = GlobalKey<FormState>();
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
  void dispose() {
    _name.dispose(); _type.dispose();
    _brand.dispose(); _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final prov = context.read<ProductProvider>();

    if (_editing) {
      await prov.update(
        p: widget.product!.copyWith(
          name:        _name.text.trim(),
          type:        _type.text.trim(),
          brand:       _brand.text.trim(),
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        ),
        userId:   auth.currentUser!.id,
        userName: auth.currentUser!.name,
      );
    } else {
      await prov.create(
        name:        _name.text.trim(),
        type:        _type.text.trim(),
        brand:       _brand.text.trim(),
        description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        userId:      auth.currentUser!.id,
        userName:    auth.currentUser!.name,
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
    final prov = context.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(
          title: Text(_editing
              ? AppStrings.editProduct
              : AppStrings.addProduct)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _form, child: Column(children: [
          AoTextField(
            label: '${AppStrings.productName} *',
            controller: _name,
            validator: Validators.required,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AoTextField(
            label: '${AppStrings.productType} *',
            controller: _type,
            validator: Validators.required,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AoTextField(
            label: '${AppStrings.productBrand} *',
            controller: _brand,
            validator: Validators.required,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AoTextField(
            label:    AppStrings.productDescription,
            controller: _desc,
            maxLines:   3,
            textCapitalization: TextCapitalization.sentences,
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