import 'dart:convert';

class PartidaGuardada {

  int id;
  int idUsuari;
  List<int> tauler;
  int puntuacio;
  int moviments;
  int segonsTranscorreguts;

  PartidaGuardada({
    int? id,
    required this.idUsuari,
    required this.tauler,
    required this.puntuacio,
    required this.moviments,
    required this.segonsTranscorreguts,
  }) : id = id ?? idUsuari;

  //Convertim la partida a Map
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

  //Recuperem la partida guardada des del Map
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