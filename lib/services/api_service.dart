import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://8963-2804-984-863-4d00-682e-2911-2ebb-81cb.ngrok-free.app';

  static String? token;
  static int empresaId = 0;

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Inicializa token e empresaId a partir do storage seguro
  static Future<void> init() async {
    token = await _storage.read(key: 'token');
    final idStr = await _storage.read(key: 'empresaId');
    if (idStr != null) {
      empresaId = int.tryParse(idStr) ?? 0;
    }
  }

  static Future<Map<String, dynamic>> loginProfessor(String cpf, String senha) async {
    final url = Uri.parse('$baseUrl/auth/professor');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Salva token e cpf (ou outros dados) no storage seguro
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'cpf', value: data['cpf']);

      // Atualiza token estático para uso imediato
      token = data['token'];

      return data;
    } else {
      throw Exception('Falha no login: ${response.body}');
    }
  }


  /// Retorna a lista de alunos da empresa

  static Future<List<dynamic>> listarAlunos() async {
    final token = await AuthService().getToken();
    final url = Uri.parse('$baseUrl/aluno/listaDeAlunos');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar alunos: ${response.statusCode}');
    }
  }

  /// Retorna a lista de professores (exemplo anterior)
  static Future<List<dynamic>> getProfessores() async {
    final url = Uri.parse('$baseUrl/professores');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Erro ${response.statusCode}: ${response.body}');
      throw Exception('Erro ao buscar professores');
    }
  }
}
