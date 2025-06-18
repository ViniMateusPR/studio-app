import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TreinoDestaqueService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'treinos_destaque';
  static String get storageKey => _key;

  static Future<List<Map<String, dynamic>>> getTreinosSalvos() async {
    final jsonString = await _storage.read(key: _key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> adicionarTreinoCompleto(Map<String, dynamic> data) async {
    final treinosSalvos = await getTreinosSalvos();

    final aluno = data['aluno'] as Map<String, dynamic>;
    final treino = Map<String, dynamic>.from(data['treino']);

    final alunoId = aluno['id'].toString();

    // 🔥 Verifica e adiciona data de realização, se não existir
    treino['dataRealizacao'] = treino['dataRealizacao'] ?? DateTime.now().toIso8601String();

    // Verifica se já existe esse aluno na lista
    final index = treinosSalvos.indexWhere((item) {
      final a = item['aluno'] as Map<String, dynamic>;
      return a['id'].toString() == alunoId;
    });

    if (index != -1) {
      // Já existe -> adiciona treino
      treinosSalvos[index]['treinos'].add(treino);
    } else {
      // Não existe -> cria novo
      treinosSalvos.add({
        'aluno': {
          'id': alunoId,
          'nome': aluno['nome'],
        },
        'treinos': [treino],
      });
    }

    await _storage.write(key: _key, value: jsonEncode(treinosSalvos));
  }


  static Future<void> removerTreinoPorId(String alunoId) async {
    final treinos = await getTreinosSalvos();
    treinos.removeWhere((t) => t['aluno']['id'].toString() == alunoId);
    await _storage.write(key: _key, value: jsonEncode(treinos));
  }

  static Future<void> limparTodosTreinos() async {
    await _storage.delete(key: _key);
  }
}
