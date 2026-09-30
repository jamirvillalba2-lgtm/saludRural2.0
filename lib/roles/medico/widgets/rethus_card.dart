import 'package:flutter/material.dart';

class RethusCard extends StatelessWidget {
  final double confianza;
  final String nombreExtraido;
  final String rethusExtraido;
  const RethusCard({
    super.key,
    required this.confianza,
    required this.nombreExtraido,
    required this.rethusExtraido,
  });

  @override
  Widget build(BuildContext context) {
    Color color = confianza > 0.85
        ? Colors.green
        : confianza > 0.6
        ? Colors.orange
        : Colors.red;
    return Card(
      child: ListTile(
        leading: Icon(Icons.verified, color: color),
        title: Text('Confianza OCR: ${(confianza * 100).toStringAsFixed(0)}%'),
        subtitle: Text('$nombreExtraido - $rethusExtraido'),
      ),
    );
  }
}
