import 'package:flutter_test/flutter_test.dart';
import 'package:salud_rural/main.dart';

void main() {
  testWidgets('App carga RoleSelector', (WidgetTester tester) async {
    await tester.pumpWidget(const SaludRuralApp());

    // Verifica que cargue la pantalla de selección de roles
    expect(find.text('ConectaSaludRural'), findsOneWidget);
    expect(find.text('Soy Paciente Rural - MÓVIL'), findsOneWidget);
    expect(find.text('Soy Médico - RETHUS'), findsOneWidget);
    expect(find.text('Soy Administrador - WEB'), findsOneWidget);
  });
}
