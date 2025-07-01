import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/montar_treino_provider.dart';
import 'number_field.dart';

class ExercicioTile extends StatelessWidget {
  final Map<String, dynamic> ex;
  const ExercicioTile({ super.key, required this.ex });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MontarTreinoProvider>();
    final selected = prov.exerciciosSelecionados.any((e)=> e['exercicioId']==ex['id']);
    return Column(
      children: [
        CheckboxListTile(
          title: Text(ex['nome'], style: const TextStyle(color: AppColors.onSurface)),
          value: selected,
          activeColor: AppColors.accent,
          onChanged: (_) => prov.toggleExercicio(ex),
        ),
        // animação suave na expansão dos campos
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: selected
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                NumberField(label: 'Ordem', model: prov.exerciciosSelecionados.firstWhere((e)=>e['exercicioId']==ex['id']), keyName: 'ordem'),
                const SizedBox(height: 8),
                NumberField(label: 'Séries', model: prov.exerciciosSelecionados.firstWhere((e)=>e['exercicioId']==ex['id']), keyName: 'series'),
                const SizedBox(height: 8),
                NumberField(label: 'Repetições', model: prov.exerciciosSelecionados.firstWhere((e)=>e['exercicioId']==ex['id']), keyName: 'repeticoes'),
                const SizedBox(height: 8),
                NumberField(label: 'Carga (kg)', model: prov.exerciciosSelecionados.firstWhere((e)=>e['exercicioId']==ex['id']), keyName: 'carga'),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Observação'),
                  onChanged: (v) {
                    final eMod = prov.exerciciosSelecionados.firstWhere((e)=>e['exercicioId']==ex['id']);
                    eMod['observacao'] = v;
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
