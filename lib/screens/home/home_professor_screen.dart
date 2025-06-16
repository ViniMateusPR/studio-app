import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../aluno/lista_alunos_professor_screen.dart';
import '../treino/editar_treino_screen.dart';
import '../professor/cadastrar_exercicio_screen.dart';

class HomeProfessorScreen extends StatefulWidget {
  const HomeProfessorScreen({super.key});

  @override
  State<HomeProfessorScreen> createState() => _HomeProfessorScreenState();
}

class _HomeProfessorScreenState extends State<HomeProfessorScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _alunosComTreinos = [];
  bool _loading = true;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, bool> _checkboxStatus = {};

  @override
  void initState() {
    super.initState();
    _carregarTreinosSalvos();
    _carregarCheckboxStatus();
  }

  String capitalizarNome(String nome) {
    return nome
        .toLowerCase()
        .split(' ')
        .map((palavra) =>
    palavra.isNotEmpty ? '${palavra[0].toUpperCase()}${palavra.substring(1)}' : '')
        .join(' ');
  }

  Future<void> _carregarTreinosSalvos() async {
    final treinosSalvos = await TreinoDestaqueService.getTreinosSalvos();

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

  Future<void> _carregarCheckboxStatus() async {
    final jsonString = await _storage.read(key: 'checkbox_status');
    if (jsonString != null) {
      setState(() {
        _checkboxStatus = Map<String, bool>.from(jsonDecode(jsonString));
      });
    }
  }

  Future<void> _salvarCheckboxStatus() async {
    await _storage.write(key: 'checkbox_status', value: jsonEncode(_checkboxStatus));
  }

  void _atualizarCheckbox(String key, bool value) {
    setState(() {
      _checkboxStatus[key] = value;
    });
    _salvarCheckboxStatus();
  }

  void _limparCheckboxesAluno(String cpfAluno) {
    _checkboxStatus.removeWhere((key, value) => key.startsWith(cpfAluno));
    _salvarCheckboxStatus();
  }

  void _finalizarTreino(String cpfAluno) async {
    try {
      final aluno = _alunosComTreinos.firstWhere((a) => a['cpf'] == cpfAluno);
      final treino = aluno['treinos'].last;

      final treinoId = treino['treinoId'] ?? treino['id'] ?? treino['treino_id'];
      if (treinoId == null) {
        throw Exception('ID do treino não encontrado no JSON');
      }

      final dataHoje = DateTime.now().toIso8601String().substring(0, 10);

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

      _limparCheckboxesAluno(cpfAluno);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Treino finalizado com sucesso.")),
      );
    } catch (e) {
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
        title: Text(
          temDados ? capitalizarNome(_alunosComTreinos[_selectedIndex]['nome']) : 'Professor',
        ),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      drawer: _buildDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : !temDados
          ? const Center(child: Text('Nenhum treino salvo.', style: TextStyle(color: Colors.white70)))
          : _buildTreinosAluno(_alunosComTreinos[_selectedIndex]),
      bottomNavigationBar: temDados && _alunosComTreinos.length > 1
          ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _alunosComTreinos.take(5).map((a) {
          final nome = a['nome'].toString();
          final nomeLabel = nome.length > 10 ? '${nome.substring(0, 10)}…' : nome;
          return BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: capitalizarNome(nomeLabel),
          );
        }).toList(),
      )
          : null,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFFF6B00)),
            child: Text(
              'Menu do Professor',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text('Lista de Alunos', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ListaAlunosProfessorScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.white),
            title: const Text('Cadastrar Exercício', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CadastrarExercicioScreen()),
              );
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
    );
  }

  Widget _buildTreinosAluno(Map<String, dynamic> alunoData) {
    final treinos = alunoData['treinos'] ?? [];
    final cpf = alunoData['cpf'];
    final nome = alunoData['nome'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: treinos.map<Widget>((treino) {
          final List<dynamic> exercicios = treino['exercicios'] ?? [];

          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCabecalhoTreino(treino, cpf, nome),
                  const SizedBox(height: 8),
                  Text('Data: ${treino['data'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                  const Divider(color: Colors.orange),
                  ...exercicios.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ex = entry.value;
                    final checkboxKey = '$cpf-${treino['id'] ?? treino['treinoId']}-$idx';
                    final isChecked = _checkboxStatus[checkboxKey] ?? false;

                    return CheckboxListTile(
                      value: isChecked,
                      onChanged: (val) => _atualizarCheckbox(checkboxKey, val ?? false),
                      activeColor: Colors.orange,
                      checkColor: Colors.black,
                      title: Text(
                        '${ex['nomeExercicio']} ${ex['series']}x${ex['repeticoes']} - ${ex['carga'] ?? '0'}kg - ${ex['observacao'] ?? ''}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  _buildBotoesAcao(cpf),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCabecalhoTreino(Map<String, dynamic> treino, String cpf, String nome) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            treino['descricao'] ?? 'Sem título',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70),
          onPressed: () async {
            final id = treino['id'] ?? treino['treinoId'];
            final atualizou = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditarTreinoScreen(
                  treinoId: id,
                  alunoCpf: cpf,
                  alunoNome: nome,
                ),
              ),
            );

            if (atualizou == true) {
              await _carregarTreinosSalvos();
            }
          },
        ),
      ],
    );
  }

  Widget _buildBotoesAcao(String cpf) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _alunosComTreinos.removeWhere((a) => a['cpf'] == cpf);
              _selectedIndex = 0;
              _limparCheckboxesAluno(cpf);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Treino cancelado e removido da tela.')),
            );
          },
          icon: const Icon(Icons.cancel, color: Colors.white,),
          label: const Text("Cancelar Treino", style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _finalizarTreino(cpf),
          icon: const Icon(Icons.check, color: Colors.white,),
          label: const Text("Finalizar Treino", style: TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }
}
