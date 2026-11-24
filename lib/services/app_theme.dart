import 'package:flutter/material.dart';

class AppTheme {

  //Colors principals de l'aplicació
  static const Color colorPrincipal = Colors.deepOrange;
  static const Color colorSecundari = Colors.orange;

  //Mides i espais que utilitzarem a les pantalles
  static const double espaiPetit = 8;
  static const double espaiMitja = 16;
  static const double espaiGran = 24;
  static const double radiVores = 12;
  static const double midaSubtitol = 18;

  //Tema clar de l'aplicació
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

  //Tema fosc de l'aplicació
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

  //Color segons el valor de la fitxa
  static Color obtenirColorFitxa(
      int valor,
      bool esFosc,
      Color colorPersonalitzat,
      ) {

    switch (valor) {

      case 0:
        return esFosc
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFCDC1B4);

    //Barregem el color seleccionat amb blanc
      case 2:
        return Color.lerp(
          Colors.white, colorPersonalitzat, 0.15,
        )!;

      case 4:
        return Color.lerp(
          Colors.white, colorPersonalitzat, 0.30,
        )!;

      case 8:
        return Color.lerp(
          Colors.white, colorPersonalitzat, 0.45,
        )!;

      case 16:
        return Color.lerp(
          Colors.white, colorPersonalitzat, 0.60,
        )!;

      case 32:
        return Color.lerp(
          Colors.white, colorPersonalitzat, 0.75,
        )!;

      case 64:
        return colorPersonalitzat;

    //Barregem el color seleccionat amb negre
      case 128:
        return Color.lerp(
          colorPersonalitzat, Colors.black, 0.10,
        )!;

      case 256:
        return Color.lerp(
          colorPersonalitzat, Colors.black, 0.20,
        )!;

      case 512:
        return Color.lerp(
          colorPersonalitzat, Colors.black, 0.30,
        )!;

      case 1024:
        return Color.lerp(
          colorPersonalitzat, Colors.black, 0.40,
        )!;

      case 2048:
        return Color.lerp(
          colorPersonalitzat, Colors.black, 0.50,
        )!;

      default:
        return Color.lerp(
          colorPersonalitzat, Colors.black, 0.60,
        )!;
    }
  }

  //Color del text segons el fons
  static Color obtenirColorTextFitxa(
      int valor,
      bool esFosc,
      Color colorPersonalitzat,
      ) {

    final Color colorFons = obtenirColorFitxa(
      valor,
      esFosc,
      colorPersonalitzat,
    );

    //Si el fons és clar, utilitzem text negre.
    //Si el fons és fosc, utilitzem text blanc.
    return colorFons.computeLuminance() > 0.179
        ? Colors.black
        : Colors.white;
  }

  static const TextStyle estilTitol = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle estilPuntuacio = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle estilFitxa = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
}