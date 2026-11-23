import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class StatCard extends StatelessWidget {

  // Títol de l'estadística
  final String titol;

  // Valor que volem mostrar
  final String valor;

  // Icona de l'estadística
  final IconData icona;

  // Color opcional de la icona
  final Color? colorIcona;

  const StatCard({
    super.key,
    required this.titol,
    required this.valor,
    required this.icona,
    this.colorIcona,
  });

  @override
  Widget build(BuildContext context) {

    // Obtenim els colors del tema actual
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,

      // Definim les vores arrodonides
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Icona de l'estadística
            Icon(
              icona,
              size: 30,
              color: colorIcona ?? colors.primary,
            ),

            const SizedBox(
              height: AppTheme.espaiMitja,
            ),

            // Mostrem el valor de l'estadística
            Text(
              valor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.estilPuntuacio.copyWith(
                color: colors.onSurface,
              ),
            ),

            const SizedBox(
              height: AppTheme.espaiPetit,
            ),

            // Mostrem el títol
            Text(
              titol,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
