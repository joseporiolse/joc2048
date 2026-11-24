import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class StatCard extends StatelessWidget {

  final String titol;

  final String valor;

  final IconData icona;

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

    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,

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

            Icon(
              icona,
              size: 30,
              color: colorIcona ?? colors.primary,
            ),

            const SizedBox(
              height: AppTheme.espaiMitja,
            ),

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