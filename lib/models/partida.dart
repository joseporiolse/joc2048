class Partida {
  int? idPartida;
  int idUsuari;
  int puntuacio;
  int fitxaMaxima;
  int moviments;
  int duracioSegons;
  String data;
  int midaTauler;

  // Constructor de la partida
  Partida({
    this.idPartida,
    required this.idUsuari,
    required this.puntuacio,
    required this.fitxaMaxima,
    required this.moviments,
    required this.duracioSegons,
    required this.data,
    this.midaTauler = 4,
  });

  // Convertim la partida en un Map per guardar-la a SQLite
  Map<String, dynamic> toMap() {
    return {
      'id_partida': idPartida,
      'id_usuario': idUsuari,
      'puntuacion': puntuacio,
      'ficha_maxima': fitxaMaxima,
      'movimientos': moviments,
      'duracion_segundos': duracioSegons,
      'fecha': data,
      'tamano_tablero': midaTauler,
    };
  }

  // Convertim les dades de SQLite en un objecte Partida
  factory Partida.fromMap(Map<String, dynamic> map) {
    return Partida(
      idPartida: map['id_partida'],
      idUsuari: map['id_usuario'],
      puntuacio: map['puntuacion'],
      fitxaMaxima: map['ficha_maxima'],
      moviments: map['movimientos'],
      duracioSegons: map['duracion_segundos'],
      data: map['fecha'],
      midaTauler: map['tamano_tablero'] ?? 4,
    );
  }
}
