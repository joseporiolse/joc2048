import 'package:flutter/material.dart';
import 'models/usuari.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/history_screen.dart';
import 'screens/game_detail_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/settings_screen.dart';
import 'services/app_theme.dart';
import 'services/preferencies_service.dart';

//Tema actual de l'aplicació
final ValueNotifier<ThemeMode> temaActual =
ValueNotifier<ThemeMode>(ThemeMode.system);

final ValueNotifier<Color> colorFitxes =
ValueNotifier<Color>(Colors.orange);

Future<void> main() async {

  //Inicialitzem Flutter abans de carregar les preferències
  WidgetsFlutterBinding.ensureInitialized();

  //Recuperem el tema guardat a SharedPreferences
  temaActual.value =
  await PreferenciesService.llegirModeTema();

  //Recuperem el color guardat de les fitxes
  colorFitxes.value =
  await PreferenciesService.llegirColorFitxes();

  //Iniciem l'aplicació
  runApp(const Joc2048App());
}

class Joc2048App extends StatelessWidget {
  const Joc2048App({super.key});

  //Gestionem totes les rutes de l'aplicació
  Route<dynamic> _generarRuta(RouteSettings settings) {

    switch (settings.name) {

      case '/login':
        return MaterialPageRoute<Usuari>(
          builder: (context) => const LoginScreen(),
        );

      case '/registre':
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        );

      case '/inici':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            usuari: usuari,
          ),
        );

      case '/joc':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => GameScreen(
            usuari: usuari,
            continuarPartida: false,
          ),
        );

      case '/continuar':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => GameScreen(
            usuari: usuari,
            continuarPartida: true,
          ),
        );

      case '/historial':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => HistoryScreen(
            usuari: usuari,
          ),
        );

      case '/detall':

        final arguments = settings.arguments as Map<String, int>;
        final int idPartida = arguments['idPartida']!;

        return MaterialPageRoute<bool>(
          builder: (context) => GameDetailScreen(
            idPartida: idPartida,
            idUsuari: arguments['idUsuari']!,
          ),
        );

      case '/ranking':
        return MaterialPageRoute(
          builder: (context) => const RankingScreen(),
        );

      case '/configuracio':
        return MaterialPageRoute(
          builder: (context) => SettingsScreen(usuari: settings.arguments as Usuari),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Pantalla no trobada'),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    //Escoltem els canvis del tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaActual,

      builder: (context, mode, child) {

        return MaterialApp(

          title: 'Joc 2048',

          debugShowCheckedModeBanner: false,

          theme: AppTheme.temaClar,

          darkTheme: AppTheme.temaFosc,

          themeMode: mode,

          home: const PantallaAcces(),

          onGenerateRoute: _generarRuta,
        );
      },
    );
  }
}

//Pantalla inicial amb els botons d'accés
class PantallaAcces extends StatefulWidget {
  const PantallaAcces({super.key});

  @override
  State<PantallaAcces> createState() =>
      _PantallaAccesState();
}

class _PantallaAccesState extends State<PantallaAcces> {

  //Obrim el login i esperem l'usuari autenticat
  Future<void> _iniciarSessio() async {

    final Usuari? usuari = await Navigator.pushNamed<Usuari>(
      context,
      '/login',
    );

    if (!mounted || usuari == null) {
      return;
    }

    Navigator.pushNamed(
      context,
      '/inici',
      arguments: usuari,
    );
  }

  void _crearCompte() {

    Navigator.pushNamed(
      context,
      '/registre',
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            AppTheme.espaiGran,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.grid_4x4,
                size: 110,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: AppTheme.espaiPetit,
              ),

              const Text(
                'Combina les fitxes i arriba a 2048!',
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              ElevatedButton.icon(
                onPressed: _iniciarSessio,
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sessió'),
              ),

              const SizedBox(
                height: AppTheme.espaiMitja,
              ),

              OutlinedButton.icon(
                onPressed: _crearCompte,
                icon: const Icon(Icons.person_add),
                label: const Text('Crear compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}