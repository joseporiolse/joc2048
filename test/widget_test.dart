
import 'package:flutter_test/flutter_test.dart';

import 'package:joc_2048/main.dart';

void main() {

  // Comprovem que la pantalla inicial es mostra
  testWidgets(
    'La pantalla inicial del joc 2048 funciona',
        (WidgetTester tester) async {

      // Carreguem l'aplicació
      await tester.pumpWidget(
        const Joc2048App(),
      );

      // Comprovem que apareix el títol
      expect(
        find.text('2048'),
        findsOneWidget,
      );

      // Comprovem el botó d'iniciar sessió
      expect(
        find.text('Iniciar sessió'),
        findsOneWidget,
      );

      // Comprovem el botó de registre
      expect(
        find.text('Crear compte'),
        findsOneWidget,
      );
    },
  );
}
