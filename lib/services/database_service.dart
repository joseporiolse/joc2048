import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {

  //Guardem la base de dades per no crear una nova connexio cada vegada
  static Database? _database;

  static Future<Database> obtenirDatabase() async {

    //Si ja tenim la base de dades la retornem
    if (_database != null) {
      return _database!;
    }

    //Busquem la ruta on es guardara la base de dades
    String ruta = await getDatabasesPath();

    String rutaCompleta = join(ruta, 'habitosapp.db');

    //Obrim la base de dades i si no existeix la creem
    _database = await openDatabase(
      rutaCompleta,
      version: 2,

      //Activem les claus foranes per relacionar les taules
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      //Creem les taules quan es crea la base de dades per primera vegada
      onCreate: (db, version) async {

await db.execute('''
    CREATE TABLE usuario(
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario TEXT NOT NULL UNIQUE,
    nombre TEXT NOT NULL,
    contrasena TEXT NOT NULL,
    email TEXT NOT NULL,
    fecha_creacion TEXT NOT NULL,
    victorias INTEGER NOT NULL DEFAULT 0,
    derrotas INTEGER NOT NULL DEFAULT 0)
    ');

await db.execute('''
     CREATE TABLE partidas(
       id_partida INTEGER PRIMARY KEY AUTOINCREMENT,
       id_usuario INTEGER NOT NULL,
       puntuacion INTEGER NOT NULL,
       ficha_maxima INTEGER NOT NULL,
       movimientos INTEGER NOT NULL,
       duracion_segundos INTEGER NOT NULL,
       fecha TEXT NOT NULL,
       FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
  ');

await db.execute('''
    CREATE TABLE tablero(
    id_partida INTEGER FOREIGN KEY partidas,
    id_tablero INTEGER PRIMARY KEY AUTOINCREMENT,
    movimientos INTEGER NOT NULL,
    segundos INTEGER NOT NULL
    )
    ');