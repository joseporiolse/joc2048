import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../models/partida.dart';
import '../models/partida_guardada.dart';
import '../models/usuari.dart';
import '../services/app_theme.dart';
import '../services/joc_service.dart';
import '../main.dart';
import '../widgets/board_widget.dart';
import '../widgets/score_card.dart';

class GameScreen extends StatefulWidget {
  final Usuari usuari;
  final bool continuarPartida;

  const GameScreen({
    super.key,
    required this.usuari,
    this.continuarPartida = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {

  final JocService _joc = JocService();
  final PartidaDao _partidaDao = PartidaDao();
  final PartidaGuardadaDao _guardadaDao =
  PartidaGuardadaDao();

  //Mantenim el focus del teclat
  final FocusNode _focusNode = FocusNode();

  Timer? _temporitzador;

  int _segons = 0;
  int _millorPuntuacio = 0;

  bool _carregant = true;
  bool _finalitzada = false;
  bool _sortint = false;
  bool _permetSortir = false;
  bool _dialogObert = false;
  bool _victoriaMostrada = false;

  //Guardem les partides en ordre
  Future<void> _operacionsGuardat = Future<void>.value();

  //Dades necessàries per desfer un moviment
  List<int>? _taulerAnterior;
  int _puntuacioAnterior = 0;
  int _movimentsAnteriors = 0;

  int get _idUsuari => widget.usuari.idUsuari!;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _inicialitzarJoc();
  }

  @override
  void dispose() {
    _temporitzador?.cancel();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //Guardem automàticament quan sortim de l'aplicació
  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {

      _temporitzador?.cancel();

      if (!_carregant &&
          !_finalitzada &&
          !_sortint &&
          !_dialogObert) {
        _guardarPartida();
      }

    } else if (state == AppLifecycleState.resumed) {

      if (!_carregant &&
          !_finalitzada &&
          !_sortint &&
          !_dialogObert) {
        _iniciarTemporitzador();
      }
    }
  }

  //Carreguem o iniciem la partida
  Future<void> _inicialitzarJoc() async {
    try {
      _millorPuntuacio =
      await _partidaDao.obtenirMillorPuntuacio(
        _idUsuari,
      );

      final PartidaGuardada? guardada =
      await _guardadaDao.recuperar(_idUsuari);

      if (!mounted) return;

      if (widget.continuarPartida && guardada != null) {

        //Recuperem el tauler, la puntuació i el temps
        _joc.carregarPartida(
          guardada.tauler,
          guardada.puntuacio,
          guardada.moviments,
        );

        _segons = guardada.segonsTranscorreguts;

        //Si ja havíem arribat a 2048, no repetim l'avís
        _victoriaMostrada = _joc.haGuanyat();

      } else if (widget.continuarPartida) {

        _mostrarMissatge(
          'No hi ha cap partida guardada.',
        );

        _sortirPantalla();
        return;

      } else {

        //Abans de començar, comprovem si perdrem un guardat
        if (guardada != null) {
          final bool? confirmar = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Partida guardada'),
              content: const Text(
                'Ja tens una partida guardada. '
                    'Si comences una partida nova, '
                    'perdràs l\'anterior. Vols continuar?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel·lar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Nova partida'),
                ),
              ],
            ),
          );

          if (!mounted) return;

          if (confirmar != true) {
            _sortirPantalla();
            return;
          }

          await _guardadaDao.eliminar(_idUsuari);
        }

        _joc.iniciarPartida();
      }

      if (!mounted) return;

      setState(() {
        _carregant = false;
      });

