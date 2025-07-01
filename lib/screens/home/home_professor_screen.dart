// lib/screens/home/home_professor_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../aluno/lista_alunos_professor_screen.dart';
import '../professor/cadastrar_exercicio_screen.dart';
import '../treino/editar_treino_screen.dart';

class HomeProfessorScreen extends StatefulWidget {
  const HomeProfessorScreen({Key? key}) : super(key: key);

  @override
  State<HomeProfessorScreen> createState() => _HomeProfessorScreenState();
}

class _HomeProfessorScreenState extends State<HomeProfessorScreen> {
  final _storage = const FlutterSecureStorage();
  late final PageController _pageController;
  bool _loading = true;
  int _selectedIndex = 0;
  String _nomeProfessor = '';
  List<Map<String, dynamic>> _alunosComTreinos = [];
  Map<String, bool> _checkboxStatus = {};

  static const double _itemWidth = 100;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadNomeProfessor();
    _loadAll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNomeProfessor() async {
    final nome = await _storage.read(key: 'nome');
    setState(() => _nomeProfessor = nome ?? '');
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    final jsonString = await _storage.read(key: 'checkbox_status');
    if (jsonString != null) {
      _checkboxStatus = Map<String, bool>.from(jsonDecode(jsonString));
    }

    final salvos = await TreinoDestaqueService.getTreinosSalvos();
    final alunosList = salvos.map<Map<String, dynamic>>((item) {
      final aluno = item['aluno'] as Map<String, dynamic>;
      return {
        'id': aluno['id'].toString(),
        'nome': aluno['nome'],
        'treinos': item['treinos'] as List<dynamic>,
      };
    }).toList();

    setState(() {
      _alunosComTreinos = alunosList;
      _selectedIndex = 0;
      _loading = false;
    });
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  Future<void> _saveCheckbox() =>
      _storage.write(key: 'checkbox_status', value: jsonEncode(_checkboxStatus));

  void _toggleCheckbox(String key, bool val) {
    setState(() {
      _checkboxStatus[key] = val;
    });
    _saveCheckbox();
  }

  Future<bool> _handleDismiss(
      BuildContext ctx, String alunoId, bool isFinish) async {
    final action = isFinish ? 'finalizar' : 'cancelar';
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isFinish ? 'Finalizar Treino' : 'Cancelar Treino',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.accent),
        ),
        content: Text(
          'Deseja realmente $action este treino?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Não',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sim',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    if (isFinish) {
      final alunoItem =
      _alunosComTreinos.firstWhere((a) => a['id'] == alunoId);
      final treino = (alunoItem['treinos'] as List).last as Map<String, dynamic>;
      final raw = treino['treinoId'] ?? treino['id'] ?? treino['treino_id'];
      final int? id = raw is int ? raw : int.tryParse(raw.toString());
      if (id != null) {
        final hoje = DateTime.now().toIso8601String().substring(0, 10);
        await ApiService.finalizarTreinoViaWebsocket(
          treinoId: id,
          alunoId: int.parse(alunoId),
          dataRealizacao: hoje,
        );
      }
    }

    await TreinoDestaqueService.removerTreinoPorId(alunoId);

