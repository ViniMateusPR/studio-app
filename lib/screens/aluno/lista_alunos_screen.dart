import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ListaAlunosScreen extends StatefulWidget {
  const ListaAlunosScreen({super.key});

  @override
  State<ListaAlunosScreen> createState() => _ListaAlunosScreenState();
}

class _ListaAlunosScreenState extends State<ListaAlunosScreen> {
  late Future<List<dynamic>> _futureAlunos;

  @override
  void initState() {
    super.initState();
    _futureAlunos = ApiService.listarAlunos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Alunos"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureAlunos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum aluno encontrado.'));
          }

          final alunos = snapshot.data!;

          return ListView.builder(
            itemCount: alunos.length,
            itemBuilder: (context, index) {
              final aluno = alunos[index];
              return ListTile(
                title: Text(aluno['nome'] ?? 'Sem nome'),
                subtitle: Text('Email: ${aluno['email'] ?? "Sem email"}'),
                // Adapte para os campos que seu objeto Aluno tiver
              );
            },
          );
        },
      ),
    );
  }
}