      _iniciarTemporitzador();

    } catch (error) {
      if (!mounted) return;

      _mostrarMissatge(
        'No s\'ha pogut preparar la partida.',
      );

      _sortirPantalla();
    }
  }

  //Iniciem el cronòmetre
  void _iniciarTemporitzador() {
    _temporitzador?.cancel();

    _temporitzador = Timer.periodic(
      const Duration(seconds: 1),
          (temporitzador) {
        if (!mounted ||
            _carregant ||
            _finalitzada ||
            _sortint ||
            _dialogObert) {
          return;
        }

        setState(() {
          _segons++;
        });
      },
    );
  }

  //Convertim els segons en minuts i segons
  String _formatarTemps() {
    final int minuts = _segons ~/ 60;
    final int segons = _segons % 60;

    return '${minuts.toString().padLeft(2, '0')}:'
        '${segons.toString().padLeft(2, '0')}';
  }

  void _mostrarMissatge(String missatge) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(missatge)),
    );
  }

  //Guardem una còpia de l'estat actual
  //Les operacions s'executen en ordre
  Future<bool> _guardarPartida() async {
    if (_carregant || _finalitzada) return false;

    final PartidaGuardada partida = PartidaGuardada(
      idUsuari: _idUsuari,
      tauler: List<int>.from(_joc.tauler),
      puntuacio: _joc.puntuacio,
      moviments: _joc.moviments,
      segonsTranscorreguts: _segons,
    );

    final Completer<bool> resultat = Completer<bool>();

    _operacionsGuardat = _operacionsGuardat.then((_) async {
      try {
        await _guardadaDao.guardar(partida);
        resultat.complete(true);
      } catch (error) {
        resultat.complete(false);
      }
    });

    final bool correcte = await resultat.future;

    if (!correcte) {
      _mostrarMissatge(
        'No s\'ha pogut guardar la partida.',
      );
    }

    return correcte;
  }

  //Guardem la partida i tornem al menú principal
  Future<void> _guardarISortir() async {
    if (_carregant || _finalitzada || _sortint || _dialogObert) return;

    setState(() {
      _sortint = true;
    });
    _temporitzador?.cancel();

    final bool correcte = await _guardarPartida();
    if (!mounted) return;

    if (correcte) {
      _mostrarMissatge('Partida guardada.');
      _sortirPantalla();
    } else {
      setState(() {
        _sortint = false;
      });
      _iniciarTemporitzador();
    }
  }

  //Esperem que acabin els guardats pendents
  Future<void> _esperarGuardats() async {
    await _operacionsGuardat;
  }

  //Guardem les dades abans d'un moviment
  void _prepararDesfer() {
    _taulerAnterior = List<int>.from(_joc.tauler);
    _puntuacioAnterior = _joc.puntuacio;
    _movimentsAnteriors = _joc.moviments;
  }

  //Recuperem el tauler anterior
  void _desferMoviment() {
    if (_taulerAnterior == null ||
        _finalitzada ||
        _sortint ||
        _dialogObert) {
      return;
    }

    setState(() {
      _joc.carregarPartida(
        _taulerAnterior!,
        _puntuacioAnterior,
        _movimentsAnteriors,
      );

      _taulerAnterior = null;
    });

    _mostrarMissatge('Moviment desfet.');
  }

  //Gestionem els moviments del 2048
  void _moure(Direccio direccio) {
    if (_carregant ||
        _finalitzada ||
        _sortint ||
        _dialogObert) {
      return;
    }

    _prepararDesfer();

    final bool movimentRealitzat = _joc.moure(direccio);

    if (!movimentRealitzat) {
      _taulerAnterior = null;
      return;
    }

    setState(() {
      if (_joc.puntuacio > _millorPuntuacio) {
        _millorPuntuacio = _joc.puntuacio;
      }
    });

    //Comprovem primer si el jugador ha perdut
    if (_joc.haPerdut()) {
      _finalitzarPartida(_joc.haGuanyat());
      return;
    }

    //Mostrem la victòria una sola vegada
    if (_joc.haGuanyat() && !_victoriaMostrada) {
      _victoriaMostrada = true;
      _mostrarVictoria();
    }
  }

  //Funcions per als controls del teclat
  void _moureAmunt() => _moure(Direccio.amunt);
  void _moureAvall() => _moure(Direccio.avall);
  void _moureEsquerra() => _moure(Direccio.esquerra);
  void _moureDreta() => _moure(Direccio.dreta);

  //Controls amb el teclat
  void _gestionarTeclat(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moureAmunt();
    } else if (event.logicalKey ==
        LogicalKeyboardKey.arrowDown) {
      _moureAvall();
    } else if (event.logicalKey ==
        LogicalKeyboardKey.arrowLeft) {
      _moureEsquerra();
    } else if (event.logicalKey ==
        LogicalKeyboardKey.arrowRight) {
      _moureDreta();
    }
  }

  //Doble toc sobre la puntuació
  void _mostrarInformacioPuntuacio() {
    _mostrarMissatge(
      'Puntuació: ${_joc.puntuacio} · '
          'Millor: $_millorPuntuacio · '
          'Moviments: ${_joc.moviments}',
    );
  }

  //Reiniciem el joc amb confirmació
  Future<void> _reiniciarPartida() async {
    if (_carregant || _finalitzada || _sortint) return;

    _dialogObert = true;
    _temporitzador?.cancel();

    final bool? confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar partida'),
        content: const Text(
          'Vols començar de zero? '
              'Perdràs el progrés de la partida actual.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel·lar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmar == true) {
      try {
        //Evitem que un guardat anterior reaparegui
        await _esperarGuardats();
        await _guardadaDao.eliminar(_idUsuari);

        if (!mounted) return;

        setState(() {
          _joc.iniciarPartida();
          _segons = 0;
          _taulerAnterior = null;
          _victoriaMostrada = false;
        });

      } catch (error) {
        _mostrarMissatge(
          'No s\'ha pogut reiniciar la partida.',
        );
      }
    }

    _dialogObert = false;
    _iniciarTemporitzador();
  }

  //Diàleg quan arribem a 2048
  Future<void> _mostrarVictoria() async {
    _dialogObert = true;
    _temporitzador?.cancel();

    final bool? continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Has arribat a 2048!'),
        content: const Text(
          'Enhorabona! Vols continuar jugant '
              'o finalitzar la partida?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Finalitzar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    _dialogObert = false;

    if (continuar == true) {
      _iniciarTemporitzador();
    } else {
      await _finalitzarPartida(true);
    }
  }

  //Confirmem si volem finalitzar la partida actual
  Future<void> _confirmarFinalitzacio() async {
    if (_carregant || _finalitzada || _sortint || _dialogObert) return;

    _dialogObert = true;
    _temporitzador?.cancel();

    final bool? confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Finalitzar partida?'),
        content: Text(
          'Es registraran els ${_joc.puntuacio} punts a l\'historial '
              'i es tindran en compte al rànquing. '
              'No podràs continuar aquesta partida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel·lar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalitzar'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    _dialogObert = false;

    if (confirmar == true) {
      await _finalitzarPartida(_joc.haGuanyat());
    } else {
      _iniciarTemporitzador();
    }
  }

  //Guardem el resultat final a SQLite
  Future<void> _finalitzarPartida(bool victoria) async {
    if (_finalitzada || _sortint) return;

    _finalitzada = true;
    _temporitzador?.cancel();

    try {
      await _esperarGuardats();

      final Partida partida = Partida(
        idUsuari: _idUsuari,
        puntuacio: _joc.puntuacio,
        fitxaMaxima: _joc.obtenirFitxaMaxima(),
        moviments: _joc.moviments,
        duracioSegons: _segons,
        data: DateTime.now().toIso8601String(),
        midaTauler: 4,
      );

      //Registrem la partida i eliminem el guardat
      await _partidaDao.finalitzarPartida(partida);

      if (!mounted) return;

      final bool? tornarAJugar = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            victoria ? 'Victòria!' : 'Fi de la partida',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puntuació: ${_joc.puntuacio}'),
              Text(
                'Fitxa màxima: ${_joc.obtenirFitxaMaxima()}',
              ),
              Text('Moviments: ${_joc.moviments}'),
              Text('Temps: ${_formatarTemps()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tornar a l\'inici'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Tornar a jugar'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (tornarAJugar == true) {
        //Reiniciem el joc sense perdre el resultat anterior
        setState(() {
          _joc.iniciarPartida();
          _segons = 0;
          _finalitzada = false;
          _sortint = false;
          _dialogObert = false;
          _victoriaMostrada = false;
          _taulerAnterior = null;
          _puntuacioAnterior = 0;
          _movimentsAnteriors = 0;
        });

        _focusNode.requestFocus();
        _iniciarTemporitzador();
      } else {
        _sortirPantalla();
      }

    } catch (error) {
      if (!mounted) return;
      _finalitzada = false;

      _mostrarMissatge(
        'No s\'ha pogut registrar la partida.',
      );

      _iniciarTemporitzador();
    }
  }

  //Permetem sortir després de completar les operacions
  void _sortirPantalla() {
    if (!mounted) return;

    setState(() {
      _permetSortir = true;
      _sortint = true;
    });

    _temporitzador?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  //Opcions abans de sortir del joc
  Future<void> _confirmarSortida() async {
    if (_carregant || _sortint || _finalitzada || _dialogObert) return;

    _dialogObert = true;
    _temporitzador?.cancel();

    final String? opcio = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sortir de la partida?'),
        content: const Text(
          'Què vols fer amb la partida actual?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'cancelar');
            },
            child: const Text('Cancel·lar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'descartar');
            },
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'finalitzar');
            },
            child: const Text('Finalitzar partida'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, 'guardar');
            },
            child: const Text('Guardar i sortir'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (opcio == null || opcio == 'cancelar') {
      _dialogObert = false;
      _iniciarTemporitzador();
      return;
    }

    if (opcio == 'finalitzar') {
      _dialogObert = false;
      await _finalitzarPartida(_joc.haGuanyat());
      return;
    }

    _sortint = true;

    if (opcio == 'guardar') {
      final bool correcte = await _guardarPartida();

      if (!mounted) return;

      if (!correcte) {
        _sortint = false;
        _dialogObert = false;
        _iniciarTemporitzador();
        return;
      }

    } else if (opcio == 'descartar') {
      try {
        await _esperarGuardats();
        await _guardadaDao.eliminar(_idUsuari);

      } catch (error) {
        if (!mounted) return;

        _sortint = false;
        _dialogObert = false;

        _mostrarMissatge(
          'No s\'ha pogut descartar la partida.',
        );

        _iniciarTemporitzador();
        return;
      }
    }

    if (!mounted) return;

    _dialogObert = false;
    _sortirPantalla();
  }

  //Gestionem el botó de tornar enrere
  void _gestionarSortida(
      bool didPop,
      Object? resultat,
      ) {
    if (!didPop) {
      _confirmarSortida();
    }
  }

  //Menú d'opcions del joc
  void _mostrarOpcions() {
    if (_carregant || _finalitzada || _sortint) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('Desfer moviment'),
              onTap: () {
                Navigator.pop(context);
                _desferMoviment();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reiniciar partida'),
              onTap: () {
                Navigator.pop(context);
                _reiniciarPartida();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Finalitzar partida'),
              onTap: () {
                Navigator.pop(context);
                _confirmarFinalitzacio();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sortir'),
              onTap: () {
                Navigator.pop(context);
                _confirmarSortida();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _permetSortir,
      onPopInvokedWithResult: _gestionarSortida,

      child: Scaffold(
        appBar: AppBar(
          title: const Text('2048'),
          leading: BackButton(onPressed: _confirmarSortida),
          actions: [
            IconButton(
              onPressed: _reiniciarPartida,
              tooltip: 'Reiniciar partida',
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: _mostrarOpcions,
              tooltip: 'Opcions del joc',
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),

        body: _carregant
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.espaiMitja),
            child: LayoutBuilder(
              builder: (context, mida) {
                //En horitzontal posem el tauler al costat de les dades
                if (mida.maxWidth > mida.maxHeight) {
                  return Row(
                    children: [
                      Expanded(child: _construirTauler()),
                      const SizedBox(width: AppTheme.espaiMitja),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _construirDades(),
                              const SizedBox(height: AppTheme.espaiMitja),
                              _construirBotoGuardar(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                //En vertical adaptem el tauler sense fer scroll
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        _construirDades(),
                        const SizedBox(height: AppTheme.espaiMitja),
                        Expanded(child: _construirTauler()),
                        const SizedBox(height: AppTheme.espaiMitja),
                        _construirBotoGuardar(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  //Mostrem el jugador, les puntuacions i el temps
  Widget _construirDades() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Jugador: ${widget.usuari.usuari}',
          style: const TextStyle(fontSize: AppTheme.midaSubtitol, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppTheme.espaiPetit),
        GestureDetector(
          onDoubleTap: _mostrarInformacioPuntuacio,
          child: Row(
            children: [
              Expanded(child: ScoreCard(titol: 'Puntuació', valor: _joc.puntuacio)),
              Expanded(child: ScoreCard(titol: 'Millor', valor: _millorPuntuacio)),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.espaiPetit),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Temps: ${_formatarTemps()}'),
            Text('Moviments: ${_joc.moviments}'),
          ],
        ),
      ],
    );
  }

  //Adaptem el tauler a la pantalla
  Widget _construirTauler() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _gestionarTeclat,
          child: ValueListenableBuilder<Color>(
            valueListenable: colorFitxes,
            builder: (context, color, child) {
              return BoardWidget(
                tauler: _joc.tauler,
                colorPersonalitzat: color,
                enMoure: _moure,
                enPulsacioLlarga: _desferMoviment,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _construirBotoGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _sortint || _finalitzada ? null : _guardarISortir,
        icon: const Icon(Icons.save),
        label: const Text('Guardar partida'),
      ),
    );
  }
}