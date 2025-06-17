// lib/screens/aluno/cadastro_aluno_screen.dart

import 'package:flutter/material.dart';
import 'package:studio_app/services/cadastro_service.dart';

class CadastroAlunoScreen extends StatefulWidget {
  final int empresaId;
  const CadastroAlunoScreen({super.key, required this.empresaId});

  @override
  State<CadastroAlunoScreen> createState() => _CadastroAlunoScreenState();
}

class _CadastroAlunoScreenState extends State<CadastroAlunoScreen> {
  final _cpfController = TextEditingController();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _service = CadastroService();

  String? _mensagem;
  bool _erro = false;
  bool _showSenha = false; // controla visibilidade

  Future<void> _cadastrar() async {
    final sucesso = await _service.cadastrarAluno(
      cpf: _cpfController.text.trim(),
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      celular: _celularController.text.trim(),
      senha: _senhaController.text.trim(),
      empresaId: widget.empresaId,
    );

    setState(() {
      _erro = !sucesso;
      _mensagem = sucesso
          ? "Aluno cadastrado com sucesso!"
          : "Erro ao cadastrar aluno.";
    });
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Cadastro de Aluno"),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_cpfController, 'CPF',
                keyboardType: TextInputType.number),
            _buildTextField(_nomeController, 'Nome'),
            _buildTextField(_emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            _buildTextField(_celularController, 'Celular',
                keyboardType: TextInputType.phone),
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
            ElevatedButton(
              onPressed: _cadastrar,
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
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
