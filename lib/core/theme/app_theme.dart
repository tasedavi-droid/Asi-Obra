import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color title, Color body) => TextTheme(
    displayLarge:  GoogleFonts.publicSans(fontSize: 28, fontWeight: FontWeight.w700, color: title),
    displayMedium: GoogleFonts.publicSans(fontSize: 22, fontWeight: FontWeight.w700, color: title),
    titleLarge:    GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600, color: title),
    titleMedium:   GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w500, color: title),
    titleSmall:    GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: title),
    bodyLarge:     GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w400, color: body),
    bodyMedium:    GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w400, color: body),
    bodySmall:     GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w300, color: body),
    labelLarge:    GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600, color: title),
    labelMedium:   GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: body),
  );

  static ThemeData get light => _build(
    brightness:   Brightness.light,
    primary:      AppColors.vermelho,
    background:   AppColors.lightBackground,
    surface:      AppColors.lightSurface,
    card:         AppColors.lightCard,
    border:       AppColors.lightBorder,
    textTitle:    AppColors.lightTextTitle,
    textBody:     AppColors.lightTextBody,
    textHint:     AppColors.lightTextHint,
    divider:      AppColors.lightDivider,
    statusBrightness: Brightness.dark,
  );

  static ThemeData get dark => _build(
    brightness:   Brightness.dark,
    primary:      AppColors.vermelho,
    background:   AppColors.darkBackground,
    surface:      AppColors.darkSurface,
    card:         AppColors.darkCard,
    border:       AppColors.darkBorder,
    textTitle:    AppColors.darkTextTitle,
    textBody:     AppColors.darkTextBody,
    textHint:     AppColors.darkTextHint,
    divider:      AppColors.darkDivider,
    statusBrightness: Brightness.light,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color card,
    required Color border,
    required Color textTitle,
    required Color textBody,
    required Color textHint,
    required Color divider,
    required Brightness statusBrightness,
  }) {
    final tt = _textTheme(textTitle, textBody);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness:   brightness,
        primary:      primary,
        onPrimary:    AppColors.branco,
        secondary:    AppColors.azulArdosia,
        onSecondary:  AppColors.branco,
        surface:      surface,
        onSurface:    textTitle,
        background:   background,
        onBackground: textTitle,
        error:        AppColors.vermelho,
        onError:      AppColors.branco,
      ),
      scaffoldBackgroundColor: background,
      textTheme: tt,
      appBarTheme: AppBarTheme(
        backgroundColor:    surface,
        foregroundColor:    textTitle,
        elevation:          0,
        centerTitle:        false,
        surfaceTintColor:   Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:            Colors.transparent,
          statusBarIconBrightness:   statusBrightness,
        ),
        titleTextStyle: GoogleFonts.publicSans(
          fontSize: 17, fontWeight: FontWeight.w600, color: textTitle),
        iconTheme: IconThemeData(color: textTitle),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.branco,
          minimumSize:     const Size(double.infinity, 52),
          elevation:       0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side:            BorderSide(color: primary, width: 1.5),
          minimumSize:     const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:          true,
        fillColor:       brightness == Brightness.light ? AppColors.branco : AppColors.darkCard,
        contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   const BorderSide(color: AppColors.vermelho, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:   const BorderSide(color: AppColors.vermelho, width: 2),
        ),
        hintStyle:  GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w300, color: textHint),
        errorStyle: GoogleFonts.publicSans(fontSize: 12, color: AppColors.vermelho),
      ),
      cardTheme: CardTheme(
        color:     card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:         BorderSide(color: border),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.branco,
        elevation:       2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:      surface,
        selectedItemColor:    primary,
        unselectedItemColor:  textHint,
        type:                 BottomNavigationBarType.fixed,
        elevation:            0,
        selectedLabelStyle:   GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      dividerTheme:  DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior:         SnackBarBehavior.floating,
        backgroundColor:  textTitle,
        contentTextStyle: GoogleFonts.publicSans(color: background, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}