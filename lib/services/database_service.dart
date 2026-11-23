
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {

  // Guardem la base de dades per no crear una nova connexió cada vegada
  static Database? _database;

  static Future<Database> obtenirDatabase() async {

    // Si ja tenim la base de dades la retornem
    if (_database != null) {
      return _database!;
    }

    // Busquem la ruta on es guardarà la base de dades
    String ruta = await getDatabasesPath();
    String rutaCompleta = join(ruta, 'game2048.db');

    // Obrim la base de dades i si no existeix la creem
    _database = await openDatabase(
      rutaCompleta,
      version: 2,

      // Activem les claus foranes per relacionar les taules
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // Creem les taules quan es crea la base de dades per primera vegada
      onCreate: (db, version) async {

        // Taula dels usuaris registrats
        await db.execute('''
          CREATE TABLE usuario(
            id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL UNIQUE,
            contrasena TEXT NOT NULL,
            fecha_registro TEXT NOT NULL
          )
        ''');

        // Taula de les partides finalitzades
        await db.execute('''
          CREATE TABLE partidas(
            id_partida INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER NOT NULL,
            puntuacion INTEGER NOT NULL,
            ficha_maxima INTEGER NOT NULL,
            movimientos INTEGER NOT NULL,
            duracion_segundos INTEGER NOT NULL,
            fecha TEXT NOT NULL,
            tamano_tablero INTEGER NOT NULL DEFAULT 4,
            FOREIGN KEY (id_usuario)
              REFERENCES usuario(id_usuario)
          )
        ''');

        // Taula per guardar la partida actual
        await db.execute('''
          CREATE TABLE partida_guardada(
            id INTEGER PRIMARY KEY CHECK (id = 1),
            id_usuario INTEGER NOT NULL,
            tablero TEXT NOT NULL,
            puntuacion INTEGER NOT NULL,
            movimientos INTEGER NOT NULL,
            segundos_transcurridos INTEGER NOT NULL,
            FOREIGN KEY (id_usuario)
              REFERENCES usuario(id_usuario)
          )
        ''');

      },

      // Actualitzem la base de dades sense perdre les dades existents
      onUpgrade: (db, oldVersion, newVersion) async {

        // Si venim de la versió 1, afegim la mida del tauler
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE partidas
            ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4
          ''');
        }

      },
    );

    // Retornem la base de dades
    return _database!;
  }
}
