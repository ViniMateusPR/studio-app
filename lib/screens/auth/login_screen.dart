// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:studio_app/screens/auth/register_screen.dart';
import 'package:studio_app/screens/auth/login_professor_screen.dart';
import 'package:studio_app/screens/home/home_empresa_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import 'forgot_password_screen.dart';

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

  // Máscara de CNPJ (##.###.###/####-##)
  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: { "#": RegExp(r'\d') },
  );

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final ok = await AuthService().login(
      cnpj: _cnpjFormatter.getUnmaskedText(),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
                    Image.asset('assets/images/logo.png', height: 150),
                    const SizedBox(height: 20),
                    // CNPJ
                    TextFormField(
                      controller: _cnpjCtrl,
                      inputFormatters: [_cnpjFormatter],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildDecoration(
                        hint: 'CNPJ',
                        icon: Icons.credit_card,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o CNPJ';
                        if (_cnpjFormatter.getUnmaskedText().length != 14)
                          return 'CNPJ incompleto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Senha
                    TextFormField(
                      controller: _senhaCtrl,
                      obscureText: !_showPassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildDecoration(
                        hint: 'Senha',
                        icon: Icons.lock,
                        suffix: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe a senha';
                        if (v.length < 4) return 'Senha muito curta';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Erro de login
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 16),
                    ],

                    // Botão Entrar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Entrar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Links de navegação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text(
                            'Registrar sua empresa',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const LoginProfessorScreen()),
                          ),
                          child: const Text(
                            'Login Professor',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
