

class TreinoDetalhado {
  final int id;
  final String descricao;
  final String data;
  final String alunoCpf;
  final String personalCpf;
  final List<TreinoExercicioDetalhado> exercicios;

  TreinoDetalhado({
    required this.id,
    required this.descricao,
    required this.data,
    required this.alunoCpf,
    required this.personalCpf,
    required this.exercicios,
  });

  factory TreinoDetalhado.fromJson(Map<String, dynamic> json) {
    return TreinoDetalhado(
      id: json['id'] ?? json['treinoId'],
      descricao: json['descricao'],
      data: json['data'],
      alunoCpf: json['alunoCpf'],
      personalCpf: json['personalCpf'],
      exercicios: (json['exercicios'] as List<dynamic>)
          .map((e) => TreinoExercicioDetalhado.fromJson(e))
          .toList(),
    );
  }

}

class TreinoExercicioDetalhado {
  final int exercicioId;
  final String nomeExercicio;
  final int ordem;
  final int series;
  final int repeticoes;
  final String? observacao;
  final int carga;

  TreinoExercicioDetalhado({
    required this.exercicioId,
    required this.nomeExercicio,
    required this.ordem,
    required this.series,
    required this.repeticoes,
    this.observacao,
    required this.carga
  });

  factory TreinoExercicioDetalhado.fromJson(Map<String, dynamic> json) {
    return TreinoExercicioDetalhado(
      exercicioId: json['exercicioId'] ?? 0,
      nomeExercicio: json['nomeExercicio'] ?? '',
      ordem: json['ordem'] ?? 0,
      series: json['series'] ?? 0,
      repeticoes: json['repeticoes'] ?? 0,
      observacao: json['observacao'],
      carga: json['carga'],
    );
  }


}
