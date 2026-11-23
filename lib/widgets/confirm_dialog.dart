import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {

  // Títol del diàleg
  final String titol;

  // Missatge que volem mostrar
  final String missatge;

  // Text del botó de confirmació
  final String textConfirmar;

  // Text del botó de cancel·lació
  final String textCancelar;

  // Indica si l'acció és perillosa
  final bool esPerillos;

  const ConfirmDialog({
    super.key,
    required this.titol,
    required this.missatge,
    this.textConfirmar = 'Confirmar',
    this.textCancelar = 'Cancel·lar',
    this.esPerillos = false,
  });

  // Mostrem el diàleg i retornem la resposta
  static Future<bool> mostrar(
      BuildContext context, {
        required String titol,
        required String missatge,
        String textConfirmar = 'Confirmar',
        String textCancelar = 'Cancel·lar',
        bool esPerillos = false,
      }) async {

    final bool? resultat = await showDialog<bool>(
      context: context,

      builder: (context) {
        return ConfirmDialog(
          titol: titol,
          missatge: missatge,
          textConfirmar: textConfirmar,
          textCancelar: textCancelar,
          esPerillos: esPerillos,
        );
      },
    );

    // Si es tanca sense confirmar, retornem false
    return resultat ?? false;
  }

  // Tanquem el diàleg sense confirmar
  void _cancelar(BuildContext context) {
    Navigator.pop(context, false);
  }

  // Tanquem el diàleg confirmant l'acció
  void _confirmar(BuildContext context) {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    // Obtenim els colors del tema
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(

      // Títol del diàleg
      title: Text(titol),

      // Missatge de confirmació
      content: Text(missatge),

      // Botons del diàleg
      actions: [

        TextButton(
          onPressed: () => _cancelar(context),
          child: Text(textCancelar),
        ),

        FilledButton(
          style: esPerillos
              ? FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          )
              : null,

          onPressed: () => _confirmar(context),
          child: Text(textConfirmar),
        ),
      ],
    );
  }
}
