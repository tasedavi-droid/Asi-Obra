import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/inventory_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/common/ao_text_field.dart';
import 'inventory_form_screen.dart';
import 'stock_out_form_screen.dart';

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

Color stockColor(InventoryModel item) {
  if (item.isExpired || item.isEmpty) return AppColors.vermelho;
  final pct = item.stockPercent;
  if (pct < 0.20) return AppColors.vermelho;
  if (pct < 0.50) return AppColors.warning;
  return AppColors.success;
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<InventoryProvider>();
    final auth   = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final subColor = isDark ? AppColors.darkTextBody : AppColors.lightTextBody;
    final divColor = isDark ? _divEscuro : _divClaro;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          Container(
            width: double.infinity, color: bg,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 40),
            child: Text('Estoque', style: GoogleFonts.publicSans(
              fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.vermelho)),
          ),
          Container(height: 2, width: double.infinity, color: divColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: AoTextField(label: AppStrings.search,
              prefixIcon: const Icon(Icons.search, size: 18),
              onChanged: prov.setSearch),
          ),
          Expanded(
            child: prov.loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.vermelho))
                : prov.items.isEmpty
                    ? Center(child: Text(AppStrings.noInventory,
                        style: GoogleFonts.publicSans(fontSize: 13, color: subColor)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: prov.items.length,
                        itemBuilder: (_, i) => _InvCard(
                          item: prov.items[i], canEdit: auth.canEdit,
                          isAdmin: auth.isAdmin, isDark: isDark)),
          ),
        ]),
      ),
      floatingActionButton: auth.canEdit ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const InventoryFormScreen())),
        backgroundColor: AppColors.vermelho, foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Novo lote', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
      ) : null,
    );
  }
}

class _InvCard extends StatelessWidget {
  final InventoryModel item; final bool canEdit, isAdmin, isDark;
  const _InvCard({required this.item, required this.canEdit,
    required this.isAdmin, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor  = isDark ? AppColors.darkCard : Colors.white;
    final border     = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final titleColor = isDark ? Colors.white : AppColors.lightTextTitle;
    final subColor   = isDark ? AppColors.darkTextBody : AppColors.lightTextBody;
    final divColor   = isDark ? AppColors.darkBorder : const Color(0xFFD8D3CB);
    final barBg      = isDark ? AppColors.darkBorder : const Color(0xFFE5E1D8);
    final sc         = stockColor(item);
    final actionColor = isDark ? AppColors.darkTextBody : AppColors.lightTextBody;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.productName ?? 'Produto', style: GoogleFonts.publicSans(
              fontSize: 14, fontWeight: FontWeight.w600, color: titleColor)),
            Text('Lote: ${item.batchNumber}', style: GoogleFonts.publicSans(
              fontSize: 11, color: subColor)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Editado: ${DateFormatter.date(item.updatedAt)}',
                  style: GoogleFonts.publicSans(fontSize: 10, color: subColor)),
                if (item.lastEditedByName?.isNotEmpty == true)
                  Text('Por: ${item.lastEditedByName}',
                    style: GoogleFonts.publicSans(fontSize: 10, color: subColor)),
              ]),
              const SizedBox(width: 16),
              Text('Cadastrado: ${DateFormatter.date(item.createdAt)}',
                style: GoogleFonts.publicSans(fontSize: 10, color: subColor)),
            ]),
          ]),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: item.stockPercent, minHeight: 5,
            backgroundColor: barBg,
            valueColor: AlwaysStoppedAnimation(sc)),
        ),
        const SizedBox(height: 10),
        Row(children: [
          _Metric('Qtd. Atual:', item.currentQuantity.toString(), sc),
          const SizedBox(width: 20),
          _Metric('Qtd. Inicial:', item.initialQuantity.toString(), titleColor),
          if (item.expirationDate != null) ...[
            const SizedBox(width: 20),
            _Metric('Validade:', DateFormatter.date(item.expirationDate),
              item.isExpired || item.expiresSoon ? sc : titleColor),
          ],
        ]),
        if (canEdit) ...[
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: divColor),
          const SizedBox(height: 10),
          Row(children: [
            _Act(icon: Icons.trending_down_rounded, label: 'Registrar baixa',
              color: actionColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => StockOutFormScreen(item: item)))),
            const SizedBox(width: 20),
            _Act(icon: Icons.edit_outlined, label: 'Editar', color: actionColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => InventoryFormScreen(item: item)))),
            if (isAdmin) ...[
              const SizedBox(width: 20),
              _Act(icon: Icons.delete_outline, label: 'Excluir',
                color: AppColors.vermelho,
                onTap: () async {
                  final ok = await _confirm(context);
                  if (ok && context.mounted) {
                    context.read<InventoryProvider>().delete(item.id);
                  }
                }),
            ],
          ]),
        ],
      ]),
    );
  }

  Future<bool> _confirm(BuildContext ctx) async {
    final r = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      title: const Text('Excluir lote'),
      content: const Text('Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.vermelho, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(_, true), child: const Text('Excluir')),
      ],
    ));
    return r ?? false;
  }
}

class _Metric extends StatelessWidget {
  final String label; final String? value; final Color color;
  const _Metric(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    final sub = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextBody : AppColors.lightTextBody;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.publicSans(fontSize: 10, color: sub)),
      Text(value ?? '—', style: GoogleFonts.publicSans(
        fontSize: 16, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}

class _Act extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _Act({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.publicSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    ]),
  );
}