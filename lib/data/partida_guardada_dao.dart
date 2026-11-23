import 'package:sqflite/sqflite.dart';
import '../models/partida_guardada.dart';
import '../services/database_service.dart';

class PartidaGuardadaDao {

  // Obtenim la connexió amb la base de dades
  Future<Database> get _db => DatabaseService.obtenirDatabase();

  // Guardem la partida actual
  Future<void> guardar(PartidaGuardada partida) async {
    final db = await _db;

    // Comprovem que el tauler tingui 16 caselles
    if (partida.tauler.length != 16) {
      throw Exception('El tauler ha de tenir 16 caselles');
    }

    // Guardem o actualitzem la partida existent
    await db.insert(
      'partida_guardada',
      partida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Recuperem la partida guardada de l'usuari
  Future<PartidaGuardada?> recuperar(int idUsuari) async {
    final db = await _db;

    final files = await db.query(
      'partida_guardada',
      where: 'id = ? AND id_usuario = ?',
      whereArgs: [1, idUsuari],
      limit: 1,
    );

    // Si no hi ha cap partida guardada retornem null
    if (files.isEmpty) {
      return null;
    }

    // Convertim les dades en un objecte PartidaGuardada
    return PartidaGuardada.fromMap(files.first);
  }

  // Eliminem la partida guardada de l'usuari
  Future<int> eliminar(int idUsuari) async {
    final db = await _db;

    return await db.delete(
      'partida_guardada',
      where: 'id = ? AND id_usuario = ?',
      whereArgs: [1, idUsuari],
    );
  }

  // Comprovem si l'usuari té una partida guardada
  Future<bool> existeixPartida(int idUsuari) async {
    final partida = await recuperar(idUsuari);

    return partida != null;
  }
}
