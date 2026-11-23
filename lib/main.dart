import 'package:flutter/material.dart';

import 'services/preferencies_service.dart';
import 'services/app_theme.dart';

// Guardem el tema i el color per actualitzar l'aplicació
final ValueNotifier<ThemeMode> temaActual =
ValueNotifier(ThemeMode.system);

final ValueNotifier<Color> colorFitxes =
ValueNotifier(Colors.orange);

Future<void> main() async {

  // Inicialitzem Flutter abans de carregar les preferències
  WidgetsFlutterBinding.ensureInitialized();

  // Recuperem el tema guardat
  temaActual.value =
  await PreferenciesService.llegirModeTema();

  // Recuperem el color de les fitxes
  colorFitxes.value =
  await PreferenciesService.llegirColorFitxes();

  // Iniciem l'aplicació
  runApp(const Joc2048App());
}

class Joc2048App extends StatelessWidget {
  const Joc2048App({super.key});

  @override
  Widget build(BuildContext context) {

    // Escoltem els canvis del tema
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaActual,
      builder: (context, mode, child) {

        return MaterialApp(
          title: 'Joc 2048',
          debugShowCheckedModeBanner: false,

          // Definim els temes de l'aplicació
          theme: AppTheme.temaClar,
          darkTheme: AppTheme.temaFosc,
          themeMode: mode,

          // Pantalla temporal d'inici
          home: const PantallaInicial(),
        );
      },
    );
  }
}

// Pantalla temporal per comprovar l'aplicació
class PantallaInicial extends StatelessWidget {
  const PantallaInicial({super.key});

  // Canviem el tema a mode clar
  Future<void> activarTemaClar() async {
    temaActual.value = ThemeMode.light;

    await PreferenciesService.guardarModeTema(
      ThemeMode.light,
    );
  }

  // Canviem el tema a mode fosc
  Future<void> activarTemaFosc() async {
    temaActual.value = ThemeMode.dark;

    await PreferenciesService.guardarModeTema(
      ThemeMode.dark,
    );
  }

  // Utilitzem el tema del sistema
  Future<void> activarTemaSistema() async {
    temaActual.value = ThemeMode.system;

    await PreferenciesService.guardarModeTema(
      ThemeMode.system,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joc 2048'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Benvingut al joc 2048!',
              style: AppTheme.estilTitol,
            ),

            const SizedBox(height: AppTheme.espaiGran),

            ElevatedButton(
              onPressed: activarTemaClar,
              child: const Text('Tema clar'),
            ),

            const SizedBox(height: AppTheme.espaiPetit),

            ElevatedButton(
              onPressed: activarTemaFosc,
              child: const Text('Tema fosc'),
            ),

            const SizedBox(height: AppTheme.espaiPetit),

            ElevatedButton(
              onPressed: activarTemaSistema,
              child: const Text('Tema del sistema'),
            ),

          ],
        ),
      ),
    );
  }
}
