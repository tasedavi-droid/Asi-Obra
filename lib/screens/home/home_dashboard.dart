import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/stock_out_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/stock_out_provider.dart';
import '../../providers/theme_provider.dart';

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final products  = context.watch<ProductProvider>();
    final inventory = context.watch<InventoryProvider>();
    final stockOuts = context.watch<StockOutProvider>();
    final theme     = context.watch<ThemeProvider>();
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    final firstName  = auth.currentUser?.name.split(' ').first ?? '';
    final alertCount = inventory.alertCount;

    final bg        = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final titleColor = isDark ? Colors.white             : AppColors.lightTextTitle;
    final subColor  = isDark ? AppColors.darkTextBody    : AppColors.lightTextBody;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final border    = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final divColor  = isDark ? _divEscuro : _divClaro;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [

          Container(
            width: double.infinity,
            color: bg,
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo.png',
                      width: 56, height: 56, fit: BoxFit.contain,
                      color: AppColors.vermelho,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.home_repair_service_rounded,
                        color: AppColors.vermelho, size: 56)),
                    const SizedBox(height: 6),
                    Text('Asi & Obra',
                      style: GoogleFonts.publicSans(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: AppColors.vermelho)),
                    const SizedBox(height: 2),
                    Text('Olá, $firstName!',
                      style: GoogleFonts.publicSans(
                        fontSize: 13, fontWeight: FontWeight.w400,
                        color: subColor)),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: IconButton(
                    onPressed: theme.toggle,
                    icon: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      color: subColor, size: 24),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 2, width: double.infinity, color: divColor),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                Text('Resumo', style: GoogleFonts.publicSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.7,
                  children: [
                    _SCard(icon: Icons.inventory_2_outlined,
                      value: products.total.toString(), label: 'Produtos',
                      vColor: isDark ? Colors.white : AppColors.lightTextTitle,
                      lColor: subColor, card: cardColor, bdr: border),
                    _SCard(icon: Icons.warehouse_outlined,
                      value: inventory.total.toString(), label: 'Lotes',
                      vColor: isDark ? Colors.white : AppColors.lightTextTitle,
                      lColor: subColor, card: cardColor, bdr: border),
                    _SCard(icon: Icons.trending_down_rounded,
                      value: stockOuts.total.toString(), label: 'Baixas',
                      vColor: isDark ? Colors.white : AppColors.lightTextTitle,
                      lColor: subColor, card: cardColor, bdr: border),
                    _SCard(icon: Icons.warning_amber_rounded,
                      value: alertCount.toString(), label: 'Alertas',
                      vColor: alertCount > 0 ? AppColors.warning : AppColors.success,
                      lColor: subColor, card: cardColor, bdr: border),
                  ],
                ),

                const SizedBox(height: 24),
                Text('Últimas Baixas', style: GoogleFonts.publicSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: titleColor)),
                const SizedBox(height: 12),

                if (stockOuts.stockOuts.isEmpty)
                  Text('Nenhuma baixa registrada.',
                    style: GoogleFonts.publicSans(fontSize: 13, color: subColor))
                else
                  ...stockOuts.stockOuts.take(5).map((s) => _BRow(
                    so: s, tc: titleColor, sc: subColor, card: cardColor, bdr: border)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SCard extends StatelessWidget {
  final IconData icon; final String value, label;
  final Color vColor, lColor, card, bdr;
  const _SCard({required this.icon, required this.value, required this.label,
    required this.vColor, required this.lColor, required this.card, required this.bdr});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: bdr)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: vColor, size: 22),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.publicSans(
            fontSize: 24, fontWeight: FontWeight.w700, color: vColor)),
          Text(label, style: GoogleFonts.publicSans(fontSize: 11, color: lColor)),
        ]),
      ]),
  );
}

class _BRow extends StatelessWidget {
  final StockOutModel so; final Color tc, sc, card, bdr;
  const _BRow({required this.so, required this.tc, required this.sc,
    required this.card, required this.bdr});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: bdr)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 3, child: _C('Item:', so.inventoryItemName ?? '—', tc, sc)),
      Expanded(flex: 3, child: _C('Usuário:', so.userName ?? '—', tc, sc)),
      Expanded(flex: 3, child: _C('Data:', DateFormatter.date(so.date), tc, sc)),
      Text(so.quantity.toString().padLeft(2, '0'), style: GoogleFonts.publicSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: tc)),
    ]),
  );
}

class _C extends StatelessWidget {
  final String l, v; final Color tc, sc;
  const _C(this.l, this.v, this.tc, this.sc);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l, style: GoogleFonts.publicSans(fontSize: 10, color: sc)),
      Text(v, style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600, color: tc),
        maxLines: 1, overflow: TextOverflow.ellipsis),
    ]);
}