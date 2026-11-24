import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenciesService {

  //Claus per guardar les preferències
  static const String _clauTema = 'mode_tema';
  static const String _clauColorFitxes = 'color_fitxes';

  //Guardem el mode del tema seleccionat
  static Future<void> guardarModeTema(ThemeMode mode) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_clauTema, mode.name);
  }

  //Recuperem el mode del tema guardat
  static Future<ThemeMode> llegirModeTema() async {

    final prefs = await SharedPreferences.getInstance();

    String? tema = prefs.getString(_clauTema);

    //Si no hi ha cap tema guardat, utilitzem el del sistema
    if (tema == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
          (mode) => mode.name == tema,
      orElse: () => ThemeMode.system,
    );
  }

  //Guardem el color seleccionat per a les fitxes
  static Future<void> guardarColorFitxes(Color color) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _clauColorFitxes,
      color.toARGB32(),
    );
  }

  //Recuperem el color de les fitxes
  static Future<Color> llegirColorFitxes() async {

    final prefs = await SharedPreferences.getInstance();

    int? colorGuardat = prefs.getInt(_clauColorFitxes);

    //Si no hi ha cap color guardat, utilitzem el taronja
    if (colorGuardat == null) {
      return Colors.orange;
    }

    return Color(colorGuardat);
  }
}