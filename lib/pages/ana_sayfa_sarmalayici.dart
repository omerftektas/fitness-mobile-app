// ============================================================
// DOSYA: ana_sayfa_sarmalayici.dart  (eskiden: main_page.dart)
// AÇIKLAMA: Uygulamanın ANA ÇERÇEVE sayfasıdır.
//   - Alt navigasyon çubuğu (BottomNavigationBar) burada oluşturulur
//   - 3 ana sekme yönetilir: Ana Sayfa, İstatistikler, Profil
//   - Sekmeler arasında geçiş IndexedStack ile yapılır
//     (IndexedStack: aktif olmayan sayfaları bellekte tutar, yeniden yüklemez)
// ============================================================

import 'package:flutter/material.dart';
import 'antrenman_gunlugu_sayfasi.dart'; // Ana Sayfa - antrenman listesi
import 'haftalik_istatistik_sayfasi.dart'; // İstatistikler sayfası
import 'kullanici_profil_sayfasi.dart'; // Profil sayfası

// StatefulWidget: Seçili sekme değiştiğinde UI'ı güncellemek için gerekli
class AnaSayfaSarmalayici extends StatefulWidget {
  const AnaSayfaSarmalayici({super.key});

  @override
  State<AnaSayfaSarmalayici> createState() => _AnaSayfaSarmalayicisiState();
}

class _AnaSayfaSarmalayicisiState extends State<AnaSayfaSarmalayici> {
  // Hangi sekmenin seçili olduğunu tutan değişken (0 = Ana Sayfa)
  int _secilenSekme = 0;

  // Tüm sayfaları bir liste olarak tanımlıyoruz
  final List<Widget> _sayfalar = [
    const AntrenmanGunluguSayfasi(),     // 0 - Ana Sayfa
    const HaftalikIstatistikSayfasi(),   // 1 - İstatistikler
    const KullaniciProfilSayfasi(),      // 2 - Profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack: tüm sayfaları oluşturur ama sadece seçileni gösterir
      // Böylece sekme değişince sayfa sıfırdan yüklenmez, hızlıdır
      body: IndexedStack(
        index: _secilenSekme,
        children: _sayfalar,
      ),

      // Alt navigasyon çubuğu
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _secilenSekme,
          onDestinationSelected: (index) {
            // Kullanıcı başka bir sekmeye bastığında setState ile UI güncellenir
            setState(() {
              _secilenSekme = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'İstatistikler',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
