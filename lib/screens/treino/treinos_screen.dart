import 'package:flutter/material.dart';
import '../../models/aluno.dart';

class TreinosScreen extends StatelessWidget {
  final Aluno aluno;

  const TreinosScreen({super.key, required this.aluno});

  @override
  Widget build(BuildContext context) {
    final treinos = [
      'Treino A: Peito e Tríceps',
      'Treino B: Costas e Bíceps',
      'Treino C: Pernas e Ombros',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Treinos de ${aluno.nome}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...treinos.map((t) => ListTile(title: Text(t))),
      ],
    );
  }
}
