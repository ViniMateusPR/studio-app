// Arquivo: montar_treino_professor_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../../services/treino_destaque_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home_professor_screen.dart';

class MontarTreinoProfessorScreen extends StatefulWidget {
  final Aluno aluno;

  const MontarTreinoProfessorScreen({super.key, required this.aluno});

  @override
  State<MontarTreinoProfessorScreen> createState() => _MontarTreinoProfessorScreenState();
}

class _MontarTreinoProfessorScreenState extends State<MontarTreinoProfessorScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, List<dynamic>> _exerciciosPorGrupo = {};
  List<Map<String, dynamic>> _exerciciosSelecionados = [];
  List<dynamic> _treinosAnteriores = [];
  bool _loading = true;
  bool _criandoNovo = true;
  final TextEditingController _nomeTreinoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final exercicios = await ApiService.getExerciciosAgrupados();
      final treinos = await ApiService.listarTreinosPorAluno(widget.aluno.cpf);
      setState(() {
        _exerciciosPorGrupo = exercicios;
        _treinosAnteriores = treinos ?? [];
        _loading = false;
        _criandoNovo = (_treinosAnteriores.isEmpty);
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _loading = false);
    }
  }

  void _salvarTreino() async {
    try {
      final cpfProfessor = await _storage.read(key: 'cpf');
      final nomeTreino = _nomeTreinoController.text.trim();

      if (nomeTreino.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Digite o nome do treino.')),
        );
        return;
      }

      final treino = {
        'descricao': nomeTreino,
        'alunoCpf': widget.aluno.cpf,
        'personalCpf': cpfProfessor,
        'data': DateTime.now().toIso8601String(),
        'exercicios': _exerciciosSelecionados
      };

      await ApiService.salvarTreinoDetalhado(treino);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao salvar treino: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar treino: \$e')),
      );
    }
  }

  Widget _buildCamposExtras(Map<String, dynamic> exercicio) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Ordem', filled: true),
          keyboardType: TextInputType.number,
          onChanged: (val) => exercicio['ordem'] = int.tryParse(val),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Séries', filled: true),
          keyboardType: TextInputType.number,
          onChanged: (val) => exercicio['series'] = int.tryParse(val),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Repetições', filled: true),
          keyboardType: TextInputType.number,
          onChanged: (val) => exercicio['repeticoes'] = int.tryParse(val),
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Observação', filled: true),
          onChanged: (val) => exercicio['observacao'] = val,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  void dispose() {
    _nomeTreinoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Treino de ${widget.aluno.nome}'),
        backgroundColor: const Color(0xFFFF6B00),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : !_criandoNovo
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Último Treino', style: TextStyle(color: Colors.orange, fontSize: 18)),
          ),
          if (_treinosAnteriores.isNotEmpty)
            Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_treinosAnteriores.last['descricao'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Data: ${_treinosAnteriores.last['data'] ?? ''}',
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          const Divider(color: Colors.orange, height: 32),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Treinos Anteriores',
                style: TextStyle(color: Colors.orange, fontSize: 18)),
          ),
          Expanded(
            child: ListView(
              children: _treinosAnteriores.map((t) => ListTile(
                title: Text(t['descricao'], style: const TextStyle(color: Colors.white)),
                subtitle:
                Text(t['data'], style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Colors.orange),
                  onPressed: () async {
                    final treinoId = t['treino_id'] ?? t['id'];
                    try {
                      final detalhes = await ApiService.getTreinoDetalhado(treinoId);
                      final treinoCompleto = {
                        'aluno': {'cpf': widget.aluno.cpf, 'nome': widget.aluno.nome},
                        'treino': detalhes,
                      };
                      await TreinoDestaqueService.adicionarTreinoCompleto(treinoCompleto);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao buscar detalhes do treino.')),
                      );
                    }
                  },
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _criandoNovo = true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Criar novo treino'),
          )
        ],
      )
          : ListView(children: [_buildFormularioNovoTreino()]),
      floatingActionButton: _criandoNovo
          ? FloatingActionButton.extended(
        onPressed: _salvarTreino,
        backgroundColor: const Color(0xFFFF6B00),
        label: const Text("Salvar Treino"),
        icon: const Icon(Icons.save),
      )
          : null,
    );
  }

  Widget _buildFormularioNovoTreino() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _nomeTreinoController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nome do Treino',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ..._exerciciosPorGrupo.entries.map((entry) {
          final grupo = entry.key;
          final exercicios = entry.value;
          return ExpansionTile(
            title:
            Text(grupo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            iconColor: Colors.orange,
            collapsedIconColor: Colors.orange,
            children: exercicios.map((exercicio) {
              final id = exercicio['id'];
              final nome = exercicio['nome'];
              final index = _exerciciosSelecionados.indexWhere((e) => e['exercicioId'] == id);
              final selecionado = index != -1;
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(nome, style: const TextStyle(color: Colors.white)),
                    value: selecionado,
                    activeColor: Colors.orange,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _exerciciosSelecionados.add({
                            'exercicioId': id,
                            'ordem': 1,
                            'series': 3,
                            'repeticoes': 10,
                            'observacao': ''
                          });
                        } else {
                          _exerciciosSelecionados.removeWhere((e) => e['exercicioId'] == id);
                        }
                      });
                    },
                  ),
                  if (selecionado)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildCamposExtras(_exerciciosSelecionados[index]),
                    ),
                ],
              );
            }).toList(),
          );
        }).toList(),
        const SizedBox(height: 80),
      ],
    );
  }
}
