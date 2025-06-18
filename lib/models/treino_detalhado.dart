class TreinoDetalhado {
  final int treinoId;
  final String descricao;
  final String data;
  final String alunoCpf;
  final String personalCpf;
  final List<TreinoExercicioDetalhado> exercicios;
  final String? alteradoPorNome;
  final String? criadoPorNome; // <-- adiciona isso

  TreinoDetalhado({
    required this.treinoId,
    required this.descricao,
    required this.data,
    required this.alunoCpf,
    required this.personalCpf,
    required this.exercicios,
    this.alteradoPorNome,
    this.criadoPorNome, // <-- adiciona isso
  });

  factory TreinoDetalhado.fromJson(Map<String, dynamic> json) {
    final List<dynamic> exList = json['exercicios'] ?? [];
    return TreinoDetalhado(
      treinoId: json['treinoId'] ?? json['id'],
      descricao: json['descricao'] ?? '',
      data: json['data'],
      alunoCpf: json['alunoCpf'] ?? '',
      personalCpf: json['personalCpf'] ?? '',
      alteradoPorNome: json['alteradoPorNome'],
      criadoPorNome: json['criadoPorNome'], // <-- adiciona isso
      exercicios: exList.map((e) => TreinoExercicioDetalhado.fromJson(e)).toList(),
    );
  }
}

class TreinoExercicioDetalhado {
  final int exercicioId;
  final String nomeExercicio;
  int ordem;
  int series;
  int repeticoes;
  String? observacao;
  int carga;

  TreinoExercicioDetalhado({
    required this.exercicioId,
    required this.nomeExercicio,
    required this.ordem,
    required this.series,
    required this.repeticoes,
    this.observacao,
    required this.carga,
  });

  factory TreinoExercicioDetalhado.fromJson(Map<String, dynamic> json) {
    return TreinoExercicioDetalhado(
      exercicioId: json['exercicioId'],
      nomeExercicio: json['nomeExercicio'] ?? '',
      ordem: json['ordem'],
      series: json['series'],
      repeticoes: json['repeticoes'],
      observacao: json['observacao'],
      carga: json['carga'],
    );
  }
}
