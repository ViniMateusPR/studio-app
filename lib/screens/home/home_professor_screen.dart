import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
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
  final _storage = const FlutterSecureStorage();
  late PageController _pageController;
  bool _loading = true;
  int _selectedIndex = 0;
  String nomeProfessor = '';
  List<Map<String, dynamic>> _alunosComTreinos = [];
  Map<String, bool> _checkboxStatus = {};

  static const double _itemWidth = 100;
  static const double _spacing = 24;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadAll();
    _loadNomeProfessor();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNomeProfessor() async {
    final nome = await _storage.read(key: 'nome');
    setState(() {
      nomeProfessor = nome ?? '';
    });
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final jsonString = await _storage.read(key: 'checkbox_status');
    if (jsonString != null) {
      _checkboxStatus = Map<String, bool>.from(jsonDecode(jsonString));
    }

    final salvos = await TreinoDestaqueService.getTreinosSalvos();
    final grouped = <String, Map<String, dynamic>>{};
    for (var item in salvos) {
      final aluno = item['aluno'] as Map<String, dynamic>;
      grouped.putIfAbsent(aluno['cpf'], () => {
        'cpf': aluno['cpf'],
        'nome': aluno['nome'],
        'treinos': <dynamic>[],
      });
      grouped[aluno['cpf']]!['treinos'].add(item['treino']);
    }
    setState(() {
      _alunosComTreinos = grouped.values.toList();
      _selectedIndex = 0;
      _loading = false;
    });
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  Future<void> _saveCheckbox() => _storage.write(
      key: 'checkbox_status', value: jsonEncode(_checkboxStatus));

  void _toggleCheckbox(String key, bool val) {
    setState(() => _checkboxStatus[key] = val);
    _saveCheckbox();
  }

  Future<bool> _handleDismiss(
      BuildContext ctx, String cpf, bool isFinish) async {
    final action = isFinish ? 'finalizar' : 'cancelar';
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          isFinish ? 'Finalizar Treino' : 'Cancelar Treino',
          style: const TextStyle(color: Colors.orange),
        ),
        content: Text(
          'Deseja realmente $action este treino?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: const Text('Não', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: const Text('Sim', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    if (isFinish) {
      final alunoItem = _alunosComTreinos.firstWhere((a) => a['cpf'] == cpf);
      final treino = alunoItem['treinos'].last as Map<String, dynamic>;
      final raw = treino['treinoId'] ?? treino['id'] ?? treino['treino_id'];
      final int? id = raw is int ? raw : int.tryParse(raw.toString());
      if (id != null) {
        final hoje = DateTime.now().toIso8601String().substring(0, 10);
        await ApiService.finalizarTreino(
          treinoId: id,
          alunoCpf: cpf,
          dataRealizacao: hoje,
        );
      }
    }

    await TreinoDestaqueService.removerTreinoPorCpf(cpf);
    setState(() {
      _alunosComTreinos.removeWhere((a) => a['cpf'] == cpf);
      _selectedIndex = _alunosComTreinos.isEmpty
          ? 0
          : _selectedIndex.clamp(0, _alunosComTreinos.length - 1);
      _pageController.jumpToPage(_selectedIndex);
    });

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          isFinish
              ? 'Treino finalizado e removido.'
              : 'Treino cancelado e removido.',
        ),
      ),
    );
    return false;
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final hasData = !_loading && _alunosComTreinos.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: _buildDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : hasData
          ? PageView.builder(
        controller: _pageController,
        itemCount: _alunosComTreinos.length,
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        itemBuilder: (_, i) => _buildTreinosAluno(_alunosComTreinos[i]),
      )
          : Center(
        child: Text(
          'Bem-vindo, $nomeProfessor 👋',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white70, fontSize: 18),
        ),
      ),
      bottomNavigationBar:
      hasData ? _buildBottomNav() : const SizedBox.shrink(),
    );
  }

  Widget _buildDrawer() => Drawer(
    backgroundColor: const Color(0xFF1E1E1E),
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Color(0xFFFF6B00)),
          child: Text('Menu do Professor',
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
        ListTile(
          leading: const Icon(Icons.people, color: Colors.white),
          title: const Text('Lista de Alunos',
              style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const ListaAlunosProfessorScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.fitness_center, color: Colors.white),
          title: const Text('Cadastrar Exercício',
              style: TextStyle(color: Colors.white)),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const CadastrarExercicioScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Sair', style: TextStyle(color: Colors.white)),
          onTap: _logout,
        ),
      ],
    ),
  );

  Widget _buildBottomNav() => LayoutBuilder(builder: (context, bc) {
    final totalWidth = _alunosComTreinos.length * _itemWidth +
        (_alunosComTreinos.length - 1) * _spacing;
    final align = totalWidth < bc.maxWidth
        ? WrapAlignment.center
        : WrapAlignment.start;

    return Container(
      color: const Color(0xFF1E1E1E),
      height: 60,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: bc.maxWidth),
          child: Wrap(
            alignment: align,
            spacing: _spacing,
            children: List.generate(_alunosComTreinos.length, (i) {
              final aluno = _alunosComTreinos[i];
              final isSel = i == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  _pageController.jumpToPage(i);
                },
                child: SizedBox(
                  width: _itemWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 3,
                        width: 60,
                        color:
                        isSel ? Colors.orange : Colors.transparent,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        aluno['nome'].toString().split(' ').first,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSel
                              ? Colors.white
                              : Colors.white54,
                          fontWeight: isSel
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  });

  Widget _buildTreinosAluno(Map<String, dynamic> alunoData) {
    final cpf = alunoData['cpf'] as String;
    final treinos = alunoData['treinos'] as List<dynamic>;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: treinos.length,
      itemBuilder: (_, idx) {
        final treino = treinos[idx] as Map<String, dynamic>;
        final exs = treino['exercicios'] as List<dynamic>;
        final total = exs.length;
        final done = exs
            .asMap()
            .entries
            .where((e) {
          final key =
              '$cpf-${treino['id'] ?? treino['treinoId']}-${e.key}';
          return _checkboxStatus[key] == true;
        })
            .length;
        final prog = total > 0 ? done / total : 0.0;

        return Dismissible(
          key: ValueKey('$cpf-${treino['id'] ?? treino['treinoId']}-$idx'),
          background: Container(
            alignment: Alignment.centerLeft,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.check, color: Colors.white),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.cancel, color: Colors.white),
          ),
          confirmDismiss: (direction) {
            final isFinish = direction == DismissDirection.startToEnd;
            return _handleDismiss(context, cpf, isFinish);
          },
          onDismissed: (_) {},
          child: Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarTreinoScreen(
                                treinoId: id,
                                alunoCpf: cpf,
                                alunoNome: alunoData['nome'],
                              ),
                            ),
                          );
                          if (ok == true) _loadAll();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: prog,
                    color: Colors.orange,
                    backgroundColor: const Color(0xFF2C2C2C),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data: ${_formatDate(treino['data'] ?? '')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Divider(color: Colors.orange),
                  ...exs.asMap().entries.map((e) {
                    final ex = e.value as Map<String, dynamic>;
                    final key =
                        '$cpf-${treino['id'] ?? treino['treinoId']}-${e.key}';
                    final ck = _checkboxStatus[key] ?? false;
                    return CheckboxListTile(
                      value: ck,
                      onChanged: (v) => _toggleCheckbox(key, v ?? false),
                      activeColor: Colors.orange,
                      checkColor: Colors.black,
                      title: Text(
                        '${ex['nomeExercicio']} ${ex['series']}x'
                            '${ex['repeticoes']} - ${ex['carga'] ?? '0'}kg '
                            '${ex['observacao'] ?? ''}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
