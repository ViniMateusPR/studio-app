import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_professor_screen.dart';  // Importe a tela de login do professor

class ResetPasswordScreen extends StatefulWidget {
  final String cpf;
  const ResetPasswordScreen({super.key, required this.cpf});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; });

    // Chamada para API que vai processar a redefinição de senha
    final success = await AuthService().resetPassword(
      cpf: widget.cpf,
      token: _tokenCtrl.text.trim(),
      novaSenha: _novaSenhaCtrl.text.trim(),
    );

    setState(() { _loading = false; });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha redefinida com sucesso!')),
      );
      // Redireciona para a tela de Login do Professor
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginProfessorScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao redefinir a senha.')),
      );
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _novaSenhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Redefinir Senha")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tokenCtrl,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Digite o código de 5 dígitos',
                  hintText: 'Código',
                  prefixIcon: const Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o código';
                  if (v.length != 5) return 'Código inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _novaSenhaCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  hintText: 'Nova Senha',
                  prefixIcon: const Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a nova senha';
                  if (v.length < 4) return 'Senha muito curta';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _resetPassword,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Redefinir Senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
