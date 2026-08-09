// ============================================================
// DOSYA: kullanici_profil_sayfasi.dart
// AÇIKLAMA: Kullanıcının kişisel bilgilerini (yaş, kilo, hedef vb.) girip 
//   kaydettiği sayfadır. Ayrıca BMI hesaplayıcısına geçiş yapılabilir 
//   ve karanlık/aydınlık tema değiştirilebilir.
// ============================================================

import 'package:flutter/material.dart';
import '../services/veri_depolama_servisi.dart';
import '../main.dart'; // Tema değişimi için gerekli
import 'bmi_hesaplayici_sayfasi.dart'; // BMI Hesaplama sayfasına geçiş için

class KullaniciProfilSayfasi extends StatefulWidget {
  const KullaniciProfilSayfasi({super.key});

  @override
  State<KullaniciProfilSayfasi> createState() => _KullaniciProfilSayfasiState();
}

class _KullaniciProfilSayfasiState extends State<KullaniciProfilSayfasi> {
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();
  
  // Metin kutuları için kontrolcüler
  final _isimKontrolcusu = TextEditingController();
  final _yasKontrolcusu = TextEditingController();
  final _kiloKontrolcusu = TextEditingController();
  final _hedefKontrolcusu = TextEditingController();
  
  bool _yukleniyor = true;
  bool _duzenlemeModu = false; // Kullanıcı "Düzenle"ye basana kadar alanlar kilitli

  @override
  void initState() {
    super.initState();
    _profiliYukle(); // Sayfa açılınca kayıtlı verileri getir
  }

  // Telefondan daha önce kaydedilen profil verilerini alır
  Future<void> _profiliYukle() async {
    final veri = await _depolamaServisi.getProfile();
    if (veri != null) {
      _isimKontrolcusu.text = veri['isim'] ?? '';
      _yasKontrolcusu.text = veri['yas']?.toString() ?? '';
      _kiloKontrolcusu.text = veri['kilo']?.toString() ?? '';
      _hedefKontrolcusu.text = veri['hedef'] ?? '';
    }
    if (mounted) {
      setState(() {
        _yukleniyor = false; // Yükleme bitti, sayfayı göster
      });
    }
  }

  // Yeni girilen bilgileri telefona (SharedPreferences) kaydeder
  Future<void> _profiliKaydet() async {
    await _depolamaServisi.saveProfile({
      'isim': _isimKontrolcusu.text,
      'yas': int.tryParse(_yasKontrolcusu.text),
      'kilo': double.tryParse(_kiloKontrolcusu.text),
      'hedef': _hedefKontrolcusu.text,
    });
    
    if (mounted) {
      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi!')),
      );
      setState(() {
        _duzenlemeModu = false; // Düzenleme modunu kapat (Alanları kilitle)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mevcut temanın koyu (dark) mı yoksa açık (light) mı olduğunu kontrol et
    final temaModu = FitnessUygulamasi.of(context).themeMode;
    final koyuMu = temaModu == ThemeMode.dark || 
        (temaModu == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          // Tema değiştirme butonu (Güneş / Ay ikonu)
          IconButton(
            icon: Icon(koyuMu ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final yeniMod = koyuMu ? ThemeMode.light : ThemeMode.dark;
              FitnessUygulamasi.of(context).temaYiDegistir(yeniMod);
            },
          ),
          // Eğer düzenleme modunda değilsek düzenleme butonunu göster
          if (!_duzenlemeModu)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _duzenlemeModu = true; // Metin kutularının kilidini aç
                });
              },
            ),
        ],
      ),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kullanıcı İkonu
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 60),
                  ),
                ),
                const SizedBox(height: 20),
                
                // İsim Alanı
                _metinKutusuOlustur(
                  kontrolcu: _isimKontrolcusu,
                  etiket: 'İsim',
                  ikon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                
                // Yaş ve Kilo Alanları Yan Yana
                Row(
                  children: [
                    Expanded(
                      child: _metinKutusuOlustur(
                        kontrolcu: _yasKontrolcusu,
                        etiket: 'Yaş',
                        ikon: Icons.cake_outlined,
                        klavyeTipi: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _metinKutusuOlustur(
                        kontrolcu: _kiloKontrolcusu,
                        etiket: 'Kilo (kg)',
                        ikon: Icons.monitor_weight_outlined,
                        klavyeTipi: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Hedef Alanı
                _metinKutusuOlustur(
                  kontrolcu: _hedefKontrolcusu,
                  etiket: 'Hedef (Örn: Kas kazanmak, Zayıflamak)',
                  ikon: Icons.flag_outlined,
                ),
                
                // Düzenleme modundaysa İptal ve Kaydet butonlarını göster
                if (_duzenlemeModu) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _duzenlemeModu = false;
                              _profiliYukle(); // Değişiklikleri iptal et, eski veriyi geri getir
                            });
                          },
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _profiliKaydet,
                          child: const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 32),
                const Divider(), // Araya çizgi koy
                const SizedBox(height: 16),
                
                // Araçlar Başlığı
                const Text(
                  'Araçlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // BMI Hesaplayıcıya giden buton/kart
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calculate, color: Colors.blue),
                    title: const Text('BMI Hesaplayıcı'),
                    subtitle: const Text('Vücut kitle indeksinizi ölçün'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // BMI Sayfasına geçiş yap
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BmiHesaplayiciSayfasi()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Metin kutusu oluşturmak için tekrarlayan kodları azaltan yardımcı fonksiyon
  Widget _metinKutusuOlustur({
    required TextEditingController kontrolcu,
    required String etiket,
    required IconData ikon,
    TextInputType? klavyeTipi,
  }) {
    return TextField(
      controller: kontrolcu,
      enabled: _duzenlemeModu, // Eğer düzenleme modu kapalıysa kilitli olur
      keyboardType: klavyeTipi,
      decoration: InputDecoration(
        labelText: etiket,
        prefixIcon: Icon(ikon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
