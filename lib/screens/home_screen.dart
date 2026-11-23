import 'package:flutter/material.dart';
import '../models/usuari.dart';
import '../data/partida_guardada_dao.dart';
import '../services/app_theme.dart';

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

  // Posició seleccionada de la navegació inferior
  int _indexSeleccionat = 0;

  // DAO per comprovar si tenim una partida guardada
  final PartidaGuardadaDao _partidaGuardadaDao =
  PartidaGuardadaDao();

  // Indica si l'usuari té una partida pendent
  bool _tePartidaGuardada = false;

  // Indica si estem carregant les dades
  bool _carregant = true;

  @override
  void initState() {
    super.initState();

    // Comprovem si hi ha una partida per continuar
    _comprovarPartidaGuardada();
  }

  // Consultem SQLite per saber si hi ha una partida guardada
  Future<void> _comprovarPartidaGuardada() async {
    try {
      final bool existeix =
      await _partidaGuardadaDao.existeixPartida(
        widget.usuari.idUsuari!,
      );

      if (!mounted) return;

      setState(() {
        _tePartidaGuardada = existeix;
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
            'No s\'ha pogut comprovar la partida guardada.',
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

    // Quan tornem, actualitzem la partida guardada
    if (!mounted) return;

    await _comprovarPartidaGuardada();
  }

  // Comencem una partida nova
  Future<void> _novaPartida() async {
    await _obrirRuta('/joc');
  }

  // Continuem la partida guardada
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

  // Tanquem la sessió
  void _tancarSessio() {
    Navigator.pop(context);
  }

  // Gestionem la navegació inferior
  void _canviarSeccio(int index) {

    if (index == 0) {
      setState(() {
        _indexSeleccionat = 0;
      });
      return;
    }

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
        title: const Text('Joc 2048'),

        actions: [

          // Botó per tancar la sessió
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

                // Icona principal del joc
                Icon(
                  Icons.grid_4x4,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Botó per començar una partida nova
                ElevatedButton.icon(
                  onPressed: _novaPartida,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Nova partida'),
                ),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                // Mostrem el botó de continuar si hi ha partida
                if (_carregant)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_tePartidaGuardada)
                  ElevatedButton.icon(
                    onPressed: _continuarPartida,
                    icon: const Icon(Icons.restore),
                    label: const Text('Continuar partida'),
                  ),

                const SizedBox(
                  height: AppTheme.espaiGran,
                ),

                // Accés directe a l'historial
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Historial'),
                    subtitle: const Text(
                      'Consulta les teves partides anteriors',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _anarHistorial,
                  ),
                ),

                // Accés directe al rànquing
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Rànquing i estadístiques'),
                    subtitle: const Text(
                      'Consulta les millors puntuacions',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _anarRanking,
                  ),
                ),

                // Accés directe a la configuració
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Configuració'),
                    subtitle: const Text(
                      'Personalitza el tema i els colors',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _anarConfiguracio,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Navegació principal inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexSeleccionat,
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
