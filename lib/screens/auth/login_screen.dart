// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:studio_app/screens/auth/register_screen.dart';
import 'package:studio_app/screens/auth/login_professor_screen.dart';
import 'package:studio_app/screens/home/home_empresa_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cnpjCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await AuthService().login(
      cnpj: _cnpjCtrl.text.trim(),
      senha: _senhaCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = 'CNPJ ou senha inválidos.');
      return;
    }
    await ApiService.init();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeEmpresaScreen()),
    );
  }

  @override
  void dispose() {
    _cnpjCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Bem-vindo!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _cnpjCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      hint: 'CNPJ',
                      icon: Icons.business,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o CNPJ';
                      if (v.length < 14) return 'CNPJ incompleto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaCtrl,
                    obscureText: !_showPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      hint: 'Senha',
                      icon: Icons.lock,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 4) return 'Senha muito curta';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Registrar sua empresa', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginProfessorScreen())),
                    child: const Text('Login Professor', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                  const SizedBox(height: 40),
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.white70),
    );
  }
}
