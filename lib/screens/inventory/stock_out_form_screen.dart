import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/inventory_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stock_out_provider.dart';
import '../../widgets/common/ao_button.dart';
import '../../widgets/common/ao_text_field.dart';

class StockOutFormScreen extends StatefulWidget {
  final InventoryModel item;
  const StockOutFormScreen({super.key, required this.item});
  @override
  State<StockOutFormScreen> createState() => _StockOutFormScreenState();
}

class _StockOutFormScreenState extends State<StockOutFormScreen> {
  final _form       = GlobalKey<FormState>();
  final _qtyCtrl    = TextEditingController();
  final _reasonCtrl = TextEditingController();
  String? _selectedReason;

  static const _reasons = [
    'Venda', 'Vencido', 'Danificado', 'Devolução', 'Uso interno', 'Outro',
  ];

  @override
  void dispose() { _qtyCtrl.dispose(); _reasonCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final reason = (_selectedReason == 'Outro' || _selectedReason == null)
        ? _reasonCtrl.text.trim()
        : _selectedReason!;
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Informe o motivo da baixa.'),
          backgroundColor: AppColors.vermelho));
      return;
    }

    final auth = context.read<AuthProvider>();
    final prov = context.read<StockOutProvider>();
    final ok   = await prov.register(
      inventoryItemId:   widget.item.id,
      inventoryItemName: widget.item.productName,
      batchNumber:       widget.item.batchNumber,
      quantity:          int.tryParse(_qtyCtrl.text) ?? 0,
      userId:            auth.currentUser!.id,
      userName:          auth.currentUser!.name,
      reason:            reason,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Baixa registrada com sucesso!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(prov.error ?? AppStrings.errorGeneric),
          backgroundColor: AppColors.vermelho));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<StockOutProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showFreeText =
        _selectedReason == 'Outro' || _selectedReason == null;

    return Scaffold(
      appBar: AppBar(
        title:           const Text(AppStrings.stockOut),
        backgroundColor: AppColors.vermelho,
        foregroundColor: AppColors.branco,
        iconTheme:       const IconThemeData(color: AppColors.branco),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _form, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info do item selecionado
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        AppColors.vermelho.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.vermelho.withOpacity(0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.item.productName ?? 'Produto',
                  style: GoogleFonts.publicSans(
                      fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('Lote: ${widget.item.batchNumber}',
                  style: GoogleFonts.publicSans(
                      fontSize: 12, fontWeight: FontWeight.w300)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.inventory_outlined,
                      size: 14, color: AppColors.azulArdosia),
                  const SizedBox(width: 4),
                  Text(
                    'Disponível: ${widget.item.currentQuantity} unidades',
                    style: GoogleFonts.publicSans(fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.item.isLow
                            ? AppColors.warning
                            : AppColors.success),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 20),

            Text('Dados da baixa',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),

            AoTextField(
              label:           '${AppStrings.stockOutQuantity} *',
              controller:      _qtyCtrl,
              validator:       Validators.maxInt(widget.item.currentQuantity),
              keyboardType:    TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            Text('${AppStrings.stockOutReason} *',
              style: GoogleFonts.publicSans(fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 8),

            // Chips de motivo rápido
            Wrap(
              spacing: 8, runSpacing: 6,
              children: _reasons.map((r) => ChoiceChip(
                label:    Text(r),
                selected: _selectedReason == r,
                onSelected: (v) =>
                    setState(() => _selectedReason = v ? r : null),
                selectedColor: AppColors.vermelho.withOpacity(0.12),
                labelStyle: TextStyle(
                  color: _selectedReason == r
                      ? AppColors.vermelho : null,
                  fontWeight: _selectedReason == r
                      ? FontWeight.w600 : FontWeight.w400),
                side: BorderSide(
                  color: _selectedReason == r
                      ? AppColors.vermelho
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder)),
              )).toList(),
            ),

            if (showFreeText) ...[
              const SizedBox(height: 12),
              AoTextField(
                label:    'Descreva o motivo *',
                controller: _reasonCtrl,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
            const SizedBox(height: 28),

            AoButton(
              label:    'Confirmar baixa',
              onPressed: _save,
              loading:  prov.loading,
              variant:  AoButtonVariant.danger,
              icon:     Icons.trending_down_rounded,
            ),
            const SizedBox(height: 12),
            AoButton(
              label:    AppStrings.cancel,
              onPressed: () => Navigator.pop(context),
              variant:  AoButtonVariant.outlined,
            ),
          ],
        )),
      ),
    );
  }
}