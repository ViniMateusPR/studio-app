class Exercicio {
  final int id;
  final String nome;
  final String grupoMuscular;

  Exercicio({
    required this.id,
    required this.nome,
    required this.grupoMuscular,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      id: json['id'],
      nome: json['nome'],
      grupoMuscular: json['grupoMuscular'],
    );
  }
}
