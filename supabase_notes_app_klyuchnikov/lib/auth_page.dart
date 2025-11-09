import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notes_page.dart';

final supabaseClient = Supabase.instance.client;

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  Future<void> signInUser() async {
    updateState(loading: true, error: null);

    try {
      final userEmail = emailController.text.trim();
      final userPassword = passwordController.text.trim();

      final authResponse = await supabaseClient.auth.signInWithPassword(
        email: userEmail,
        password: userPassword,
      );

      if (authResponse.user != null) {
        navigateToNotes();
      } else {
        updateState(error: 'Ошибка входа, проверьте e-mail и пароль');
      }
    } on AuthException catch (e) {
      updateState(error: e.message);
    } catch (e) {
      updateState(error: 'Произошла ошибка, попробуйте позже');
    } finally {
      if (mounted) updateState(loading: false);
    }
  }

  Future<void> signUpUser() async {
    updateState(loading: true, error: null);

    try {
      final userEmail = emailController.text.trim();
      final userPassword = passwordController.text.trim();

      final registrationResponse = await supabaseClient.auth.signUp(
        email: userEmail,
        password: userPassword,
      );

      if (registrationResponse.user != null) {
        final loginResponse = await supabaseClient.auth.signInWithPassword(
          email: userEmail,
          password: userPassword,
        );

        if (loginResponse.user != null) {
          navigateToNotes();
        } else {
          updateState(error: 'Ошибка входа');
        }
      } else {
        updateState(error: 'Ошибка регистрации');
      }
    } on AuthException catch (e) {
      updateState(error: e.message);
    } catch (e) {
      updateState(error: 'Произошла ошибка, попробуйте позже');
    } finally {
      if (mounted) updateState(loading: false);
    }
  }

  void updateState({bool? loading, String? error}) {
    if (!mounted) return;
    setState(() {
      if (loading != null) isLoading = loading;
      if (error != null) errorText = error;
    });
  }

  void navigateToNotes() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NotesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.password),
                ),
              ),
              const SizedBox(height: 24),
              if (errorText != null)
                Text(
                  errorText!,
                  style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
                ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: signInUser,
                          child: const Text('Войти'),
                        ),
                        ElevatedButton(
                          onPressed: signUpUser,
                          child: const Text('Зарегистрироваться'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
