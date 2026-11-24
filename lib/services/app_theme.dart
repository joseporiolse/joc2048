import 'package:flutter/material.dart';

class AppTheme {

  // Colors principals de l'aplicació
  static const Color colorPrincipal = Colors.deepOrange;
  static const Color colorSecundari = Colors.orange;

  // Mides i espais que utilitzarem a les pantalles
  static const double espaiPetit = 8;
  static const double espaiMitja = 16;
  static const double espaiGran = 24;
  static const double radiVores = 12;
  static const double midaSubtitol = 18;

  // Tema clar de l'aplicació
  static final ThemeData temaClar = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrincipal,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: const Color(0xFFFAF8EF),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFFFAF8EF),
      foregroundColor: Colors.black87,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(espaiMitja),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiVores),
        ),
      ),
    ),
  );

  // Tema fosc de l'aplicació
  static final ThemeData temaFosc = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: colorPrincipal,
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: const Color(0xFF202020),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF202020),
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorPrincipal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(espaiMitja),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiVores),
        ),
      ),
    ),
  );

  // Obtenim el color d'una fitxa segons el seu valor
  static Color obtenirColorFitxa(
      int valor,
      bool esFosc,
      Color colorPersonalitzat,
      ) {

    // Les caselles buides tenen un color diferent
    if (valor == 0) {
      if (esFosc) {
        return const Color(0xFF3A3A3A);
      }
      return const Color(0xFFCDC1B4);
    }

    // Colors de les fitxes petites
    if (valor == 2) {
      return esFosc
          ? const Color(0xFF776E65)
          : const Color(0xFFEEE4DA);
    }

    if (valor == 4) {
      return esFosc
          ? const Color(0xFF8F7A66)
          : const Color(0xFFEDE0C8);
    }

    // Les fitxes de valor 8 o superior utilitzen
    // el color personalitzat seleccionat per l'usuari
    return colorPersonalitzat;
  }

  // Obtenim el color del text de les fitxes
  static Color obtenirColorTextFitxa(
      int valor,
      bool esFosc,
      ) {

    // En les fitxes de valor baix utilitzem text fosc
    // quan el tema és clar
    if (valor <= 4 && !esFosc) {
      return const Color(0xFF776E65);
    }

    return Colors.white;
  }

  // Estil del text dels títols
  static const TextStyle estilTitol = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  // Estil del text de les puntuacions
  static const TextStyle estilPuntuacio = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  // Estil del text de les fitxes
  static const TextStyle estilFitxa = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}