import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class ScoreCard extends StatelessWidget {

  final String titol;

  final int valor;

  final IconData? icona;

  const ScoreCard({
    super.key,
    required this.titol,
    required this.valor,
    this.icona,
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
          children: [

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