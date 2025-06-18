// lib/screens/professor/cadastrar_exercicio_screen.dart

import 'package:flutter/material.dart';
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
  List<String> _gruposMusculares = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _buscarGruposMusculares();
  }

  Future<void> _buscarGruposMusculares() async {
    try {
      final response = await ApiService.getExercicios();
      final grupos = response
          .map<String>((e) => e['grupoMuscular'].toString())
          .toSet()
          .toList()
        ..sort();
      setState(() {
        _gruposMusculares = grupos;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _salvarExercicio() async {
    if (!_formKey.currentState!.validate()) return;
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

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Cadastrar Exercício'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
            );
          },
        ),
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // — Nome do exercício —
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nome do Exercício',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),
              // — Grupo muscular —
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFF1E1E1E),
                ),
                child: DropdownButtonFormField<String>(
                  value: _grupoSelecionado,
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.orange,
                  decoration: InputDecoration(
                    hintText: 'Grupo Muscular',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _gruposMusculares
                      .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g,
                        style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => _grupoSelecionado = v),
                  validator: (v) =>
                  v == null ? 'Selecione um grupo' : null,
                ),
              ),
              const SizedBox(height: 32),
              // — Botão Salvar —
              ElevatedButton(
                onPressed: _salvarExercicio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Salvar Exercício',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
