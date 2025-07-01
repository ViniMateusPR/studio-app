class Aluno {
  final int id;
  final String nome;
  final String? email;
  final String? celular;
  final bool ativo;
  final int? ultimoTreinoId;
  final int empresaId;
  final DateTime? dataNascimento;
  final String? sexo;

  Aluno({
    required this.id,
    required this.nome,
    this.email,
    this.celular,
    this.ativo = true,
    this.ultimoTreinoId,
    required this.empresaId,
    this.dataNascimento,
    this.sexo,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String?,              // agora opcional
      celular: json['celular'] as String?,          // agora opcional
      ativo: (json['ativo'] as bool?) ?? true,
      ultimoTreinoId: json['ultimoTreinoId'] as int?,
      empresaId: json['empresaId'] as int,
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.tryParse(json['dataNascimento'] as String)
          : null,                                     // agora opcional
      sexo: json['sexo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'celular': celular,
    'ativo': ativo,
    'ultimoTreinoId': ultimoTreinoId,
    'empresaId': empresaId,
    'dataNascimento': dataNascimento?.toIso8601String(),
    'sexo': sexo,
  };
}
