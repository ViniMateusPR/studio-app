// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://f8c0-168-197-141-209.ngrok-free.app';

  Future<bool> login({required String cnpj, required String senha}) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cnpj': cnpj, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'empresaId', value: data['id'].toString());
        await _storage.write(key: 'empresaNome', value: data['nome']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro no login: $e');
      return false;
    }
  }

  Future<bool> loginProfessor({required String cpf, required String senha}) async {
    final url = Uri.parse('$_baseUrl/auth/professor');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cpf': cpf, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        // Pode salvar outros dados do professor se quiser
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro no login do professor: $e');
      return false;
    }
  }


  Future<bool> register({
    required String nome,
    required String cnpj,
    required String senha,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'cnpj': cnpj,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'empresaId', value: data['id'].toString());
        await _storage.write(key: 'empresaNome', value: data['nome']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro no registro: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getEmpresaId() async {
    return await _storage.read(key: 'empresaId');
  }

  Future<String?> getEmpresaNome() async {
    return await _storage.read(key: 'empresaNome');
  }
}
