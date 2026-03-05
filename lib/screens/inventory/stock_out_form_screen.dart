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
import '../../widgets/common/ao_text_field.dart';
import 'inventory_screen.dart' show stockColor;

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

class StockOutFormScreen extends StatefulWidget {
  final InventoryModel item;
  const StockOutFormScreen({super.key, required this.item});
  @override
  State<StockOutFormScreen> createState() => _State();
}

class _State extends State<StockOutFormScreen> {
  final _form     = GlobalKey<FormState>();
  final _qtyCtrl  = TextEditingController();
  final _freeCtrl = TextEditingController();
  String? _sel;

  static const _reasons = ['Venda','Vencido','Danificado','Devolução','Uso interno','Outro'];

  @override
  void dispose() { _qtyCtrl.dispose(); _freeCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final reason = (_sel == 'Outro' || _sel == null) ? _freeCtrl.text.trim() : _sel!;
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
    final prov       = context.watch<StockOutProvider>();
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bg         = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final divColor   = isDark ? _divEscuro : _divClaro;
    final titleColor = isDark ? Colors.white : AppColors.lightTextTitle;
    final subColor   = isDark ? AppColors.darkTextBody : AppColors.lightTextBody;
    final sc         = stockColor(widget.item);
    final showFree   = _sel == 'Outro' || _sel == null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, surfaceTintColor: Colors.transparent,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context), color: AppColors.vermelho),
        title: Text('Registrar Baixa', style: GoogleFonts.publicSans(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.vermelho)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, width: double.infinity, color: divColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 40),
        child: Form(key: _form, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Card produto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.vermelho.withOpacity(isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.vermelho.withOpacity(0.35))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Produto: ${widget.item.productName ?? '—'}',
                  style: GoogleFonts.publicSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: titleColor)),
                const SizedBox(height: 2),
                Text('Lote: ${widget.item.batchNumber}',
                  style: GoogleFonts.publicSans(fontSize: 12, color: titleColor)),
                const SizedBox(height: 4),
                RichText(text: TextSpan(
                  style: GoogleFonts.publicSans(fontSize: 12),
                  children: [
                    TextSpan(text: 'Disponível: ', style: TextStyle(color: titleColor)),
                    TextSpan(text: '${widget.item.currentQuantity} unidades',
                      style: TextStyle(color: sc, fontWeight: FontWeight.w700)),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 24),

            Text('Dados da baixa', style: GoogleFonts.publicSans(
              fontSize: 16, fontWeight: FontWeight.w700, color: titleColor)),
            const SizedBox(height: 16),

            AoTextField(
              label: 'Quantidade*', controller: _qtyCtrl,
              validator: Validators.maxInt(widget.item.currentQuantity),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next),
            const SizedBox(height: 20),

            Text('Motivo da baixa*', style: GoogleFonts.publicSans(
              fontSize: 14, fontWeight: FontWeight.w500, color: subColor)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8, runSpacing: 8,
              children: _reasons.map((r) {
                final sel = _sel == r;
                return GestureDetector(
                  onTap: () => setState(() => _sel = sel ? null : r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.vermelho
                          : AppColors.vermelho.withOpacity(isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.vermelho.withOpacity(sel ? 1.0 : 0.35))),
                    child: Text(r, style: GoogleFonts.publicSans(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: sel
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.azulArdosia))),
                  ),
                );
              }).toList(),
            ),

            if (showFree) ...[
              const SizedBox(height: 14),
              AoTextField(
                label: 'Descreva o motivo*', controller: _freeCtrl,
                maxLines: 2, textCapitalization: TextCapitalization.sentences),
            ],
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: prov.loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vermelho, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
                icon: prov.loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.trending_down_rounded, size: 18),
                label: Text('Confirmar baixa', style: GoogleFonts.publicSans(
                  fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vermelho,
                  side: const BorderSide(color: AppColors.vermelho),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Cancelar', style: GoogleFonts.publicSans(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.vermelho)),
              ),
            ),
          ],
        )),
      ),
    );
  }
}