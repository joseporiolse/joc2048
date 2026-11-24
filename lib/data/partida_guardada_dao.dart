import 'package:sqflite/sqflite.dart';
import '../models/partida_guardada.dart';
import '../services/database_service.dart';

class PartidaGuardadaDao {

  // Obtenim la connexió amb la base de dades
  Future<Database> get _db =>
      DatabaseService.obtenirDatabase();

  // Guardem la partida actual de l'usuari
  Future<void> guardar(PartidaGuardada partida) async {

    final db = await _db;

    // Comprovem que el tauler tingui 16 caselles
    if (partida.tauler.length != 16) {
      throw Exception('El tauler ha de tenir 16 caselles');
    }

    // Convertim la partida en un Map
    final dades = partida.toMap();

    // Cada usuari tindrà el seu propi identificador
    dades['id'] = dades['id_usuario'];

    // Guardem o actualitzem la partida de l'usuari
    await db.insert(
      'partida_guardada',
      dades,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Recuperem la partida guardada de l'usuari
  Future<PartidaGuardada?> recuperar(int idUsuari) async {

    final db = await _db;

    final files = await db.query(
      'partida_guardada',
      where: 'id_usuario = ?',
      whereArgs: [idUsuari],
      limit: 1,
    );

    // Si no té cap partida guardada retornem null
    if (files.isEmpty) {
      return null;
    }

    // Convertim les dades en un objecte PartidaGuardada
    return PartidaGuardada.fromMap(files.first);
  }

  // Eliminem només la partida guardada de l'usuari
  Future<int> eliminar(int idUsuari) async {

    final db = await _db;

    return await db.delete(
      'partida_guardada',
      where: 'id_usuario = ?',
      whereArgs: [idUsuari],
    );
  }

  // Comprovem si l'usuari té una partida guardada
  Future<bool> existeixPartida(int idUsuari) async {

    final partida = await recuperar(idUsuari);

    return partida != null;
  }
}