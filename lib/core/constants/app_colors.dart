import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //  Cores base 
  static const Color vermelho    = Color(0xFFAC4430); // Vermelho Tijolo
  static const Color azulArdosia = Color(0xFF3E505B); // Azul Ardósia
  static const Color perola      = Color(0xFFEAE9E4); // Pérola
  static const Color grafite     = Color(0xFF121212); // Grafite Profundo
  static const Color offWhite01  = Color(0xFFF4F0E5); // Off White 01
  static const Color offWhite02  = Color(0xFFE7DECF); // Off White 02
  static const Color branco      = Color(0xFFFFFFFF);
  static const Color azulEscuro01 = Color(0xFF1B242B);
  static const Color azulEscuro02 = Color(0xFF172027);
  static const Color sombra      = Color(0xFF03021B);

  //  Modo Claro 
  static const Color lightBackground = offWhite01;
  static const Color lightSurface    = branco;
  static const Color lightCard       = offWhite02;
  static const Color lightBorder     = perola;
  static const Color lightTextTitle  = azulEscuro02;
  static const Color lightTextBody   = azulArdosia;
  static const Color lightTextHint   = Color(0xFF8A9099);
  static const Color lightDivider    = perola;

  // Modo Escuro 
  static const Color darkBackground = azulEscuro02;
  static const Color darkSurface    = azulEscuro01;
  static const Color darkCard       = Color(0xFF1F2D35);
  static const Color darkBorder     = Color(0xFF2A3940);
  static const Color darkTextTitle  = perola;
  static const Color darkTextBody   = Color(0xFFB0BAC0);
  static const Color darkTextHint   = Color(0xFF607080);
  static const Color darkDivider    = Color(0xFF2A3940);

  //  Status 
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFE8A020);
  static const Color error   = vermelho;

  //  Roles 
  static const Color roleAdmin      = vermelho;
  static const Color roleEstoquista = azulArdosia;
  static const Color roleLeitor     = Color(0xFF4CAF50);
}