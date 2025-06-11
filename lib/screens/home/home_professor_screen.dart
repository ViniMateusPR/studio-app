import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../aluno/lista_alunos_professor_screen.dart';

class HomeProfessorScreen extends StatefulWidget {
  const HomeProfessorScreen({super.key});

  @override
  State<HomeProfessorScreen> createState() => _HomeProfessorScreenState();
}

class _HomeProfessorScreenState extends State<HomeProfessorScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _alunosComTreinos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarTreinosSalvos();
  }

  Future<void> _carregarTreinosSalvos() async {
    final treinosSalvos = await TreinoDestaqueService.getTreinosSalvos();

    // Agrupa os treinos por aluno
    Map<String, Map<String, dynamic>> agrupado = {};
    for (var item in treinosSalvos) {
      final aluno = item['aluno'];
      final treino = item['treino'];

      if (!agrupado.containsKey(aluno['cpf'])) {
        agrupado[aluno['cpf']] = {
          'cpf': aluno['cpf'],
          'nome': aluno['nome'],
          'treinos': [treino]
        };
      } else {
        agrupado[aluno['cpf']]!['treinos'].add(treino);
      }
    }

    setState(() {
      _alunosComTreinos = agrupado.values.toList();
      _selectedIndex = 0;
      _loading = false;
    });
  }

  void _finalizarTreino(String cpfAluno) async {
    try {
      final aluno = _alunosComTreinos.firstWhere((a) => a['cpf'] == cpfAluno);
      final treino = aluno['treinos'].last;

      print('Treino recebido: $treino');

      final treinoId = treino['treinoId'] ?? treino['id'] ?? treino['treino_id'];
      if (treinoId == null) {
        throw Exception('ID do treino não encontrado no JSON');
      }

      final dataHoje = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

      await ApiService.finalizarTreino(
        treinoId: treinoId,
        alunoCpf: cpfAluno,
        dataRealizacao: dataHoje,
      );

      await TreinoDestaqueService.removerTreinoPorCpf(cpfAluno);

      setState(() {
        _alunosComTreinos.removeWhere((a) => a['cpf'] == cpfAluno);
        _selectedIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Treino finalizado com sucesso.")),
      );
    } catch (e) {
      print("Erro ao finalizar treino: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao finalizar treino: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temDados = _alunosComTreinos.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(temDados ? _alunosComTreinos[_selectedIndex]['nome'] : 'Professor'),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFF6B00)),
              child: Text('Menu do Professor', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text('Lista de Alunos', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListaAlunosProfessorScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Sair', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : !temDados
          ? const Center(
        child: Text('Nenhum treino salvo.', style: TextStyle(color: Colors.white70)),
      )
          : _buildTreinosAluno(_alunosComTreinos[_selectedIndex]),
      bottomNavigationBar: temDados && _alunosComTreinos.length > 1
          ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _alunosComTreinos
            .take(5)
            .map((a) => BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: a['nome'].toString().length > 10
              ? '${a['nome'].toString().substring(0, 10)}…'
              : a['nome'],
        ))
            .toList(),
      )
          : null,
    );
  }

  Widget _buildTreinosAluno(Map<String, dynamic> alunoData) {
    final treinos = alunoData['treinos'] ?? [];
    final cpf = alunoData['cpf'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ...treinos.map<Widget>((treino) {
            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(treino['descricao'] ?? 'Sem título',
                        style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Data: ${treino['data'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                    const Divider(color: Colors.orange),
                    ...(treino['exercicios'] as List<dynamic>).map((ex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '• ${ex['nomeExercicio']} (${ex['exercicioId']}): '
                              '${ex['series']}x${ex['repeticoes']} - ${ex['observacao'] ?? ''}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _finalizarTreino(cpf),
                        icon: const Icon(Icons.check),
                        label: const Text("Finalizar Treino"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
