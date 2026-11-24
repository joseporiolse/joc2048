import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class TileWidget extends StatelessWidget {

  final int valor;

  final Color colorPersonalitzat;

  const TileWidget({
    super.key,
    required this.valor,
    required this.colorPersonalitzat,
  });

  @override
  Widget build(BuildContext context) {

    final bool esFosc =
        Theme.of(context).brightness == Brightness.dark;

    final Color colorFons = AppTheme.obtenirColorFitxa(
      valor,
      esFosc,
      colorPersonalitzat,
    );

    final Color colorText = AppTheme.obtenirColorTextFitxa(
      valor,
      esFosc,
      colorPersonalitzat,
    );

    //Ajustem la mida del text segons el valor
    double midaText = 24;

    if (valor >= 1024) {
      midaText = 18;
    } else if (valor >= 128) {
      midaText = 21;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,

      width: double.infinity,
      height: double.infinity,

      alignment: Alignment.center,

      decoration: BoxDecoration(
        color: colorFons,
        borderRadius: BorderRadius.circular(
          AppTheme.radiVores,
        ),
      ),

      //Si la casella està buida, no mostrem cap número
      child: valor == 0
          ? const SizedBox.shrink()
          : FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            '$valor',
            style: AppTheme.estilFitxa.copyWith(
              fontSize: midaText,
              color: colorText,
            ),
          ),
        ),
      ),
    );
  }
}