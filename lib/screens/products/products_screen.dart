import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/ao_text_field.dart';
import 'product_form_screen.dart';

const _divClaro  = Color(0xFFC4B9A8);
const _divEscuro = Color(0xFF253038);

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<ProductProvider>();
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
            child: Text('Produtos', style: GoogleFonts.publicSans(
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
                : prov.products.isEmpty
                    ? Center(child: Text(AppStrings.noProducts,
                        style: GoogleFonts.publicSans(fontSize: 13, color: subColor)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: prov.products.length,
                        itemBuilder: (_, i) => _ProductCard(
                          product: prov.products[i], canEdit: auth.canEdit,
                          isAdmin: auth.isAdmin, isDark: isDark)),
          ),
        ]),
      ),
      floatingActionButton: auth.canEdit ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen())),
        backgroundColor: AppColors.vermelho, foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Novo produto', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
      ) : null,
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product; final bool canEdit, isAdmin, isDark;
  const _ProductCard({required this.product, required this.canEdit,
    required this.isAdmin, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final border    = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    // Nome: cor de título (branco/darkTitle)
    final nameColor = isDark ? Colors.white : AppColors.lightTextTitle;
    // Descrição + Editado/Cadastrado/Por: cinza em ambos modos
    final metaColor = isDark ? AppColors.darkTextBody : AppColors.lightTextBody;
    final tagBg     = isDark ? const Color(0xFF253038) : const Color(0xFFF0EDE6);
    final tagBorder = isDark ? const Color(0xFF334450) : const Color(0xFFD8D3CB);
    final tagColor  = isDark ? AppColors.darkTextBody  : AppColors.azulArdosia;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Nome: cor título
              Text('Nome: ${product.name}', style: GoogleFonts.publicSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: nameColor)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 4, children: [
                if (product.type.isNotEmpty)
                  _Tag(product.type, bg: tagBg, border: tagBorder, color: tagColor),
                if (product.brand.isNotEmpty)
                  _Tag(product.brand, bg: tagBg, border: tagBorder, color: tagColor),
              ]),
              if (product.description?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                // Descrição: CINZA em ambos os modos
                Text('Descrição: ${product.description}',
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.publicSans(
                    fontSize: 12, fontWeight: FontWeight.w400, color: metaColor)),
              ],
              const SizedBox(height: 8),
              // Editado/Cadastrado: mesma cor do nome (título)
              Text('Editado: ${DateFormatter.date(product.updatedAt)}   '
                   'Cadastrado: ${DateFormatter.date(product.createdAt)}',
                style: GoogleFonts.publicSans(fontSize: 10, color: nameColor)),
              if (product.lastEditedByName?.isNotEmpty == true)
                Text('Por: ${product.lastEditedByName}',
                  style: GoogleFonts.publicSans(fontSize: 10, color: nameColor)),
            ]),
          ),
        ),
        if (canEdit)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: Column(children: [
              _Btn(label: 'Editar', outlined: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: product)))),
              const SizedBox(height: 6),
              if (isAdmin)
                _Btn(label: 'Excluir', outlined: false, onTap: () async {
                  final ok = await _confirm(context);
                  if (ok && context.mounted) {
                    context.read<ProductProvider>().delete(product.id);
                  }
                }),
            ]),
          ),
      ]),
    );
  }

  Future<bool> _confirm(BuildContext ctx) async {
    final r = await showDialog<bool>(context: ctx, builder: (_) => AlertDialog(
      title: const Text('Excluir produto'),
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

class _Tag extends StatelessWidget {
  final String text; final Color bg, border, color;
  const _Tag(this.text, {required this.bg, required this.border, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5),
      border: Border.all(color: border)),
    child: Text(text, style: GoogleFonts.publicSans(
      fontSize: 10, fontWeight: FontWeight.w500, color: color)),
  );
}

class _Btn extends StatelessWidget {
  final String label; final bool outlined; final VoidCallback onTap;
  const _Btn({required this.label, required this.outlined, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.vermelho,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.vermelho)),
      child: Text(label, style: GoogleFonts.publicSans(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: outlined ? AppColors.vermelho : Colors.white)),
    ),
  );
}