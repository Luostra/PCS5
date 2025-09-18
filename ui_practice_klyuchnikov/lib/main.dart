import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Практика 3")),
        body: Column(
          children: [
            Text(
              "приветствуем",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 7, 7),
              ),
            ),
            ElevatedButton(onPressed: () {}, child: Text("это кнопка")),
            Container(height: 100, width: 100, color: Colors.black),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 100, width: 100),
                Icon(Icons.smoke_free, color: Color(0xFF6200EE)),
                Icon(Icons.heart_broken, color: Color.fromARGB(255, 171, 0, 0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
