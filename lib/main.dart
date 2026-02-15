import 'package:flutter/material.dart';
import 'main_page.dart';

void main() {
  runApp(const SecimApp());
}

class SecimApp extends StatelessWidget {
  const SecimApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF090B14);
    const panel = Color(0x80131826);
    const cyan = Color(0xFF00E5FF);
    const purple = Color(0xFF9D4DFF);

    return MaterialApp(
      title: 'PoliVision Turkiye',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: purple,
          surface: panel,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cyan.withOpacity(0.18)),
          ),
          elevation: 0,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: cyan,
          thumbColor: cyan,
        ),
      ),
      home: const MainPage(),
    );
  }
}
