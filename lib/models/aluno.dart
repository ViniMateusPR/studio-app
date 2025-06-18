class Aluno {
  final int id;
  final String nome;
  final String email;
  final String? celular;
  final bool? ativo;
  final int? ultimoTreinoId;
  final int? empresaId;

  Aluno({
    required this.id,
    required this.nome,
    required this.celular,
    required this.email,
    required this.ativo,
    this.ultimoTreinoId,
    required this.empresaId,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'],
      celular: json['celular'],
      email: json['email'],
      ativo: json['ativo'],
      ultimoTreinoId: json['ultimoTreinoId'],
      empresaId: json['empresaId'],
    );
  }
}
