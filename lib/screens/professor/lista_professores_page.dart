import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ListaProfessoresPage extends StatefulWidget {
  const ListaProfessoresPage({Key? key}) : super(key: key);

  @override
  _ListaProfessoresPageState createState() => _ListaProfessoresPageState();
}

class _ListaProfessoresPageState extends State<ListaProfessoresPage> {
  List<dynamic> professores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarProfessores();
  }

  Future<void> carregarProfessores() async {
    final resultado = await ApiService.getProfessores();
    setState(() {
      professores = resultado;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Professores Cadastrados")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: professores.length,
        itemBuilder: (context, index) {
          final professor = professores[index];
          return ListTile(
            title: Text(professor['nome']),
            subtitle: Text("CPF: ${professor['cpf']} - Email: ${professor['email']}"),
          );
        },
      ),
    );
  }
}
