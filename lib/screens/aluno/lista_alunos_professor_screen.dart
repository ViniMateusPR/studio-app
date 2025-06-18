import 'package:flutter/material.dart';
import 'package:studio_app/screens/treino/montar_treino_professor_screen.dart';
import '../../services/api_service.dart';
import '../../models/aluno.dart';
import '../home/home_professor_screen.dart';

class ListaAlunosProfessorScreen extends StatefulWidget {
  const ListaAlunosProfessorScreen({super.key});

  @override
  State<ListaAlunosProfessorScreen> createState() => _ListaAlunosProfessorScreenState();
}

class _ListaAlunosProfessorScreenState extends State<ListaAlunosProfessorScreen> {
  late Future<List<dynamic>> _futureAlunos;
  List<Aluno> _alunos = [];
  List<Aluno> _alunosFiltrados = [];
  final TextEditingController _searchController = TextEditingController();
  bool _mostrarAtivos = true;

  @override
  void initState() {
    super.initState();
    _futureAlunos = _carregarAlunos();
  }

  Future<List<dynamic>> _carregarAlunos() async {
    final data = await ApiService.listarAlunos();
    _alunos = data.map((e) => Aluno.fromJson(e)).toList();
    _filtrarAlunos(_searchController.text);
    return data;
  }

  void _filtrarAlunos(String texto) {
    setState(() {
      _alunosFiltrados = _alunos.where((a) {
        final correspondeBusca = a.nome.toLowerCase().contains(texto.toLowerCase());
        final correspondeStatus = !_mostrarAtivos || a.ativo == true;
        return correspondeBusca && correspondeStatus;
      }).toList();
    });
  }

  String capitalizarNome(String nome) {
    return nome
        .toLowerCase()
        .split(' ')
        .map((palavra) => palavra.isNotEmpty ? '${palavra[0].toUpperCase()}${palavra.substring(1)}' : '')
        .join(' ');
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
              MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
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
                  child: Row(
                    children: [
                      Expanded(
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
                      const SizedBox(width: 10),
                      FilterChip(
                        label: const Text("Ativos", style: TextStyle(color: Colors.white)),
                        selected: _mostrarAtivos,
                        onSelected: (val) {
                          setState(() {
                            _mostrarAtivos = val;
                            _filtrarAlunos(_searchController.text);
                          });
                        },
                        selectedColor: Colors.orange,
                        backgroundColor: const Color(0xFF1E1E1E),
                      )
                    ],
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
                          title: Text(
                            capitalizarNome(aluno.nome),
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Email: ${aluno.email}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          leading: const Icon(Icons.person, color: Color(0xFFFF6B00)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MontarTreinoProfessorScreen(aluno: aluno),
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
