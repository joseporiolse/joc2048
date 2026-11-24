import 'package:flutter/material.dart';
import '../data/partida_dao.dart';
import '../main.dart';
import '../models/usuari.dart';
import '../services/app_theme.dart';
import '../services/preferencies_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/tile_widget.dart';

class SettingsScreen extends StatefulWidget {
  final Usuari usuari;

  const SettingsScreen({super.key, required this.usuari});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final PartidaDao _partidaDao = PartidaDao();

  //Tema seleccionat per l'usuari
  late ThemeMode _modeTema;

  //Color seleccionat per a les fitxes
  late Color _colorSeleccionat;

  //Evitem executar diverses eliminacions alhora
  bool _eliminantHistorial = false;

  //Colors disponibles
  final List<Color> _colorsDisponibles = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  //Valors de les fitxes que mostrem a la vista prèvia
  final List<int> _valorsFitxes = [
    2, 4, 8, 16,
    32, 64, 128, 256,
    512, 1024, 2048, 4096,
  ];

  @override
  void initState() {
    super.initState();

    _modeTema = temaActual.value;
    _colorSeleccionat = colorFitxes.value;
  }

  //Canviem el tema de l'aplicació
  Future<void> _canviarTema(ThemeMode nouTema) async {

    final ThemeMode temaAnterior = _modeTema;

    setState(() {
      _modeTema = nouTema;
    });

    temaActual.value = nouTema;

    try {
      await PreferenciesService.guardarModeTema(nouTema);

    } catch (error) {
      if (!mounted) return;

      //Recuperem el valor anterior si falla
      setState(() {
        _modeTema = temaAnterior;
      });

      temaActual.value = temaAnterior;

      _mostrarMissatge(
        'No s\'ha pogut guardar el tema.',
      );
    }
  }

  //Canviem el color de les fitxes
  Future<void> _canviarColor(Color nouColor) async {

    final Color colorAnterior = _colorSeleccionat;

    setState(() {
      _colorSeleccionat = nouColor;
    });

    colorFitxes.value = nouColor;

    try {
      await PreferenciesService.guardarColorFitxes(
        nouColor,
      );

    } catch (error) {
      if (!mounted) return;

      setState(() {
        _colorSeleccionat = colorAnterior;
      });

      colorFitxes.value = colorAnterior;

      _mostrarMissatge(
        'No s\'ha pogut guardar el color.',
      );
    }
  }

