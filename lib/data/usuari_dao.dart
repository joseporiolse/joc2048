import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/usuari.dart';
import '../services/database_service.dart';

class UsuariDao {

  //Obtenim la connexió amb la base de dades
  Future<Database> get _db => DatabaseService.obtenirDatabase();

  //Registrem un usuari nou
  Future<int> registrar(Usuari usuari) async {
    final db = await _db;

    if (usuari.usuari.trim().isEmpty) {
      throw Exception('El nom d\'usuari no pot estar buit');
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(usuari.email)) {
      throw Exception('El correu electrònic no és vàlid');
    }

    if (usuari.contrasena.isEmpty) {
      throw Exception('La contrasenya no pot estar buida');
    }

    //Generem un hash segur de la contrasenya
    String hash = BCrypt.hashpw(
      usuari.contrasena,
      BCrypt.gensalt(),
    );

    final dades = usuari.toMap();

    dades['contrasena'] = hash;

    return await db.insert('usuario', dades);
  }

  //Busquem un usuari pel seu nom
  Future<Usuari?> obtenirPerNom(String nom) async {
    final db = await _db;

    final files = await db.query(
      'usuario',
      where: 'usuario = ?',
      whereArgs: [nom],
      limit: 1,
    );

    if (files.isEmpty) {
      return null;
    }

    return Usuari.fromMap(files.first);
  }

  //Busquem un usuari pel seu identificador
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

  //Comprovem les dades per iniciar sessió
  Future<Usuari?> iniciarSessio(
      String nom,
      String contrasena,
      ) async {

    Usuari? usuari = await obtenirPerNom(nom);

    if (usuari == null) {
      return null;
    }

    //Comprovem la contrasenya amb el hash guardat
    bool correcta = BCrypt.checkpw(
      contrasena,
      usuari.contrasena,
    );

    if (correcta) {
      return usuari;
    }

    return null;
  }
}