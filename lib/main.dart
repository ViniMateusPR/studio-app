// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_app/screens/post/criar_post_screen.dart';

import 'app_theme.dart';
import 'models/aluno.dart';
import 'providers/montar_treino_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_empresa_screen.dart';
import 'screens/home/home_professor_screen.dart';
import 'screens/treino/montar_treino_professor_screen.dart';

// Observador global de rotas, para atualizar telas ao voltar a elas
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MontarTreinoProvider()),
        // adicione outros providers aqui, se tiver
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estúdio App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/login',
      navigatorObservers: [routeObserver],
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home_empresa': (_) => const HomeEmpresaScreen(),
        '/home_professor': (_) => const HomeProfessorScreen(),
        '/criarPost': (context) => const CriarPostScreen(),
        '/montar_treino': (ctx) {
          final aluno = ModalRoute.of(ctx)!.settings.arguments as Aluno;
          return MontarTreinoProfessorScreen(aluno: aluno);
        },
      },
    );
  }
}
