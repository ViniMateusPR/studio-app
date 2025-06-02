import 'package:flutter/material.dart';
import '../../controllers/aluno_controller.dart';
import '../treino/treino_screen.dart';

class HomeProfessorScreen extends StatefulWidget {
  const HomeProfessorScreen({super.key});

  @override
  State<HomeProfessorScreen> createState() => _HomeProfessorScreenState();
}

class _HomeProfessorScreenState extends State<HomeProfessorScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final alunos = AlunoController.alunosSelecionados;

    if (alunos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nenhum aluno selecionado')),
        body: const Center(child: Text('Nenhum aluno para mostrar')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(alunos[_selectedIndex].nome),
      ),
      body: TreinoScreen(aluno: alunos[_selectedIndex], treinos: [] ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: alunos.map((aluno) {
          return BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: aluno.nome,
          );
        }).toList(),
      ),
    );
  }
}
