import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckboxStateService {
  static const _storage = FlutterSecureStorage();

  static String _buildKey(String alunoCpf, int treinoId) {
    return 'checkbox_${alunoCpf}_$treinoId';
  }

  /// Salva o estado dos checkboxes para um treino específico
  static Future<void> salvarEstado(
      String alunoCpf, int treinoId, Map<int, bool> estado) async {
    final key = _buildKey(alunoCpf, treinoId);
    final jsonString = jsonEncode(estado);
    await _storage.write(key: key, value: jsonString);
  }

  /// Carrega o estado dos checkboxes para um treino específico
  static Future<Map<int, bool>> carregarEstado(
      String alunoCpf, int treinoId) async {
    final key = _buildKey(alunoCpf, treinoId);
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((k, v) => MapEntry(int.parse(k), v as bool));
  }

  /// Limpa o estado dos checkboxes (opcional, pode ser chamado ao finalizar treino)
  static Future<void> limparEstado(String alunoCpf, int treinoId) async {
    final key = _buildKey(alunoCpf, treinoId);
    await _storage.delete(key: key);
  }
}
