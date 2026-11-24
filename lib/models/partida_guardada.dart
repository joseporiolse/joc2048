import 'dart:convert';

class PartidaGuardada {

  int id;
  int idUsuari;
  List<int> tauler;
  int puntuacio;
  int moviments;
  int segonsTranscorreguts;

  // Constructor de la partida guardada
  PartidaGuardada({
    int? id,
    required this.idUsuari,
    required this.tauler,
    required this.puntuacio,
    required this.moviments,
    required this.segonsTranscorreguts,
  }) : id = id ?? idUsuari;

  // Convertim la partida en un Map per guardar-la a SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_usuario': idUsuari,
      'tablero': jsonEncode(tauler),
      'puntuacion': puntuacio,
      'movimientos': moviments,
      'segundos_transcurridos': segonsTranscorreguts,
    };
  }

  // Convertim les dades de SQLite en un objecte PartidaGuardada
  factory PartidaGuardada.fromMap(Map<String, dynamic> map) {
    return PartidaGuardada(
      id: map['id'],
      idUsuari: map['id_usuario'],
      tauler: List<int>.from(jsonDecode(map['tablero'])),
      puntuacio: map['puntuacion'],
      moviments: map['movimientos'],
      segonsTranscorreguts: map['segundos_transcurridos'],
    );
  }
}
