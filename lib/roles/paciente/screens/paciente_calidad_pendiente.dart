import 'package:flutter/material.dart';

class PacienteValidacionPendiente extends StatelessWidget {
  const PacienteValidacionPendiente({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending, size: 80, color: Colors.orange),
            Text('Tu cédula está en revisión manual'),
            Text('Confianza < 85% - Admin te validará pronto'),
          ],
        ),
      ),
    );
  }
}
