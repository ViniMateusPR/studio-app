import 'package:flutter/material.dart';
import 'package:studio_app/screens/home/home_empresa_screen.dart';
import 'package:studio_app/screens/home/home_professor_screen.dart';
import 'package:studio_app/screens/treino/montar_treino_empresa_screen.dart';
import '../../services/api_service.dart';
import '../../models/aluno.dart';

class ListaAlunosScreen extends StatefulWidget {
  const ListaAlunosScreen({super.key});

  @override
  State<ListaAlunosScreen> createState() => _ListaAlunosScreenState();
}

class _ListaAlunosScreenState extends State<ListaAlunosScreen> {
  late Future<List<dynamic>> _futureAlunos;
  List<Aluno> _alunos = [];
  List<Aluno> _alunosFiltrados = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureAlunos = _carregarAlunos();
  }

  Future<List<dynamic>> _carregarAlunos() async {
    final data = await ApiService.listarAlunos();
    _alunos = data.map((e) => Aluno.fromJson(e)).toList();
    _alunosFiltrados = List.from(_alunos);
    return data;
  }

  void _filtrarAlunos(String texto) {
    setState(() {
      _alunosFiltrados = _alunos
          .where((a) => a.nome.toLowerCase().contains(texto.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Lista de Alunos"),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeEmpresaScreen()),
            );
          },
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _futureAlunos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filtrarAlunos,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar aluno...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _alunosFiltrados.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhum aluno encontrado.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _alunosFiltrados.length,
                    itemBuilder: (context, index) {
                      final aluno = _alunosFiltrados[index];
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(aluno.nome, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('Email: ${aluno.email}', style: const TextStyle(color: Colors.white70)),
                          leading: const Icon(Icons.person, color: Color(0xFFFF6B00)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MontarTreinoEmpresaScreen(aluno: aluno),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
