import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';

class CadastroProfessorScreen extends StatefulWidget {
  const CadastroProfessorScreen({super.key});

  @override
  State<CadastroProfessorScreen> createState() => _CadastroProfessorScreenState();
}

class _CadastroProfessorScreenState extends State<CadastroProfessorScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final String baseUrl = 'https://f8c0-168-197-141-209.ngrok-free.app';

  bool _isLoading = false;
  String? _mensagem;
  bool _erro = false;

  Future<void> _cadastrarProfessor() async {
    final nome = _nomeController.text.trim();
    final cpf = _cpfController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (nome.isEmpty || cpf.isEmpty || email.isEmpty || senha.isEmpty) {
      setState(() {
        _erro = true;
        _mensagem = 'Preencha todos os campos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _mensagem = null;
    });

    try {
      final empresaId = await AuthService().getEmpresaId();
      final token = await AuthService().getToken();

      final url = Uri.parse('$baseUrl/professores/cadastrarProfessor');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': nome,
          'cpf': cpf,
          'email': email,
          'senha': senha,
          'empresaId': int.parse(empresaId!),
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _erro = false;
          _mensagem = 'Professor cadastrado com sucesso!';
        });
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _erro = true;
          _mensagem = 'Erro ao cadastrar professor.';
        });
        print('Erro ao cadastrar: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _erro = true;
        _mensagem = 'Erro de conexão ou formato inválido';
      });
      print('Exceção: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Cadastrar Professor"),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_nomeController, 'Nome'),
            _buildTextField(_cpfController, 'CPF', keyboardType: TextInputType.number),
            _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
            _buildTextField(_senhaController, 'Senha', obscure: true),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _cadastrarProfessor,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Cadastrar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (_mensagem != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _mensagem!,
                  style: TextStyle(
                    color: _erro ? Colors.redAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscure = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
