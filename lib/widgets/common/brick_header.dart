import 'package:flutter/material.dart';

class BrickHeader extends StatelessWidget {
  final double heightFactor;

  /// Widget no canto superior esquerdo 
  final Widget? topLeft;


  final Widget? topRight;

  const BrickHeader({
    super.key,
    this.heightFactor = 0.26,
    this.topLeft,
    this.topRight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    final imagePath = isDark
        ? 'assets/images/brick_wall_dark.png'
        : 'assets/images/brick_wall_light.png';

    return SizedBox(
      height: size.height * heightFactor,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de tijolos 
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: isDark
                  ? const Color(0xFF263038)
                  : const Color(0xFFB97050)),
          ),

          // Botões de navegação sobrepostos
          if (topLeft != null || topRight != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    topLeft  ?? const SizedBox.shrink(),
                    topRight ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}