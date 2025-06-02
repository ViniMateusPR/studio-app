import '../screens/treino/treino.dart';

final List<Treino> treinoData = [
  // Pernas - grupo A
  Treino(nomeExercicio: "Agachamento", series: 4, repeticoes: 12, grupo: 'A'),
  Treino(nomeExercicio: "Leg Press", series: 4, repeticoes: 10, grupo: 'A'),
  Treino(nomeExercicio: "Cadeira Extensora", series: 3, repeticoes: 15, grupo: 'A'),
  Treino(nomeExercicio: "Cadeira Flexora", series: 3, repeticoes: 15, grupo: 'A'),
  Treino(nomeExercicio: "Panturrilha em Pé", series: 4, repeticoes: 20, grupo: 'A'),

  // Peito - grupo B
  Treino(nomeExercicio: "Supino Reto", series: 4, repeticoes: 10, grupo: 'B'),
  Treino(nomeExercicio: "Supino Inclinado", series: 3, repeticoes: 12, grupo: 'B'),
  Treino(nomeExercicio: "Crucifixo", series: 3, repeticoes: 15, grupo: 'B'),
  Treino(nomeExercicio: "Peck Deck", series: 3, repeticoes: 12, grupo: 'B'),
  Treino(nomeExercicio: "Flexão de Braço", series: 3, repeticoes: 20, grupo: 'B'),

  // Costas - grupo C
  Treino(nomeExercicio: "Puxada na Barra Fixa", series: 3, repeticoes: 8, grupo: 'C'),
  Treino(nomeExercicio: "Remada Curvada", series: 4, repeticoes: 10, grupo: 'C'),
  Treino(nomeExercicio: "Remada Máquina", series: 3, repeticoes: 12, grupo: 'C'),
  Treino(nomeExercicio: "Levantamento Terra", series: 3, repeticoes: 8, grupo: 'C'),
  Treino(nomeExercicio: "Pullover", series: 3, repeticoes: 15, grupo: 'C'),

  // Ombros - grupo D
  Treino(nomeExercicio: "Elevação Lateral", series: 3, repeticoes: 15, grupo: 'D'),
  Treino(nomeExercicio: "Desenvolvimento com Halteres", series: 4, repeticoes: 12, grupo: 'D'),
  Treino(nomeExercicio: "Elevação Frontal", series: 3, repeticoes: 15, grupo: 'D'),
  Treino(nomeExercicio: "Remada Alta", series: 3, repeticoes: 12, grupo: 'D'),
  Treino(nomeExercicio: "Encolhimento de Ombros", series: 4, repeticoes: 15, grupo: 'D'),

  // Braços - grupo E
  Treino(nomeExercicio: "Rosca Direta", series: 3, repeticoes: 12, grupo: 'E'),
  Treino(nomeExercicio: "Rosca Martelo", series: 3, repeticoes: 12, grupo: 'E'),
  Treino(nomeExercicio: "Tríceps Testa", series: 3, repeticoes: 15, grupo: 'E'),
  Treino(nomeExercicio: "Tríceps Pulley", series: 3, repeticoes: 12, grupo: 'E'),
  Treino(nomeExercicio: "Mergulho no Banco", series: 3, repeticoes: 15, grupo: 'E'),

  // Abdômen - grupo F
  Treino(nomeExercicio: "Abdominal Supra", series: 3, repeticoes: 20, grupo: 'F'),
  Treino(nomeExercicio: "Abdominal Infra", series: 3, repeticoes: 20, grupo: 'F'),
  Treino(nomeExercicio: "Prancha", series: 3, repeticoes: 30, grupo: 'F'), // segundos
  Treino(nomeExercicio: "Abdominal Oblíquo", series: 3, repeticoes: 20, grupo: 'F'),
  Treino(nomeExercicio: "Elevação de Pernas", series: 3, repeticoes: 20, grupo: 'F'),
];
