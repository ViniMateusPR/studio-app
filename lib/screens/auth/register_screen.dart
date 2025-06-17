import 'package:flutter/material.dart';
import 'package:studio_app/screens/home/home_empresa_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await AuthService().register(
      nome: _nomeCtrl.text.trim(),
      cnpj: _cnpjCtrl.text.trim(),
      senha: _senhaCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!ok) {
      setState(() => _error =
      'Não foi possível registrar. Tente outro CNPJ.');
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
    _nomeCtrl.dispose();
    _cnpjCtrl.dispose();
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
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Cadastro da Empresa',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Nome
                    TextFormField(
                      controller: _nomeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'Nome da empresa',
                        icon: Icons.business,
                      ),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),

                    // CNPJ
                    TextFormField(
                      controller: _cnpjCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _fieldDecoration(
                        hint: 'CNPJ',
                        icon: Icons.credit_card,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o CNPJ';
                        if (v.length < 14) return 'CNPJ incompleto';
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
                        if (v.length < 6) return 'Senha muito curta';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Erro
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    // Botão Registrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
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
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Registrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
      ),
    );
  }
}
