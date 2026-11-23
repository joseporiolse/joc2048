
import 'package:flutter/material.dart';

import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../services/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/stat_card.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() =>
      _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {

  // DAO per consultar SQLite
  final PartidaDao _partidaDao = PartidaDao();

  // Controlador del cercador
  final TextEditingController _controladorCerca =
  TextEditingController();

  // Consultes asíncrones
  late Future<List<Partida>> _futurRanking;
  late Future<Map<String, dynamic>> _futurEstadistiques;
  late Future<List<Map<String, dynamic>>>
  _futurEstadistiquesJugadors;

  // Filtres actius
  String _nomJugador = '';
  int? _filtreFitxa;

  @override
  void initState() {
    super.initState();
    _carregarDades();
  }

  @override
  void dispose() {
    _controladorCerca.dispose();
    super.dispose();
  }

  // Carreguem les dades mantenint els filtres
  void _carregarDades() {
    setState(() {
      _futurRanking = _obtenirRankingFiltrat();

      _futurEstadistiques =
          _partidaDao.obtenirEstadistiques();

      _futurEstadistiquesJugadors =
          _partidaDao.obtenirEstadistiquesJugadors();
    });
  }

  // Obtenim les partides segons els filtres seleccionats
  Future<List<Partida>> _obtenirRankingFiltrat() async {

    List<Partida> partides;

    // Si filtrem pel jugador, utilitzem el DAO
    if (_nomJugador.isNotEmpty) {
      partides = await _partidaDao.filtrarPerJugador(
        _nomJugador,
      );

    } else if (_filtreFitxa != null) {

      // Si només filtrem per fitxa, consultem SQLite
      partides = await _partidaDao.filtrarPerFitxa(
        _filtreFitxa!,
      );

    } else {

      // Sense filtres, obtenim el rànquing principal
      partides = await _partidaDao.obtenirRanking();
    }

    // Si hi ha dos filtres, apliquem també el de fitxa
    if (_nomJugador.isNotEmpty && _filtreFitxa != null) {
      partides = partides.where((partida) {
        return partida.fitxaMaxima >= _filtreFitxa!;
      }).toList();
    }

    // Ordenem les partides de major a menor puntuació
    partides.sort(
          (a, b) => b.puntuacio.compareTo(a.puntuacio),
    );

    // Limitem el rànquing a les 10 millors partides
    return partides.take(10).toList();
  }

  // Actualitzem el rànquing arrossegant cap avall
  Future<void> _actualitzarDades() async {
    _carregarDades();

    try {
      await Future.wait<dynamic>([
        _futurRanking,
        _futurEstadistiques,
        _futurEstadistiquesJugadors,
      ]);
    } catch (error) {
      // AsyncDataView mostrarà l'error corresponent.
    }
  }

  // Apliquem el filtre pel nom del jugador
  void _cercarJugador() {
    _nomJugador = _controladorCerca.text.trim();
    _carregarDades();
  }

  // Canviem el filtre de fitxa màxima
  void _canviarFiltre(int? valor) {
    _filtreFitxa = valor;
    _carregarDades();
  }

  // Eliminem tots els filtres
  void _netejarFiltres() {
    _controladorCerca.clear();

    _nomJugador = '';
    _filtreFitxa = null;

    _carregarDades();
  }

  // Convertim segons en hores i minuts
  String _formatarTemps(int segonsTotals) {
    final int hores = segonsTotals ~/ 3600;
    final int minuts = (segonsTotals % 3600) ~/ 60;

    if (hores > 0) {
      return '$hores h $minuts min';
    }

    return '$minuts min';
  }

  // Convertim un valor SQLite en enter
  int _obtenirEnter(dynamic valor) {
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    return 0;
  }

  // Construïm les partides del rànquing
  Widget _construirRanking(
      BuildContext context,
      List<Partida> partides,
      ) {

    if (partides.isEmpty) {
      return const EmptyStateView(
        titol: 'No hi ha resultats',
        missatge:
        'No s\'han trobat partides amb els '
            'filtres seleccionats.',
        icona: Icons.emoji_events_outlined,
      );
    }

    return Column(
      children: [

        // Mostrem la posició de cada partida
        for (int index = 0; index < partides.length; index++)

          Card(
            child: ListTile(

              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),

              title: Text(
                '${partides[index].puntuacio} punts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Fitxa màxima: '
                    '${partides[index].fitxaMaxima} · '
                    'Moviments: ${partides[index].moviments}',
              ),

              trailing: const Icon(
                Icons.emoji_events_outlined,
              ),
            ),
          ),
      ],
    );
  }

  // Construïm les estadístiques globals
  Widget _construirEstadistiques(
      BuildContext context,
      Map<String, dynamic> dades,
      ) {

    final int total =
    _obtenirEnter(dades['total_partides']);

    final int millor =
    _obtenirEnter(dades['millor_puntuacio']);

    final double mitjana =
        (dades['puntuacio_mitjana'] as num?)
            ?.toDouble() ?? 0;

    final int fitxaMaxima =
    _obtenirEnter(dades['fitxa_maxima']);

    final int tempsTotal =
    _obtenirEnter(dades['temps_total']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        const Text(
          'Estadístiques globals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: AppTheme.espaiMitja,
        ),

        StatCard(
          titol: 'Partides jugades',
          valor: total.toString(),
          icona: Icons.sports_esports,
        ),

        const SizedBox(
          height: AppTheme.espaiPetit,
        ),

        StatCard(
          titol: 'Millor puntuació',
          valor: millor.toString(),
          icona: Icons.star,
        ),

        const SizedBox(
          height: AppTheme.espaiPetit,
        ),

        StatCard(
          titol: 'Puntuació mitjana',
          valor: mitjana.toStringAsFixed(1),
          icona: Icons.bar_chart,
        ),

        const SizedBox(
          height: AppTheme.espaiPetit,
        ),

        StatCard(
          titol: 'Fitxa màxima',
          valor: fitxaMaxima.toString(),
          icona: Icons.grid_view,
        ),

        const SizedBox(
          height: AppTheme.espaiPetit,
        ),

        StatCard(
          titol: 'Temps total',
          valor: _formatarTemps(tempsTotal),
          icona: Icons.timer,
        ),
      ],
    );
  }

  // Construïm les estadístiques agrupades per jugador
  Widget _construirEstadistiquesJugadors(
      BuildContext context,
      List<Map<String, dynamic>> jugadors,
      ) {

    if (jugadors.isEmpty) {
      return const EmptyStateView(
        titol: 'Sense estadístiques',
        missatge:
        'Encara no hi ha partides registrades.',
        icona: Icons.people_outline,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        const Text(
          'Estadístiques per jugador',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: AppTheme.espaiMitja,
        ),

        // Mostrem les dades de cada jugador
        for (final jugador in jugadors)

          Padding(
            padding: const EdgeInsets.only(bottom: 8),

            child: StatCard(
              titol:
              '${jugador['usuario'] ?? 'Jugador'}',
              valor:
              '${jugador['millor_puntuacio'] ?? 0} punts',
              icona: Icons.person,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rànquing i estadístiques'),

        actions: [
          IconButton(
            onPressed: _actualitzarDades,
            tooltip: 'Actualitzar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _actualitzarDades,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.all(
            AppTheme.espaiMitja,
          ),

          children: [

            const Text(
              'Millors puntuacions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: AppTheme.espaiMitja,
            ),

            // Cercador de jugadors
            TextField(
              controller: _controladorCerca,
              textInputAction: TextInputAction.search,

              onSubmitted: (valor) {
                _cercarJugador();
              },

              decoration: InputDecoration(
                labelText: 'Cercar jugador',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  onPressed: _cercarJugador,
                  tooltip: 'Cercar',
                  icon: const Icon(Icons.search),
                ),
              ),
            ),

            const SizedBox(
              height: AppTheme.espaiMitja,
            ),

            // Filtre per fitxa màxima
            DropdownButtonFormField<int>(
              key: ValueKey(_filtreFitxa),
              initialValue: _filtreFitxa,

              decoration: const InputDecoration(
                labelText: 'Fitxa màxima mínima',
                border: OutlineInputBorder(),
              ),

              items: const [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text('Totes les fitxes'),
                ),
                DropdownMenuItem<int>(
                  value: 32,
                  child: Text('32 o superior'),
                ),
                DropdownMenuItem<int>(
                  value: 64,
                  child: Text('64 o superior'),
                ),
                DropdownMenuItem<int>(
                  value: 128,
                  child: Text('128 o superior'),
                ),
                DropdownMenuItem<int>(
                  value: 256,
                  child: Text('256 o superior'),
                ),
                DropdownMenuItem<int>(
                  value: 512,
                  child: Text('512 o superior'),
                ),
                DropdownMenuItem<int>(
                  value: 1024,
                  child: Text('1024 o superior'),
                ),
                DropdownMenuItem<int>(
                  value: 2048,
                  child: Text('2048 o superior'),
                ),
              ],

              onChanged: _canviarFiltre,
            ),

            const SizedBox(
              height: AppTheme.espaiPetit,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _netejarFiltres,
                icon: const Icon(Icons.clear),
                label: const Text('Netejar filtres'),
              ),
            ),

            const SizedBox(
              height: AppTheme.espaiMitja,
            ),

            // Rànquing filtrat
            AsyncDataView<List<Partida>>(
              futur: _futurRanking,
              missatgeCarrega: 'Carregant rànquing...',
              enReintentar: _carregarDades,
              construirContingut: _construirRanking,
            ),

            const SizedBox(
              height: AppTheme.espaiGran,
            ),

            // Estadístiques globals
            AsyncDataView<Map<String, dynamic>>(
              futur: _futurEstadistiques,
              missatgeCarrega:
              'Carregant estadístiques...',
              enReintentar: _carregarDades,
              construirContingut:
              _construirEstadistiques,
            ),

            const SizedBox(
              height: AppTheme.espaiGran,
            ),

            // Estadístiques per jugador
            AsyncDataView<List<Map<String, dynamic>>>(
              futur: _futurEstadistiquesJugadors,
              missatgeCarrega:
              'Carregant estadístiques dels jugadors...',
              enReintentar: _carregarDades,
              construirContingut:
              _construirEstadistiquesJugadors,
            ),

            const SizedBox(
              height: AppTheme.espaiGran,
            ),
          ],
        ),
      ),
    );
  }
}