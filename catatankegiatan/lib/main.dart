import 'package:flutter/material.dart';
import 'data/catatan_repository.dart';
import 'screens/login_screen.dart';

void main() async {
  // 1. Inisialisasi binding Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Tunggu SharedPreferences siap sebelum UI ditampilkan
  await CatatanRepository.init();

  runApp(const CatatanKegiatanApp());
}

class CatatanKegiatanApp extends StatelessWidget {
  const CatatanKegiatanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Kegiatan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF246B60)),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
