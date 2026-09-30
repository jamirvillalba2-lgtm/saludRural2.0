import 'package:flutter/material.dart';

class MedicoValidacionPendiente extends StatelessWidget {
  const MedicoValidacionPendiente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Validación en curso',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Tu tarjeta profesional y número RETHUS están siendo verificados por el administrador de SaludRural. Te notificaremos en menos de 24 horas.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Entendido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