  void _mostrarMissatge(String missatge) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(missatge),
      ),
    );
  }

  //Recuperem la configuració inicial
  Future<void> _restablirConfiguracio() async {

    await _canviarTema(ThemeMode.system);

    if (!mounted) return;

    await _canviarColor(Colors.orange);

    if (!mounted) return;

    _mostrarMissatge(
      'Configuració restablerta.',
    );
  }

  //Confirmem abans de buidar tot l'historial
  Future<void> _confirmarBuidarHistorial() async {

    if (_eliminantHistorial) return;

    final bool confirmar = await ConfirmDialog.mostrar(
      context,
      titol: 'Buidar tot l\'historial?',
      missatge:
      'S\'eliminaran permanentment totes les '
          'partides registrades del teu compte. '
          'Aquesta acció no es podrà desfer.',
      textConfirmar: 'Eliminar-ho tot',
      esPerillos: true,
    );

    if (!confirmar || !mounted) return;

    await _buidarHistorial();
  }

  //Eliminem l'historial de l'usuari actual
  Future<void> _buidarHistorial() async {

    setState(() {
      _eliminantHistorial = true;
    });

    try {
      await _partidaDao.buidarHistorial(
        widget.usuari.idUsuari!,
      );

      if (!mounted) return;

      _mostrarMissatge(
        'Historial eliminat correctament.',
      );

    } catch (error) {
      if (!mounted) return;

      _mostrarMissatge(
        'No s\'ha pogut eliminar l\'historial.',
      );

    } finally {
      if (mounted) {
        setState(() {
          _eliminantHistorial = false;
        });
      }
    }
  }

  //Triem text blanc o negre segons el color de fons
  Color _colorText(Color color) {
    return color.computeLuminance() > 0.179
        ? Colors.black
        : Colors.white;
  }

  //Construïm una opció de color
  Widget _construirOpcioColor(Color color) {

    final bool seleccionat =
        _colorSeleccionat.toARGB32() ==
            color.toARGB32();

    return Tooltip(
      message: seleccionat
          ? 'Color seleccionat'
          : 'Seleccionar color',

      child: InkWell(
        onTap: () {
          _canviarColor(color);
        },

        borderRadius: BorderRadius.circular(
          AppTheme.radiVores,
        ),

        child: Container(
          width: 65,
          height: 65,

          decoration: BoxDecoration(
            color: color,

            borderRadius: BorderRadius.circular(
              AppTheme.radiVores,
            ),

            border: Border.all(
              color: seleccionat
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),

          child: seleccionat
              ? Icon(
            Icons.check,
            color: _colorText(color),
            size: 32,
          )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuració'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(
          AppTheme.espaiMitja,
        ),

        children: [

          const Text(
            'Tema de l\'aplicació',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiPetit,
          ),

          const Text(
            'Selecciona l\'aparença que prefereixis.',
          ),

          const SizedBox(
            height: AppTheme.espaiMitja,
          ),

          RadioGroup<ThemeMode>(
            groupValue: _modeTema,
            onChanged: (ThemeMode? nouTema) {
              if (nouTema != null) {
                _canviarTema(nouTema);
              }
            },

            child: const Column(
              children: [

                RadioListTile<ThemeMode>(
                  title: Text('Automàtic'),
                  subtitle: Text(
                    'Utilitza el tema del dispositiu',
                  ),
                  secondary: Icon(
                    Icons.brightness_auto,
                  ),
                  value: ThemeMode.system,
                ),

                RadioListTile<ThemeMode>(
                  title: Text('Clar'),
                  subtitle: Text(
                    'Utilitza sempre el tema clar',
                  ),
                  secondary: Icon(
                    Icons.light_mode,
                  ),
                  value: ThemeMode.light,
                ),

                RadioListTile<ThemeMode>(
                  title: Text('Fosc'),
                  subtitle: Text(
                    'Utilitza sempre el tema fosc',
                  ),
                  secondary: Icon(
                    Icons.dark_mode,
                  ),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiGran,
          ),

          const Divider(),

          const SizedBox(
            height: AppTheme.espaiMitja,
          ),

          const Text(
            'Color de les fitxes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiPetit,
          ),

          const Text(
            'Personalitza el color de les fitxes del joc.',
          ),

          const SizedBox(
            height: AppTheme.espaiGran,
          ),

          Wrap(
            spacing: AppTheme.espaiMitja,
            runSpacing: AppTheme.espaiMitja,

            children: _colorsDisponibles
                .map(_construirOpcioColor)
                .toList(),
          ),

          const SizedBox(
            height: AppTheme.espaiGran,
          ),

          const Divider(),

          const SizedBox(
            height: AppTheme.espaiMitja,
          ),

          const Text(
            'Vista prèvia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiPetit,
          ),

          const Text(
            'Així es mostraran les fitxes durant la partida.',
          ),

          const SizedBox(
            height: AppTheme.espaiMitja,
          ),

          GridView.builder(

            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppTheme.espaiPetit,
              mainAxisSpacing: AppTheme.espaiPetit,
            ),

            itemCount: _valorsFitxes.length,

            //Reutilitzem el mateix widget que al joc
            itemBuilder: (context, index) {
              return TileWidget(
                valor: _valorsFitxes[index],
                colorPersonalitzat: _colorSeleccionat,
              );
            },
          ),

          const SizedBox(
            height: AppTheme.espaiGran,
          ),

          OutlinedButton.icon(
            onPressed: _restablirConfiguracio,
            icon: const Icon(Icons.restore),
            label: const Text(
              'Restablir configuració',
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiGran,
          ),

          const Divider(),

          const SizedBox(
            height: AppTheme.espaiMitja,
          ),

          const Text(
            'Gestió de dades',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiPetit,
          ),

          const Text(
            'Vols eliminar l\'historial de partides '
                'del teu compte?',
          ),

          const SizedBox(
            height: AppTheme.espaiMitja,
          ),

          OutlinedButton.icon(
            onPressed: _eliminantHistorial
                ? null
                : _confirmarBuidarHistorial,

            icon: _eliminantHistorial
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.delete_forever),

            label: Text(
              _eliminantHistorial
                  ? 'Eliminant historial...'
                  : 'Buidar tot l\'historial',
            ),

            style: OutlinedButton.styleFrom(
              foregroundColor:
              Theme.of(context).colorScheme.error,
            ),
          ),

          const SizedBox(
            height: AppTheme.espaiGran,
          ),
        ],
      ),
    );
  }
}