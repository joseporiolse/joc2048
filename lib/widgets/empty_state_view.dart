import 'package:flutter/material.dart';

import '../services/app_theme.dart';

class EmptyStateView extends StatelessWidget {

  // Títol que mostrem quan no hi ha dades
  final String titol;

  // Missatge explicatiu
  final String missatge;

  // Icona que representa l'estat buit
  final IconData icona;

  // Text opcional del botó
  final String? textBoto;

  // Acció opcional del botó
  final VoidCallback? enPremer;

  const EmptyStateView({
    super.key,
    required this.titol,
    required this.missatge,
    this.icona = Icons.inbox_outlined,
    this.textBoto,
    this.enPremer,
  });

  @override
  Widget build(BuildContext context) {

    // Obtenim els colors del tema actual
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppTheme.espaiGran,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Icona de l'estat buit
            Icon(
              icona,
              size: 72,
              color: colors.primary,
            ),

            const SizedBox(
              height: AppTheme.espaiMitja,
            ),

            // Títol principal
            Text(
              titol,
              textAlign: TextAlign.center,
              style: AppTheme.estilPuntuacio.copyWith(
                color: colors.onSurface,
              ),
            ),

            const SizedBox(
              height: AppTheme.espaiPetit,
            ),

            // Missatge explicatiu
            Text(
              missatge,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurfaceVariant,
              ),
            ),

            // Mostrem el botó només si tenim
            // un text i una acció definits
            if (textBoto != null && enPremer != null) ...[

              const SizedBox(
                height: AppTheme.espaiGran,
              ),

              ElevatedButton(
                onPressed: enPremer,
                child: Text(textBoto!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
