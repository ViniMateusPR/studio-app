import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../aluno/cadastro_aluno_screen.dart';
import '../professor/cadastro_professor_screen.dart';
import '../aluno/lista_alunos_screen.dart';
import '../treino/treinos_vencidos_screen.dart';

class HomeEmpresaScreen extends StatefulWidget {
  const HomeEmpresaScreen({super.key});

  @override
  State<HomeEmpresaScreen> createState() => _HomeEmpresaScreenState();
}

class _HomeEmpresaScreenState extends State<HomeEmpresaScreen> {
  List<dynamic> professores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);
    try {
      final dados = await ApiService.getProfessoresComFinalizacoes();
      setState(() {
        professores = dados;
      });
    } catch (e) {
      debugPrint('Erro ao carregar professores: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _mostrarAlunosDoProfessor(String nome, String professorCpf) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Alunos de $nome', style: const TextStyle(color: Colors.orange)),
        content: FutureBuilder<List<dynamic>>(
          future: ApiService.getAlunosFinalizadosPorProfessor(professorCpf),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Text('Erro ao carregar alunos', style: TextStyle(color: Colors.red));
            }
            final alunos = snapshot.data ?? [];
            if (alunos.isEmpty) {
              return const Text('Nenhum aluno finalizou treino hoje',
                  style: TextStyle(color: Colors.white70));
            }
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alunos.length,
                itemBuilder: (context, index) {
                  final aluno = alunos[index];
                  return ListTile(
                    title: Text(
                      aluno['nome'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.orange)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF121212),
          child: SafeArea(
            child: Column(
              children: [
                const DrawerHeader(
                  child: Center(
                    child: Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.person_add,
                  text: 'Cadastrar Aluno',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CadastroAlunoScreen(empresaId: ApiService.empresaId),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  text: 'Cadastrar Professor',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroProfessorScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.list,
                  text: 'Mostrar Lista de Alunos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ListaAlunosScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.warning,
                  text: 'Treinos Vencidos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TreinosVencidosScreen(),
                      ),
                    );
                  },
                ),

                const Spacer(),
                const Divider(thickness: 1, color: Color(0xFFFF6B00)),
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: () => _logout(context),
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
      body: carregando
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
      )
          : RefreshIndicator(
        onRefresh: _carregarDados,
        color: const Color(0xFFFF6B00),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Professores',
              style: TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...professores.map((prof) {
              final nome = prof['nome'] ?? '';
              final cpf = (prof['cpf'] ?? prof['id']).toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _mostrarAlunosDoProfessor(nome, cpf),
                        child: Text(
                          nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${prof['qtdFinalizacoesHoje'] ?? 0} treinos',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFFFF6B00),
    Color textColor = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        text,
        style: TextStyle(color: textColor),
      ),
      onTap: onTap,
    );
  }
}
