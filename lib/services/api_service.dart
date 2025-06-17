// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://f8c0-168-197-141-209.ngrok-free.app';
  static String? token;
  static int empresaId = 0;
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Inicializa token e empresaId do storage seguro
  static Future<void> init() async {
    token = await _storage.read(key: 'token');
    final idStr = await _storage.read(key: 'empresaId');
    if (idStr != null) {
      empresaId = int.tryParse(idStr) ?? 0;
    }
  }

  /// Recupera o CPF do professor logado
  static Future<String?> getCpfLogado() async {
    return await _storage.read(key: 'cpf');
  }

  /// Genérico GET
  static Future<dynamic> get(String endpoint) async {
    final t = token ?? await _storage.read(key: 'token');
    final resp = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('Erro GET $endpoint: ${resp.statusCode} ${resp.body}');
  }

  /// Genérico POST
  static Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final t = token ?? await _storage.read(key: 'token');
    final resp = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (t != null) 'Authorization': 'Bearer $t',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }
    throw Exception('Erro POST $endpoint: ${resp.statusCode} ${resp.body}');
  }

  /// POST para salvar treino detalhado
  static Future<void> salvarTreinoDetalhado(Map<String, dynamic> treino) async {
    final t = token ?? await _storage.read(key: 'token');
    final resp = await http.post(
      Uri.parse('$baseUrl/treinos/salvar'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
      body: jsonEncode(treino),
    );
    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception('Erro ao salvar treino: ${resp.body}');
    }
  }

  /// PUT para atualizar treino detalhado
  static Future<void> atualizarTreinoDetalhado(int id, Map<String, dynamic> json) async {
    final t = token ?? await _storage.read(key: 'token');
    final cpfProf = await getCpfLogado();
    final resp = await http.put(
      Uri.parse('$baseUrl/treinos/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
        if (cpfProf != null) 'cpfProfessor': cpfProf,
      },
      body: jsonEncode(json),
    );
    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar treino: ${resp.body}');
    }
  }

  /// DELETE para excluir treino
  static Future<void> excluirTreino(int id) async {
    final t = token ?? await _storage.read(key: 'token');
    final resp = await http.delete(
      Uri.parse('$baseUrl/treinos/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('Erro ao deletar treino: ${resp.body}');
    }
  }

  /// Lista de alunos
  static Future<List<dynamic>> listarAlunos() async {
    final data = await get('/aluno/listaDeAlunos');
    return (data as List<dynamic>);
  }

  /// Lista de exercícios
  static Future<List<dynamic>> getExercicios() async {
    final data = await get('/exercicios/listar');
    return (data as List<dynamic>);
  }

  /// Exercícios agrupados por grupo muscular
  static Future<Map<String, List<dynamic>>> getExerciciosAgrupados() async {
    final lista = await getExercicios();
    const ordem = [
      'Funcional','Abdômen','Panturrilhas','Pernas',
      'Tríceps','Bíceps','Ombros','Costas','Peito'
    ];
    final agrupado = <String, List<dynamic>>{ for (var g in ordem) g: [] };
    for (var ex in lista) {
      final g = ex['grupoMuscular'] as String? ?? 'Outro';
      if (agrupado.containsKey(g)) {
        agrupado[g]!.add(ex);
      } else {
        agrupado[g] = [ex];
      }
    }
    return agrupado;
  }

  /// Lista treinos de um aluno
  static Future<List<dynamic>> listarTreinosPorAluno(String cpf) async {
    final data = await get('/treinos/aluno/$cpf');
    return (data as List<dynamic>);
  }

  /// Detalhes de um treino
  static Future<Map<String, dynamic>> getTreinoDetalhado(int id) async {
    final data = await get('/treinos/$id/detalhado');
    return Map<String, dynamic>.from(data);
  }

  /// Finalizar treino
  static Future<void> finalizarTreino({
    required int treinoId,
    required String alunoCpf,
    required String dataRealizacao,
  }) async {
    final token = await _storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/treinos/finalizar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'treinoId': treinoId,
        'alunoCpf': alunoCpf,
        'dataRealizacao': dataRealizacao,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao finalizar treino: ${response.body}');
    }
  }


  /// Lista de professores
  static Future<List<dynamic>> getProfessores() async {
    final data = await get('/professores');
    return (data as List<dynamic>);
  }
}
