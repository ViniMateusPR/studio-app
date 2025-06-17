// lib/screens/professor/cadastro_professor_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class CadastroProfessorScreen extends StatefulWidget {
  const CadastroProfessorScreen({super.key});

  @override
  State<CadastroProfessorScreen> createState() =>
      _CadastroProfessorScreenState();
}

class _CadastroProfessorScreenState extends State<CadastroProfessorScreen> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;
  String? _mensagem;
  bool _erro = false;
  bool _showSenha = false; // controla visibilidade da senha

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
      final url = Uri.parse(
          '${ApiService.baseUrl}/professores/cadastrarProfessor');

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
      }
    } catch (e) {
      setState(() {
        _erro = true;
        _mensagem = 'Erro de conexão ou formato inválido';
      });
    } finally {
      setState(() => _isLoading = false);
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
            _buildTextField(_cpfController, 'CPF',
                keyboardType: TextInputType.number),
            _buildTextField(_emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            _buildTextField(
              _senhaController,
              'Senha',
              obscure: !_showSenha,
              suffixIcon: IconButton(
                icon: Icon(
                  _showSenha ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () =>
                    setState(() => _showSenha = !_showSenha),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(
                child:
                CircularProgressIndicator(color: Colors.orange))
                : ElevatedButton(
              onPressed: _cadastrarProfessor,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Cadastrar",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (_mensagem != null) ...[
              const SizedBox(height: 20),
              Text(
                _mensagem!,
                style: TextStyle(
                  color: _erro ? Colors.redAccent : Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscure = false,
        TextInputType? keyboardType,
        Widget? suffixIcon,
      }) {
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
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
