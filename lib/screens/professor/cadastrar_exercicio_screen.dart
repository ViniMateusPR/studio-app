// lib/screens/professor/cadastrar_exercicio_screen.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_theme.dart';
import '../../services/api_service.dart';
import '../home/home_professor_screen.dart';

class CadastrarExercicioScreen extends StatefulWidget {
  const CadastrarExercicioScreen({super.key});

  @override
  State<CadastrarExercicioScreen> createState() =>
      _CadastrarExercicioScreenState();
}

class _CadastrarExercicioScreenState extends State<CadastrarExercicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String? _grupoSelecionado;
  bool _erroGrupo = false;
  List<String> _gruposMusculares = [];
  bool _loading = true;

  bool get _isNomeValido => _nomeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _fetchGrupos();
    _nomeController.addListener(() => setState(() {}));
  }

  Future<void> _fetchGrupos() async {
    try {
      final lista = await ApiService.getExercicios();
      final grupos = lista
          .map<String>((e) => e['grupoMuscular'].toString())
          .toSet()
          .toList()
        ..sort();
      setState(() {
        _gruposMusculares = grupos;
      });
    } catch (_) {
      // falha silenciosa
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    setState(() => _erroGrupo = _grupoSelecionado == null);
    if (!_isNomeValido || !_formKey.currentState!.validate() || _erroGrupo)
      return;
    try {
      await ApiService.post(
        '/exercicios/cadastrar',
        body: {
          'nome': _nomeController.text.trim(),
          'grupoMuscular': _grupoSelecionado,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercício cadastrado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar exercício: $e')),
      );
    }
  }

  void _abrirSelecaoGrupo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Escolha o Grupo',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceLight),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.surface),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _gruposMusculares.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.surface),
                itemBuilder: (context, i) {
                  final g = _gruposMusculares[i];
                  final selected = g == _grupoSelecionado;
                  return ListTile(
                    title: Text(
                      g,
                      style: TextStyle(
                        color: selected ? AppColors.accent : AppColors.onSurface,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(Icons.check, color: AppColors.accent)
                        : null,
                    onTap: () {
                      setState(() {
                        _grupoSelecionado = g;
                        _erroGrupo = false;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(
          color: AppColors.onSurface,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
            );
          },
        ),
        title: const Text('Cadastrar Exercício'),
      ),
      body: _loading
          ? _buildShimmer()
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome do Exercício
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 24),
              // Grupo Muscular (custom)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grupo Muscular',
                    style: TextStyle(color: AppColors.onSurfaceLight),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _abrirSelecaoGrupo,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _grupoSelecionado == null
                              ? AppColors.onSurfaceLight.withOpacity(0.4)
                              : AppColors.accent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _grupoSelecionado ?? 'Selecione um grupo',
                              style: TextStyle(
                                color: _grupoSelecionado == null
                                    ? AppColors.onSurfaceLight
                                    : AppColors.onSurface,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.onSurfaceLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_erroGrupo)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Selecione um grupo',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isNomeValido ? _salvar : null,
                child: const Text('Salvar Exercício'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.primary,
        child: ListView(
          children: [
            // placeholder do campo de nome
            Container(height: 48, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12))),
            // placeholder do dropdown
            Container(height: 48, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 24),
            // placeholder do botão
            Container(height: 48, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12))),
          ],
        ),
      ),
    );
  }
}
