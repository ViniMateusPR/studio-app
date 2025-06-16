import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/treino_detalhado.dart';
import '../../services/treino_destaque_service.dart';

class EditarTreinoScreen extends StatefulWidget {
  final int treinoId;
  final String alunoCpf;
  final String alunoNome;

  const EditarTreinoScreen({
    super.key,
    required this.treinoId,
    required this.alunoCpf,
    required this.alunoNome,
  });

  @override
  State<EditarTreinoScreen> createState() => _EditarTreinoScreenState();
}

class _EditarTreinoScreenState extends State<EditarTreinoScreen> {
  late Future<TreinoDetalhado> _futureTreino;
  final TextEditingController _descricaoController = TextEditingController();
  List<TreinoExercicioDetalhado> _exercicios = [];

  @override
  void initState() {
    super.initState();
    _futureTreino = _carregarTreinoDetalhado();
  }

  Future<TreinoDetalhado> _carregarTreinoDetalhado() async {
    final data = await ApiService.getTreinoDetalhado(widget.treinoId);

    final treino = TreinoDetalhado.fromJson(data);
    _descricaoController.text = treino.descricao;

    setState(() {
      _exercicios = List.from(treino.exercicios);
    });

    return treino;
  }

  void _salvarAlteracoes() async {
    try {
      final treinoJson = {
        'id': widget.treinoId,
        'descricao': _descricaoController.text,
        'data': DateTime.now().toIso8601String(),
        'alunoCpf': widget.alunoCpf,
        'personalCpf': await ApiService.getCpfLogado(),
        'exercicios': _exercicios.map((e) => {
          'exercicioId': e.exercicioId,
          'ordem': e.ordem,
          'series': e.series,
          'repeticoes': e.repeticoes,
          'observacao': e.observacao,
          'carga': e.carga,
          'nomeExercicio': e.nomeExercicio,
        }).toList(),
      };

      await ApiService.atualizarTreinoDetalhado(widget.treinoId, treinoJson);


      await TreinoDestaqueService.adicionarTreinoCompleto({
        'aluno': {
          'cpf': widget.alunoCpf,
          'nome': widget.alunoNome,
        },
        'treino': treinoJson,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino atualizado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar treino: $e')),
      );
    }
  }


  void _abrirDialogoAdicionarExercicio() async {
    final todos = await ApiService.getExercicios();
    final idsExistentes = _exercicios.map((e) => e.exercicioId).toSet();
    final disponiveis = todos.where((e) => !idsExistentes.contains(e['id'])).toList();

    if (disponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os exercícios já foram adicionados.')),
      );
      return;
    }

    final Map<String, List<dynamic>> agrupados = {};
    for (var ex in disponiveis) {
      final grupo = ex['grupoMuscular'] ?? 'Outro';
      agrupados.putIfAbsent(grupo, () => []).add(ex);
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Adicionar Exercício',
          style: TextStyle(color: Colors.orange),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            shrinkWrap: true,
            children: agrupados.entries.map((entry) {
              final grupo = entry.key;
              final exercicios = entry.value;

              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  collapsedIconColor: Colors.orange,
                  iconColor: Colors.orange,
                  title: Text(grupo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                  children: exercicios.map((ex) {
                    return ListTile(
                      title: Text(ex['nome'], style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.add, color: Colors.orange),
                      onTap: () {
                        setState(() {
                          _exercicios.add(TreinoExercicioDetalhado(
                            exercicioId: ex['id'],
                            nomeExercicio: ex['nome'],
                            ordem: _exercicios.length + 1,
                            series: 3,
                            repeticoes: 10,
                            observacao: '',
                            carga: 0,
                          ));
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildExercicioTile(TreinoExercicioDetalhado ex, int index) {
    return ListTile(
      title: Text(ex.nomeExercicio, style: const TextStyle(color: Colors.white)),
      subtitle: Text('${ex.series}x${ex.repeticoes} - ${ex.observacao ?? ''} - Carga: ${ex.carga ?? 0}kg',
          style: const TextStyle(color: Colors.white70)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () => _editarExercicioDialog(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                _exercicios.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  void _editarExercicioDialog(int index) {
    final ex = _exercicios[index];
    final seriesCtrl = TextEditingController(text: ex.series.toString());
    final repsCtrl = TextEditingController(text: ex.repeticoes.toString());
    final obsCtrl = TextEditingController(text: ex.observacao ?? '');
    final cargaCtrl = TextEditingController(text: ex.carga?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Editar Exercício',
          style: TextStyle(color: Colors.orange),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: seriesCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Séries',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: repsCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Repetições',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cargaCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Carga (kg)',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: obsCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Observação',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              setState(() {
                _exercicios[index] = TreinoExercicioDetalhado(
                  exercicioId: ex.exercicioId,
                  nomeExercicio: ex.nomeExercicio,
                  ordem: ex.ordem,
                  series: int.tryParse(seriesCtrl.text) ?? ex.series,
                  repeticoes: int.tryParse(repsCtrl.text) ?? ex.repeticoes,
                  observacao: obsCtrl.text,
                  carga: int.tryParse(cargaCtrl.text) ?? ex.carga,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Editar Treino de ${widget.alunoNome}'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<TreinoDetalhado>(
        future: _futureTreino,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _descricaoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Exercícios', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _exercicios.length,
                      itemBuilder: (context, index) => _buildExercicioTile(_exercicios[index], index),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _abrirDialogoAdicionarExercicio,
                    icon: const Icon(Icons.add, color: Colors.white,),
                    label: const Text('Adicionar Exercício', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _salvarAlteracoes,
                    icon: const Icon(Icons.save, color: Colors.white,),
                    label: const Text('Salvar Alterações', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
