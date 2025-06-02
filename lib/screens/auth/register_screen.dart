// lib/screens/register/register_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart'; // <-- import necessário
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _senhaController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await _authService.register(
      nome: _nomeController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      senha: _senhaController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      await ApiService.init(); // <-- carrega token e empresaId
      print('empresaId após cadastro: ${ApiService.empresaId}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _error = "Erro ao registrar empresa. Tente outro CNPJ.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Empresa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da empresa'),
            ),
            TextField(
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CNPJ'),
            ),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _register,
              child: const Text("Registrar"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
