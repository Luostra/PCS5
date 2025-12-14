import 'dart:async';
import 'package:flutter/material.dart';
import 'pages/notes_page.dart';

void main() {
  runZonedGuarded(
    () {
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('Flutter error: ${details.exception}');
      };

      runApp(const MyApp());
    },
    (error, stackTrace) {
      debugPrint('Uncaught zone error: $error');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return const Material(
        child: Center(
          child: Text(
            'Произошла ошибка.\nПопробуйте перезапустить приложение.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    };

    return const MaterialApp(home: NotesPage());
  }
}
