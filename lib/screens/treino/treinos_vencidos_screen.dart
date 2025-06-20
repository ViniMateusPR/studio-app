import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class TreinosVencidosScreen extends StatefulWidget {
  const TreinosVencidosScreen({super.key});

  @override
  State<TreinosVencidosScreen> createState() => _TreinosVencidosScreenState();
}

class _TreinosVencidosScreenState extends State<TreinosVencidosScreen> {
  late Future<List<dynamic>> futurosTreinos;

  @override
  void initState() {
    super.initState();
    futurosTreinos = ApiService.getTreinosVencidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Treinos Vencidos'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futurosTreinos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar dados',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          final treinos = snapshot.data ?? [];
          if (treinos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum treino vencido encontrado',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: treinos.length,
            itemBuilder: (context, index) {
              final treino = treinos[index];
              DateTime? dt;
              try {
                dt = DateTime.parse(treino['dataPlanejada']);
              } catch (_) {}
              final dataFormatada = dt != null
                  ? DateFormat('dd/MM/yyyy').format(dt)
                  : treino['dataPlanejada'];

              final expired = dt != null &&
                  DateTime.now().difference(dt).inDays > 40;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: expired
                      ? Border.all(color: Colors.red, width: 2)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professor: ${treino['professorNome']}',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aluno: ${treino['alunoNome']}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Treino: ${treino['treinoDescricao']}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Data Criação: $dataFormatada',
                      style: TextStyle(
                        color: expired ? Colors.red : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
