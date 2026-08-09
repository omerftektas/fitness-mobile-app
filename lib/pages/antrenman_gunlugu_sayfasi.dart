// ============================================================
// DOSYA: antrenman_gunlugu_sayfasi.dart  (eskiden: home_page.dart)
// AÇIKLAMA: Uygulamanın ANA sayfasıdır. Kullanıcı burada:
//   - Takvimden bir gün seçer
//   - Seçilen güne ait egzersizleri görür
//   - Yeni egzersiz ekler, var olanları siler veya düzenler
//   - Su tüketimi ve makro (besin) takibini yapar
//   - Motivasyon sözü okur
//   - Dinlenme sayacı kullanır
// ============================================================

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Takvim bileşeni (3. parti paket)
import 'package:uuid/uuid.dart'; // Benzersiz ID üretmek için (UUID = Unique Identifier)
import '../models/egzersiz_modeli.dart';             // Egzersiz veri modeli
import '../services/veri_depolama_servisi.dart';      // SharedPreferences servisi
import 'egzersiz_ekle_sayfasi.dart';                 // Egzersiz ekleme/düzenleme sayfası
import '../widgets/motivasyon_karti.dart';            // Motivasyon sözü kartı
import '../widgets/su_takip_karti.dart';              // Su tüketimi takip kartı
import '../widgets/makro_takip_karti.dart';           // Protein/Karb/Yağ takip kartı
import '../widgets/dinlenme_zamanlayici_karti.dart';  // Dinlenme sayacı kartı

// StatefulWidget: Takvimde seçilen gün değişince egzersiz listesi yenilenir
class AntrenmanGunluguSayfasi extends StatefulWidget {
  const AntrenmanGunluguSayfasi({super.key});

  @override
  State<AntrenmanGunluguSayfasi> createState() => _AntrenmanGunluguSayfasiState();
}

class _AntrenmanGunluguSayfasiState extends State<AntrenmanGunluguSayfasi> {
  // Yerel depolama servisinin örneği
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();

  // Seçili güne ait egzersizlerin tutulduğu liste
  List<Egzersiz> _secilenGunEgzersizleri = [];

  // Veriler yüklenirken dönen yükleniyor göstergesi için bayrak
  bool _yukleniyor = true;

