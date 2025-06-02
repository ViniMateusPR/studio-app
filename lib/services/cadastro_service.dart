import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CadastroService {
  Future<bool> cadastrarAluno({
    required String cpf,
    required String nome,
    required String email,
    required String celular,
    required String senha,
    required int empresaId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/aluno/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.token}',
      },
      body: jsonEncode({
        'cpf': cpf,
        'nome': nome,
        'email': email,
        'celular': celular,
        'senha': senha,
        'empresaId': empresaId,
        'ativo': true,  // fixo aqui
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> cadastrarProfessor({
    required String cpf,
    required String nome,
    required String email,
    required String senha,
    required int empresaId,
  }) async {
    final token = ApiService.token;

    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/professores/cadastrarProfessor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'cpf': cpf,
        'nome': nome,
        'email': email,
        'senha': senha,
        'empresaId': empresaId,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Erro ao cadastrar professor:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Token usado: $token');
      return false;
    }
  }


}

