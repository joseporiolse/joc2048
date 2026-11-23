import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../services/joc_service.dart';
import 'tile_widget.dart';

class BoardWidget extends StatefulWidget {

  // Llista de les 16 caselles del tauler
  final List<int> tauler;

  // Color personalitzat de les fitxes
  final Color colorPersonalitzat;

  // Funció que s'executa quan movem les fitxes
  final ValueChanged<Direccio> enMoure;

  // Funció opcional per a la pulsació llarga
  final VoidCallback? enPulsacioLlarga;

  const BoardWidget({
    super.key,
    required this.tauler,
    required this.colorPersonalitzat,
    required this.enMoure,
    this.enPulsacioLlarga,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {

  // Guardem el desplaçament del dit
  Offset _desplacament = Offset.zero;

  // Distància mínima per reconèixer un moviment
  static const double distanciaMinima = 30;

  // Detectem quan comença el moviment
  void _iniciarGest(DragStartDetails detalls) {
    _desplacament = Offset.zero;
  }

  // Acumulem el desplaçament del dit
  void _actualitzarGest(DragUpdateDetails detalls) {
    _desplacament += detalls.delta;
  }

  // Detectem la direcció del moviment
  void _finalitzarGest(DragEndDetails detalls) {

    // Si el moviment és massa petit, no fem res
    if (_desplacament.distance < distanciaMinima) {
      _desplacament = Offset.zero;
      return;
    }

    // Comprovem si el moviment és horitzontal
    if (_desplacament.dx.abs() > _desplacament.dy.abs()) {

      if (_desplacament.dx > 0) {
        widget.enMoure(Direccio.dreta);
      } else {
        widget.enMoure(Direccio.esquerra);
      }

    } else {

      // Moviment vertical
      if (_desplacament.dy > 0) {
        widget.enMoure(Direccio.avall);
      } else {
        widget.enMoure(Direccio.amunt);
      }
    }

    // Reiniciem el desplaçament
    _desplacament = Offset.zero;
  }

  // Reiniciem el gest si es cancel·la
  void _cancelarGest() {
    _desplacament = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {

    // Comprovem si el tema és fosc
    final bool esFosc =
        Theme.of(context).brightness == Brightness.dark;

    // Color de fons del tauler
    final Color colorTauler = esFosc
        ? const Color(0xFF303030)
        : const Color(0xFFBBADA0);

    return GestureDetector(

      // Detectem els gestos del jugador
      onPanStart: _iniciarGest,
      onPanUpdate: _actualitzarGest,
      onPanEnd: _finalitzarGest,
      onPanCancel: _cancelarGest,

      // Detectem una pulsació llarga
      onLongPress: widget.enPulsacioLlarga,

      child: AspectRatio(
        aspectRatio: 1,

        child: Container(
          padding: const EdgeInsets.all(AppTheme.espaiPetit),

          decoration: BoxDecoration(
            color: colorTauler,
            borderRadius: BorderRadius.circular(
              AppTheme.radiVores,
            ),
          ),

          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),

            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppTheme.espaiPetit,
              mainAxisSpacing: AppTheme.espaiPetit,
            ),

            itemCount: 16,

            itemBuilder: (context, index) {
              return TileWidget(
                valor: widget.tauler[index],
                colorPersonalitzat: widget.colorPersonalitzat,
              );
            },
          ),
        ),
      ),
    );
  }
}
