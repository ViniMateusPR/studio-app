import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://f8c0-168-197-141-209.ngrok-free.app';
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

  /// Método POST genérico (ex: para finalizar treino)
  static Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro POST $endpoint: ${response.statusCode} ${response.body}');
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
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'cpf', value: data['cpf']);
      token = data['token'];
      return data;
    } else {
      throw Exception('Falha no login: ${response.body}');
    }
  }

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

  static Future<Map<String, List<dynamic>>> getExerciciosAgrupados() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/exercicios/listar');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar exercícios');
    }

    final List<dynamic> lista = jsonDecode(response.body);

    final List<String> ordemGrupos = [
      'Funcional',
      'Abdomen',
      'Panturrilhas',
      'Pernas',
      'Tríceps',
      'Bíceps',
      'Ombros',
      'Costas',
      'Peito',
    ];

    final Map<String, List<dynamic>> agrupado = {
      for (var grupo in ordemGrupos) grupo: []
    };

    for (var exercicio in lista) {
      final grupo = exercicio['grupoMuscular'];
      if (agrupado.containsKey(grupo)) {
        agrupado[grupo]!.add(exercicio);
      } else {
        agrupado.putIfAbsent(grupo, () => [exercicio]);
      }
    }

    return agrupado;
  }

  static Future<List<dynamic>> getExercicios() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/exercicios/listar');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar exercícios');
    }
  }

  static Future<List<dynamic>> listarTreinosPorAluno(String cpfAluno) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/treinos/aluno/$cpfAluno');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar treinos do aluno: ${response.body}');
    }
  }

  static Future<void> salvarTreino(String cpfAluno, List<String> idsExercicios) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/treino');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cpfAluno': cpfAluno,
        'exercicios': idsExercicios,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao salvar treino');
    }
  }

  static Future<void> salvarTreinoDetalhado(Map<String, dynamic> treino) async {
    final token = await _storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/treinos/salvar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(treino),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao salvar treino: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getTreinoDetalhado(int treinoId) async {
    final token = await _storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/treinos/$treinoId/detalhado'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar treino detalhado: ${response.body}');
    }
  }

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

    // ⚠️ NUNCA faça jsonDecode aqui, já que o body está vazio
  }



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
