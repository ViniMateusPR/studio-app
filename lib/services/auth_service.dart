import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://f8c0-168-197-141-209.ngrok-free.app';

  /// Login da empresa
  Future<bool> login({required String cnpj, required String senha}) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cnpj': cnpj, 'senha': senha}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'empresaId', value: data['id'].toString());
      await _storage.write(key: 'empresaNome', value: data['nome']);
      return true;
    }
    return false;
  }

  /// Login do professor
  Future<bool> loginProfessor({required String cpf, required String senha}) async {
    final url = Uri.parse('$_baseUrl/auth/professor');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'senha': senha}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'cpf', value: data['cpf']);
      return true;
    }
    return false;
  }

  /// Registro de empresa
  Future<bool> register({required String nome, required String cnpj, required String senha}) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'cnpj': cnpj, 'senha': senha}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'empresaId', value: data['id'].toString());
      await _storage.write(key: 'empresaNome', value: data['nome']);
      return true;
    }
    return false;
  }

  Future<void> logout() async => _storage.deleteAll();
  Future<String?> getToken() async => _storage.read(key: 'token');
  Future<String?> getEmpresaId() async => _storage.read(key: 'empresaId');
  Future<String?> getEmpresaNome() async => _storage.read(key: 'empresaNome');
  Future<String?> getCpfLogado() async => _storage.read(key: 'cpf');
}
