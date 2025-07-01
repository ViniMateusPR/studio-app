import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studio_app/services/api_service.dart'; // ajuste seu import

class CriarPostScreen extends StatefulWidget {
  const CriarPostScreen({Key? key}) : super(key: key);

  @override
  _CriarPostScreenState createState() => _CriarPostScreenState();
}

class _CriarPostScreenState extends State<CriarPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  bool _enviando = false;
  XFile? _imagem;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imagem = picked);
    }
  }

  Future<void> _enviarPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma imagem.')),
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      // converte a imagem para Base64
      final bytes = await File(_imagem!.path).readAsBytes();
      final base64Img = base64Encode(bytes);

      // chama seu ApiService
      await ApiService.criarPost(
        empresaId: ApiService.empresaId,
        titulo: _tituloController.text.trim(),
        conteudoBase64: base64Img,
      );

      Navigator.of(context).pop(); // volta após sucesso
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar: $e')),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _escolherImagem,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imagem == null
                      ? const Center(child: Text('Toque para selecionar imagem'))
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imagem!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _enviando ? null : _enviarPost,
                icon: _enviando
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                label: Text(_enviando ? 'Enviando...' : 'Publicar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
