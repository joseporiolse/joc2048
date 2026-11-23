import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class AsyncDataView<T> extends StatelessWidget {

  // Operació asíncrona que recupera les dades
  final Future<T> futur;

  // Widget que mostrarem quan tinguem les dades
  final Widget Function(BuildContext context, T dades)
  construirContingut;

  // Acció opcional per tornar a carregar les dades
  final VoidCallback? enReintentar;

  // Missatge que mostrem mentre es carreguen les dades
  final String missatgeCarrega;

  const AsyncDataView({
    super.key,
    required this.futur,
    required this.construirContingut,
    this.enReintentar,
    this.missatgeCarrega = 'Carregant dades...',
  });

  @override
  Widget build(BuildContext context) {

    // FutureBuilder escolta el resultat de l'operació
    return FutureBuilder<T>(
      future: futur,

      builder: (context, snapshot) {

        // Mentre esperem les dades, mostrem la càrrega
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const CircularProgressIndicator(),

                const SizedBox(
                  height: AppTheme.espaiMitja,
                ),

                Text(missatgeCarrega),
              ],
            ),
          );
        }

        // Si hi ha hagut un error, mostrem un missatge
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(
                AppTheme.espaiGran,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.error,
                  ),

                  const SizedBox(
                    height: AppTheme.espaiMitja,
                  ),

                  const Text(
                    'No s\'han pogut carregar les dades.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: AppTheme.espaiPetit,
                  ),

                  const Text(
                    'Comprova-ho i torna-ho a intentar.',
                    textAlign: TextAlign.center,
                  ),

                  // Mostrem el botó si tenim una acció definida
                  if (enReintentar != null) ...[

                    const SizedBox(
                      height: AppTheme.espaiGran,
                    ),

                    ElevatedButton.icon(
                      onPressed: enReintentar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tornar-ho a intentar'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Si tenim dades, construïm el contingut
        if (snapshot.hasData) {
          return construirContingut(
            context,
            snapshot.data as T,
          );
        }

        // Si l'operació no retorna dades
        return const Center(
          child: Text('No hi ha dades disponibles.'),
        );
      },
    );
  }
}
