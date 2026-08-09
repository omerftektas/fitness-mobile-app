// ============================================================
// DOSYA: main.dart
// AÇIKLAMA: Uygulamanın başlangıç noktasıdır.
//   - MaterialApp tanımlanır (uygulama teması ve başlangıç sayfası burada ayarlanır)
//   - Açık tema (light) ve koyu tema (dark) tanımlanır
//   - Tema seçimi SharedPreferences'a kaydedilir ve uygulama açıldığında yüklenir
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/ana_sayfa_sarmalayici.dart'; // Alt navigasyon barını içeren ana çerçeve
import 'services/veri_depolama_servisi.dart'; // Yerel depolama işlemleri

// Uygulamanın başlangıç fonksiyonu
void main() {
  runApp(const FitnessUygulamasi());
}

// Uygulamanın kök widget'ı (StatefulWidget çünkü tema değişebilir)
class FitnessUygulamasi extends StatefulWidget {
  const FitnessUygulamasi({super.key});

  // Dışarıdan tema değişikliği yapabilmek için state'e erişim sağlar
  static _FitnessUygulamasiState of(BuildContext context) =>
      context.findAncestorStateOfType<_FitnessUygulamasiState>()!;

  @override
  State<FitnessUygulamasi> createState() => _FitnessUygulamasiState();
}

class _FitnessUygulamasiState extends State<FitnessUygulamasi> {
  // Varsayılan tema: sistemin ayarına göre (açık veya koyu)
  ThemeMode _temaModU = ThemeMode.system;
  ThemeMode get themeMode => _temaModU;

  // Yerel depolama servisi (SharedPreferences üzerinden çalışır)
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();

  @override
  void initState() {
    super.initState();
    // Uygulama açılırken kaydedilmiş tema modunu yükle
    _temayiYukle();
  }

  // Daha önce kaydedilen tema modunu SharedPreferences'tan yükler
  Future<void> _temayiYukle() async {
    final mod = await _depolamaServisi.getThemeMode();
    setState(() {
      _temaModU = mod;
    });
  }

  // Profil sayfasındaki butondan tema değiştirmek için kullanılır
  void temaYiDegistir(ThemeMode mod) {
    setState(() {
      _temaModU = mod;
    });
    _depolamaServisi.saveThemeMode(mod); // Yeni temayı kaydet
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness & Antrenman Takip',
      debugShowCheckedModeBanner: false, // Sağ üstteki "DEBUG" yazısını gizler

      // AÇIK TEMA TANIMI
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // KOYU TEMA TANIMI
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBB86FC),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      themeMode: _temaModU, // Hangi tema kullanılacağı
      home: const AnaSayfaSarmalayici(), // İlk açılacak sayfa
    );
  }
}
