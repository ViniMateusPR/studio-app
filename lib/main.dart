// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:studio_app/screens/home/home_empresa_screen.dart';
import 'package:studio_app/screens/auth/login_screen.dart';
import 'package:studio_app/screens/home/home_professor_screen.dart';
import 'package:studio_app/screens/treino/montar_treino_professor_screen.dart';
import 'models/aluno.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estúdio App',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [ Locale('pt', 'BR') ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // =====> força iniciar na rota de login
      initialRoute: '/login',

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF6B00),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFFFF6B00),
          background: Color(0xFF121212),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF6B00),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF6B00),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white70),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Colors.orange),
          checkColor: MaterialStateProperty.all(Colors.black),
        ),
        dividerTheme: const DividerThemeData(color: Colors.orange),
      ),

      // Rotas nomeadas
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home_empresa': (_) => const HomeEmpresaScreen(),
        '/home_professor': (_) => const HomeProfessorScreen(),
        '/montar_treino': (ctx) {
          final aluno = ModalRoute.of(ctx)!.settings.arguments as Aluno;
          return MontarTreinoProfessorScreen(aluno: aluno);
        },
      },
    );
  }
}
