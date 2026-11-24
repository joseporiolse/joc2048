import 'dart:math';

enum Direccio {
  amunt,
  avall,
  esquerra,
  dreta,
}

class JocService {

  //El tauler té 4 files i 4 columnes
  static const int mida = 4;

  final Random _aleatori = Random();

  //Estat actual del joc
  List<int> tauler = List.filled(16, 0);
  int puntuacio = 0;
  int moviments = 0;

  //Iniciem una partida nova
  void iniciarPartida() {
    tauler = List.filled(16, 0);
    puntuacio = 0;
    moviments = 0;

    generarFitxa();
    generarFitxa();
  }

  //Generem una fitxa en una casella buida
  void generarFitxa() {

    List<int> casellesBuides = [];

    for (int i = 0; i < tauler.length; i++) {
      if (tauler[i] == 0) {
        casellesBuides.add(i);
      }
    }

    if (casellesBuides.isEmpty) {
      return;
    }

    int posicio = casellesBuides[
    _aleatori.nextInt(casellesBuides.length)
    ];

    //90% de possibilitats de generar un 2
    //10% de possibilitats de generar un 4
    tauler[posicio] = _aleatori.nextInt(10) == 0 ? 4 : 2;
  }

  //Recuperem una partida guardada
  void carregarPartida(
      List<int> taulerGuardat,
      int puntuacioGuardada,
      int movimentsGuardats,
      ) {

    //Comprovem que el tauler tingui 16 caselles
    if (taulerGuardat.length != 16) {
      throw ArgumentError('El tauler ha de tenir 16 caselles');
    }

    tauler = List<int>.from(taulerGuardat);
    puntuacio = puntuacioGuardada;
    moviments = movimentsGuardats;
  }

  //Movem les fitxes en una direcció
  bool moure(Direccio direccio) {

    List<int> taulerAnterior = List<int>.from(tauler);

    for (int i = 0; i < mida; i++) {

      List<int> linia = [];

      for (int j = 0; j < mida; j++) {
        int posicio = _obtenirPosicio(i, j, direccio);
        linia.add(tauler[posicio]);
      }

      List<int> novaLinia = _fusionarLinia(linia);

      for (int j = 0; j < mida; j++) {
        int posicio = _obtenirPosicio(i, j, direccio);
        tauler[posicio] = novaLinia[j];
      }
    }

    bool hiHaCanvis = false;

    for (int i = 0; i < tauler.length; i++) {
      if (tauler[i] != taulerAnterior[i]) {
        hiHaCanvis = true;
        break;
      }
    }

    //Només comptem els moviments vàlids
    if (hiHaCanvis) {
      moviments++;

      //Després d'un moviment vàlid apareix una fitxa
      generarFitxa();
    }

    return hiHaCanvis;
  }

  //Obtenim la posició segons la direcció
  int _obtenirPosicio(
      int linia,
      int columna,
      Direccio direccio,
      ) {

    switch (direccio) {

      case Direccio.esquerra:
        return linia * mida + columna;

      case Direccio.dreta:
        return linia * mida + (mida - 1 - columna);

      case Direccio.amunt:
        return columna * mida + linia;

      case Direccio.avall:
        return (mida - 1 - columna) * mida + linia;
    }
  }

  //Desplacem i fusionem una fila o columna
  List<int> _fusionarLinia(List<int> linia) {

    List<int> fitxes = linia.where((valor) => valor != 0).toList();

    List<int> resultat = [];

    int i = 0;

    while (i < fitxes.length) {

      //Si dues fitxes consecutives són iguals,
      //les fusionem en una de valor doble
      if (i + 1 < fitxes.length &&
          fitxes[i] == fitxes[i + 1]) {

        int valorFusionat = fitxes[i] * 2;

        resultat.add(valorFusionat);

        //Sumem el valor de la fusió a la puntuació
        puntuacio += valorFusionat;

        i += 2;

      } else {

        resultat.add(fitxes[i]);
        i++;
      }
    }

    //Afegim zeros fins a completar quatre caselles
    while (resultat.length < mida) {
      resultat.add(0);
    }

    return resultat;
  }

  //Obtenim el valor més alt del tauler
  int obtenirFitxaMaxima() {
    return tauler.reduce(max);
  }

  //Comprovem si el jugador ha arribat a 2048
  bool haGuanyat() {
    return tauler.any((valor) => valor >= 2048);
  }

  //Comprovem si encara podem fer moviments
  bool hiHaMovimentsDisponibles() {

    if (tauler.contains(0)) {
      return true;
    }

    //Comprovem les fitxes veïnes
    for (int fila = 0; fila < mida; fila++) {
      for (int columna = 0; columna < mida; columna++) {

        int posicio = fila * mida + columna;
        int valor = tauler[posicio];

        if (columna < mida - 1 &&
            valor == tauler[posicio + 1]) {
          return true;
        }

        if (fila < mida - 1 &&
            valor == tauler[posicio + mida]) {
          return true;
        }
      }
    }

    return false;
  }

  //Comprovem si el jugador ha perdut
  bool haPerdut() {
    return !hiHaMovimentsDisponibles();
  }
}