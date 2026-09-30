import 'package:flutter/material.dart';

class MedicoDashboard extends StatelessWidget {
  const MedicoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SaludRural - Médico'),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, Dr.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // 3 tarjetas de resumen
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '12',
                    'Pacientes rurales',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _statCard('3', 'Hoy', Icons.video_call, Colors.green),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Acciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.video_call),
                title: Text('Teleconsultas de hoy'),
                subtitle: Text('3 pendientes por atender'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.folder_shared),
                title: Text('Pacientes asignados'),
                subtitle: Text('Ver lista completa'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.verified_user),
                title: Text('Mi RETHUS'),
                subtitle: Text('Validado - 92% confianza'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String num, String label, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              num,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
