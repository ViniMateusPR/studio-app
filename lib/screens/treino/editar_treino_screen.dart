// lib/screens/treino/editar_treino_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../models/treino_detalhado.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';

class EditarTreinoScreen extends StatefulWidget {
  final int treinoId;
  final int alunoId;
  final String alunoNome;

  const EditarTreinoScreen({
    Key? key,
    required this.treinoId,
    required this.alunoId,
    required this.alunoNome,
  }) : super(key: key);

  @override
  State<EditarTreinoScreen> createState() => _EditarTreinoScreenState();
}

class _EditarTreinoScreenState extends State<EditarTreinoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  late Future<TreinoDetalhado> _futureTreino;
  List<TreinoExercicioDetalhado> _exercicios = [];
  bool _saving = false;

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
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Future<void> _saveTreino() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

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

    try {
      // 1) atualiza no servidor
      await ApiService.atualizarTreinoDetalhado(widget.treinoId, treinoJson);

      // 2) refetch do objeto "detalhado", que já traz os nomeExercicio
      final detalhe = await ApiService.getTreinoDetalhado(widget.treinoId);

      // 3) salva no destaque **esse** objeto completo
      await TreinoDestaqueService.adicionarTreinoCompleto({
        'aluno': {'id': widget.alunoId, 'nome': widget.alunoNome},
        'treinos': [detalhe],
      });

      // 4) feedback e volta
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treino atualizado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar treino: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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

    final grupos = <String, List<dynamic>>{};
    for (var ex in disponiveis) {
      final g = ex['grupoMuscular'] ?? 'Outros';
      grupos.putIfAbsent(g, () => []).add(ex);
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Theme(
          data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
          child: AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: const Text('Adicionar Exercício', style: TextStyle(color: AppColors.accent)),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView(
                children: grupos.entries.map((entry) {
                  return ExpansionTile(
                    title: Text(entry.key,
                        style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                    iconColor: AppColors.accent,
                    collapsedIconColor: AppColors.accent,
                    children: entry.value.map((ex) {
                      return ListTile(
                        title: Text(ex['nome'], style: const TextStyle(color: AppColors.onSurface)),
                        trailing: Icon(Icons.add, color: AppColors.accent),
                        onTap: () {
                          setState(() {
                            _exercicios.add(
                              TreinoExercicioDetalhado(
                                exercicioId: ex['id'],
                                nomeExercicio: ex['nome'],
                                ordem: _exercicios.length + 1,
                                series: 3,
                                repeticoes: 10,
                                observacao: '',
                                carga: 0,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editExercicio(int idx) {
    final ex = _exercicios[idx];
    final sCtrl = TextEditingController(text: ex.series.toString());
    final rCtrl = TextEditingController(text: ex.repeticoes.toString());
    final cCtrl = TextEditingController(text: ex.carga.toString());
    final oCtrl = TextEditingController(text: ex.observacao);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: const Text('Editar Exercício', style: TextStyle(color: AppColors.accent)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _numberField(ctx, 'Séries', sCtrl),
                const SizedBox(height: 8),
                _numberField(ctx, 'Repetições', rCtrl),
                const SizedBox(height: 8),
                _numberField(ctx, 'Carga (kg)', cCtrl),
                const SizedBox(height: 8),
                TextField(
                  controller: oCtrl,
                  decoration: InputDecoration(
                    labelText: 'Observação',
                    filled: true,
                    fillColor: Theme.of(ctx).colorScheme.surface,
                  ),
                  style: const TextStyle(color: AppColors.onSurface),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
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
                Navigator.pop(ctx);
              },
              child: const Text('Salvar', style: TextStyle(color: AppColors.onSurface)),
            ),
          ],
        );
      },
    );
  }

  Widget _numberField(BuildContext ctx, String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(ctx).colorScheme.surface,
      ),
      style: const TextStyle(color: AppColors.onSurface),
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
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            title: const Text('Confirmar', style: TextStyle(color: AppColors.accent)),
            content: const Text('Remover este exercício?', style: TextStyle(color: AppColors.onSurface)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Não', style: TextStyle(color: AppColors.onSurfaceLight))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sim', style: TextStyle(color: AppColors.accent))),
            ],
          ),
        );
        if (ok == true) setState(() => _exercicios.removeAt(idx));
        return ok == true;
      },
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          title: Text(ex.nomeExercicio, style: const TextStyle(color: AppColors.onSurface)),
          subtitle: Text(
            '${ex.series}x${ex.repeticoes} • ${ex.carga}kg\n${ex.observacao}',
            style: const TextStyle(color: AppColors.onSurfaceLight),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: AppColors.accent),
            onPressed: () => _editExercicio(idx),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(title: Text('Editar Treino • ${widget.alunoNome}')),
      body: FutureBuilder<TreinoDetalhado>(
        future: _futureTreino,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}', style: theme.textTheme.bodyMedium));
          }
          return Stack(
            children: [
              Column(
                children: [
                  // Descrição
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(labelText: 'Descrição'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Descrição é obrigatória' : null,
                      ),
                    ),
                  ),

                  // Data
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Data: ${_formatDate(snap.data!.data)}',
                          style: theme.textTheme.titleMedium),
                    ),
                  ),
                  const Divider(color: AppColors.accent),

                  // Exercícios
                  Expanded(
                    child: _exercicios.isEmpty
                        ? Center(child: Text('Nenhum exercício', style: theme.textTheme.bodyMedium))
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _exercicios.length,
                      itemBuilder: (_, i) => _buildExercicioTile(_exercicios[i], i),
                    ),
                  ),

                  // Botões
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar'),
                            onPressed: _addExercicio,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            onPressed: _saving ? null : _saveTreino,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (_saving)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
