// lib/screens/auth/login_professor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../home/home_professor_screen.dart';
import 'forgot_password_screen.dart';

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

  // máscara de CPF: 000.000.000-00
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: { "#": RegExp(r'\d') },
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await AuthService().loginProfessor(
      cpf: _cpfFormatter.getUnmaskedText(),
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      prefixIcon: Icon(icon, color: Colors.white60),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  // Título
                  Text(
                    'Login Professor',
                    style: theme.textTheme.titleLarge!
                        .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // CPF
                        TextFormField(
                          controller: _cpfCtrl,
                          inputFormatters: [_cpfFormatter],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            hint: 'CPF',
                            icon: Icons.person,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o CPF';
                            if (_cpfFormatter.getUnmaskedText().length != 11)
                              return 'CPF incompleto';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Senha
                        TextFormField(
                          controller: _senhaCtrl,
                          obscureText: !_showPassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: _fieldDecoration(
                            hint: 'Senha',
                            icon: Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.white60,
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

                        // Mensagem de erro
                        if (_error != null) ...[
                          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                          const SizedBox(height: 16),
                        ],

                        // Botão Entrar
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),// "Esqueceu sua senha?" link
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen())),
                    child: const Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),


                  const SizedBox(height: 40),
                  // Logo inferior
                  Image.asset('assets/images/logo.png', height: 130),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
