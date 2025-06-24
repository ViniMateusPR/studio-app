import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import 'treino_tile.dart';

class FichaCard extends StatelessWidget {
  final Map<String, dynamic> ficha;
  final bool selecionada;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  const FichaCard({
    super.key,
    required this.ficha,
    required this.selecionada,
    required this.onSelect,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final treinos = List<Map<String, dynamic>>.from(ficha['treinos'] ?? []);
    final ultimo = treinos.isNotEmpty
        ? treinos.reduce((a, b) {
      final da = DateTime.parse(a['data']);
      final db = DateTime.parse(b['data']);
      return da.isAfter(db) ? a : b;
    })
        : null;
    final vencido = ultimo != null &&
        DateTime.now().difference(DateTime.parse(ultimo['data'])).inDays > 40;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: ExpansionTile(
          key: ValueKey(ficha['id']),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.library_books, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ficha['descricao'] ?? 'Ficha #${ficha['id']}',
                  style: AppTextStyles.titleLarge,
                ),
              ),
              if (selecionada)
                const Icon(Icons.check_circle, color: AppColors.accent),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Objetivo badge
              Chip(
                label: Text(
                  ficha['objetivo'] ?? '-',
                  style: TextStyle(color: AppColors.accent),
                ),
                backgroundColor: AppColors.accent.withOpacity(0.1),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 8),
              // Observação
              if ((ficha['observacao'] ?? '').toString().isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: AppColors.onSurfaceLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ficha['observacao'],
                        style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              // Último treino
              if (ultimo != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: AppColors.onSurfaceLight),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(ultimo['data'])),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        vencido ? 'Vencido' : 'Recente',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: vencido ? AppColors.error : Colors.green,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: AppColors.onSurface),
            onPressed: onEdit,
          ),
          onExpansionChanged: (expanded) {
            if (expanded) onSelect();
          },
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Novo treino
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fitness_center, color: Colors.white),
                label: const Text('Novo Treino', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: onSelect,
              ),
            ),
            const SizedBox(height: 12),
            // Lista de treinos
            if (treinos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhum treino nesta ficha.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceLight)),
              )
            else
              ...treinos.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TreinoTile(treino: t),
              )),
          ],
        ),
      ),
    );
  }
}
