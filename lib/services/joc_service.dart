import 'dart:math';

enum Direccio {
  amunt,
  avall,
  esquerra,
  dreta,
}

class JocService {

  // El tauler té 4 files i 4 columnes
  static const int mida = 4;

  // Generador de números aleatoris
  final Random _aleatori = Random();

  // Estat actual del joc
  List<int> tauler = List.filled(16, 0);
  int puntuacio = 0;
  int moviments = 0;

  // Iniciem una partida nova
  void iniciarPartida() {
    tauler = List.filled(16, 0);
    puntuacio = 0;
    moviments = 0;

    // Al principi apareixen dues fitxes
    generarFitxa();
    generarFitxa();
  }

  // Generem una fitxa en una casella buida
  void generarFitxa() {

    List<int> casellesBuides = [];

    // Busquem les posicions que tenen valor 0
    for (int i = 0; i < tauler.length; i++) {
      if (tauler[i] == 0) {
        casellesBuides.add(i);
      }
    }

    // Si el tauler està ple, no podem generar fitxes
    if (casellesBuides.isEmpty) {
      return;
    }

    // Seleccionem una posició aleatòria
    int posicio = casellesBuides[
    _aleatori.nextInt(casellesBuides.length)
    ];

    // 90% de possibilitats de generar un 2
    // 10% de possibilitats de generar un 4
    tauler[posicio] = _aleatori.nextInt(10) == 0 ? 4 : 2;
  }

  // Recuperem una partida guardada
  void carregarPartida(
      List<int> taulerGuardat,
      int puntuacioGuardada,
      int movimentsGuardats,
      ) {

    // Comprovem que el tauler tingui 16 caselles
    if (taulerGuardat.length != 16) {
      throw ArgumentError('El tauler ha de tenir 16 caselles');
    }

    // Copiem les dades per evitar modificar la llista original
    tauler = List<int>.from(taulerGuardat);
    puntuacio = puntuacioGuardada;
    moviments = movimentsGuardats;
  }

  // Movem les fitxes en una direcció
  bool moure(Direccio direccio) {

    // Guardem una còpia per detectar si hi ha canvis
    List<int> taulerAnterior = List<int>.from(tauler);

    // Processem les quatre files o columnes
    for (int i = 0; i < mida; i++) {

      List<int> linia = [];

      // Obtenim les caselles segons la direcció
      for (int j = 0; j < mida; j++) {
        int posicio = _obtenirPosicio(i, j, direccio);
        linia.add(tauler[posicio]);
      }

      // Fusionem les fitxes de la línia
      List<int> novaLinia = _fusionarLinia(linia);

      // Actualitzem les caselles del tauler
      for (int j = 0; j < mida; j++) {
        int posicio = _obtenirPosicio(i, j, direccio);
        tauler[posicio] = novaLinia[j];
      }
    }

    // Comprovem si el moviment ha modificat el tauler
    bool hiHaCanvis = false;

    for (int i = 0; i < tauler.length; i++) {
      if (tauler[i] != taulerAnterior[i]) {
        hiHaCanvis = true;
        break;
      }
    }

    // Només comptem els moviments vàlids
    if (hiHaCanvis) {
      moviments++;

      // Després d'un moviment vàlid apareix una fitxa
      generarFitxa();
    }

    return hiHaCanvis;
  }

  // Obtenim la posició segons la direcció
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

  // Desplacem i fusionem una fila o columna
  List<int> _fusionarLinia(List<int> linia) {

    // Eliminem les caselles buides
    List<int> fitxes = linia.where((valor) => valor != 0).toList();

    List<int> resultat = [];

    int i = 0;

    while (i < fitxes.length) {

      // Si dues fitxes consecutives són iguals,
      // les fusionem en una de valor doble
      if (i + 1 < fitxes.length &&
          fitxes[i] == fitxes[i + 1]) {

        int valorFusionat = fitxes[i] * 2;

        resultat.add(valorFusionat);

        // Sumem el valor de la fusió a la puntuació
        puntuacio += valorFusionat;

        // Saltem les dues fitxes fusionades
        i += 2;

      } else {

        // Si no són iguals, mantenim la fitxa
        resultat.add(fitxes[i]);
        i++;
      }
    }

    // Afegim zeros fins a completar quatre caselles
    while (resultat.length < mida) {
      resultat.add(0);
    }

    return resultat;
  }

  // Obtenim el valor més alt del tauler
  int obtenirFitxaMaxima() {
    return tauler.reduce(max);
  }

  // Comprovem si el jugador ha arribat a 2048
  bool haGuanyat() {
    return tauler.any((valor) => valor >= 2048);
  }

  // Comprovem si encara podem fer moviments
  bool hiHaMovimentsDisponibles() {

    // Si hi ha una casella buida, podem continuar
    if (tauler.contains(0)) {
      return true;
    }

    // Comprovem les fitxes veïnes
    for (int fila = 0; fila < mida; fila++) {
      for (int columna = 0; columna < mida; columna++) {

        int posicio = fila * mida + columna;
        int valor = tauler[posicio];

        // Comprovem la fitxa de la dreta
        if (columna < mida - 1 &&
            valor == tauler[posicio + 1]) {
          return true;
        }

        // Comprovem la fitxa inferior
        if (fila < mida - 1 &&
            valor == tauler[posicio + mida]) {
          return true;
        }
      }
    }

    // No queden moviments possibles
    return false;
  }

  // Comprovem si el jugador ha perdut
  bool haPerdut() {
    return !hiHaMovimentsDisponibles();
  }
}
