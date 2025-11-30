import 'package:flutter/material.dart';
import 'main_page.dart';

void main() {
  runApp(const SecimApp());
}

class SecimApp extends StatelessWidget {
  const SecimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TR Seçim Simülatörü",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MainPage(),
    );
  }
}
