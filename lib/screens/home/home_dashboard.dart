import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/stock_out_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_out_provider.dart';
import '../../providers/theme_provider.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final products  = context.watch<ProductProvider>();
    final inventory = context.watch<InventoryProvider>();
    final stockOuts = context.watch<StockOutProvider>();
    final theme     = context.watch<ThemeProvider>();

    final firstName = auth.currentUser?.name.split(' ').first ?? '';
    final expired   = inventory.items.where((i) => i.isExpired).length;
    final expiring  = inventory.items.where((i) => i.expiresSoon && !i.isExpired).length;
    final low       = inventory.items.where((i) => i.isLow && !i.isEmpty).length;
    final empty     = inventory.items.where((i) => i.isEmpty).length;
    final hasAlert  = expired > 0 || expiring > 0 || low > 0 || empty > 0;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.appName,
            style: GoogleFonts.publicSans(fontSize: 17, fontWeight: FontWeight.w700)),
          Text('Olá, $firstName!',
            style: GoogleFonts.publicSans(
              fontSize: 12, fontWeight: FontWeight.w300,
              color: Theme.of(context).textTheme.bodyMedium?.color)),
        ]),
        actions: [
          IconButton(
            tooltip:  'Alternar tema',
            icon:     Icon(theme.isDark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: theme.toggle,
          ),
        ],
      ),
      body: RefreshIndicator(
        color:    AppColors.vermelho,
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // ── Alerta ──────────────────────────────────────────
            if (hasAlert) ...[
              _AlertCard(expired: expired, expiring: expiring, low: low, empty: empty),
              const SizedBox(height: 16),
            ],

            // ── Resumo ───────────────────────────────────────────
            Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount:    2,
              shrinkWrap:        true,
              physics:           const NeverScrollableScrollPhysics(),
              mainAxisSpacing:   10,
              crossAxisSpacing:  10,
              childAspectRatio:  1.6,
              children: [
                _Card(label: 'Produtos',  value: products.total.toString(),
                    icon: Icons.inventory_2_rounded,    color: AppColors.vermelho),
                _Card(label: 'Lotes',     value: inventory.total.toString(),
                    icon: Icons.warehouse_rounded,      color: AppColors.azulArdosia),
                _Card(label: 'Baixas',    value: stockOuts.total.toString(),
                    icon: Icons.trending_down_rounded,  color: AppColors.azulArdosia),
                _Card(label: 'Alertas',   value: inventory.alertCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: hasAlert ? AppColors.warning : AppColors.success),
              ],
            ),

            // ── Últimas baixas ────────────────────────────────────
            const SizedBox(height: 24),
            Text('Últimas baixas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (stockOuts.stockOuts.isEmpty)
              _Empty(message: 'Nenhuma baixa registrada.')
            else
              ...stockOuts.stockOuts.take(5).map((s) => _StockOutTile(s, isDark)),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final int expired, expiring, low, empty;
  const _AlertCard({required this.expired, required this.expiring,
      required this.low, required this.empty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_active_rounded,
              color: AppColors.warning, size: 16),
          const SizedBox(width: 6),
          Text('Atenção', style: GoogleFonts.publicSans(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: AppColors.warning)),
        ]),
        const SizedBox(height: 8),
        if (expired  > 0) _Row('$expired lote(s) vencido(s)',           AppColors.vermelho),
        if (expiring > 0) _Row('$expiring lote(s) vencendo em 30 dias', AppColors.warning),
        if (low      > 0) _Row('$low lote(s) com estoque baixo',        AppColors.warning),
        if (empty    > 0) _Row('$empty lote(s) zerados',                AppColors.vermelho),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String text; final Color color;
  const _Row(this.text, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(children: [
      Container(width: 5, height: 5, margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      Text(text, style: GoogleFonts.publicSans(fontSize: 12, color: color)),
    ]),
  );
}

class _Card extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _Card({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: GoogleFonts.publicSans(
                fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.publicSans(fontSize: 11,
                color: Theme.of(context).textTheme.bodyMedium?.color)),
          ]),
        ]),
    );
  }
}

class _StockOutTile extends StatelessWidget {
  final StockOutModel so;
  final bool isDark;
  const _StockOutTile(this.so, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color:        AppColors.vermelho.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.trending_down_rounded,
              color: AppColors.vermelho, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(so.inventoryItemName ?? 'Item',
            style: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500)),
          Text('${so.reason}  •  ${DateFormatter.date(so.date)}',
            style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w300,
                color: Theme.of(context).textTheme.bodyMedium?.color),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text('-${so.quantity}',
          style: GoogleFonts.publicSans(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.vermelho)),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, style: GoogleFonts.publicSans(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodyMedium?.color)),
    ),
  );
}