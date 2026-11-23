import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class ScoreCard extends StatelessWidget {

  // Títol que apareixerà a la targeta
  final String titol;

  // Valor numèric que volem mostrar
  final int valor;

  // Icona opcional de la targeta
  final IconData? icona;

  const ScoreCard({
    super.key,
    required this.titol,
    required this.valor,
    this.icona,
  });

  @override
  Widget build(BuildContext context) {

    // Obtenim els colors del tema actual
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,

      // Donem forma arrodonida a la targeta
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppTheme.radiVores,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(
          AppTheme.espaiMitja,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Mostrem la icona si s'ha proporcionat
            if (icona != null)
              Icon(
                icona,
                color: colors.primary,
                size: 28,
              ),

            if (icona != null)
              const SizedBox(
                height: AppTheme.espaiPetit,
              ),

            // Mostrem el títol
            Text(
              titol,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: AppTheme.espaiPetit,
            ),

            // Mostrem el valor numèric
            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 200,
              ),

              child: Text(
                '$valor',
                key: ValueKey(valor),
                textAlign: TextAlign.center,
                style: AppTheme.estilPuntuacio.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
