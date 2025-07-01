import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/api_service.dart';
import '../../app_theme.dart';

class EditarFichaScreen extends StatefulWidget {
  final Map<String, dynamic> ficha;
  final Aluno aluno;
  const EditarFichaScreen({
    super.key,
    required this.ficha,
    required this.aluno,
  });

  @override
  State<EditarFichaScreen> createState() => _EditarFichaScreenState();
}

class _EditarFichaScreenState extends State<EditarFichaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descricaoController;
  late final TextEditingController _objetivoController;
  late final TextEditingController _observacaoController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _descricaoController =
        TextEditingController(text: widget.ficha['descricao'] ?? '');
    _objetivoController =
        TextEditingController(text: widget.ficha['objetivo'] ?? '');
    _observacaoController =
        TextEditingController(text: widget.ficha['observacao'] ?? '');
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _objetivoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await ApiService.editarFicha(
        widget.ficha['id'],
        _descricaoController.text.trim(),
        _objetivoController.text.trim(),
        _observacaoController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ficha atualizada com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar ficha: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Editar Ficha'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Descrição
                      TextFormField(
                        controller: _descricaoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Descrição da ficha',
                          hintText: 'Ex: Força de Pernas',
                          prefixIcon:
                          const Icon(Icons.description, color: Colors.white70),
                          filled: true,
                          fillColor: AppColors.primary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: AppColors.accent, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Objetivo
                      TextFormField(
                        controller: _objetivoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Objetivo',
                          hintText: 'Ex: Hipertrofia',
                          prefixIcon:
                          const Icon(Icons.flag, color: Colors.white70),
                          filled: true,
                          fillColor: AppColors.primary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: AppColors.accent, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Observação
                      TextFormField(
                        controller: _observacaoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Restrições',
                          hintText: 'Anotações ou dicas internas',
                          prefixIcon:
                          const Icon(Icons.note, color: Colors.white70),
                          filled: true,
                          fillColor: AppColors.primary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: AppColors.accent, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),

                      // Botões em linha
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.accent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _loading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text('Salvar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _loading ? null : _salvar,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_loading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accent)),
              ),
            ),
        ],
      ),
    );
  }
}
