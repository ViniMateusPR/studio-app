// lib/screens/treino/montar_treino_professor_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../models/aluno.dart';
import '../../providers/montar_treino_provider.dart';
import '../../screens/treino/criar_ficha_screen.dart';
import '../../screens/treino/editar_ficha_screen.dart';
import '../../screens/treino/editar_treino_screen.dart';
import '../../screens/home/home_professor_screen.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../../widgets/exercicio_tile.dart';

class MontarTreinoProfessorScreen extends StatefulWidget {
  static const routeName = '/montar-treino';
  final Aluno aluno;
  const MontarTreinoProfessorScreen({super.key, required this.aluno});

  @override
  State<MontarTreinoProfessorScreen> createState() =>
      _MontarTreinoProfessorScreenState();
}

class _MontarTreinoProfessorScreenState
    extends State<MontarTreinoProfessorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _injected = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_injected) {
      final prov = context.read<MontarTreinoProvider>();
      prov.alunoId = widget.aluno.id;
      // chama a carga de dados após terminar o build da frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        prov.carregarDados();
      });
      _injected = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _criarFicha() async {
    final prov = context.read<MontarTreinoProvider>();
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CriarFichaScreen(aluno: widget.aluno),
      ),
    );
    if (created == true) {
      prov.carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MontarTreinoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Treino de ${widget.aluno.nome.split(' ').first}',
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Histórico'),
            Tab(text: 'Novo'),
          ],
        ),
      ),
      body: prov.loading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _HistoricoTab(
            aluno: widget.aluno,
            onCreateTreino: () {
              prov.selectFicha(prov.fichaSelecionada!);
              _tabController.animateTo(1);
            },
            onEditFicha: (f) async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarFichaScreen(
                    ficha: f,
                    aluno: widget.aluno,
                  ),
                ),
              );
              if (ok == true) prov.carregarDados();
            },
          ),
          const _NovoTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
        onPressed: _criarFicha,
        backgroundColor: AppColors.accent,
        elevation: 4,
        icon: const Icon(Icons.note_add, color: Colors.white),
        label: const Text('Nova Ficha',
            style: TextStyle(color: Colors.white)),
      )
          : FloatingActionButton.extended(
        onPressed: prov.canSave
            ? () async {
          final ok = await prov.saveTreino();
          if (ok) {
            await prov.carregarDados();
            _tabController.animateTo(0);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Treino salvo!')),
            );
          }
        }
            : null,
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text('Salvar (${prov.exerciciosSelecionados.length})',
            style: const TextStyle(color: Colors.white)),
        backgroundColor:
        prov.canSave ? AppColors.accent : AppColors.surface,
      ),
    );
  }
}

// ——————————————————————————————————————

class _HistoricoTab extends StatelessWidget {
  final Aluno aluno;
  final VoidCallback onCreateTreino;
  final void Function(Map<String, dynamic>) onEditFicha;

  const _HistoricoTab({
    required this.aluno,
    required this.onCreateTreino,
    required this.onEditFicha,
  });

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MontarTreinoProvider>();

