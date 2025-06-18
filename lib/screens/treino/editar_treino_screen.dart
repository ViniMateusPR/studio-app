import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../../models/treino_detalhado.dart';

class EditarTreinoScreen extends StatefulWidget {
  final int treinoId;
  final int alunoId;
  final String alunoNome;

  const EditarTreinoScreen({
    super.key,
    required this.treinoId,
    required this.alunoId,
    required this.alunoNome,
  });

  @override
  State<EditarTreinoScreen> createState() => _EditarTreinoScreenState();
}

class _EditarTreinoScreenState extends State<EditarTreinoScreen> {
  late Future<TreinoDetalhado> _futureTreino;
  final _descricaoController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List<TreinoExercicioDetalhado> _exercicios = [];

  @override
  void initState() {
    super.initState();
    _futureTreino = _loadTreino();
  }

  Future<TreinoDetalhado> _loadTreino() async {
    final data = await ApiService.getTreinoDetalhado(widget.treinoId);
    final treino = TreinoDetalhado.fromJson(data);
    _descricaoController.text = treino.descricao;
    _exercicios = List.from(treino.exercicios);
    return treino;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _saveTreino() async {
    final cpfProf = await ApiService.getCpfLogado();
    final treinoJson = {
      'id': widget.treinoId,
      'descricao': _descricaoController.text.trim(),
      'data': DateTime.now().toIso8601String(),
      'alunoId': widget.alunoId,
      'personalCpf': cpfProf,
      'exercicios': _exercicios.map((e) => {
        'exercicioId': e.exercicioId,
        'ordem': e.ordem,
        'series': e.series,
        'repeticoes': e.repeticoes,
        'observacao': e.observacao,
        'carga': e.carga,
      }).toList(),
    };

    await ApiService.atualizarTreinoDetalhado(widget.treinoId, treinoJson);
    await TreinoDestaqueService.adicionarTreinoCompleto({
      'aluno': {'id': widget.alunoId, 'nome': widget.alunoNome},
      'treino': treinoJson,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino atualizado com sucesso!')),
    );
    Navigator.pop(context, true);
  }

  Future<void> _addExercicio() async {
    final todos = await ApiService.getExercicios();
    final existentes = _exercicios.map((e) => e.exercicioId).toSet();
    final disponiveis = todos.where((e) => !existentes.contains(e['id'])).toList();

    if (disponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os exercícios já foram adicionados.')),
      );
      return;
    }

    final Map<String, List<dynamic>> grupos = {};
    for (var ex in disponiveis) {
      final g = ex['grupoMuscular'] ?? 'Outros';
      grupos.putIfAbsent(g, () => []).add(ex);
    }

    showDialog<bool>(
      context: context,
      builder: (ctxDialog) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Adicionar Exercício', style: TextStyle(color: Colors.orange)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView(
            children: grupos.entries.map((entry) {
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(entry.key,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  iconColor: Colors.orange,
                  collapsedIconColor: Colors.orange,
                  children: entry.value.map((ex) {
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
                        Navigator.pop(ctxDialog, true);
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

  void _editExercicio(int idx) {
    final ex = _exercicios[idx];
    final sCtrl = TextEditingController(text: ex.series.toString());
    final rCtrl = TextEditingController(text: ex.repeticoes.toString());
    final cCtrl = TextEditingController(text: ex.carga.toString());
    final oCtrl = TextEditingController(text: ex.observacao ?? '');

    showDialog<bool>(
      context: context,
      builder: (ctxDialog) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Editar Exercício', style: TextStyle(color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numberField('Séries', sCtrl),
            const SizedBox(height: 8),
            _numberField('Repetições', rCtrl),
            const SizedBox(height: 8),
            _numberField('Carga (kg)', cCtrl, decimal: true),
            const SizedBox(height: 8),
            TextField(
              controller: oCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Observação',
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctxDialog, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              setState(() {
                _exercicios[idx] = TreinoExercicioDetalhado(
                  exercicioId: ex.exercicioId,
                  nomeExercicio: ex.nomeExercicio,
                  ordem: ex.ordem,
                  series: int.tryParse(sCtrl.text) ?? ex.series,
                  repeticoes: int.tryParse(rCtrl.text) ?? ex.repeticoes,
                  observacao: oCtrl.text,
                  carga: int.tryParse(cCtrl.text) ?? ex.carga,
                );
              });
              Navigator.pop(ctxDialog, true);
            },
            child: const Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _numberField(String label, TextEditingController ctrl, {bool decimal = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        labelStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildExercicioTile(TreinoExercicioDetalhado ex, int idx) {
    return Dismissible(
      key: ValueKey(ex.exercicioId),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text('Confirmar', style: TextStyle(color: Colors.orange)),
            content: const Text('Remover este exercício?', style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não', style: TextStyle(color: Colors.white70))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sim', style: TextStyle(color: Colors.orange))),
            ],
          ),
        );
        if (confirm == true) setState(() => _exercicios.removeAt(idx));
        return confirm == true;
      },
      child: Card(
        color: const Color(0xFF1E1E1E),
        child: ListTile(
          title: Text(ex.nomeExercicio, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            '${ex.series}x${ex.repeticoes} • ${ex.carga}kg\n${ex.observacao}',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () => _editExercicio(idx),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text('Editar Treino • ${widget.alunoNome}'),
      ),
      body: FutureBuilder<TreinoDetalhado>(
        future: _futureTreino,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snap.hasError) {
            return Center(
              child: Text('Erro: ${snap.error}', style: const TextStyle(color: Colors.white)),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _descricaoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data: ${_formatDate(snap.data!.data)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                const Divider(color: Colors.orange),
                Expanded(
                  child: _exercicios.isEmpty
                      ? const Center(child: Text('Nenhum exercício', style: TextStyle(color: Colors.white70)))
                      : ListView.builder(
                    itemCount: _exercicios.length,
                    itemBuilder: (_, i) => _buildExercicioTile(_exercicios[i], i),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Adicionar', style: TextStyle(color: Colors.white)),
                        onPressed: _addExercicio,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Salvar', style: TextStyle(color: Colors.white)),
                        onPressed: _saveTreino,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
