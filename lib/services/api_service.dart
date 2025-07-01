import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studio_app/services/treino_destaque_service.dart';

class ApiService {
  static const String baseUrl = 'https://a770-168-197-141-209.ngrok-free.app';
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

  /// Retorna headers comuns para requisições autorizadas
  static Future<Map<String, String>> headers() async {
    final t = token ?? await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
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

  /// Genérico PUT
  static Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    final t = token ?? await _storage.read(key: 'token');
    final resp = await http.put(
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
    throw Exception('Erro PUT $endpoint: ${resp.statusCode} ${resp.body}');
  }

  /// DELETE genérico
  static Future<void> delete(String endpoint) async {
    final t = token ?? await _storage.read(key: 'token');
    final resp = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Erro DELETE $endpoint: ${resp.statusCode} ${resp.body}');
    }
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
    await delete('/treinos/$id');
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
  static Future<List<dynamic>> listarTreinosPorAluno(int alunoId) async {
    final data = await get('/treinos/aluno/$alunoId');
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
    required int alunoId,
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
        'alunoId': alunoId,
        'dataRealizacao': dataRealizacao,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erro ao finalizar treino: ${response.body}');
    }

    // Atualiza a dataRealizacao localmente no treino salvo
    final treinos = await TreinoDestaqueService.getTreinosSalvos();
    final alunoIndex = treinos.indexWhere(
            (t) => t['aluno']['id'].toString() == alunoId.toString());

    if (alunoIndex != -1) {
      final treinosDoAluno = treinos[alunoIndex]['treinos'] as List<dynamic>;
      final treinoIndex = treinosDoAluno.indexWhere((t) =>
      t['id'].toString() == treinoId.toString() ||
          t['treinoId'].toString() == treinoId.toString());

      if (treinoIndex != -1) {
        treinosDoAluno[treinoIndex]['dataRealizacao'] = dataRealizacao;
        await _storage.write(
            key: TreinoDestaqueService.storageKey, value: jsonEncode(treinos));
      }
    }
  }

  /// Iniciar treino
  static Future<void> iniciarTreino({
    required int treinoId,
    required int alunoId,
  }) async {
    final url = Uri.parse('$baseUrl/treinos/iniciar');
    final token = await _storage.read(key: 'token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'treinoId': treinoId,
        'alunoId': alunoId,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao iniciar o treino (${response.statusCode})');
    }
  }

  /// Obtém o CPF do usuário logado
  static Future<String?> getCpfLogado() async {
    return await _storage.read(key: 'cpf');
  }

  /// Lista de professores
  static Future<List<dynamic>> getProfessores() async {
    final data = await get('/professores');
    return (data as List<dynamic>);
  }

