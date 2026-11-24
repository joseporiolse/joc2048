import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../services/app_theme.dart';

class PartidaListItem extends StatelessWidget {

  final Partida partida;

  final VoidCallback? enTocar;
  final bool esEliminable;
  final int? posicio;

  final VoidCallback? enEliminar;

  final Future<bool> Function()? confirmarEliminacio;

  const PartidaListItem({
    super.key,
    required this.partida,
    this.enTocar,
    this.esEliminable = true,
    this.posicio,
    this.enEliminar,
    this.confirmarEliminacio,
  });

  //Donem format a la data ISO de la partida
  String _formatarData(String data) {
    final DateTime? dataConvertida = DateTime.tryParse(data);

    if (dataConvertida == null) {
      return data;
    }

    final String dia =
    dataConvertida.day.toString().padLeft(2, '0');

    final String mes =
    dataConvertida.month.toString().padLeft(2, '0');

    final String any = dataConvertida.year.toString();

    return '$dia/$mes/$any';
  }

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Dismissible(

      key: ValueKey(partida.idPartida),

      direction: esEliminable && enEliminar != null && confirmarEliminacio != null
          ? DismissDirection.endToStart : DismissDirection.none,

      //Demanem confirmació abans d'eliminar
      confirmDismiss: (direccio) {
        return confirmarEliminacio?.call() ?? Future.value(false);
      },

      onDismissed: (direccio) {
        enEliminar?.call();
      },

      background: Container(
        alignment: Alignment.centerRight,

        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.espaiGran,
        ),

        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(
            AppTheme.radiVores,
          ),
        ),

        child: Icon(
          Icons.delete,
          color: colors.onError,
          size: 30,
        ),
      ),

      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: AppTheme.espaiPetit,
        ),

        child: ListTile(

          leading: CircleAvatar(
            backgroundColor: colors.primaryContainer,

            child: posicio != null ? Text('$posicio') : Icon(
              Icons.sports_esports,
              color: colors.onPrimaryContainer,
            ),
          ),

          title: Text(
            '${partida.puntuacio} punts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.midaSubtitol,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(
                height: AppTheme.espaiPetit,
              ),

              Text(
                'Fitxa màxima: ${partida.fitxaMaxima}',
              ),

              Text(
                'Moviments: ${partida.moviments}',
              ),

              Text(
                'Data: ${_formatarData(partida.data)}',
              ),
            ],
          ),

          trailing: Icon(enTocar != null ? Icons.chevron_right : Icons.emoji_events_outlined),

          onTap: enTocar,
        ),
      ),
    );
  }
}