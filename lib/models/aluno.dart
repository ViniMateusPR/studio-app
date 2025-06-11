class Aluno {
  final String cpf;
  final String nome;
  final String email;
  final String? celular;
  final bool? ativo;
  final int? empresaId;

  Aluno({
    required this.cpf,
    required this.nome,
    required this.email,
    this.celular,
    this.ativo,
    this.empresaId,
  });

  // ✅ Adicione este método:
  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      cpf: json['cpf'] ?? '',
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      celular: json['celular'],
      ativo: json['ativo'],
      empresaId: json['empresaId'],
    );
  }
}
