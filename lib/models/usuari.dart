class Usuari {
  int? idUsuari;
  String usuari;
  String email;
  String contrasena;
  String dataRegistre;

  Usuari({
    this.idUsuari,
    required this.usuari,
    required this.email,
    required this.contrasena,
    required this.dataRegistre,
  });

  //Convertim l'usuari a Map
  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuari,
      'usuario': usuari,
      'email': email,
      'contrasena': contrasena,
      'fecha_registro': dataRegistre,
    };
  }

  //Recuperem l'usuari des del Map
  factory Usuari.fromMap(Map<String, dynamic> map) {
    return Usuari(
      idUsuari: map['id_usuario'],
      usuari: map['usuario'],
      email: map['email'],
      contrasena: map['contrasena'],
      dataRegistre: map['fecha_registro'],
    );
  }
}