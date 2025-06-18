import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../home/home_professor_screen.dart';
import '../treino/editar_treino_screen.dart';

class MontarTreinoProfessorScreen extends StatefulWidget {
  final Aluno aluno;
  const MontarTreinoProfessorScreen({super.key, required this.aluno});

  @override
  State<MontarTreinoProfessorScreen> createState() =>
      _MontarTreinoProfessorScreenState();
}

class _MontarTreinoProfessorScreenState
    extends State<MontarTreinoProfessorScreen>
    with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();
  late TabController _tabController;

  bool _loading = true;
  Map<String, List<dynamic>> _exerciciosPorGrupo = {};
  List<Map<String, dynamic>> _exerciciosSelecionados = [];
  List<dynamic> _treinosAnteriores = [];
  Map<String, dynamic>? _ultimoTreino;
  final TextEditingController _nomeTreinoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeTreinoController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _loading = true);
    try {
      final exercicios = await ApiService.getExerciciosAgrupados();
      final treinos = await ApiService.listarTreinosPorAluno(widget.aluno.cpf);
      Map<String, dynamic>? ultimo;
      if (widget.aluno.ultimoTreinoId != null) {
        try {
          ultimo = await ApiService.getTreinoDetalhado(
            widget.aluno.ultimoTreinoId!,
          );
        } catch (_) {}
      }
      setState(() {
        _exerciciosPorGrupo = exercicios;
        _treinosAnteriores = treinos ?? [];
        _ultimoTreino = ultimo;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _salvarTreino() async {
    final nomeTreino = _nomeTreinoController.text.trim();
    if (nomeTreino.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Digite o nome do treino.')));
      return;
    }
    try {
      final cpfProf = await _storage.read(key: 'cpf');
      final body = {
        'descricao': nomeTreino,
        'alunoCpf': widget.aluno.cpf,
        'personalCpf': cpfProf,
        'data': DateTime.now().toIso8601String(),
        'exercicios': _exerciciosSelecionados,
      };
      await ApiService.salvarTreinoDetalhado(body);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Treino salvo com sucesso!')));
      await _carregarDados();
      _tabController.index = 0;
    } catch (e) {
      debugPrint('Erro ao salvar treino: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao salvar treino: $e')));
    }
  }

  bool get _canSave =>
      _nomeTreinoController.text.trim().isNotEmpty &&
          _exerciciosSelecionados.isNotEmpty;

  Future<bool> _confirmExcluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Excluir treino?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja realmente excluir este treino?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não', style: TextStyle(color: Colors.orange)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text('Treino de ${widget.aluno.nome.split(' ').first}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: const [Tab(text: 'Histórico'), Tab(text: 'Novo')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : TabBarView(
        controller: _tabController,
        children: [_buildHistorico(), _buildNovoTreino()],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
        backgroundColor: _canSave ? const Color(0xFFFF6B00) : Colors.grey,
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text(
          'Salvar (${_exerciciosSelecionados.length})',
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: _canSave ? _salvarTreino : null,
      )
          : null,
    );
  }

  Widget _buildHistorico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Último Treino',
              style: TextStyle(color: Colors.orange, fontSize: 18)),
        ),
        if (_ultimoTreino != null)
          PreviousWorkoutCard(
            data: _ultimoTreino!,
            aluno: null,
            mostrarAlteradoPor: false,
          ),
        const Divider(color: Colors.orange, height: 32),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Lista de Treinos',
              style: TextStyle(color: Colors.orange, fontSize: 18)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _treinosAnteriores.length,
            itemBuilder: (_, i) {
              final treino = _treinosAnteriores[i] as Map<String, dynamic>;
              return Dismissible(
                key: ValueKey(treino['id'] ?? treino['treino_id']),
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white)),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmExcluir(),
                onDismissed: (_) async {
                  final rawId = treino['treino_id'] ?? treino['id'];
                  final id = rawId is int ? rawId : int.tryParse(rawId.toString());
                  if (id != null) await ApiService.excluirTreino(id);
                  setState(() => _treinosAnteriores.removeAt(i));
                },
                child: PreviousWorkoutCard(
                  data: treino,
                  aluno: widget.aluno,
                  mostrarAlteradoPor: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () async {
                          final id = treino['id'] ?? treino['treino_id'];
                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarTreinoScreen(
                                treinoId: id,
                                alunoCpf: widget.aluno.cpf,
                                alunoNome: widget.aluno.nome,
                              ),
                            ),
                          );
                          if (ok == true) _carregarDados();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.orange),
                        onPressed: () async {
                          final detalhes = await ApiService.getTreinoDetalhado(
                              treino['treino_id'] ?? treino['id']);
                          await TreinoDestaqueService.adicionarTreinoCompleto({
                            'aluno': {
                              'cpf': widget.aluno.cpf,
                              'nome': widget.aluno.nome,
                            },
                            'treino': detalhes,
                          });
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
                                (r) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNovoTreino() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _nomeTreinoController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nome do Treino',
              labelStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
        ..._exerciciosPorGrupo.entries.map((e) {
          return ExerciseGroupTile(
            groupName: e.key,
            exercises: e.value,
            selected: _exerciciosSelecionados,
            onSelect: (info) {
              final ex = info['exercicio'] as Map<String, dynamic>;
              final sel = info['selected'] as bool;
              setState(() {
                if (sel) {
                  _exerciciosSelecionados.add({
                    'exercicioId': ex['id'],
                    'ordem': 1,
                    'series': 3,
                    'repeticoes': 10,
                    'carga': 0,
                    'observacao': ''
                  });
                } else {
                  _exerciciosSelecionados
                      .removeWhere((x) => x['exercicioId'] == ex['id']);
                }
              });
            },
          );
        }).toList(),
      ],
    );
  }
}

