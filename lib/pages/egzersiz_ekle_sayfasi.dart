// ============================================================
// DOSYA: egzersiz_ekle_sayfasi.dart  (eskiden: add_exercise_page.dart)
// AÇIKLAMA: Yeni egzersiz EKLEME veya mevcut egzersizi DÜZENLEME sayfasıdır.
//   - Form doğrulaması (validation) yapılır
//   - Egzersiz kategorisi seçilebilir (Göğüs, Sırt, Bacak, Kol, Karın, Kardiyo, Diğer)
//   - Set ve tekrar sayısı girilir
//   - Egzersiz SharedPreferences'a kaydedilir
//   - Eğer düzenleme modundaysa mevcut veriler forma yüklenir
// ============================================================

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Benzersiz ID üreteci
import '../models/egzersiz_modeli.dart';          // Egzersiz ve kategori modeli
import '../services/veri_depolama_servisi.dart';  // Kaydetme/güncelleme servisi

// StatefulWidget: Form içeriği değiştiğinde (kategori seçimi gibi) UI güncellenmeli
class EgzersizEkleSayfasi extends StatefulWidget {
  // Düzenleme modunda kullanılmak üzere mevcut egzersiz (null ise ekleme modu)
  final Egzersiz? duzenlenecekEgzersiz;
  // Hangi tarihe ekleneceği bilgisi
  final DateTime? secilenTarih;

  const EgzersizEkleSayfasi({
    super.key,
    this.duzenlenecekEgzersiz,
    this.secilenTarih,
  });

  @override
  State<EgzersizEkleSayfasi> createState() => _EgzersizEkleSayfasiState();
}

class _EgzersizEkleSayfasiState extends State<EgzersizEkleSayfasi> {
  // Form anahtarı: doğrulama (validate) işlemi için kullanılır
  final _formAnahtari = GlobalKey<FormState>();

  // Metin kontrolcüleri: kullanıcının girdiği değerlere erişmek için
  final _adKontrolcusu = TextEditingController();
  final _setKontrolcusu = TextEditingController();
  final _tekrarKontrolcusu = TextEditingController();

  // Depolama servisi örneği
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();

  // Seçili egzersiz kategorisi (varsayılan: Diğer)
  EgzersizKategorisi _secilenKategori = EgzersizKategorisi.diger;

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysa, mevcut egzersizin verilerini forma yükle
    if (widget.duzenlenecekEgzersiz != null) {
      _adKontrolcusu.text = widget.duzenlenecekEgzersiz!.ad;
      _setKontrolcusu.text = widget.duzenlenecekEgzersiz!.set.toString();
      _tekrarKontrolcusu.text = widget.duzenlenecekEgzersiz!.tekrar.toString();
      _secilenKategori = widget.duzenlenecekEgzersiz!.kategori;
    }
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için kontrolcüleri serbest bırak
    _adKontrolcusu.dispose();
    _setKontrolcusu.dispose();
    _tekrarKontrolcusu.dispose();
    super.dispose();
  }

  // Formu doğrulayan ve egzersizi kaydeden fonksiyon
  Future<void> _egzersizKaydet() async {
    // Form geçerli mi? (tüm validator'lar null döndürüyorsa geçerli)
    if (_formAnahtari.currentState!.validate()) {
      if (widget.duzenlenecekEgzersiz != null) {
        // DÜZENLEME MODU: Mevcut egzersizi güncelle
        final guncellenmis = widget.duzenlenecekEgzersiz!.kopyala(
          ad: _adKontrolcusu.text.trim(),
          set: int.parse(_setKontrolcusu.text),
          tekrar: int.parse(_tekrarKontrolcusu.text),
          kategori: _secilenKategori,
        );
        await _depolamaServisi.updateExercise(guncellenmis);
      } else {
        // EKLEME MODU: Yeni egzersiz oluştur ve kaydet
        final yeniEgzersiz = Egzersiz(
          id: const Uuid().v4(), // Benzersiz ID (örn: "550e8400-e29b-41d4...")
          ad: _adKontrolcusu.text.trim(),
          set: int.parse(_setKontrolcusu.text),
          tekrar: int.parse(_tekrarKontrolcusu.text),
          tarih: widget.secilenTarih ?? DateTime.now(),
          kategori: _secilenKategori,
        );
        await _depolamaServisi.saveExercise(yeniEgzersiz);
      }

      // Kaydetme bitti, önceki sayfaya dön ve başarılı olduğunu bildir
      if (mounted) {
        Navigator.pop(context, true); // 'true' = egzersiz kaydedildi
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Başlık: düzenleme modunda "Düzenle", ekleme modunda "Yeni Egzersiz"
        title: Text(widget.duzenlenecekEgzersiz != null ? 'Egzersizi Düzenle' : 'Yeni Egzersiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formAnahtari, // Form widget'ına anahtarı bağla
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // KATEGORİ SEÇİMİ BÖLÜMÜ
              const Text(
                'Kategori Seçimi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Yatay kaydırılabilir kategori listesi
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: EgzersizKategorisi.values.length,
                  itemBuilder: (context, index) {
                    final kategori = EgzersizKategorisi.values[index];
                    final seciliMi = _secilenKategori == kategori;

                    return GestureDetector(
                      onTap: () {
                        // Kategoriye dokunulduğunda seçili kategoriyi güncelle
                        setState(() {
                          _secilenKategori = kategori;
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          // Seçili ise ana renk, değilse gri arka plan
                          color: seciliMi
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              kategori.ikon,
                              color: seciliMi ? Theme.of(context).colorScheme.onPrimary : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              kategori.etiket,
                              style: TextStyle(
                                fontSize: 12,
                                color: seciliMi ? Theme.of(context).colorScheme.onPrimary : null,
                                fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // HAREKET ADI GİRİŞİ
              TextFormField(
                controller: _adKontrolcusu,
                decoration: InputDecoration(
                  labelText: 'Hareket Adı',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(_secilenKategori.ikon),
                  filled: true,
                ),
                // Doğrulama: boş bırakılamaz
                validator: (deger) {
                  if (deger == null || deger.trim().isEmpty) {
                    return 'Lütfen hareket adını girin';
                  }
                  return null; // Geçerli
                },
              ),
              const SizedBox(height: 24),

              // SET VE TEKRAR GİRİŞİ (yan yana)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setKontrolcusu,
                      keyboardType: TextInputType.number, // Sadece rakam klavyesi
                      decoration: InputDecoration(
                        labelText: 'Set',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.repeat),
                        filled: true,
                      ),
                      validator: (deger) {
                        if (deger == null || deger.trim().isEmpty) return 'Gir';
                        if (int.tryParse(deger) == null) return 'Sayı';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tekrarKontrolcusu,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tekrar',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.loop),
                        filled: true,
                      ),
                      validator: (deger) {
                        if (deger == null || deger.trim().isEmpty) return 'Gir';
                        if (int.tryParse(deger) == null) return 'Sayı';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // KAYDET BUTONU
              ElevatedButton(
                onPressed: _egzersizKaydet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(
                  widget.duzenlenecekEgzersiz != null ? 'Güncelle' : 'Antrenmanı Kaydet',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
