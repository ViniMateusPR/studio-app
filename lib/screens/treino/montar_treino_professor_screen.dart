// montar_treino_professor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../home/home_professor_screen.dart';

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
  bool _criandoNovo = true;
  Map<String, List<dynamic>> _exerciciosPorGrupo = {};
  List<Map<String, dynamic>> _exerciciosSelecionados = [];
  List<dynamic> _treinosAnteriores = [];
  Map<String, dynamic>? _ultimoTreino;
  final _nomeTreinoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
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
      final treinos =
      await ApiService.listarTreinosPorAluno(widget.aluno.cpf);
      Map<String, dynamic>? ultimo;
      if (widget.aluno.ultimoTreinoId != null) {
        try {
          ultimo = await ApiService.getTreinoDetalhado(
              widget.aluno.ultimoTreinoId!);
        } catch (_) {}
      }
      setState(() {
        _exerciciosPorGrupo = exercicios;
        _treinosAnteriores = treinos ?? [];
        _ultimoTreino = ultimo;
        _criandoNovo = _treinosAnteriores.isEmpty;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome do treino.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo com sucesso!')),
      );
      await _carregarDados();
      setState(() {
        _criandoNovo = false;
        _tabController.index = 0;
      });
    } catch (e) {
      debugPrint('Erro ao salvar treino: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar treino: $e')),
      );
    }
  }

  bool get _canSave =>
      _nomeTreinoController.text.trim().isNotEmpty &&
          _exerciciosSelecionados.isNotEmpty;

  String _capitalize(String s) => s
      .split(' ')
      .map((w) =>
  w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

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
        title: Text('Treino de ${_capitalize(widget.aluno.nome)}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: 'Histórico'),
            Tab(text: 'Novo'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildHistorico(),
          _buildNovoTreino(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF6B00),
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
            aluno: widget.aluno,
          ),
        const Divider(color: Colors.orange, height: 32),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Treinos Anteriores',
              style: TextStyle(color: Colors.orange, fontSize: 18)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _treinosAnteriores.length,
            itemBuilder: (_, i) {
              final t = _treinosAnteriores[i];
              return PreviousWorkoutCard(data: t, aluno: widget.aluno);
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
                  borderRadius: BorderRadius.all(Radius.circular(12))),
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
              setState(() {});
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
  const PreviousWorkoutCard({super.key, required this.data, this.aluno});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(data['data']);
    final expired = DateTime.now().difference(date).inDays > 40;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: expired ? Border.all(color: Colors.red, width: 2) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(data['descricao'] ?? '',
            style: TextStyle(
                color: expired ? Colors.red : Colors.white,
                fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${data['data'] ?? ''}',
                style: const TextStyle(color: Colors.white70)),
            if (expired)
              const Text('⚠ Treino vencido!',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: aluno == null
            ? null
            : IconButton(
          icon: const Icon(Icons.add, color: Colors.orange),
          onPressed: () async {
            try {
              final detalhes = await ApiService.getTreinoDetalhado(
                  data['treino_id'] ?? data['id']);
              await TreinoDestaqueService.adicionarTreinoCompleto({
                'aluno': {
                  'cpf': aluno!.cpf,
                  'nome': aluno!.nome,
                },
                'treino': detalhes,
              });
              // Navega direto para a HomeProfessorScreen, limpando a pilha
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
                    (route) => false,
              );
            } catch (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Erro ao buscar detalhes do treino.')),
              );
            }
          },
        ),

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
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
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
    _isSelected = widget.selectedList
        .any((e) => e['exercicioId'] == widget.data['id']);
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
            widget.onSelect({
              'exercicio': widget.data,
              'selected': sel,
              'index': idx,
            });
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
