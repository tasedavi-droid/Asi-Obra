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

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.inventory)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: AoTextField(
            label:      AppStrings.search,
            prefixIcon: const Icon(Icons.search, size: 18),
            onChanged:  prov.setSearch,
          ),
        ),
        Expanded(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator())
              : prov.items.isEmpty
                  ? _Empty()
                  : ListView.builder(
                      padding:    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount:  prov.items.length,
                      itemBuilder: (_, i) => _InventoryCard(
                        item:    prov.items[i],
                        canEdit: auth.canEdit,
                        isAdmin: auth.isAdmin,
                      ),
                    ),
        ),
      ]),
      floatingActionButton: auth.canEdit
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const InventoryFormScreen())),
              icon:  const Icon(Icons.add),
              label: Text(AppStrings.addInventory,
                  style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final InventoryModel item;
  final bool canEdit, isAdmin;
  const _InventoryCard({required this.item,
      required this.canEdit, required this.isAdmin});

  Color get _statusColor {
    if (item.isExpired || item.isEmpty) return AppColors.vermelho;
    if (item.expiresSoon || item.isLow) return AppColors.warning;
    return AppColors.success;
  }

  String get _statusLabel {
    if (item.isExpired)   return 'Vencido';
    if (item.isEmpty)     return 'Zerado';
    if (item.expiresSoon) return 'Vencendo';
    if (item.isLow)       return 'Baixo';
    return 'OK';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cabeçalho
        Row(children: [
          Expanded(child: Text(item.productName ?? 'Produto',
            style: GoogleFonts.publicSans(
                fontSize: 14, fontWeight: FontWeight.w600))),
          _StatusChip(label: _statusLabel, color: _statusColor),
        ]),
        const SizedBox(height: 3),
        Text('Lote: ${item.batchNumber}',
          style: GoogleFonts.publicSans(fontSize: 11,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).textTheme.bodyMedium?.color)),
        const SizedBox(height: 10),

        // Barra de estoque
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:      item.stockPercent,
            minHeight:  5,
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation(_statusColor),
          ),
        ),
        const SizedBox(height: 8),

        // Métricas
        Row(children: [
          _Metric('Atual',   item.currentQuantity.toString(), _statusColor),
          const SizedBox(width: 16),
          _Metric('Inicial', item.initialQuantity.toString(), null),
          if (item.expirationDate != null) ...[
            const SizedBox(width: 16),
            _Metric('Validade',
                DateFormatter.date(item.expirationDate),
                item.isExpired || item.expiresSoon ? _statusColor : null),
          ],
        ]),

        // Ações
        if (canEdit) ...[
          const SizedBox(height: 10),
          Divider(height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          const SizedBox(height: 6),
          Row(children: [
            _ActionBtn(
              label: AppStrings.edit,
              icon:  Icons.edit_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => InventoryFormScreen(item: item))),
            ),
            const SizedBox(width: 12),
            _ActionBtn(
              label: 'Baixa',
              icon:  Icons.trending_down_rounded,
              color: AppColors.vermelho,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => StockOutFormScreen(item: item))),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 12),
              _ActionBtn(
                label: AppStrings.delete,
                icon:  Icons.delete_outline,
                color: AppColors.vermelho,
                onTap: () async {
                  final ok = await _confirmDelete(context);
                  if (ok && context.mounted)
                    context.read<InventoryProvider>().delete(item.id);
                },
              ),
            ],
          ]),
        ],
      ]),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx) async {
    final r = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      title:   const Text(AppStrings.confirmDelete),
      content: const Text(AppStrings.undoneAction),
      actions: [
        TextButton(onPressed: () => Navigator.pop(_, false),
            child: const Text(AppStrings.cancel)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
              foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(_, true),
          child: const Text(AppStrings.delete)),
      ],
    ));
    return r ?? false;
  }
}

class _StatusChip extends StatelessWidget {
  final String label; final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color:        color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(5)),
    child: Text(label, style: GoogleFonts.publicSans(
        fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _Metric extends StatelessWidget {
  final String label, value; final Color? valueColor;
  const _Metric(this.label, this.value, this.valueColor);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.publicSans(fontSize: 10,
          color: Theme.of(context).textTheme.bodyMedium?.color)),
      Text(value, style: GoogleFonts.publicSans(fontSize: 14,
          fontWeight: FontWeight.w700,
          color: valueColor ??
              Theme.of(context).textTheme.titleLarge?.color)),
    ],
  );
}

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon;
  final Color? color; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon,
      this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14,
          color: color ??
              Theme.of(context).textTheme.bodyMedium?.color),
      const SizedBox(width: 3),
      Text(label, style: GoogleFonts.publicSans(fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color ??
              Theme.of(context).textTheme.bodyMedium?.color)),
    ]),
  );
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.warehouse_outlined,
          size: 52, color: AppColors.perola),
      const SizedBox(height: 12),
      Text(AppStrings.noInventory, style: GoogleFonts.publicSans(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodyMedium?.color)),
    ]),
  );
}