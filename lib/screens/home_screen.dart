import 'package:flutter/material.dart';
import '../models/usuari.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../services/app_theme.dart';
import '../widgets/score_card.dart';
import '../widgets/confirm_dialog.dart';

class HomeScreen extends StatefulWidget {

  // Usuari que ha iniciat sessió
  final Usuari usuari;

  const HomeScreen({
    super.key,
    required this.usuari,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // DAO per consultar les partides
  final PartidaDao _partidaDao = PartidaDao();

  // DAO per comprovar les partides guardades
  final PartidaGuardadaDao _partidaGuardadaDao =
  PartidaGuardadaDao();

  // Indica si tenim una partida pendent
  bool _tePartidaGuardada = false;

  // Millor puntuació de l'usuari
  int _millorPuntuacio = 0;

  // Indica si estem carregant les dades
  bool _carregant = true;

  @override
  void initState() {
    super.initState();

    // Carreguem les dades inicials
    _carregarDades();
  }

  // Recuperem les dades de SQLite
  Future<void> _carregarDades() async {

    if (mounted) {
      setState(() {
        _carregant = true;
      });
    }

    try {

      final int idUsuari = widget.usuari.idUsuari!;

      // Comprovem si existeix una partida guardada
      final bool existeix =
      await _partidaGuardadaDao.existeixPartida(
        idUsuari,
      );

      // Consultem la millor puntuació
      final int millor =
      await _partidaDao.obtenirMillorPuntuacio(
        idUsuari,
      );

      if (!mounted) return;

      // Actualitzem la interfície
      setState(() {
        _tePartidaGuardada = existeix;
        _millorPuntuacio = millor;
        _carregant = false;
      });

    } catch (error) {

      if (!mounted) return;

      setState(() {
        _carregant = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No s\'han pogut carregar les dades.',
          ),
        ),
      );
    }
  }

  // Obrim una pantalla mitjançant una ruta
  Future<void> _obrirRuta(String ruta) async {

    await Navigator.pushNamed(
      context,
      ruta,
      arguments: widget.usuari,
    );

    if (!mounted) return;

    // Actualitzem les dades en tornar
    await _carregarDades();
  }

  // Comencem una partida nova
  Future<void> _novaPartida() async {
    await _obrirRuta('/joc');
  }

  // Continuem una partida guardada
  Future<void> _continuarPartida() async {
    await _obrirRuta('/continuar');
  }

  // Obrim l'historial
  Future<void> _anarHistorial() async {
    await _obrirRuta('/historial');
  }

  // Obrim el rànquing
  Future<void> _anarRanking() async {
    await _obrirRuta('/ranking');
  }

  // Obrim la configuració
  Future<void> _anarConfiguracio() async {
    await _obrirRuta('/configuracio');
  }

  // Demanem confirmació abans de tancar la sessió
  Future<void> _tancarSessio() async {

    final bool confirmar = await ConfirmDialog.mostrar(
      context,
      titol: 'Tancar sessió',
      missatge: 'Estàs segur que vols tancar la sessió?',
      textConfirmar: 'Tancar sessió',
      textCancelar: 'Cancel·lar',
    );

    if (!mounted) return;

    // Si l'usuari confirma, tornem a la pantalla d'accés
    if (confirmar) {
      Navigator.pop(context);
    }
  }

  // Gestionem la navegació inferior
  void _canviarSeccio(int index) {

    if (index == 0) return;

    if (index == 1) {
      _anarHistorial();
    } else if (index == 2) {
      _anarRanking();
    } else if (index == 3) {
      _anarConfiguracio();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        // Eliminem la fletxa de tornar enrere
        automaticallyImplyLeading: false,

        title: const Text('Joc 2048'),

        actions: [

          // Demanem confirmació per tancar la sessió
          IconButton(
            onPressed: _tancarSessio,
            tooltip: 'Tancar sessió',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppTheme.espaiGran,
          ),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Missatge de benvinguda
                Text(
                  'Hola, ${widget.usuari.usuari}!',
                  textAlign: TextAlign.center,
                  style: AppTheme.estilTitol,
                ),

                const SizedBox(
                  height: AppTheme.espaiPetit,
                ),

                const Text(
                  'Preparat per arribar a 2048?',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Icona principal
                Icon(
                  Icons.grid_4x4,
                  size: 90,
                  color: Theme.of(context)
                      .colorScheme.primary,
                ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Mostrem la millor puntuació
                if (_carregant)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  ScoreCard(
                    titol: 'La teva millor puntuació',
                    valor: _millorPuntuacio,
                    icona: Icons.emoji_events,
                  ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Comencem una partida nova
                ElevatedButton.icon(
                  onPressed: _novaPartida,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Nova partida'),
                ),

                // Continuem una partida guardada
                if (!_carregant && _tePartidaGuardada) ...[

                  const SizedBox(
                    height: AppTheme.espaiMitja,
                  ),

                  ElevatedButton.icon(
                    onPressed: _continuarPartida,
                    icon: const Icon(Icons.restore),
                    label: const Text('Continuar partida'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      // Navegació principal inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _canviarSeccio,

        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inici',
          ),

          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),

          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Rànquing',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Opcions',
          ),
        ],
      ),
    );
  }
}