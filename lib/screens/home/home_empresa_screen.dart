import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../aluno/cadastro_aluno_screen.dart';
import '../professor/cadastro_professor_screen.dart';
import '../aluno/lista_alunos_screen.dart';

class HomeEmpresaScreen extends StatelessWidget {
  const HomeEmpresaScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // fundo preto da tela de cadastro
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF1E1E1E), // appBar escura igual cadastro
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF121212), // fundo preto no drawer também
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
                        color: Color(0xFFFF6B00), // laranja da tela de cadastro
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
                  iconColor: const Color(0xFFFF6B00),
                  textColor: Colors.white,
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
                  iconColor: const Color(0xFFFF6B00),
                  textColor: Colors.white,
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
                  iconColor: const Color(0xFFFF6B00),
                  textColor: Colors.white,
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
      body: const Center(
        child: Text(
          'Bem-vindo à Home!',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFFF6B00), // laranja vibrante
            fontWeight: FontWeight.bold,
          ),
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