// ───── Widgets Auxiliares ─────

class PreviousWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Aluno? aluno;
  final Widget? trailing;
  final bool mostrarAlteradoPor;

  const PreviousWorkoutCard({
    super.key,
    required this.data,
    this.aluno,
    this.trailing,
    this.mostrarAlteradoPor = false,
  });

  @override
  Widget build(BuildContext context) {
    final raw = data['data'] ?? '';
    DateTime? dt;
    try {
      dt = DateTime.parse(raw);
    } catch (_) {}
    final formatted = dt != null ? DateFormat('dd/MM/yyyy').format(dt) : raw;
    final expired = dt != null && DateTime.now().difference(dt).inDays > 40;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: expired ? Border.all(color: Colors.red, width: 2) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          data['descricao'] ?? '',
          style: TextStyle(
            color: expired ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: $formatted',
              style: const TextStyle(color: Colors.white70),
            ),
            if (mostrarAlteradoPor && data['alteradoPorNome'] != null)
              Text(
                'Alterado por: ${data['alteradoPorNome']}',
                style: const TextStyle(color: Colors.white70),
              ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}

class ExerciseGroupTile extends StatelessWidget {
  final String groupName;
  final List<dynamic> exercises;
  final List<Map<String, dynamic>> selected;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const ExerciseGroupTile({
    super.key,
    required this.groupName,
    required this.exercises,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(groupName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconColor: Colors.orange,
        collapsedIconColor: Colors.orange,
        children: exercises
            .map((ex) => ExerciseItem(
          data: ex,
          selectedList: selected,
          onSelect: onSelect,
        ))
            .toList(),
      ),
    );
  }
}

class ExerciseItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<Map<String, dynamic>> selectedList;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const ExerciseItem({
    super.key,
    required this.data,
    required this.selectedList,
    required this.onSelect,
  });

  @override
  State<ExerciseItem> createState() => _ExerciseItemState();
}

class _ExerciseItemState extends State<ExerciseItem> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected =
        widget.selectedList.any((e) => e['exercicioId'] == widget.data['id']);
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.selectedList
        .indexWhere((e) => e['exercicioId'] == widget.data['id']);
    return Column(
      children: [
        CheckboxListTile(
          title: Text(widget.data['nome'],
              style: const TextStyle(color: Colors.white)),
          value: _isSelected,
          activeColor: Colors.orange,
          checkColor: Colors.black,
          onChanged: (sel) {
            setState(() => _isSelected = sel!);
            widget.onSelect({'exercicio': widget.data, 'selected': sel, 'index': idx});
          },
        ),
        if (_isSelected)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExerciseFields(model: widget.selectedList[idx]),
          ),
      ],
    );
  }
}

class ExerciseFields extends StatelessWidget {
  final Map<String, dynamic> model;
  const ExerciseFields({super.key, required this.model});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 8),
      NumberField(label: 'Ordem', model: model, keyName: 'ordem'),
      const SizedBox(height: 8),
      NumberField(label: 'Séries', model: model, keyName: 'series'),
      const SizedBox(height: 8),
      NumberField(label: 'Repetições', model: model, keyName: 'repeticoes'),
      const SizedBox(height: 8),
      NumberField(label: 'Carga (kg)', model: model, keyName: 'carga'),
      const SizedBox(height: 8),
      TextField(
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: 'Observação',
          labelStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Color(0xFF2C2C2C),
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => model['observacao'] = v,
      ),
      const SizedBox(height: 10),
    ],
  );
}

class NumberField extends StatelessWidget {
  final String label;
  final Map<String, dynamic> model;
  final String keyName;
  const NumberField({
    super.key,
    required this.label,
    required this.model,
    required this.keyName,
  });

  @override
  Widget build(BuildContext context) => TextField(
    keyboardType: TextInputType.number,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: const OutlineInputBorder(),
    ),
    onChanged: (v) => model[keyName] = int.tryParse(v) ?? model[keyName],
  );
}
