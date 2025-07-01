// lib/screens/aluno/lista_alunos_screen.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_theme.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../home/home_empresa_screen.dart';
import '../treino/montar_treino_empresa_screen.dart';

class ListaAlunosScreen extends StatefulWidget {
  const ListaAlunosScreen({super.key});

  @override
  State<ListaAlunosScreen> createState() => _ListaAlunosScreenState();
}

class _ListaAlunosScreenState extends State<ListaAlunosScreen> {
  late Future<void> _futureAlunos;
  final List<Aluno> _alunos = [];
  final List<Aluno> _filtrados = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureAlunos = _loadAndSort();
    _searchController.addListener(() => _filter(_searchController.text));
  }

  Future<void> _loadAndSort() async {
    final data = await ApiService.listarAlunos();
    _alunos
      ..clear()
      ..addAll(data.map((e) => Aluno.fromJson(e)));
    _alunos
        .sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    _filter('');
  }

  void _filter(String text) {
    final lower = text.toLowerCase();
    setState(() {
      _filtrados
        ..clear()
        ..addAll(_alunos.where((a) => a.nome.toLowerCase().contains(lower)));
    });
  }

  String _capitalize(String nome) => nome
      .split(' ')
      .map((p) {
    if (p.isEmpty) return '';
    return p[0].toUpperCase() + p.substring(1).toLowerCase();
  })
      .join(' ');

  Future<void> _refresh() => _loadAndSort();

  Widget _buildShimmerItem() {
    return Card(
      color: AppColors.surface,
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
                    child:
                    Container(width: double.infinity, height: 14, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[700]!,
                    highlightColor: Colors.grey[500]!,
                    child: Container(width: 150, height: 12, color: Colors.grey[800]),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeEmpresaScreen()),
          ),
        ),
        title: const Text('Lista de Alunos'),
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
              child: Text(
                'Erro ao carregar: ${snap.error}',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: _refresh,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Buscar aluno...',
                      hintStyle:
                      TextStyle(color: AppColors.onSurfaceLight, fontSize: 14),
                      prefixIcon:
                      Icon(Icons.search, color: AppColors.onSurfaceLight, size: 20),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                      final contato = a.email ?? a.celular ?? '—';
                      return Card(
                        color: AppColors.surface,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Icon(Icons.person, color: AppColors.accent),
                          title: Text(
                            _capitalize(a.nome),
                            style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            contato,
                            style:
                            TextStyle(color: AppColors.onSurfaceLight),
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: Colors.white54),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MontarTreinoEmpresaScreen(
                                    aluno: a),
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
