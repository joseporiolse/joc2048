import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../models/usuari.dart';
import '../services/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class HistoryScreen extends StatefulWidget {
  final Usuari usuari;

  const HistoryScreen({
    super.key,
    required this.usuari,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  // DAO per consultar i modificar SQLite
  final PartidaDao _partidaDao = PartidaDao();

  // Controlador del filtre de jugador
  final TextEditingController _controladorJugador =
  TextEditingController();

  // Future que gestiona la càrrega de dades
  late Future<List<Partida>> _futurPartides;

  // Partides que mostrem a la pantalla
  List<Partida> _partides = [];

  // Filtres seleccionats
  String _filtreJugador = '';
  int? _filtreFitxa;

  // Evitem que una consulta antiga substitueixi la nova
  int _versioCarrega = 0;

  @override
  void initState() {
    super.initState();
    _carregarPartides();
  }

  @override
  void dispose() {
    _controladorJugador.dispose();
    super.dispose();
  }

  // Recuperem les partides des de SQLite
  void _carregarPartides() {
    final int versio = ++_versioCarrega;

    setState(() {
      _futurPartides = _obtenirPartides(versio);
    });
  }

  // Consultem SQLite i apliquem els filtres
  Future<List<Partida>> _obtenirPartides(int versio) async {

    // Consultem els filtres directament al DAO
    final String nom = _filtreJugador;
    final int? fitxa = _filtreFitxa;
    final List<Partida> resultat = await _partidaDao.filtrarHistorial(nom, fitxa);

    // Actualitzem la llista només si és la consulta actual
    if (mounted && versio == _versioCarrega) {
      _partides = resultat;
    }

    return resultat;
  }

  // Actualitzem l'historial arrossegant cap avall
  Future<void> _actualitzarHistorial() async {
    _carregarPartides();

    try {
      await _futurPartides;
    } catch (error) {
      // AsyncDataView mostrarà l'error.
    }
  }

  // Apliquem els filtres seleccionats
  void _aplicarFiltres() {
    setState(() {
      _filtreJugador = _controladorJugador.text.trim();
    });

    _carregarPartides();
  }

  // Eliminem tots els filtres
  void _netejarFiltres() {
    _controladorJugador.clear();

    setState(() {
      _filtreJugador = '';
      _filtreFitxa = null;
    });

    _carregarPartides();
  }

  // Canviem el filtre de fitxa màxima
  void _canviarFiltreFitxa(int? valor) {
    setState(() {
      _filtreFitxa = valor;
    });

    _carregarPartides();
  }

  // Confirmem l'eliminació d'una partida
  Future<bool> _confirmarEliminacio() async {
    return await ConfirmDialog.mostrar(
      context,
      titol: 'Eliminar partida?',
      missatge:
      'Estàs segur que vols eliminar aquesta partida?',
      textConfirmar: 'Eliminar',
      esPerillos: true,
    );
  }

  // Eliminem una partida de SQLite
  Future<void> _eliminarPartida(Partida partida) async {

    if (partida.idUsuari != widget.usuari.idUsuari) return;

    // Eliminem visualment la partida
    setState(() {
      _partides.removeWhere((element) {
        return element.idPartida == partida.idPartida;
      });
    });

    try {
      final eliminades = await _partidaDao.eliminar(
        partida.idPartida!, widget.usuari.idUsuari!,
      );
      if (eliminades == 0) {
        throw StateError("No s’ha eliminat cap partida");
      }

      if (!mounted) return;

      // Permetem recuperar la partida eliminada
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Partida eliminada.'),
          action: SnackBarAction(
            label: 'Desfer',
            onPressed: () {
              _restaurarPartida(partida);
            },
          ),
        ),
      );

    } catch (error) {
      if (!mounted) return;

      _carregarPartides();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No s\'ha pogut eliminar la partida.',
          ),
        ),
      );
    }
  }

  // Recuperem una partida eliminada
  Future<void> _restaurarPartida(Partida partida) async {
    try {
      await _partidaDao.restaurar(partida);

      if (!mounted) return;

      _carregarPartides();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Partida recuperada correctament.',
          ),
        ),
      );

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No s\'ha pogut recuperar la partida.',
          ),
        ),
      );
    }
  }

  // Obrim el detall d'una partida
  Future<void> _obrirDetall(Partida partida) async {

    final bool? eliminada =
    await Navigator.pushNamed<bool>(
      context,
      '/detall',
      arguments: <String, int>{
        'idPartida': partida.idPartida!,
        'idUsuari': widget.usuari.idUsuari!,
      },
    );

    if (!mounted) return;

    if (eliminada == true) {
      _carregarPartides();
    }
  }

  // Mostrem les opcions amb una pulsació llarga
  Future<void> _mostrarOpcionsPartida(
      Partida partida,
      ) async {

    final String? opcio = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Consultar el detall
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Veure detall'),
                onTap: () {
                  Navigator.pop(context, 'detall');
                },
              ),

              // Només podem eliminar les nostres partides
              if (partida.idUsuari == widget.usuari.idUsuari)
                ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,

                  ),
                  title: const Text('Eliminar partida'),
                  onTap: () {
                    Navigator.pop(context, 'eliminar');
                  },
                ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (opcio == 'detall') {
      await _obrirDetall(partida);

    } else if (opcio == 'eliminar') {

      final bool confirmar = await _confirmarEliminacio();

      if (!mounted || !confirmar) return;

      await _eliminarPartida(partida);

      // Actualitzem el Dismissible després de l'eliminació
      if (mounted) {
        _carregarPartides();
      }
    }
  }

  // Confirmem si volem buidar l'historial
  Future<void> _confirmarBuidarHistorial() async {

    final bool confirmar = await ConfirmDialog.mostrar(
      context,
      titol: 'Buidar historial?',
      missatge:
      'S\'eliminaran totes les teves partides. '
          'Aquesta acció no es podrà desfer.',
      textConfirmar: 'Buidar',
      esPerillos: true,
    );

    if (!confirmar || !mounted) return;

    await _buidarHistorial();
  }

  // Eliminem les partides de l'usuari actual
  Future<void> _buidarHistorial() async {
    try {
      await _partidaDao.buidarHistorial(widget.usuari.idUsuari!);

      if (!mounted) return;

      _carregarPartides();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Historial buidat correctament.'),
        ),
      );

    } catch (error) {
      if (!mounted) return;

      _carregarPartides();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No s\'ha pogut buidar l\'historial completament.',
          ),
        ),
      );
    }
  }

  // Construïm els controls dels filtres
  Widget _construirFiltres() {
    return Padding(
      padding: const EdgeInsets.all(
        AppTheme.espaiMitja,
      ),

      child: Column(
        children: [

          // Filtre per jugador
          TextField(
            controller: _controladorJugador,
            decoration: const InputDecoration(
              labelText: 'Filtrar per jugador',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (valor) {
              _aplicarFiltres();
            },
          ),

          const SizedBox(
            height: AppTheme.espaiPetit,
          ),

          // Filtre per fitxa màxima
          DropdownButtonFormField<int>(
            initialValue: _filtreFitxa,
            decoration: const InputDecoration(
              labelText: 'Fitxa màxima mínima',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem<int>(
                value: 128,
                child: Text('128'),
              ),
              DropdownMenuItem<int>(
                value: 256,
                child: Text('256'),
              ),
              DropdownMenuItem<int>(
                value: 512,
                child: Text('512'),
              ),
              DropdownMenuItem<int>(
                value: 1024,
                child: Text('1024'),
              ),
              DropdownMenuItem<int>(
                value: 2048,
                child: Text('2048'),
              ),
            ],
            onChanged: _canviarFiltreFitxa,
          ),

          const SizedBox(
            height: AppTheme.espaiPetit,
          ),

          // Botons dels filtres
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _aplicarFiltres,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Filtrar'),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _netejarFiltres,
                  icon: const Icon(Icons.clear),
                  label: const Text('Netejar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construïm el llistat de partides
  Widget _construirLlista(
      BuildContext context,
      List<Partida> dades,
      ) {

    if (_partides.isEmpty) {
      return RefreshIndicator(
        onRefresh: _actualitzarHistorial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            EmptyStateView(
              titol: 'No hi ha partides',
              missatge:
              'No s\'han trobat partides '
                  'amb els filtres seleccionats.',
              icona: Icons.history,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _actualitzarHistorial,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(
          AppTheme.espaiMitja,
        ),

        itemCount: _partides.length,

        itemBuilder: (context, index) {

          final Partida partida = _partides[index];

          // Detectem la pulsació llarga sobre la partida
          return GestureDetector(
            key: ValueKey(partida.idPartida),
            onLongPress: () {
              _mostrarOpcionsPartida(partida);
            },

            child: PartidaListItem(
              key: ValueKey(partida.idPartida),
              partida: partida,
              esEliminable: partida.idUsuari == widget.usuari.idUsuari,

              // Pulsació curta: obrim el detall
              enTocar: () {
                _obrirDetall(partida);
              },

              // Confirmació del lliscament
              confirmarEliminacio: _confirmarEliminacio,

              // Eliminació lateral
              enEliminar: () {
                _eliminarPartida(partida);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de partides'),

        actions: [

          // Actualitzem les dades
          IconButton(
            onPressed: _carregarPartides,
            tooltip: 'Actualitzar',
            icon: const Icon(Icons.refresh),
          ),

          // Buidem l'historial
          IconButton(
            onPressed: _confirmarBuidarHistorial,
            tooltip: 'Buidar historial',
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),

      body: Column(
        children: [

          // Controls dels filtres
          _construirFiltres(),

          // Historial recuperat de SQLite
          Expanded(
            child: AsyncDataView<List<Partida>>(
              futur: _futurPartides,
              missatgeCarrega: 'Carregant historial...',
              enReintentar: _carregarPartides,
              construirContingut: _construirLlista,
            ),
          ),
        ],
      ),
    );
  }
}
