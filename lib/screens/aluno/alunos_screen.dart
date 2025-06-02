import 'package:flutter/material.dart';
import '../../models/aluno.dart';

class AlunosScreen extends StatelessWidget {
  final void Function(Aluno) onAlunoSelecionado;

  AlunosScreen({super.key, required this.onAlunoSelecionado});

  final List<Aluno> alunos = [
    Aluno(id: 1, nome: "João", treinos: []),
    Aluno(id: 2, nome: "Maria", treinos: []),
    Aluno(id: 3, nome: "Pedro", treinos: []),
    Aluno(id: 4, nome: "Ana", treinos: []),
    Aluno(id: 5, nome: "Lucas", treinos: []),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecionar Aluno")),
      body: ListView.builder(
        itemCount: alunos.length,
        itemBuilder: (context, index) {
          final aluno = alunos[index];
          return ListTile(
            title: Text(aluno.nome),
            trailing: const Icon(Icons.add),
            onTap: () => onAlunoSelecionado(aluno),
          );
        },
      ),
    );
  }
}
