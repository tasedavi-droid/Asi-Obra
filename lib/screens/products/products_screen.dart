import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/ao_text_field.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov  = context.watch<ProductProvider>();
    final auth  = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.products)),
      body: Column(children: [

        // ── Banner permissão para LEITOR ──────────────────────
        if (!auth.canEdit)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.azulArdosia.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.azulArdosia.withOpacity(0.30))),
            child: Row(children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.azulArdosia),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Você está no modo Leitor. Apenas Estoquistas e Administradores podem cadastrar ou editar produtos.',
                  style: GoogleFonts.publicSans(
                    fontSize: 12, fontWeight: FontWeight.w300,
                    color: isDark
                        ? AppColors.perola.withOpacity(0.75)
                        : AppColors.azulArdosia)),
              ),
            ]),
          ),

        // ── Busca ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: AoTextField(
            label:      AppStrings.search,
            prefixIcon: const Icon(Icons.search, size: 18),
            onChanged:  prov.setSearch,
          ),
        ),

        // ── Lista ─────────────────────────────────────────────
        Expanded(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator(
                  color: AppColors.vermelho))
              : prov.products.isEmpty
                  ? _Empty(canEdit: auth.canEdit)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: prov.products.length,
                      itemBuilder: (_, i) => _ProductCard(
                        product: prov.products[i],
                        canEdit: auth.canEdit,
                        isAdmin: auth.isAdmin,
                      ),
                    ),
        ),
      ]),

      // ── FAB — apenas Estoquista/Admin ─────────────────────────
      floatingActionButton: auth.canEdit
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const ProductFormScreen())),
              backgroundColor: AppColors.vermelho,
              foregroundColor: Colors.white,
              elevation: 2,
              icon:  const Icon(Icons.add),
              label: Text(AppStrings.addProduct,
                  style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

// ── Card de produto ────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool canEdit, isAdmin;
  const _ProductCard({
    required this.product,
    required this.canEdit,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                  style: GoogleFonts.publicSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  if (product.type.isNotEmpty)
                    _Tag(product.type, AppColors.azulArdosia),
                  if (product.brand.isNotEmpty)
                    _Tag(product.brand, AppColors.vermelho),
                ]),
                if (product.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(product.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              ],
            ),
          ),

          // Menu ações — apenas Estoquista/Admin
          if (canEdit)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) async {
                if (v == 'edit') {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ProductFormScreen(product: product)));
                } else if (v == 'delete') {
                  final ok = await _confirmDelete(context);
                  if (ok && context.mounted)
                    context.read<ProductProvider>().delete(product.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined, size: 18),
                    title: Text(AppStrings.edit))),
                if (isAdmin)
                  const PopupMenuItem(value: 'delete',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline,
                          size: 18, color: AppColors.vermelho),
                      title: Text(AppStrings.delete,
                          style: TextStyle(color: AppColors.vermelho)))),
              ],
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext ctx) async {
    final r = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title:   const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.undoneAction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text(AppStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vermelho,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(_, true),
            child: const Text(AppStrings.delete)),
        ],
      ),
    );
    return r ?? false;
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label; final Color color;
  const _Tag(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color:        color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: GoogleFonts.publicSans(
        fontSize: 10, fontWeight: FontWeight.w500, color: color)),
  );
}

class _Empty extends StatelessWidget {
  final bool canEdit;
  const _Empty({required this.canEdit});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.inventory_2_outlined,
          size: 52, color: AppColors.perola),
      const SizedBox(height: 12),
      Text(AppStrings.noProducts,
        style: GoogleFonts.publicSans(fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color)),
      if (canEdit) ...[
        const SizedBox(height: 8),
        Text('Toque no botão + para cadastrar.',
          style: GoogleFonts.publicSans(fontSize: 12,
              color: AppColors.vermelho)),
      ],
    ]),
  );
}