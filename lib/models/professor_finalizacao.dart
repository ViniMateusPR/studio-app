class ProfessorFinalizacao {
  final String nome;
  final String cpf;
  final int qtdFinalizacoesHoje;

  ProfessorFinalizacao({
    required this.nome,
    required this.cpf,
    required this.qtdFinalizacoesHoje,
  });

  factory ProfessorFinalizacao.fromJson(Map<String, dynamic> json) {
    return ProfessorFinalizacao(
      nome: json['nome'],
      cpf: json['cpf'],
      qtdFinalizacoesHoje: json['qtdFinalizacoesHoje'] ?? 0,
    );
  }
}
