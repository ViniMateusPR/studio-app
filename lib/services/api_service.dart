import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://f8c0-168-197-141-209.ngrok-free.app';
  static String? token;
  static int empresaId = 0;
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 🔐 Inicializa token e empresaId do storage seguro
  static Future<void> init() async {
    token = await _storage.read(key: 'token');
    final idStr = await _storage.read(key: 'empresaId');
    if (idStr != null) {
      empresaId = int.tryParse(idStr) ?? 0;
    }
  }

  /// 🔑 Recupera CPF logado
  static Future<String> getCpfLogado() async {
    return await _storage.read(key: 'cpf') ?? '00000000000';
  }

  /// 🚪 Login do professor
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

  /// 🔄 POST genérico
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

  /// 📄 Lista de alunos
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

  /// 🏋️‍♂️ Lista de exercícios agrupados por grupo muscular
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
      'Abdômen',
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

  /// 📑 Lista de todos os exercícios
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

  /// 📅 Lista treinos de um aluno
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

  /// ✅ Salvar treino detalhado
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

  /// 🔍 Buscar treino detalhado
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

  /// 🏁 Finalizar treino
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

  /// ✍️ Atualizar treino detalhado (com CPF do professor no header)
  static Future<void> atualizarTreinoDetalhado(int id, Map<String, dynamic> treinoJson) async {
    final token = await _storage.read(key: 'token');
    final cpf = await getCpfLogado();
    final url = Uri.parse('$baseUrl/treinos/$id');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'cpfProfessor': cpf, // <- CPF logado enviado no header
      },
      body: jsonEncode(treinoJson),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar treino: ${response.body}');
    }
  }

  /// 👨‍🏫 Lista de professores
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
