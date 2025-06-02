import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../controllers/aluno_controller.dart';
import '../home/home_professor_screen.dart';

class AlunoDetalhesScreen extends StatelessWidget {
  final Aluno aluno;

  const AlunoDetalhesScreen({super.key, required this.aluno});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(aluno.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              AlunoController.adicionarAluno(aluno);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeProfessorScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: const Center(child: Text('Detalhes do aluno')),
    );
  }
}
