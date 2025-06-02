import '../models/aluno.dart';

class AlunoController {
  static final List<Aluno> alunosSelecionados = [];

  static void adicionarAluno(Aluno aluno) {
    if (alunosSelecionados.length < 4 &&
        !alunosSelecionados.any((a) => a.id == aluno.id)) {
      alunosSelecionados.add(aluno);
    }
  }

  static void removerAluno(Aluno aluno) {
    alunosSelecionados.removeWhere((a) => a.id == aluno.id);
  }
}