    setState(() {
      _alunosComTreinos.removeWhere((a) => a['id'] == alunoId);
      _selectedIndex = _alunosComTreinos.isEmpty
          ? 0
          : _selectedIndex.clamp(0, _alunosComTreinos.length - 1);
      _pageController.jumpToPage(_selectedIndex);
    });

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(isFinish
            ? 'Treino finalizado e removido.'
            : 'Treino cancelado e removido.'),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: AppColors.accent,
          onPressed: () => _loadAll(),
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
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      drawer: _buildDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : hasData
          ? PageView.builder(
        controller: _pageController,
        itemCount: _alunosComTreinos.length,
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        itemBuilder: (_, i) =>
            _buildTreinosAluno(_alunosComTreinos[i]),
      )
          : Center(
        child: Text(
          'Bem-vindo, $_nomeProfessor 👋',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.onSurfaceLight),
        ),
      ),
      bottomNavigationBar:
      hasData ? _buildBottomNav() : const SizedBox.shrink(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: AppColors.surface,
              child: Text(
                'Menu do Professor',
                style:
                AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
              ),
            ),
            const Divider(color: AppColors.accent, height: 1),
            _drawerItem(
              icon: Icons.people,
              label: 'Lista de Alunos',
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const ListaAlunosProfessorScreen()),
              ),
            ),
            _drawerItem(
              icon: Icons.fitness_center,
              label: 'Cadastrar Exercício',
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const CadastrarExercicioScreen()),
              ),
            ),
            const Spacer(),
            const Divider(color: AppColors.accent, height: 1),
            _drawerItem(
              icon: Icons.logout,
              label: 'Sair',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = AppColors.onSurface,
    Color textColor = AppColors.onSurface,
  }) =>
      ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(label,
            style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        horizontalTitleGap: 16,
      );

  Widget _buildBottomNav() {
    return Container(
      color: AppColors.surface,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _alunosComTreinos.length,
        itemBuilder: (_, i) {
          final aluno = _alunosComTreinos[i];
          final isSel = i == _selectedIndex;
          final nome = aluno['nome'].toString().split(' ').first;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
              _pageController.jumpToPage(i);
            },
            child: Container(
              width: (_alunosComTreinos.length > 5)
                  ? _itemWidth
                  : MediaQuery.of(context).size.width /
                  _alunosComTreinos.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 3,
                    width: 60,
                    color: isSel ? AppColors.accent : Colors.transparent,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nome,
                    style: TextStyle(
                      color: isSel
                          ? AppColors.onSurface
                          : AppColors.onSurfaceLight,
                      fontWeight:
                      isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTreinosAluno(Map<String, dynamic> alunoData) {
    final id = alunoData['id'] as String;
    final treinos = (alunoData['treinos'] ?? []) as List<dynamic>;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: treinos.length,
      itemBuilder: (_, idx) {
        final treino = treinos[idx] as Map<String, dynamic>;
        final exs = (treino['exercicios'] ?? []) as List<dynamic>;
        final total = exs.length;
        final done = exs.asMap().entries.where((e) {
          final key = '$id-${treino['id'] ?? treino['treinoId']}-${e.key}';
          return _checkboxStatus[key] == true;
        }).length;
        final prog = total > 0 ? done / total : 0.0;

        return Dismissible(
          key: ValueKey('$id-${treino['id'] ?? treino['treinoId']}-$idx'),
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
          confirmDismiss: (dir) =>
              _handleDismiss(context, id, dir == DismissDirection.startToEnd),
          child: Card(
            color: AppColors.surface,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // título + editar
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          treino['descricao'] ?? 'Sem título',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.accent, fontSize: 20),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: AppColors.onSurfaceLight),
                        tooltip: 'Editar treino',
                        onPressed: () async {
                          final idTreino =
                              treino['id'] ?? treino['treinoId'];
                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarTreinoScreen(
                                treinoId: idTreino,
                                alunoId: int.parse(id),
                                alunoNome: alunoData['nome'],
                              ),
                            ),
                          );
                          if (ok == true) _loadAll();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    _formatDate(treino['data'] ?? ''),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.onSurfaceLight),
                  ),
                  const SizedBox(height: 12),

                  // progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: prog,
                      minHeight: 8,
                      color: AppColors.accent,
                      backgroundColor: AppColors.surface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // exercícios
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, j) {
                      final ex = exs[j] as Map<String, dynamic>;
                      final key =
                          '$id-${treino['id'] ?? treino['treinoId']}-$j';
                      final ck = _checkboxStatus[key] ?? false;

                      final nomeEx = ex['nomeExercicio'] ??
                          ex['nome'] ??
                          '<sem nome>';
                      final series = ex['series']?.toString() ?? '';
                      final reps = ex['repeticoes']?.toString() ?? '';
                      final carga = ex['carga']?.toString() ?? '0';
                      final obs = ex['observacao'] ?? '';

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _toggleCheckbox(key, !ck),
                        child: CheckboxListTile(
                          value: ck,
                          onChanged: (v) => _toggleCheckbox(key, v!),
                          activeColor: AppColors.accent,
                          checkColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '$nomeEx ${series}x$reps – ${carga}kg $obs',
                            style: AppTextStyles.bodyMedium,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
