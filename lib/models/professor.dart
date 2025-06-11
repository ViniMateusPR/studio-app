class Professor {
  final String cpf;
  final String nome;
  final String email;
  final int? empresaId;

  Professor({
    required this.cpf,
    required this.nome,
    required this.email,
    required this.empresaId
  });

  factory Professor.fromJson(Map<String, dynamic>json) {
    return Professor(
        cpf: json['cpf'] ?? '',
        nome: json['nome'] ?? '',
        email: json['email'] ?? '',
      empresaId: json['empresaId'],
    );
  }
}
