import 'package:sqflite/sqflite.dart';
import '../models/partida.dart';
import '../services/database_service.dart';

class PartidaDao {

  // Obtenim la connexió amb la base de dades
  Future<Database> get _db =>
      DatabaseService.obtenirDatabase();

  // Inserim una partida finalitzada
  Future<int> inserir(Partida partida) async {
    final db = await _db;

    return await db.insert(
      'partidas',
      partida.toMap(),
    );
  }

  // Obtenim totes les partides ordenades per data
  Future<List<Partida>> obtenirHistorial() async {
    final db = await _db;

    final files = await db.query(
      'partidas',
      orderBy: 'fecha DESC',
    );

    return files.map(Partida.fromMap).toList();
  }

  // Busquem una partida pel seu identificador
  Future<Partida?> obtenirPerId(int id) async {
    final db = await _db;

    final files = await db.query(
      'partidas',
      where: 'id_partida = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (files.isEmpty) {
      return null;
    }

    return Partida.fromMap(files.first);
  }

  // Eliminem una partida concreta del nostre usuari
  Future<int> eliminar(int id, int idUsuari) async {
    final db = await _db;

    return await db.delete(
      'partidas',
      where: 'id_partida = ? AND id_usuario = ?',
      whereArgs: [id, idUsuari],
    );
  }

  // Eliminem totes les partides de l'usuari actual
  Future<int> buidarHistorial(int idUsuari) async {
    final db = await _db;

    return await db.delete(
      'partidas',
      where: 'id_usuario = ?',
      whereArgs: [idUsuari],
    );
  }

  // Restaurem una partida eliminada
  Future<void> restaurar(Partida partida) async {
    final db = await _db;

    await db.insert(
      'partidas',
      partida.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // Obtenim les 10 millors partides
  Future<List<Partida>> obtenirRanking() async {
    final db = await _db;

    final files = await db.query(
      'partidas',
      orderBy: 'puntuacion DESC',
      limit: 10,
    );

    return files.map(Partida.fromMap).toList();
  }

  // Consultem l'historial aplicant els dos filtres a SQLite
  Future<List<Partida>> filtrarHistorial(String nom, int? fitxa) async {
    final db = await _db;

    final files = await db.rawQuery('''
      SELECT p.* FROM partidas p
      INNER JOIN usuario u ON p.id_usuario = u.id_usuario
      WHERE u.usuario LIKE ? AND p.ficha_maxima >= ?
      ORDER BY p.fecha DESC
    ''', ['%$nom%', fitxa ?? 0]);

    return files.map(Partida.fromMap).toList();
  }

  // Filtrem l'historial pel nom del jugador
  Future<List<Partida>> filtrarPerJugador(String nom) async {
    final db = await _db;

    final files = await db.rawQuery('''
      SELECT p.*
      FROM partidas p
      INNER JOIN usuario u
      ON p.id_usuario = u.id_usuario
      WHERE u.usuario LIKE ?
      ORDER BY p.fecha DESC
    ''', ['%$nom%']);

    return files.map(Partida.fromMap).toList();
  }

  // Filtrem les partides per la fitxa màxima
  Future<List<Partida>> filtrarPerFitxa(int fitxa) async {
    final db = await _db;

    final files = await db.query(
      'partidas',
      where: 'ficha_maxima >= ?',
      whereArgs: [fitxa],
      orderBy: 'fecha DESC',
    );

    return files.map(Partida.fromMap).toList();
  }

  // Calculem les estadístiques globals
  Future<Map<String, dynamic>> obtenirEstadistiques() async {
    final db = await _db;

    final resultat = await db.rawQuery('''
      SELECT
        COUNT(*) AS total_partides,
        MAX(puntuacion) AS millor_puntuacio,
        AVG(puntuacion) AS puntuacio_mitjana,
        MAX(ficha_maxima) AS fitxa_maxima,
        SUM(duracion_segundos) AS temps_total
      FROM partidas
    ''');

    final dades = resultat.first;

    return {
      'total_partides': dades['total_partides'] ?? 0,
      'millor_puntuacio': dades['millor_puntuacio'] ?? 0,
      'puntuacio_mitjana': dades['puntuacio_mitjana'] ?? 0,
      'fitxa_maxima': dades['fitxa_maxima'] ?? 0,
      'temps_total': dades['temps_total'] ?? 0,
    };
  }

  // Calculem les estadístiques de cada jugador
  Future<List<Map<String, Object?>>>
  obtenirEstadistiquesJugadors() async {
    final db = await _db;

    return await db.rawQuery('''
      SELECT
        u.usuario,
        COUNT(*) AS total_partides,
        MAX(p.puntuacion) AS millor_puntuacio
      FROM partidas p
      INNER JOIN usuario u
      ON p.id_usuario = u.id_usuario
      GROUP BY u.id_usuario, u.usuario
      ORDER BY millor_puntuacio DESC
    ''');
  }

  // Obtenim la millor puntuació d'un jugador
  Future<int> obtenirMillorPuntuacio(int idUsuari) async {
    final db = await _db;

    final resultat = await db.rawQuery('''
      SELECT MAX(puntuacion) AS millor
      FROM partidas
      WHERE id_usuario = ?
    ''', [idUsuari]);

    return (resultat.first['millor'] as int?) ?? 0;
  }

  // Finalitzem una partida amb una transacció
  Future<void> finalitzarPartida(Partida partida) async {
    final db = await _db;

    await db.transaction((txn) async {

      // Guardem la partida finalitzada a l'historial
      await txn.insert(
        'partidas',
        partida.toMap(),
      );

      // Eliminem només la partida guardada de l'usuari actual
      await txn.delete(
        'partida_guardada',
        where: 'id_usuario = ?',
        whereArgs: [partida.idUsuari],
      );

    });
  }
}
