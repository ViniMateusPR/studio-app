import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../home/home_professor_screen.dart';

class LoginProfessorScreen extends StatefulWidget {
  const LoginProfessorScreen({super.key});
  @override
  State<LoginProfessorScreen> createState() => _LoginProfessorScreenState();
}

class _LoginProfessorScreenState extends State<LoginProfessorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await AuthService().loginProfessor(
      cpf: _cpfCtrl.text.trim(),
      senha: _senhaCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = 'CPF ou senha inválidos.');
      return;
    }
    await ApiService.init();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeProfessorScreen()),
    );
  }

  @override
  void dispose() {
    _cpfCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login Professor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _cpfCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration('CPF', Icons.person),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o CPF';
                            if (v.length < 11) return 'CPF incompleto';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaCtrl,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _decoration('Senha', Icons.lock)
                              .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
                              ),
                              onPressed: () => setState(
                                      () => _showPassword = !_showPassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Informe a senha';
                            if (v.length < 6) return 'Senha muito curta';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B00),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _loading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                                : const Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Image.asset('assets/images/logo.png', height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
