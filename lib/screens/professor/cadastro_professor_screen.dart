// lib/screens/professor/cadastro_professor_screen.dart

import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class CadastroProfessorScreen extends StatefulWidget {
  const CadastroProfessorScreen({super.key});

  @override
  State<CadastroProfessorScreen> createState() =>
      _CadastroProfessorScreenState();
}

class _CadastroProfessorScreenState extends State<CadastroProfessorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _isLoading = false;
  String? _mensagem;
  bool _erro = false;
  bool _showSenha = false;

  Future<void> _cadastrarProfessor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _mensagem = null;
    });

    try {
      final empresaId = await AuthService().getEmpresaId();
      final cpfProfessor = await AuthService().getCpfLogado();
      // monta o body do POST
      final body = {
        'nome': _nomeController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'email': _emailController.text.trim(),
        'senha': _senhaController.text,
        'empresaId': int.parse(empresaId!),
      };

      // usa o método genérico post do ApiService
      await ApiService.post(
        '/professores/cadastrarProfessor',
        body: body,
      );

      setState(() {
        _erro = false;
        _mensagem = 'Professor cadastrado com sucesso!';
      });

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _erro = true;
        _mensagem = 'Falha ao cadastrar: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: const Text('Cadastrar Professor'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Nome
                TextFormField(
                  controller: _nomeController,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // CPF
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'CPF'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'CPF obrigatório';
                    if (v.trim().length < 11) return 'CPF incompleto';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'E-mail obrigatório';
                    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!regex.hasMatch(v.trim())) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _senhaController,
                  obscureText: !_showSenha,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showSenha ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.onSurfaceLight,
                      ),
                      onPressed: () =>
                          setState(() => _showSenha = !_showSenha),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Senha obrigatória';
                    if (v.length < 6) return 'Mínimo de 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: _cadastrarProfessor,
                    child: const Text('Cadastrar'),
                  ),
                ),

                // Mensagem de retorno
                if (_mensagem != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _mensagem!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _erro ? AppColors.error : AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
