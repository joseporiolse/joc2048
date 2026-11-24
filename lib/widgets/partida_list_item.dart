import 'package:flutter/material.dart';
import '../models/partida.dart';
import '../services/app_theme.dart';

class PartidaListItem extends StatelessWidget {

  // Partida que volem mostrar
  final Partida partida;

  // Acció quan l'usuari toca la partida
  final VoidCallback? enTocar;
  final bool esEliminable;
  final int? posicio;

  // Acció quan l'usuari elimina la partida
  final VoidCallback? enEliminar;

  // Funció que confirma si podem eliminar la partida
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

  // Donem format a la data ISO de la partida
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

    // Obtenim els colors del tema actual
    final colors = Theme.of(context).colorScheme;

    return Dismissible(

      // Cada partida té un identificador únic
      key: ValueKey(partida.idPartida),

      // Només permetem lliscar cap a l'esquerra
      direction: esEliminable && enEliminar != null && confirmarEliminacio != null
          ? DismissDirection.endToStart : DismissDirection.none,

      // Demanem confirmació abans d'eliminar
      confirmDismiss: (direccio) {
        return confirmarEliminacio?.call() ?? Future.value(false);
      },

      // Avisem la pantalla quan s'ha confirmat
      onDismissed: (direccio) {
        enEliminar?.call();
      },

      // Fons vermell que apareix en lliscar
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

          // Icona de la partida
          leading: CircleAvatar(
            backgroundColor: colors.primaryContainer,

            child: posicio != null ? Text('$posicio') : Icon(
              Icons.sports_esports,
              color: colors.onPrimaryContainer,
            ),
          ),

          // Puntuació principal
          title: Text(
            '${partida.puntuacio} punts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.midaSubtitol,
            ),
          ),

          // Informació complementària
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

          // Icona per indicar que podem veure el detall
          trailing: Icon(enTocar != null ? Icons.chevron_right : Icons.emoji_events_outlined),

          // Obrim el detall quan es toca la partida
          onTap: enTocar,
        ),
      ),
    );
  }
}