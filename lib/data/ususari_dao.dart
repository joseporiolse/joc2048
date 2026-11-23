import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';

import '../models/usuari.dart';
import '../services/database_service.dart';

class UsuariDao {

  // Obtenim la connexió amb la base de dades
  Future<Database> get _db => DatabaseService.obtenirDatabase();

  // Registrem un usuari nou
  Future<int> registrar(Usuari usuari) async {
    final db = await _db;

    // Comprovem que el nom d'usuari no estigui buit
    if (usuari.usuari.trim().isEmpty) {
      throw Exception('El nom d\'usuari no pot estar buit');
    }

    // Comprovem que el correu electrònic sigui vàlid
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(usuari.email)) {
      throw Exception('El correu electrònic no és vàlid');
    }

    // Comprovem que la contrasenya no estigui buida
    if (usuari.contrasena.isEmpty) {
      throw Exception('La contrasenya no pot estar buida');
    }

    // Generem un hash segur de la contrasenya
    String hash = BCrypt.hashpw(
      usuari.contrasena,
      BCrypt.gensalt(),
    );

    // Convertim l'usuari en un Map
    final dades = usuari.toMap();

    // Substituïm la contrasenya pel hash
    dades['contrasena'] = hash;

    // Guardem l'usuari a SQLite
    return await db.insert('usuario', dades);
  }

  // Busquem un usuari pel seu nom
  Future<Usuari?> obtenirPerNom(String nom) async {
    final db = await _db;

    final files = await db.query(
      'usuario',
      where: 'usuario = ?',
      whereArgs: [nom],
      limit: 1,
    );

    // Si no existeix, retornem null
    if (files.isEmpty) {
      return null;
    }

    return Usuari.fromMap(files.first);
  }

  // Busquem un usuari pel seu identificador
  Future<Usuari?> obtenirPerId(int id) async {
    final db = await _db;

    final files = await db.query(
      'usuario',
      where: 'id_usuario = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (files.isEmpty) {
      return null;
    }

    return Usuari.fromMap(files.first);
  }

  // Comprovem les dades per iniciar sessió
  Future<Usuari?> iniciarSessio(
      String nom,
      String contrasena,
      ) async {

    // Busquem l'usuari a la base de dades
    Usuari? usuari = await obtenirPerNom(nom);

    // Si no existeix, retornem null
    if (usuari == null) {
      return null;
    }

    // Comprovem la contrasenya amb el hash guardat
    bool correcta = BCrypt.checkpw(
      contrasena,
      usuari.contrasena,
    );

    // Si la contrasenya és correcta, retornem l'usuari
    if (correcta) {
      return usuari;
    }

    return null;
  }
}
