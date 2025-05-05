import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const MetricCard(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 28, color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }
}
