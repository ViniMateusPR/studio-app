// lib/providers/montar_treino_provider.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MontarTreinoProvider extends ChangeNotifier {
  int? alunoId;

  bool _loading = true;
  bool get loading => _loading;

  /// Cache dos exercícios agrupados
  Map<String, List<dynamic>> _exerciciosPorGrupo = {};
  bool _exerciciosCarregados = false;
  Map<String, List<dynamic>> get exerciciosPorGrupo => _exerciciosPorGrupo;

  List<dynamic> _fichas = [];
  List<dynamic> get fichas => _fichas;

  Map<String, dynamic>? _fichaSelecionada;
  Map<String, dynamic>? get fichaSelecionada => _fichaSelecionada;

  List<Map<String, dynamic>> _exerciciosSelecionados = [];
  List<Map<String, dynamic>> get exerciciosSelecionados =>
      _exerciciosSelecionados;

  String _nomeTreino = '';
  bool get canSave =>
      _nomeTreino.trim().isNotEmpty &&
          _exerciciosSelecionados.isNotEmpty &&
          _fichaSelecionada != null;

  void updateNome(String nome) {
    _nomeTreino = nome;
    notifyListeners();
  }

  /// Força rebuild sem alterar estado
  void notifyUpdate() => notifyListeners();

  void removeExercicio(Map<String, dynamic> ex) {
    _exerciciosSelecionados.remove(ex);
    // reordena
    for (var i = 0; i < _exerciciosSelecionados.length; i++) {
      _exerciciosSelecionados[i]['ordem'] = i + 1;
    }
    notifyListeners();
  }

  Future<void> carregarDados() async {
    if (alunoId == null) return;

    _loading = true;
    notifyListeners();

    try {
      // 1) busca fichas
      _fichas = await ApiService.listarFichasPorAluno(alunoId!);

      // 2) carrega exercícios agrupados apenas na primeira vez
      if (!_exerciciosCarregados) {
        _exerciciosPorGrupo = await ApiService.getExerciciosAgrupados();
        _exerciciosCarregados = true;
      }

      // 3) mantém ficha selecionada, se houver
      if (_fichas.isNotEmpty && _fichaSelecionada != null) {
        final idAntigo = _fichaSelecionada!['id'];
        _fichaSelecionada = _fichas.firstWhere(
              (f) => f['id'] == idAntigo,
          orElse: () => _fichas.first,
        );
      }

      // 4) limpa seleção de exercícios
      _exerciciosSelecionados.clear();
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectFicha(Map<String, dynamic> ficha) {
    _fichaSelecionada = ficha;
    _exerciciosSelecionados.clear();
    notifyListeners();
  }

  void toggleExercicio(Map<String, dynamic> ex) {
    final idx = _exerciciosSelecionados
        .indexWhere((s) => s['exercicioId'] == ex['id']);

    if (idx == -1) {
      // adiciona no final, atribuindo ordem incremental
      _exerciciosSelecionados.add({
        'exercicioId': ex['id'],
        'ordem': _exerciciosSelecionados.length + 1,
        'series': 3,
        'repeticoes': 10,
        'carga': 0,
        'observacao': '',
      });
    } else {
      // remove e reordena todo mundo
      _exerciciosSelecionados.removeAt(idx);
      for (var i = 0; i < _exerciciosSelecionados.length; i++) {
        _exerciciosSelecionados[i]['ordem'] = i + 1;
      }
    }

    notifyListeners();
  }


  Future<bool> saveTreino() async {
    if (!canSave) return false;

    final cpfProf = await ApiService.getCpfLogado();

    final body = {
      'descricao': _nomeTreino.trim(),
      'alunoId': alunoId,                    // campo plano
      'fichaId': fichaSelecionada!['id'],    // campo plano
      'exercicios': _exerciciosSelecionados,
      'personalCpf': cpfProf,                // se seu back espera personalCpf
    };

    try {
      await ApiService.salvarTreinoComFicha(body);
      _nomeTreino = '';
      _exerciciosSelecionados.clear();
      await carregarDados();
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar treino: $e');
      return false;
    }
  }
}
