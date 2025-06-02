import '../screens/treino/treino.dart';

class Aluno {
  final int id;
  final String nome;
  final List<Treino> treinos;

  Aluno({required this.id, required this.nome, required this.treinos});
}