  /// Lista de professores com finalizações no dia
  static Future<List<dynamic>> getProfessoresComFinalizacoes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/empresa/$empresaId/professores/finalizacoes-dia'),
      headers: await headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Erro ao buscar dados');
    }
  }

  /// Lista alunos finalizados por professor no dia
  static Future<List<dynamic>> getAlunosFinalizadosPorProfessor(String professorId) async {
    final resp = await get('/empresa/$empresaId/professor/$professorId/alunos-finalizados');
    return resp as List<dynamic>;
  }

  /// Lista treinos vencidos da empresa
  static Future<List<dynamic>> getTreinosVencidos() async {
    final resp = await get('/empresa/$empresaId/treinos-vencidos');
    return resp as List<dynamic>;
  }

  /// 📄 Lista de fichas de um aluno
  static Future<List<dynamic>> listarFichasPorAluno(int alunoId) async {
    final data = await get('/fichas/aluno/$alunoId/fichas');
    return (data as List<dynamic>);
  }

  /// ➕ Criar uma nova ficha
  static Future<void> criarFicha(int alunoId, String descricao, String objetivo, String observacao) async {
    final cpf = await getCpfLogado();
    final body = {
      'descricao': descricao,
      'objetivo': objetivo,
      'observacao': observacao,
      'aluno': {'id': alunoId},
      'personal': {'cpf': cpf},
    };
    await post('/fichas', body: body);
  }

  /// ❌ Excluir uma ficha
  static Future<void> excluirFicha(int fichaId) async {
    await delete('/fichas/$fichaId');
  }

  /// 🔄 Editar ficha
  static Future<void> editarFicha(
      int fichaId, String descricao, String objetivo, String observacao) async {
    final cpf = await getCpfLogado();
    final body = {
      'descricao': descricao,
      'objetivo': objetivo,
      'observacao': observacao,
      'personal': {'cpf': cpf},
    };
    await put('/fichas/editar/$fichaId', body: body);
  }

  static Future<void> finalizarTreinoViaWebsocket({
    required int treinoId,
    required int alunoId,
    required String dataRealizacao,
  }) async {
    final token = await _storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('$baseUrl/treinos/finalizar-via-websocket'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'treinoId': treinoId,
        'alunoId': alunoId,
        'dataRealizacao': dataRealizacao,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao finalizar treino via websocket: ${response.body}');
    }
  }

  static Future<void> atualizarTreinoViaWebsocket({
    required int treinoId,
    required String descricao,
    required List<Map<String, dynamic>> exercicios,
  }) async {
    final token = await _storage.read(key: 'token');
    final cpfProfessor = await getCpfLogado();

    final response = await http.post(
      Uri.parse('$baseUrl/treinos/atualizar-via-websocket'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (cpfProfessor != null) 'cpfProfessor': cpfProfessor,
      },
      body: jsonEncode({
        'treinoId': treinoId,
        'descricao': descricao,
        'exercicios': exercicios,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao atualizar treino via websocket: ${response.body}');
    }
  }



  /// 📋 Lista treinos de uma ficha
  static Future<List<dynamic>> listarTreinosPorFicha(int fichaId) async {
    final data = await get('/fichas/$fichaId/treinos');
    return (data as List<dynamic>);
  }

  /// 🔥 Salvar treino dentro de uma ficha
  static Future<void> salvarTreinoComFicha(Map<String, dynamic> treino) async {
    final t = token ?? await _storage.read(key: 'token');
    final cpfProfessor = await getCpfLogado(); // pega o cpf do personal logado

    // monta o body incluindo o 'personal'
    final body = {
      ...treino,
      'personal': { 'cpf': cpfProfessor },
    };

    final resp = await http.post(
      Uri.parse('$baseUrl/fichas/salvar-com-ficha'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        if (t != null) 'Authorization': 'Bearer $t',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Erro ao salvar treino na ficha (status ${resp.statusCode}): ${resp.body}');
    }
  }
  /// Cria um post com empresaId, título e conteúdo em Base64
  static Future<void> criarPost({
    required int empresaId,
    required String titulo,
    required String conteudoBase64,
  }) async {
    await post(
      '/post/novo',
      body: {
        'empresaId': empresaId,
        'titulo': titulo,
        'conteudo': conteudoBase64,
      },
    );
  }

  /// Busca posts da empresa em formato leve:
  /// titulo, imagemUrl, nomeEmpresa, publicadoEm, likeCount, commentsCount
  static Future<List<Map<String, dynamic>>> getPostsEmpresa() async {
    final uri = Uri.parse('$baseUrl/post/empresa/$empresaId');
    final resp = await http.get(uri, headers: await headers());
    if (resp.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(resp.body) as List<dynamic>;
      return decoded
          .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erro ao buscar posts da empresa (${resp.statusCode})');
    }
  }
  /// Lista comentários de um post
  static Future<List<dynamic>> getComments(int postId) async {
    final uri = Uri.parse('$baseUrl/post/$postId/comentarios');
    final resp = await http.get(uri, headers: await headers());
    if (resp.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(resp.body);
      return lista.map((item) {
        return {
          'conteudo': item['conteudo'],
          'nomeAluno': item['nomeAluno'],
          'comentadoEm': item['comentadoEm'],
        };
      }).toList();
    }
    throw Exception('Erro ao buscar comentários (${resp.statusCode})');
  }



}