    if (prov.fichas.isEmpty) {
      return RefreshIndicator(
        onRefresh: prov.carregarDados,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'Nenhuma ficha encontrada.',
                style: TextStyle(color: AppColors.onSurfaceLight),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: prov.carregarDados,
      child: ListView.builder(
        itemCount: prov.fichas.length,
        itemBuilder: (context, i) {
          final f = prov.fichas[i];
          final treinos =
          (f['treinos'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

          // determina último treino
          Map<String, dynamic>? ultimo;
          if (treinos.isNotEmpty) {
            ultimo = treinos.reduce((a, b) {
              final da =
                  DateTime.tryParse(a['data'] ?? '') ?? DateTime(0);
              final db =
                  DateTime.tryParse(b['data'] ?? '') ?? DateTime(0);
              return da.isAfter(db) ? a : b;
            });
          }
          final dataUlt = ultimo != null
              ? DateTime.tryParse(ultimo['data'] ?? '')
              : null;
          final vencido = dataUlt != null &&
              DateTime.now().difference(dataUlt).inDays > 40;

          return Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              key: ValueKey(f['id']),
              collapsedIconColor: Colors.white,
              iconColor: Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.library_books, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f['descricao'] ?? 'Ficha #${f['id']}',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                  if (prov.fichaSelecionada?['id'] == f['id'])
                    const Icon(Icons.check_circle, color: AppColors.accent),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      f['objetivo'] ?? '-',
                      style: TextStyle(color: AppColors.accent),
                    ),
                    backgroundColor: AppColors.accent.withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                  ),
                  if ((f['observacao'] ?? '').toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.note,
                            size: 16, color: AppColors.onSurfaceLight),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            f['observacao'],
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (ultimo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      ultimo['descricao'] ?? '',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: AppColors.onSurfaceLight),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(ultimo['data']),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(
                            vencido ? 'Vencido' : 'Recente',
                            style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor:
                          vencido ? AppColors.error : Colors.green,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.onSurface),
                onPressed: () => onEditFicha(f),
              ),
              onExpansionChanged: (expanded) {
                if (expanded) prov.selectFicha(f);
              },
              childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fitness_center, color: Colors.white),
                    label: const Text('Novo Treino',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: onCreateTreino,
                  ),
                ),
                const SizedBox(height: 12),
                if (treinos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nenhum treino nesta ficha.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.onSurfaceLight)),
                  )
                else
                  ...treinos.map((t) {
                    final treinoId = t['treinoId'] ?? t['id'];
                    final dataStr = t['data'] ?? '';
                    final dt = DateTime.tryParse(dataStr) ?? DateTime(0);
                    final venc = DateTime.now().difference(dt).inDays > 40;
                    return ListTile(
                      tileColor:
                      venc ? Colors.redAccent.withOpacity(0.2) : null,
                      title: Text(
                        t['descricao'] ?? '',
                        style: TextStyle(
                          color: venc ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(dataStr),
                        style: TextStyle(
                          color: venc
                              ? Colors.redAccent
                              : AppColors.onSurfaceLight,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                            const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              final ok = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarTreinoScreen(
                                    treinoId: treinoId,
                                    alunoId: aluno.id,
                                    alunoNome: aluno.nome,
                                  ),
                                ),
                              );
                              if (ok == true) prov.carregarDados();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  title: const Text('Excluir treino?',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                      'Deseja realmente excluir este treino?',
                                      style: TextStyle(
                                          color: AppColors.onSurfaceLight)),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Não',
                                          style: TextStyle(
                                              color: AppColors
                                                  .onSurfaceLight)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: const Text('Sim',
                                          style: TextStyle(
                                              color: AppColors.accent)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ApiService.excluirTreino(treinoId);
                                prov.carregarDados();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            onPressed: () async {
                              try {
                                final detalhe = await ApiService.getTreinoDetalhado(treinoId);

                                // ✅ Inicia o treino
                                await ApiService.iniciarTreino(
                                  treinoId: detalhe['treinoId'],
                                  alunoId: aluno.id,
                                );

                                // ✅ Salva localmente
                                await TreinoDestaqueService.adicionarTreinoCompleto({
                                  'aluno': {
                                    'id': aluno.id,
                                    'nome': aluno.nome,
                                  },
                                  'treinos': [detalhe],
                                });

                                // ✅ Vai pra Home
                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
                                      (route) => false,
                                );
                              } catch (e) {
                                debugPrint('Erro ao iniciar treino: $e');
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Erro ao iniciar treino')),
                                );
                              }
                            },
                          ),

                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NovoTab extends StatelessWidget {
  const _NovoTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MontarTreinoProvider>();
    if (prov.fichaSelecionada == null) {
      return Center(
        child: Text(
          'Selecione uma ficha no Histórico',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nome do Treino',
            labelStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: prov.updateNome,
        ),
        const SizedBox(height: 16),
        ...prov.exerciciosPorGrupo.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key,
                style: const TextStyle(color: Colors.white)),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: entry.value
                .map<Widget>((ex) => ExercicioTile(ex: ex))
                .toList(),
          );
        }).toList(),
      ],
    );
  }
}
