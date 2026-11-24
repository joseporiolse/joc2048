import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../services/app_theme.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/score_card.dart';
import '../widgets/stat_card.dart';

class GameDetailScreen extends StatefulWidget {

  final int idPartida;
  final int idUsuari;

  const GameDetailScreen({
    super.key,
    required this.idPartida,
    required this.idUsuari,
  });

  @override
  State<GameDetailScreen> createState() =>
      _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {

  final PartidaDao _partidaDao = PartidaDao();

  late Future<Partida?> _futurPartida;

  //Evitem eliminar dues vegades la mateixa partida
  bool _eliminant = false;

  @override
  void initState() {
    super.initState();

    _carregarPartida();
  }

  //Recuperem la partida des de SQLite
  void _carregarPartida() {
    setState(() {
      _futurPartida = _partidaDao.obtenirPerId(
        widget.idPartida,
      );
    });
  }

  //Convertim els segons en hores, minuts i segons
  String _formatarDuracio(int segonsTotals) {

    final int hores = segonsTotals ~/ 3600;
    final int minuts = (segonsTotals % 3600) ~/ 60;
    final int segons = segonsTotals % 60;

    if (hores > 0) {
      return '${hores.toString().padLeft(2, '0')}:'
          '${minuts.toString().padLeft(2, '0')}:'
          '${segons.toString().padLeft(2, '0')}';
    }

    return '${minuts.toString().padLeft(2, '0')}:'
        '${segons.toString().padLeft(2, '0')}';
  }

  //Convertim la data ISO en un format llegible
  String _formatarData(String data) {

    final DateTime? dataConvertida =
    DateTime.tryParse(data);

    if (dataConvertida == null) {
      return data;
    }

    final String dia =
    dataConvertida.day.toString().padLeft(2, '0');

    final String mes =
    dataConvertida.month.toString().padLeft(2, '0');

    final String any = dataConvertida.year.toString();

    final String hora =
    dataConvertida.hour.toString().padLeft(2, '0');

    final String minut =
    dataConvertida.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$any - $hora:$minut';
  }

  //Demanem confirmació abans d'eliminar
  Future<void> _confirmarEliminacio() async {

    if (_eliminant) return;

    final bool confirmar = await ConfirmDialog.mostrar(
      context,
      titol: 'Eliminar partida?',
      missatge:
      'Estàs segur que vols eliminar aquesta partida? '
          'Aquesta acció no es podrà desfer des del detall.',
      textConfirmar: 'Eliminar',
      esPerillos: true,
    );

    if (!confirmar || !mounted) return;

    await _eliminarPartida();
  }

  //Eliminem la partida de SQLite
  Future<void> _eliminarPartida() async {

    setState(() {
      _eliminant = true;
    });

    try {

      final int filesEliminades =
      await _partidaDao.eliminar(
        widget.idPartida,
        widget.idUsuari,
      );

      if (!mounted) return;

      if (filesEliminades == 0) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La partida no existeix o no és teva.',
            ),
          ),
        );

        _carregarPartida();
        return;
      }

      Navigator.pop(context, true);

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No s\'ha pogut eliminar la partida.',
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _eliminant = false;
        });
      }
    }
  }

  //Construïm la informació de la partida
  Widget _construirDetall(
      BuildContext context,
      Partida? partida,
      ) {

    if (partida == null) {

      return const Center(
        child: Text(
          'No s\'ha trobat aquesta partida.',
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(
        AppTheme.espaiMitja,
      ),

      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Icon(
                Icons.emoji_events,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(
                height: AppTheme.espaiMitja,
              ),

              const Text(
                'Resultat de la partida',
                textAlign: TextAlign.center,
                style: AppTheme.estilTitol,
              ),

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              ScoreCard(
                titol: 'Puntuació final',
                valor: partida.puntuacio,
                icona: Icons.star,
              ),

              const SizedBox(
                height: AppTheme.espaiMitja,
              ),

              Row(
                children: [

                  Expanded(
                    child: StatCard(
                      titol: 'Fitxa màxima',
                      valor: partida.fitxaMaxima.toString(),
                      icona: Icons.grid_view,
                    ),
                  ),

                  Expanded(
                    child: StatCard(
                      titol: 'Moviments',
                      valor: partida.moviments.toString(),
                      icona: Icons.swipe,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppTheme.espaiMitja,
              ),

              Row(
                children: [

                  Expanded(
                    child: StatCard(
                      titol: 'Durada',
                      valor: _formatarDuracio(
                        partida.duracioSegons,
                      ),
                      icona: Icons.timer,
                    ),
                  ),

                  Expanded(
                    child: StatCard(
                      titol: 'Tauler',
                      valor:
                      '${partida.midaTauler} × ${partida.midaTauler}',
                      icona: Icons.apps,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppTheme.espaiMitja,
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Informació de la partida',
                        style: TextStyle(
                          fontSize: AppTheme.midaSubtitol,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: AppTheme.espaiMitja,
                      ),

                      Text(
                        'Identificador: ${partida.idPartida}',
                      ),

                      const SizedBox(
                        height: AppTheme.espaiPetit,
                      ),

                      Text(
                        'Data: ${_formatarData(partida.data)}',
                      ),

                      const SizedBox(
                        height: AppTheme.espaiPetit,
                      ),

                      Text(
                        'Mida del tauler: '
                            '${partida.midaTauler} × ${partida.midaTauler}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              if (partida.idUsuari == widget.idUsuari)
                FilledButton.icon(
                  onPressed:
                  _eliminant ? null : _confirmarEliminacio,

                  icon: _eliminant
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.delete),

                  label: Text(
                    _eliminant
                        ? 'Eliminant...'
                        : 'Eliminar partida',
                  ),

                  style: FilledButton.styleFrom(
                    backgroundColor:
                    Theme.of(context).colorScheme.error,
                    foregroundColor:
                    Theme.of(context).colorScheme.onError,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detall de la partida'),

        actions: [

          IconButton(
            onPressed: _carregarPartida,
            tooltip: 'Actualitzar',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: AsyncDataView<Partida?>(
        futur: _futurPartida,

        missatgeCarrega: 'Carregant partida...',

        enReintentar: _carregarPartida,

        construirContingut: _construirDetall,
      ),
    );
  }
}