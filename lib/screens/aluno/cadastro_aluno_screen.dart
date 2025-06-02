import 'package:flutter/material.dart';
import '../../services/cadastro_service.dart';

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

  void _cadastrar() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // preto igual ao login
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
            _buildTextField(_cpfController, 'CPF'),
            _buildTextField(_nomeController, 'Nome'),
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_celularController, 'Celular'),
            _buildTextField(_senhaController, 'Senha', obscure: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cadastrar,
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
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
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
