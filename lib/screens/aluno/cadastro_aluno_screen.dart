// lib/screens/aluno/cadastro_aluno_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../services/cadastro_service.dart';

class CadastroAlunoScreen extends StatefulWidget {
  final int empresaId;
  const CadastroAlunoScreen({Key? key, required this.empresaId}) : super(key: key);

  @override
  State<CadastroAlunoScreen> createState() => _CadastroAlunoScreenState();
}

class _CadastroAlunoScreenState extends State<CadastroAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cpfCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  String? _sexo;
  DateTime? _dataNascimento;

  bool _showSenha = false;
  bool _isLoading = false;
  String? _mensagem;
  bool _erro = false;

  @override
  void dispose() {
    _cpfCtrl.dispose();
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _celularCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final hoje = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: hoje.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (dt != null) {
      setState(() => _dataNascimento = dt);
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sexo == null) {
      setState(() => _mensagem = 'Selecione o sexo.');
      return;
    }
    if (_dataNascimento == null) {
      setState(() => _mensagem = 'Informe a data de nascimento.');
      return;
    }

    setState(() {
      _isLoading = true;
      _mensagem = null;
    });

    final sucesso = await CadastroService().cadastrarAluno(
      cpf: _cpfCtrl.text.trim(),
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      celular: _celularCtrl.text.trim(),
      senha: _senhaCtrl.text.trim(),
      empresaId: widget.empresaId,
      sexo: _sexo!,
      dataNascimento: DateFormat('yyyy-MM-dd').format(_dataNascimento!),
    );

    setState(() {
      _isLoading = false;
      _erro = !sucesso;
      _mensagem = sucesso
          ? 'Aluno cadastrado com sucesso!'
          : 'Erro ao cadastrar aluno.';
    });

    if (sucesso) {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: const Text('Cadastro de Aluno'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // CPF
                TextFormField(
                  controller: _cpfCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'CPF'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'CPF obrigatório';
                    if (v.trim().length < 11) return 'CPF incompleto';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nome
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nome obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'E-mail obrigatório';
                    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!regex.hasMatch(v.trim())) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Celular
                TextFormField(
                  controller: _celularCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Celular'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Celular obrigatório';
                    if (v.trim().length < 8) return 'Número inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sexo
                DropdownButtonFormField<String>(
                  value: _sexo,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                  ],
                  onChanged: (v) => setState(() => _sexo = v),
                  validator: (v) => v == null ? 'Selecione o sexo' : null,
                ),
                const SizedBox(height: 16),

                // Data de Nascimento
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Data de Nascimento',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ),
                  controller: TextEditingController(
                    text: _dataNascimento == null
                        ? ''
                        : DateFormat('dd/MM/yyyy').format(_dataNascimento!),
                  ),
                  validator: (_) =>
                  _dataNascimento == null ? 'Informe a data de nascimento' : null,
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _senhaCtrl,
                  obscureText: !_showSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showSenha ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.onSurfaceLight,
                      ),
                      onPressed: () => setState(() => _showSenha = !_showSenha),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Senha obrigatória';
                    if (v.length < 6) return 'Mínimo de 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Botão Cadastrar
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                      : ElevatedButton(
                    onPressed: _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Cadastrar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

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
