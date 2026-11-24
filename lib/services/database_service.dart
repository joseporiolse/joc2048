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
      version: 3,

      // Activem les claus foranes per relacionar les taules
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // Creem les taules quan es crea la base de dades
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

        // Cada usuari pot tenir una partida guardada
        await db.execute('''
          CREATE TABLE partida_guardada(
            id INTEGER PRIMARY KEY,
            id_usuario INTEGER NOT NULL UNIQUE,
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

        // Migració de la versió 1 a la versió 2
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE partidas
            ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4
          ''');
        }

        // Migració a la versió 3
        if (oldVersion < 3) {

          // Canviem el nom de la taula antiga
          await db.execute('''
            ALTER TABLE partida_guardada
            RENAME TO partida_guardada_antiga
          ''');

          // Creem la nova taula sense la restricció de l'id
          await db.execute('''
            CREATE TABLE partida_guardada(
              id INTEGER PRIMARY KEY,
              id_usuario INTEGER NOT NULL UNIQUE,
              tablero TEXT NOT NULL,
              puntuacion INTEGER NOT NULL,
              movimientos INTEGER NOT NULL,
              segundos_transcurridos INTEGER NOT NULL,
              FOREIGN KEY (id_usuario)
                REFERENCES usuario(id_usuario)
            )
          ''');

          // Recuperem les dades de la taula antiga
          // Utilitzem l'id de l'usuari com a id de la partida
          await db.execute('''
            INSERT INTO partida_guardada(
              id,
              id_usuario,
              tablero,
              puntuacion,
              movimientos,
              segundos_transcurridos
            )
            SELECT
              id_usuario,
              id_usuario,
              tablero,
              puntuacion,
              movimientos,
              segundos_transcurridos
            FROM partida_guardada_antiga
          ''');

          // Eliminem la taula antiga després de copiar les dades
          await db.execute('''
            DROP TABLE partida_guardada_antiga
          ''');

        }

      },
    );

    // Retornem la base de dades
    return _database!;
  }
}