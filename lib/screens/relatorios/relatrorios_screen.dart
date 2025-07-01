import 'package:flutter/material.dart';
import 'package:studio_app/services/api_service.dart';
import '../../app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  List<dynamic> _alunos = [];
  List<dynamic> _profs = [];

  bool _showAtivos = true, _showInativos = true;
  bool _showMasc = true, _showFem = true;

  static const List<_AgeBracket> _brackets = [
    _AgeBracket('5-8', 5, 8),
    _AgeBracket('9-12', 9, 12),
    _AgeBracket('13-20', 13, 20),
    _AgeBracket('21-30', 21, 30),
    _AgeBracket('31-40', 31, 40),
    _AgeBracket('41-50', 41, 50),
    _AgeBracket('50+', 51, 150),
  ];

  int _calcAge(String iso) {
    final dob = DateTime.tryParse(iso);
    if (dob == null) return 0;
    final today = DateTime.now();
    var age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  List<List<int>> get _ageDist {
    final masc = List<int>.filled(_brackets.length, 0);
    final fem = List<int>.filled(_brackets.length, 0);
    for (var a in _alunos) {
      if (a['ativo'] != true) continue;
      final dob = a['dataNascimento'] as String?;
      if (dob == null) continue;
      final age = _calcAge(dob);
      for (var i = 0; i < _brackets.length; i++) {
        if (_brackets[i].inBracket(age)) {
          final sx = (a['sexo'] ?? '').toString().toLowerCase();
          if (sx == 'masculino') masc[i]++;
          if (sx == 'feminino') fem[i]++;
        }
      }
    }
    return [masc, fem];
  }

  int get _ativosCount => _alunos.where((a) => a['ativo'] == true).length;
  int get _inativosCount => _alunos.where((a) => a['ativo'] == false).length;
  int get _mascCount => _alunos.where((a) => a['ativo'] == true && (a['sexo'] ?? '').toLowerCase() == 'masculino').length;
  int get _femCount => _alunos.where((a) => a['ativo'] == true && (a['sexo'] ?? '').toLowerCase() == 'feminino').length;

  List<dynamic> get _aniversHoje {
    final hoje = DateTime.now();
    return _alunos.where((a) {
      if (a['ativo'] != true) return false;
      final dn = a['dataNascimento'] as String?;
      if (dn == null) return false;
      final dt = DateTime.tryParse(dn);
      return dt != null && dt.month == hoje.month && dt.day == hoje.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _alunos = await ApiService.listarAlunos();
    _profs = await ApiService.getProfessoresComFinalizacoes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dist = _ageDist;
    final masc = dist[0].map((e) => e.toDouble()).toList();
    final fem = dist[1].map((e) => e.toDouble()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTitle('Distribuição por Faixa Etária'),
          _buildAgeChart(masc, fem),
          const SizedBox(height: 16),
          _buildTitle('Distribuição por Sexo'),
          _buildPieWithLegend(
            title: 'Sexo',
            sections: _makeSections(_showMasc, _showFem, _mascCount, _femCount,
                Colors.blue, Colors.pink, 'Masc.', 'Fem.'),
            labels: ['Masc.', 'Fem.'],
            colors: [Colors.blue, Colors.pink],
            toggles: [_showMasc, _showFem],
            onToggle: (i) => setState(() => i == 0 ? _showMasc = !_showMasc : _showFem = !_showFem),
          ),
          const SizedBox(height: 16),
          _buildTitle('Clientes'),
          _buildPieWithLegend(
            title: 'Ativos/Inativos',
            sections: _makeSections(_showAtivos, _showInativos, _ativosCount,
                _inativosCount, Colors.green, Colors.red, 'Ativos', 'Inativos'),
            labels: ['Ativos', 'Inativos'],
            colors: [Colors.green, Colors.red],
            toggles: [_showAtivos, _showInativos],
            onToggle: (i) => setState(() => i == 0 ? _showAtivos = !_showAtivos : _showInativos = !_showInativos),
          ),
          const SizedBox(height: 16),
          _buildTitle('Aniversariantes de Hoje'),
          _buildBirthdayList(),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) => Text(
    title,
    style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
  );

  Widget _buildAgeChart(List<double> masc, List<double> fem) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(_brackets.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: masc[i], color: Colors.blue, width: 8),
                BarChartRodData(toY: fem[i], color: Colors.pink, width: 8),
              ],
              barsSpace: 4,
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= _brackets.length) return const SizedBox.shrink();
                  return Text(_brackets[i].label, style: AppTextStyles.bodyMedium);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  List<PieChartSectionData> _makeSections(
      bool s1,
      bool s2,
      int c1,
      int c2,
      Color col1,
      Color col2,
      String t1,
      String t2,
      ) {
    return [
      PieChartSectionData(
        value: s1 ? c1.toDouble() : 0,
        color: col1,
        title: '$t1\n$c1',
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      PieChartSectionData(
        value: s2 ? c2.toDouble() : 0,
        color: col2,
        title: '$t2\n$c2',
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    ];
  }

  Widget _buildPieWithLegend({
    required String title,
    required List<PieChartSectionData> sections,
    required List<String> labels,
    required List<Color> colors,
    required List<bool> toggles,
    required void Function(int) onToggle,
  }) {
    return Card(
      color: AppColors.surface,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(
              labels.length,
                  (i) => FilterChip(
                label: Text(
                  labels[i],
                  style: TextStyle(color: toggles[i] ? Colors.white : Colors.black54),
                ),
                selected: toggles[i],
                selectedColor: colors[i],
                backgroundColor: AppColors.surface,
                onSelected: (_) => onToggle(i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdayList() {
    if (_aniversHoje.isEmpty) {
      return const Text('Nenhum aniversariante hoje.');
    }
    return Column(
      children: _aniversHoje.map((a) {
        final nome = (a['nome'] as String).split(' ').take(2).join(' ');
        final data = a['dataNascimento'];
        final fmt = DateFormat('dd/MM').format(DateTime.parse(data));
        return ListTile(
          leading: const Icon(Icons.cake, color: Colors.orange),
          title: Text(nome),
          subtitle: Text('Data: $fmt'),
        );
      }).toList(),
    );
  }
}

class _AgeBracket {
  final String label;
  final int min, max;
  const _AgeBracket(this.label, this.min, this.max);
  bool inBracket(int age) => age >= min && age <= max;
}
