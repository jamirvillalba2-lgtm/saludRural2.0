import 'package:flutter_test/flutter_test.dart';
import 'package:salud_rural/main.dart';

void main() {
  testWidgets('App carga correctamente', (WidgetTester tester) async {
    // Construye nuestra app en el entorno de pruebas
    await tester.pumpWidget(const SaludRuralApp());

    // Valida que la aplicación principal exista y se renderice sin errores
    expect(find.byType(SaludRuralApp), findsOneWidget);
  });
}
