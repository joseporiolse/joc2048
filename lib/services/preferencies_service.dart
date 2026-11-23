import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciesService {

  // Claus per guardar les preferències
  static const String _clauTema = 'mode_tema';
  static const String _clauColorFitxes = 'color_fitxes';

  // Guardem el mode del tema seleccionat
  static Future<void> guardarModeTema(ThemeMode mode) async {

    // Obtenim les preferències
    final prefs = await SharedPreferences.getInstance();

    // Guardem el mode com a text
    await prefs.setString(_clauTema, mode.name);
  }

  // Recuperem el mode del tema guardat
  static Future<ThemeMode> llegirModeTema() async {

    // Obtenim les preferències
    final prefs = await SharedPreferences.getInstance();

    // Llegim el tema guardat
    String? tema = prefs.getString(_clauTema);

    // Si no hi ha cap tema guardat, utilitzem el del sistema
    if (tema == null) {
      return ThemeMode.system;
    }

    // Convertim el text en un ThemeMode
    return ThemeMode.values.firstWhere(
          (mode) => mode.name == tema,
      orElse: () => ThemeMode.system,
    );
  }

  // Guardem el color seleccionat per a les fitxes
  static Future<void> guardarColorFitxes(Color color) async {

    final prefs = await SharedPreferences.getInstance();

    // Guardem el color com un número enter
    await prefs.setInt(
      _clauColorFitxes,
      color.toARGB32(),
    );
  }

  // Recuperem el color de les fitxes
  static Future<Color> llegirColorFitxes() async {

    final prefs = await SharedPreferences.getInstance();

    // Llegim el color guardat
    int? colorGuardat = prefs.getInt(_clauColorFitxes);

    // Si no hi ha cap color guardat, utilitzem el taronja
    if (colorGuardat == null) {
      return Colors.orange;
    }

    // Convertim el número en un Color
    return Color(colorGuardat);
  }
}
