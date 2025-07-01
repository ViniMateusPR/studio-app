import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'package:intl/intl.dart';

class TreinoTile extends StatelessWidget {
  final Map<String, dynamic> treino;
  const TreinoTile({ super.key, required this.treino });

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.parse(treino['data']);
    final vencido = DateTime.now().difference(dt).inDays > 40;
    return ListTile(
      tileColor: vencido ? AppColors.error.withOpacity(0.2) : null,
      title: Text(
        treino['descricao'],
        style: TextStyle(color: vencido? AppColors.error: AppColors.onSurface),
      ),
      subtitle: Text(
        DateFormat('dd/MM/yyyy').format(dt),
        style: TextStyle(color: vencido? AppColors.error: AppColors.onSurfaceLight),
      ),
      // aqui você pode extrair ícones de editar / deletar em outro widget
    );
  }
}
