import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {

  final String titol;

  final String missatge;

  final String textConfirmar;

  final String textCancelar;

  final bool esPerillos;

  const ConfirmDialog({
    super.key,
    required this.titol,
    required this.missatge,
    this.textConfirmar = 'Confirmar',
    this.textCancelar = 'Cancel·lar',
    this.esPerillos = false,
  });

  //Mostrem el diàleg i retornem la resposta
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

    return resultat ?? false;
  }

  //Tanquem el diàleg sense confirmar
  void _cancelar(BuildContext context) {
    Navigator.pop(context, false);
  }

  //Tanquem el diàleg confirmant l'acció
  void _confirmar(BuildContext context) {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return AlertDialog(

      title: Text(titol),

      content: Text(missatge),

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