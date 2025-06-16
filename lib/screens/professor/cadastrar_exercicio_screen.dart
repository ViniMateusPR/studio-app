import 'package:flutter/material.dart';
import 'package:studio_app/services/api_service.dart';

import '../home/home_professor_screen.dart';

class CadastrarExercicioScreen extends StatefulWidget {
  const CadastrarExercicioScreen({super.key});

  @override
  State<CadastrarExercicioScreen> createState() => _CadastrarExercicioScreenState();
}

class _CadastrarExercicioScreenState extends State<CadastrarExercicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  String? _grupoSelecionado;
  List<String> _gruposMusculares = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _buscarGruposMusculares();
  }

  Future<void> _buscarGruposMusculares() async {
    try {
      final response = await ApiService.getExercicios();
      final grupos = response
          .map<String>((e) => e['grupoMuscular'].toString())
          .toSet()
          .toList()
        ..sort();
      setState(() {
        _gruposMusculares = grupos;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao buscar grupos musculares: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _salvarExercicio() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ApiService.post(
          '/exercicios/cadastrar',
          body: {
            "nome": _nomeController.text,
            "grupoMuscular": _grupoSelecionado,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercício cadastrado com sucesso!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeProfessorScreen()));
      } catch (e) {
        print("Erro ao salvar exercício: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar exercício: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B00),
        title: const Text('Cadastrar Exercício'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HomeProfessorScreen())),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 16),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.grey[900],
                  inputDecorationTheme: const InputDecorationTheme(
                    border: OutlineInputBorder(),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _grupoSelecionado,
                  isExpanded: true,
                  iconEnabledColor: Colors.white,
                  dropdownColor: Colors.grey[900],
                  decoration: const InputDecoration(
                    labelText: 'Grupo Muscular',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(),
                  ),
                  items: _gruposMusculares
                      .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g, style: const TextStyle(color: Colors.white)),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _grupoSelecionado = value),
                  validator: (value) => value == null ? "Selecione um grupo" : null,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvarExercicio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save, color: Colors.white,),
                label: const Text("Salvar Exercício", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