  // Takvim için: odaklanılan ve seçilen gün
  DateTime _odaklanilanGun = DateTime.now();
  DateTime? _secilenGun;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında bugünü seç ve egzersizleri yükle
    _secilenGun = _odaklanilanGun;
    _egzersizleriYukle(_secilenGun!);
  }

  // Seçilen güne ait egzersizleri SharedPreferences'tan yükleyen fonksiyon
  Future<void> _egzersizleriYukle(DateTime tarih) async {
    setState(() {
      _yukleniyor = true; // Yükleniyor göstergesini başlat
    });

    final egzersizler = await _depolamaServisi.getExercisesByDate(tarih);

    // mounted kontrolü: widget hala ekranda mı? (async işlemlerden sonra mutlaka kontrol edilmeli)
    if (mounted) {
      setState(() {
        _secilenGunEgzersizleri = egzersizler;
        _yukleniyor = false; // Yükleniyor göstergesini durdur
      });
    }
  }

  // Egzersizi ID'ye göre silen ve listeyi yenileyen fonksiyon
  Future<void> _egzersizSil(String id) async {
    await _depolamaServisi.deleteExercise(id);
    _egzersizleriYukle(_secilenGun!); // Silme sonrası listeyi yenile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrenman Günlüğüm', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Üstte takvim bileşeni
          _takvimOlustur(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Motivasyon sözü kartı
                  const MotivasYonKarti(),
                  const SizedBox(height: 12),

                  // Su tüketimi takip kartı
                  SuTakipKarti(secilenTarih: _secilenGun!),
                  const SizedBox(height: 12),

                  // Makro (protein/karb/yağ) takip kartı
                  MakroTakipKarti(secilenTarih: _secilenGun!),
                  const SizedBox(height: 12),

                  // Dinlenme sayacı kartı
                  const DinlenmeZamanLayiciKarti(),
                  const SizedBox(height: 20),

                  // Başlık satırı: "Bugünün Antrenmanları" + "Hızlı Ekle" butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bugünün Antrenmanları',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      // Favorilere eklenen egzersizleri hızlıca ekleme butonu
                      TextButton.icon(
                        onPressed: _favorileriGoster,
                        icon: const Icon(Icons.flash_on, size: 18),
                        label: const Text('Hızlı Ekle'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Egzersiz listesi
                  _egzersizListesiOlustur(),
                  const SizedBox(height: 80), // FAB için boşluk
                ],
              ),
            ),
          ),
        ],
      ),

      // Sağ alttaki "+" butonu - yeni egzersiz ekleme sayfasına yönlendirir
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // EgzersizEkleSayfasi'na git, geri döndüğünde 'result' değerini al
          final sonuc = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EgzersizEkleSayfasi(secilenTarih: _secilenGun),
            ),
          );

          // Eğer egzersiz başarıyla eklendiyse listeyi yenile
          if (sonuc == true) {
            _egzersizleriYukle(_secilenGun!);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Egzersiz Ekle'),
      ),
    );
  }

  // Egzersiz listesini oluşturan yardımcı fonksiyon
  Widget _egzersizListesiOlustur() {
    // Veri yükleniyorsa döngüsel gösterge
    if (_yukleniyor) {
      return const Center(child: CircularProgressIndicator());
    }

    // Egzersiz yoksa boş durum mesajı göster
    if (_secilenGunEgzersizleri.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Icon(Icons.fitness_center, size: 56, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Bu gün için antrenman yok.\nHadi başlayalım!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Egzersizler varsa liste olarak göster
    return ListView.builder(
      shrinkWrap: true, // Column içinde kullanıldığı için kendi boyutunu hesaplar
      physics: const NeverScrollableScrollPhysics(), // Kaydırma SingleChildScrollView'da yapılır
      itemCount: _secilenGunEgzersizleri.length,
      itemBuilder: (context, index) {
        final egzersiz = _secilenGunEgzersizleri[index];

        // Dismissible: sağdan sola kaydırarak silme özelliği
        return Dismissible(
          key: Key(egzersiz.id), // Her egzersizin benzersiz anahtarı
          direction: DismissDirection.endToStart, // Sağdan sola kaydırma
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _egzersizSil(egzersiz.id), // Sil ve listeyi güncelle
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              // Karta tıklayınca düzenleme sayfasına git
              onTap: () async {
                final sonuc = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EgzersizEkleSayfasi(
                      duzenlenecekEgzersiz: egzersiz, // Mevcut egzersizi düzenle
                      secilenTarih: _secilenGun,
                    ),
                  ),
                );
                if (sonuc == true) {
                  _egzersizleriYukle(_secilenGun!);
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              // Sol taraf: kategori ikonu
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(egzersiz.kategori.ikon, color: Theme.of(context).colorScheme.primary, size: 22),
              ),
              title: Text(
                egzersiz.ad,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  '${egzersiz.set} Set × ${egzersiz.tekrar} Tekrar',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Sağ taraf: favori butonu
              trailing: IconButton(
                icon: Icon(
                  egzersiz.favori ? Icons.favorite : Icons.favorite_border,
                  color: egzersiz.favori ? Colors.red : Colors.grey,
                  size: 22,
                ),
                onPressed: () async {
                  // Favori durumunu tersine çevir ve kaydet
                  final guncellenmis = egzersiz.kopyala(favori: !egzersiz.favori);
                  await _depolamaServisi.updateExercise(guncellenmis);
                  _egzersizleriYukle(_secilenGun!);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Favori egzersizleri listeleyen alt panel (BottomSheet)
  void _favorileriGoster() async {
    final tumEgzersizler = await _depolamaServisi.getExercises();

    // Aynı isimli favorilerden en son tarihlisini al (tekrar önleme)
    final favorilerHaritasi = <String, Egzersiz>{};
    for (var ex in tumEgzersizler) {
      if (ex.favori) {
        if (!favorilerHaritasi.containsKey(ex.ad) ||
            ex.tarih.isAfter(favorilerHaritasi[ex.ad]!.tarih)) {
          favorilerHaritasi[ex.ad] = ex;
        }
      }
    }

    final benzersizFavoriler = favorilerHaritasi.values.toList();

    if (benzersizFavoriler.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Henüz favori antrenmanınız yok.')),
        );
      }
      return;
    }

    if (!mounted) return;

    // Alt panel olarak favori listesini göster
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Favori Antrenmanlar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: benzersizFavoriler.length,
                  itemBuilder: (context, index) {
                    final favori = benzersizFavoriler[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(favori.kategori.ikon, color: Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      title: Text(favori.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${favori.set} Set × ${favori.tekrar} Tekrar'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () async {
                          // Favoriyi bugünün tarihiyle yeni bir egzersiz olarak ekle
                          final yeniEgzersiz = favori.kopyala(
                            id: const Uuid().v4(), // Yeni benzersiz ID ata
                            tarih: _secilenGun ?? DateTime.now(),
                          );
                          await _depolamaServisi.saveExercise(yeniEgzersiz);
                          if (mounted) {
                            Navigator.pop(context);
                            _egzersizleriYukle(_secilenGun!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${favori.ad} eklendi!')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Takvim bileşenini oluşturan yardımcı fonksiyon
  Widget _takvimOlustur() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _odaklanilanGun,
        calendarFormat: CalendarFormat.week, // Haftalık görünüm
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, // Format değiştirme butonu gizli
          titleCentered: true,
        ),
        selectedDayPredicate: (gun) {
          return isSameDay(_secilenGun, gun); // Seçili günü vurgula
        },
        onDaySelected: (secilenGun, odaklanilanGun) {
          // Farklı bir güne tıklandığında egzersizleri yenile
          if (!isSameDay(_secilenGun, secilenGun)) {
            setState(() {
              _secilenGun = secilenGun;
              _odaklanilanGun = odaklanilanGun;
            });
            _egzersizleriYukle(secilenGun);
          }
        },
        calendarStyle: CalendarStyle(
          // Seçili günün stili
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          // Bugünün stili
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
