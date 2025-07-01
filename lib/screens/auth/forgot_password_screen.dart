import 'package:flutter/material.dart';
import 'package:studio_app/screens/auth/reset_password_screen.dart';

import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _loading = true; });

    // Chamada para API que vai enviar o e-mail com o código (implementação da API necessária)
    final success = await AuthService().requestPasswordReset(_cpfCtrl.text.trim());

    setState(() { _loading = false; });

    if (success) {
      // Redirecionar para a próxima tela (onde o usuário vai inserir o token)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(cpf: _cpfCtrl.text.trim())),
      );
    } else {
      // Exibir erro, caso o CPF não seja encontrado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CPF não encontrado ou erro ao enviar o e-mail.')),
      );
    }
  }

  @override
  void dispose() {
    _cpfCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Esqueceu sua senha?")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cpfCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Digite seu CPF',
                  hintText: 'CPF',
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe seu CPF';
                  if (v.length != 11) return 'CPF inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _sendResetLink,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Enviar Código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
