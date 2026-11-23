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

// Tema actual de l'aplicació
final ValueNotifier<ThemeMode> temaActual =
ValueNotifier<ThemeMode>(ThemeMode.system);

// Color personalitzat de les fitxes
final ValueNotifier<Color> colorFitxes =
ValueNotifier<Color>(Colors.orange);

Future<void> main() async {

  // Inicialitzem Flutter abans de carregar preferències
  WidgetsFlutterBinding.ensureInitialized();

  // Recuperem el tema guardat a SharedPreferences
  temaActual.value =
  await PreferenciesService.llegirModeTema();

  // Recuperem el color guardat de les fitxes
  colorFitxes.value =
  await PreferenciesService.llegirColorFitxes();

  // Iniciem l'aplicació
  runApp(const Joc2048App());
}

class Joc2048App extends StatelessWidget {
  const Joc2048App({super.key});

  // Gestionem totes les rutes de l'aplicació
  Route<dynamic> _generarRuta(RouteSettings settings) {

    switch (settings.name) {

    // Pantalla d'inici de sessió
      case '/login':
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );

    // Pantalla de registre
      case '/registre':
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        );

    // Pantalla principal
      case '/inici':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => HomeScreen(
            usuari: usuari,
          ),
        );

    // Nova partida
      case '/joc':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => GameScreen(
            usuari: usuari,
            continuarPartida: false,
          ),
        );

    // Continuar una partida guardada
      case '/continuar':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => GameScreen(
            usuari: usuari,
            continuarPartida: true,
          ),
        );

    // Historial de partides
      case '/historial':

        final Usuari usuari = settings.arguments as Usuari;

        return MaterialPageRoute(
          builder: (context) => HistoryScreen(
            usuari: usuari,
          ),
        );

    // Detall d'una partida
      case '/detall':

        final int idPartida = settings.arguments as int;

        return MaterialPageRoute(
          builder: (context) => GameDetailScreen(
            idPartida: idPartida,
          ),
        );

    // Rànquing i estadístiques
      case '/ranking':
        return MaterialPageRoute(
          builder: (context) => const RankingScreen(),
        );

    // Configuració
      case '/configuracio':
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        );

    // Ruta desconeguda
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

    // Escoltem els canvis del tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaActual,

      builder: (context, mode, child) {

        return MaterialApp(

          // Nom de l'aplicació
          title: 'Joc 2048',

          // Eliminem la banda de depuració
          debugShowCheckedModeBanner: false,

          // Tema clar
          theme: AppTheme.temaClar,

          // Tema fosc
          darkTheme: AppTheme.temaFosc,

          // Tema seleccionat per l'usuari
          themeMode: mode,

          // Primera pantalla de l'aplicació
          home: const PantallaAcces(),

          // Gestió centralitzada de les rutes
          onGenerateRoute: _generarRuta,
        );
      },
    );
  }
}

// Pantalla que controla l'accés a l'aplicació
class PantallaAcces extends StatefulWidget {
  const PantallaAcces({super.key});

  @override
  State<PantallaAcces> createState() =>
      _PantallaAccesState();
}

class _PantallaAccesState extends State<PantallaAcces> {

  // Evitem obrir dues vegades la pantalla principal
  bool _navegant = false;

  // Obrim el login i esperem l'usuari autenticat
  Future<void> _iniciarSessio() async {

    if (_navegant) return;

    _navegant = true;

    try {

      // Obrim la pantalla d'inici de sessió
      final Usuari? usuari =
      await Navigator.pushNamed<Usuari>(
        context,
        '/login',
      );

      if (!mounted || usuari == null) return;

      // Obrim la pantalla principal
      await Navigator.pushNamed(
        context,
        '/inici',
        arguments: usuari,
      );

    } finally {
      _navegant = false;
    }
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

              // Icona principal
              Icon(
                Icons.grid_4x4,
                size: 110,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              // Nom del joc
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

              // Botó per iniciar sessió
              ElevatedButton.icon(
                onPressed: _iniciarSessio,
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sessió'),
              ),

              const SizedBox(
                height: AppTheme.espaiMitja,
              ),

              // Botó per registrar-se
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/registre',
                  );
                },
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
