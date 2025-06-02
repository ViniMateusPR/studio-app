// lib/services/aluno_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AlunoService {
  Future<bool> cadastrarAluno(String nome, String email, String senha) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/aluno'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiService.token}',
      },
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );

    return response.statusCode == 201;
  }
}
