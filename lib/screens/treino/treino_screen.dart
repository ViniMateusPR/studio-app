import 'package:flutter/material.dart';
import 'package:studio_app/models/aluno.dart';
import 'package:studio_app/screens/treino/treino.dart';

class TreinoScreen extends StatefulWidget {
  final List<Treino> treinos;

  const TreinoScreen({Key? key, required this.treinos, required Aluno aluno}) : super(key: key);

  @override
  _TreinoScreenState createState() => _TreinoScreenState();
}

class _TreinoScreenState extends State<TreinoScreen> {
  late Map<String, List<Treino>> treinosPorGrupo;
  late List<String> grupos;

  @override
  void initState() {
    super.initState();

    treinosPorGrupo = {};
    for (var treino in widget.treinos) {
      treinosPorGrupo.putIfAbsent(treino.grupo, () => []).add(treino);
    }
    grupos = treinosPorGrupo.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Se não houver grupos (lista vazia), mostramos uma tela simples
    if (grupos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Treinos'),
        ),
        body: const Center(
          child: Text('Nenhum treino disponível'),
        ),
      );
    }

    return DefaultTabController(
      length: grupos.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Treinos'),
          bottom: TabBar(
            isScrollable: true,
            tabs: grupos.map((g) => Tab(text: 'Treino $g')).toList(),
          ),
        ),
        body: TabBarView(
          children: grupos.map((grupo) {
            final lista = treinosPorGrupo[grupo]!;
            return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final treino = lista[index];
                return ListTile(
                  title: Text(treino.nomeExercicio),
                  subtitle: Text('${treino.series} séries x ${treino.repeticoes} repetições'),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
