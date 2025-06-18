import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MontarTreinoScreen extends StatefulWidget {
  final Aluno aluno;

  const MontarTreinoScreen({super.key, required this.aluno});

  @override
  State<MontarTreinoScreen> createState() => _MontarTreinoScreenState();
}

class _MontarTreinoScreenState extends State<MontarTreinoScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, List<dynamic>> _exerciciosPorGrupo = {};
  List<Map<String, dynamic>> _exerciciosSelecionados = [];
  List<dynamic> _treinosAnteriores = [];
  bool _loading = true;
  bool _criandoNovo = false;
  final TextEditingController _nomeTreinoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final exercicios = await ApiService.getExerciciosAgrupados();
      final treinos = await ApiService.listarTreinosPorAluno(widget.aluno.id);
      setState(() {
        _exerciciosPorGrupo = exercicios;
        _treinosAnteriores = treinos ?? [];
        _loading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _loading = false);
    }
  }

  void _salvarTreino() async {
    try {
      final cpfProfessor = await _storage.read(key: 'cpf');
      final nomeTreino = _nomeTreinoController.text.trim();

      if (nomeTreino.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Digite o nome do treino.')),
        );
        return;
      }

      final treino = {
        'descricao': nomeTreino,
        'alunoCpf': widget.aluno.id,
        'personalCpf': cpfProfessor,
        'data': DateTime.now().toIso8601String(),
        'exercicios': _exerciciosSelecionados
      };

      await ApiService.salvarTreinoDetalhado(treino);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao salvar treino: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar treino: $e')),
      );
    }
  }

  Widget _buildCamposExtras(Map<String, dynamic> exercicio) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Ordem', filled: true),
          keyboardType: TextInputType.number,
          onChanged: (val) => exercicio['ordem'] = int.tryParse(val),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Séries', filled: true),
          keyboardType: TextInputType.number,
          onChanged: (val) => exercicio['series'] = int.tryParse(val),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Repetições', filled: true),
          keyboardType: TextInputType.number,
          onChanged: (val) => exercicio['repeticoes'] = int.tryParse(val),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Observação', filled: true),
          onChanged: (val) => exercicio['observacao'] = val,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFormularioNovoTreino() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _nomeTreinoController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nome do Treino',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ..._exerciciosPorGrupo.entries.map((entry) {
          final grupo = entry.key;
          final exercicios = entry.value;

          return ExpansionTile(
            title: Text(grupo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            iconColor: Colors.orange,
            collapsedIconColor: Colors.orange,
            children: exercicios.map((exercicio) {
              final id = exercicio['id'];
              final nome = exercicio['nome'];
              final index = _exerciciosSelecionados.indexWhere((e) => e['exercicioId'] == id);
              final selecionado = index != -1;

              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(nome, style: const TextStyle(color: Colors.white)),
                    value: selecionado,
                    activeColor: Colors.orange,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _exerciciosSelecionados.add({
                            'exercicioId': id,
                            'ordem': 1,
                            'series': 3,
                            'repeticoes': 10,
                            'observacao': ''
                          });
                        } else {
                          _exerciciosSelecionados.removeWhere((e) => e['exercicioId'] == id);
                        }
                      });
                    },
                  ),
                  if (selecionado)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildCamposExtras(_exerciciosSelecionados[index]),
                    ),
                ],
              );
            }).toList(),
          );
        }).toList(),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  void dispose() {
    _nomeTreinoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Treino de ${widget.aluno.nome}'),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : !_criandoNovo
          ? (_treinosAnteriores.isNotEmpty
          ? Column(
        children: [
          const SizedBox(height: 16),
          ..._treinosAnteriores.map((t) => ListTile(
            title: Text(t['descricao'], style: const TextStyle(color: Colors.white)),
            subtitle: Text(t['data'], style: const TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: const Icon(Icons.add, color: Colors.orange),
              onPressed: () async {
                final treinoId = t['treino_id'] ?? t['id']; // depende de como o backend retorna
                try {
                  final detalhes = await ApiService.getTreinoDetalhado(treinoId);
                  print('Treino detalhado (ID: $treinoId): $detalhes');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Treino detalhado impresso no console.')),
                  );
                } catch (e) {
                  print('Erro ao buscar treino detalhado: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao buscar detalhes do treino.')),
                  );
                }
              },
            ),

          )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _criandoNovo = true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Criar novo treino'),
          )
        ],
      )
          : ListView(children: [_buildFormularioNovoTreino()]))
          : ListView(children: [_buildFormularioNovoTreino()]),
      floatingActionButton: _criandoNovo
          ? FloatingActionButton.extended(
        onPressed: _salvarTreino,
        backgroundColor: const Color(0xFFFF6B00),
        label: const Text("Salvar Treino"),
        icon: const Icon(Icons.save),
      )
          : null,
    );
  }

}
