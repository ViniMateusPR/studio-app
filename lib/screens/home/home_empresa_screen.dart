import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../aluno/cadastro_aluno_screen.dart';
import '../professor/cadastrar_exercicio_screen.dart';
import '../professor/cadastro_professor_screen.dart';
import '../aluno/lista_alunos_screen.dart';
import '../relatorios/relatrorios_screen.dart';
import '../treino/treinos_vencidos_screen.dart';
import '../post/criar_post_screen.dart';

class HomeEmpresaScreen extends StatefulWidget {
  const HomeEmpresaScreen({Key? key}) : super(key: key);

  @override
  State<HomeEmpresaScreen> createState() => _HomeEmpresaScreenState();
}

class _HomeEmpresaScreenState extends State<HomeEmpresaScreen> {
  final _storage = const FlutterSecureStorage();
  bool _loadingPosts = true;
  List<Map<String, dynamic>> _posts = [];
  Map<String, String>? _authHeaders;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await ApiService.init();
    _authHeaders = await ApiService.headers();
    await _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _loadingPosts = true);
    try {
      final raw = await ApiService.getPostsEmpresa();
      _posts = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      _posts = [];
    } finally {
      setState(() => _loadingPosts = false);
    }
  }

  void _logout() async {
    await AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  void _goToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CriarPostScreen()),
    ).then((_) => _fetchPosts());
  }

  void _showComments(int postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => _CommentsViewer(
          postId: postId,
          scrollController: controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_authHeaders == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Empresa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Criar Post',
            onPressed: _goToCreatePost,
          )
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _fetchPosts,
        child: _loadingPosts
            ? const Center(
            child: CircularProgressIndicator(color: AppColors.accent))
            : _posts.isEmpty
            ? Center(
          child: Text(
            'Nenhum post encontrado.',
            style: AppTextStyles.bodyMedium,
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _posts.length,
          itemBuilder: (_, index) {
            final post = _posts[index];
            final titulo = post['titulo'] as String? ?? '';
            final nomeEmp = post['nomeEmpresa'] as String? ?? '';
            final rawDate =
                post['publicadoEm'] as String? ?? '';
            final dt = DateTime.tryParse(rawDate) ?? DateTime.now();
            final dataFormat =
            DateFormat('dd/MM/yyyy').format(dt);
            final imagemUrl = post['imagemUrl'] as String?;
            final curtidas = post['likeCount'] as int? ?? 0;
            final comentarios = post['commentsCount'] as int? ?? 0;
            final networkImage = imagemUrl != null
                ? NetworkImage(imagemUrl, headers: _authHeaders!)
                : null;

            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 8),
                    if (nomeEmp.isNotEmpty)
                      Text(
                        nomeEmp,
                        style: AppTextStyles.bodyMedium
                            .copyWith(
                            color: AppColors.onSurface),
                      ),
                    if (networkImage != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(8),
                        child: Image(
                          image: networkImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder:
                              (ctx, child, prog) =>
                          prog == null
                              ? child
                              : const SizedBox(
                              height: 150),
                          errorBuilder:
                              (_, __, ___) =>
                          const SizedBox(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up,
                            size: 20,
                            color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('$curtidas'),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment,
                            size: 20,
                            color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('$comentarios'),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showComments(post['id'] as int),
                          child: const Text(
                            'Ver comentários',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Postado em $dataFormat',
                      style: AppTextStyles.bodyMedium
                          .copyWith(
                          color:
                          AppColors.onSurfaceLight),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.surface),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            _drawerItem(Icons.person_add, 'Cadastrar Aluno', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        CadastroAlunoScreen(empresaId: ApiService.empresaId)),
              );
            }),
            _drawerItem(Icons.person, 'Cadastrar Professor', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CadastroProfessorScreen()),
              );
            }),
            _drawerItem(Icons.app_registration, 'Cadastrar Exercício',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CadastrarExercicioScreen()),
                  );
                }),
            _drawerItem(Icons.list, 'Lista de Alunos', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ListaAlunosScreen()),
              );
            }),
            _drawerItem(Icons.bar_chart, 'Relatórios', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RelatoriosScreen()),
              );
            }),
            _drawerItem(Icons.warning, 'Treinos Vencidos', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TreinosVencidosScreen()),
              );
            }),
            const Spacer(),
            const Divider(color: AppColors.accent),
            _drawerItem(Icons.logout, 'Logout', _logout,
                iconColor: AppColors.error,
                textColor: AppColors.error),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label, VoidCallback onTap,
      {Color iconColor = AppColors.accent,
        Color textColor = AppColors.onSurface}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label,
          style:
          AppTextStyles.bodyMedium.copyWith(color: textColor)),
      onTap: onTap,
    );
  }
}

/// Apenas visualização de comentários
class _CommentsViewer extends StatefulWidget {
  final int postId;
  final ScrollController scrollController;
  const _CommentsViewer(
      {required this.postId, required this.scrollController, Key? key})
      : super(key: key);

  @override
  State<_CommentsViewer> createState() => __CommentsViewerState();
}

class __CommentsViewerState extends State<_CommentsViewer> {
  bool _loading = true;
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final raw = await ApiService.getComments(widget.postId);
      _comments =
          raw.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      _comments = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: Colors.grey[300]),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _comments.isEmpty
              ? Center(
              child: Text('Nenhum comentário.',
                  style: AppTextStyles.bodyMedium))
              : ListView.builder(
            controller: widget.scrollController,
            itemCount: _comments.length,
            itemBuilder: (_, i) {
              final c = _comments[i];
              final author = c['nomeAluno'] as String? ?? '';
              final content = c['conteudo'] as String? ?? '';
              final when = DateTime.tryParse(
                  c['comentadoEm'] as String) ??
                  DateTime.now();
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    author.isNotEmpty ? author[0] : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(author,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(content),
                trailing: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(when),
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceLight),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
