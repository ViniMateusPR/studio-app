import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TreinoDestaqueService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'treinos_destaque';

  static Future<List<Map<String, dynamic>>> getTreinosSalvos() async {
    final jsonString = await _storage.read(key: _key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> adicionarTreinoCompleto(Map<String, dynamic> treinoCompleto) async {
    final treinos = await getTreinosSalvos();

    // Remove qualquer treino anterior do mesmo aluno (CPF)
    treinos.removeWhere((t) => t['aluno']['cpf'] == treinoCompleto['aluno']['cpf']);
    treinos.add(treinoCompleto);

    await _storage.write(key: _key, value: jsonEncode(treinos));
  }

  static Future<void> removerTreinoPorCpf(String cpf) async {
    final treinos = await getTreinosSalvos();
    treinos.removeWhere((t) => t['aluno']['cpf'] == cpf);
    await _storage.write(key: _key, value: jsonEncode(treinos));
  }

  static Future<void> limparTodosTreinos() async {
    await _storage.delete(key: _key);
  }
}
