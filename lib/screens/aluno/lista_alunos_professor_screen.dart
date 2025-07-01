// lib/screens/aluno/lista_alunos_professor_screen.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_theme.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../home/home_professor_screen.dart';
import '../treino/montar_treino_professor_screen.dart';

class ListaAlunosProfessorScreen extends StatefulWidget {
  const ListaAlunosProfessorScreen({super.key});

  @override
  State<ListaAlunosProfessorScreen> createState() =>
      _ListaAlunosProfessorScreenState();
}

class _ListaAlunosProfessorScreenState
    extends State<ListaAlunosProfessorScreen> {
  late Future<void> _futureAlunos;
  final List<Aluno> _alunos = [];
  final List<Aluno> _filtrados = [];
  final TextEditingController _searchController = TextEditingController();
  bool _mostrarAtivos = true;

  @override
  void initState() {
    super.initState();
    _futureAlunos = _carregarEOrdenar();
    _searchController.addListener(() => _filtrar(_searchController.text));
  }

  Future<void> _carregarEOrdenar() async {
    final data = await ApiService.listarAlunos();
    _alunos
      ..clear()
      ..addAll(data.map((e) => Aluno.fromJson(e)));
    _alunos.sort((a, b) =>
        a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    _filtrar(_searchController.text);
  }

  void _filtrar(String texto) {
    final lower = texto.toLowerCase();
    setState(() {
      _filtrados
        ..clear()
        ..addAll(_alunos.where((a) {
          final matchNome = a.nome.toLowerCase().contains(lower);
          final matchStatus = !_mostrarAtivos || a.ativo == true;
          return matchNome && matchStatus;
        }));
    });
  }

  String _capitalizar(String nome) => nome
      .split(' ')
      .map((p) =>
  p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
      .join(' ');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => _carregarEOrdenar();

  Widget _buildShimmerItem() {
    final surface = AppColors.surface;
    return Card(
      color: surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[700]!,
              highlightColor: Colors.grey[500]!,
              child: CircleAvatar(radius: 16, backgroundColor: Colors.grey[800]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[700]!,
                    highlightColor: Colors.grey[500]!,
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[700]!,
                    highlightColor: Colors.grey[500]!,
                    child: Container(
                      width: 150,
                      height: 12,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface;
    final onSurface = AppColors.onSurface;
    final onSurfaceLight = AppColors.onSurfaceLight;
    final accent = AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: surface,
        title: const Text('Lista de Alunos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _futureAlunos,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (_, __) => _buildShimmerItem(),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text('Erro ao carregar: ${snap.error}',
                  style: TextStyle(color: AppColors.error)),
            );
          }
          return RefreshIndicator(
            color: accent,
            onRefresh: _refresh,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: onSurface),
                          decoration: InputDecoration(
                            hintText: 'Buscar aluno...',
                            hintStyle:
                            TextStyle(color: onSurfaceLight, fontSize: 14),
                            prefixIcon:
                            Icon(Icons.search, color: onSurfaceLight, size: 20),
                            filled: true,
                            fillColor: surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilterChip(
                        label: const Text('Ativos'),
                        labelStyle: TextStyle(
                            color:
                            _mostrarAtivos ? Colors.white : onSurfaceLight),
                        selected: _mostrarAtivos,
                        onSelected: (v) => setState(() {
                          _mostrarAtivos = v;
                          _filtrar(_searchController.text);
                        }),
                        selectedColor: accent,
                        backgroundColor: surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filtrados.isEmpty
                      ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: Text(
                          'Nenhum aluno encontrado.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filtrados.length,
                    itemBuilder: (ctx, i) {
                      final a = _filtrados[i];
                      // escolhe email ou celular
                      final contato = a.email ?? a.celular ?? '—';
                      return Card(
                        color: surface,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Icon(Icons.person, color: accent),
                          title: Text(
                            _capitalizar(a.nome),
                            style: TextStyle(
                                color: onSurface,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            contato,
                            style: TextStyle(color: onSurfaceLight),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.white54),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MontarTreinoProfessorScreen(aluno: a),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
