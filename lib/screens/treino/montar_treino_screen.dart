import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import '../treino/editar_treino_screen.dart';
import '../treino/montar_treino_professor_screen.dart';
import '../home/home_professor_screen.dart';
import '../../app_theme.dart';

class MontarTreinoScreen extends StatefulWidget {
  final Aluno aluno;
  const MontarTreinoScreen({super.key, required this.aluno});

  @override
  State<MontarTreinoScreen> createState() => _MontarTreinoScreenState();
}

class _MontarTreinoScreenState extends State<MontarTreinoScreen> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _treinosAnteriores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _loading = true);
    try {
      final treinos = await ApiService.listarTreinosPorAluno(widget.aluno.id);
      setState(() {
        _treinosAnteriores = treinos ?? [];
      });
    } catch (e) {
      debugPrint('Erro ao carregar treinos: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text('Treinos de ${widget.aluno.nome}'),
        backgroundColor: AppColors.accent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : RefreshIndicator(
        onRefresh: _carregarDados,
        child: _treinosAnteriores.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'Nenhum treino encontrado.',
                style: TextStyle(color: AppColors.onSurfaceLight),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _treinosAnteriores.length,
          itemBuilder: (_, i) {
            final t = _treinosAnteriores[i] as Map<String, dynamic>;
            final treinoId = t['treino_id'] ?? t['id'];
            final dataStr = t['data'] ?? '';
            final dt = DateTime.tryParse(dataStr) ?? DateTime(0);
            final vencido = DateTime.now().difference(dt).inDays > 40;

            return Card(
              color: theme.colorScheme.surface,
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              child: ListTile(
                tileColor: vencido
                    ? Colors.redAccent.withOpacity(0.2)
                    : null,
                title: Text(
                  t['descricao'] ?? 'Sem descrição',
                  style: TextStyle(
                    color: vencido
                        ? Colors.redAccent
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _formatDate(dataStr),
                  style: TextStyle(
                    color: vencido
                        ? Colors.redAccent
                        : AppColors.onSurfaceLight,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Editar Treino
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppColors.onSurfaceLight),
                      onPressed: () async {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditarTreinoScreen(
                              treinoId: treinoId,
                              alunoId: widget.aluno.id,
                              alunoNome: widget.aluno.nome,
                            ),
                          ),
                        );
                        if (ok == true) _carregarDados();
                      },
                    ),
                    // Excluir Treino
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor:
                            AppColors.surface,
                            title: const Text(
                              'Excluir treino?',
                              style: TextStyle(
                                  color:
                                  AppColors.onSurface),
                            ),
                            content: const Text(
                              'Deseja realmente excluir este treino?',
                              style: TextStyle(
                                  color: AppColors
                                      .onSurfaceLight),
                            ),
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
                                        color: AppColors
                                            .accent)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ApiService.excluirTreino(
                              treinoId);
                          _carregarDados();
                        }
                      },
                    ),
                    // Enviar Treino para HomeProfessor
                    IconButton(
                      icon: const Icon(Icons.arrow_forward,
                          color: AppColors.accent),
                      onPressed: () async {
                        final detalhe = await ApiService
                            .getTreinoDetalhado(treinoId);
                        await TreinoDestaqueService
                            .adicionarTreinoCompleto({
                          'aluno': {
                            'id': widget.aluno.id,
                            'nome': widget.aluno.nome,
                          },
                          'treinos': [detalhe],
                        });
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const HomeProfessorScreen()),
                              (route) => false,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Criar novo treino'),
        onPressed: () async {
          // Navega para a tela de montagem completa:
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MontarTreinoProfessorScreen(aluno: widget.aluno),
            ),
          );
          // Ao voltar, recarrega a lista
          _carregarDados();
        },
      ),
    );
  }
}
