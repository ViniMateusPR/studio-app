import 'package:flutter/material.dart';
import 'package:studio_app/models/treino.dart';

class EditarTreinoScreen extends StatefulWidget {
  final Treino treino;
  final Function(Treino) onTreinoSalvo;

  const EditarTreinoScreen({
    Key? key,
    required this.treino,
    required this.onTreinoSalvo,
  }) : super(key: key);

  @override
  _EditarTreinoScreenState createState() => _EditarTreinoScreenState();
}

class _EditarTreinoScreenState extends State<EditarTreinoScreen> {
  late TextEditingController _seriesController;
  late TextEditingController _repeticoesController;
  late TextEditingController _grupoController;

  @override
  void initState() {
    super.initState();
    _seriesController = TextEditingController(text: widget.treino.series.toString());
    _repeticoesController = TextEditingController(text: widget.treino.repeticoes.toString());
    _grupoController = TextEditingController(text: widget.treino.grupo);
  }

  @override
  void dispose() {
    _seriesController.dispose();
    _repeticoesController.dispose();
    _grupoController.dispose();
    super.dispose();
  }

  void _salvarTreino() {
    final int? series = int.tryParse(_seriesController.text);
    final int? repeticoes = int.tryParse(_repeticoesController.text);
    final String grupo = _grupoController.text.trim();

    if (series == null || repeticoes == null || grupo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos corretamente.')),
      );
      return;
    }

    // Atualiza o treino com os novos valores
    final treinoAtualizado = Treino(
      nomeExercicio: widget.treino.nomeExercicio,
      series: series,
      repeticoes: repeticoes,
      grupo: grupo,
    );

    widget.onTreinoSalvo(treinoAtualizado);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Treino - ${widget.treino.nomeExercicio}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _seriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Séries'),
            ),
            TextField(
              controller: _repeticoesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Repetições'),
            ),
            TextField(
              controller: _grupoController,
              decoration: const InputDecoration(labelText: 'Grupo (ex: A, B, C)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarTreino,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
