import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TreinoDestaqueService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'treinos_destaque';

  /// Expõe a chave do storage para outros serviços
  static String get storageKey => _key;

  static Future<List<Map<String, dynamic>>> getTreinosSalvos() async {
    final jsonString = await _storage.read(key: _key);
    if (jsonString == null) return [];
    final decoded = jsonDecode(jsonString) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> adicionarTreinoCompleto(Map<String, dynamic> data) async {
    final salvos = await getTreinosSalvos();
    final aluno = data['aluno'] as Map<String, dynamic>;
    final treinos = List<Map<String, dynamic>>.from(data['treinos'] as List);
    final alunoId = aluno['id'].toString();

    final idx = salvos.indexWhere((item) =>
    (item['aluno'] as Map<String, dynamic>)['id'].toString() == alunoId
    );

    if (idx != -1) {
      salvos[idx]['treinos'] = treinos; // sobrescreve
    } else {
      salvos.add({
        'aluno': { 'id': alunoId, 'nome': aluno['nome'] },
        'treinos': treinos,
      });
    }

    await _storage.write(key: _key, value: jsonEncode(salvos));
  }

  static Future<void> removerTreinoPorId(String alunoId) async {
    final salvos = await getTreinosSalvos();
    salvos.removeWhere((t) =>
    (t['aluno'] as Map<String, dynamic>)['id'].toString() == alunoId
    );
    await _storage.write(key: _key, value: jsonEncode(salvos));
  }

  static Future<void> limparTodosTreinos() async {
    await _storage.delete(key: _key);
  }
}
