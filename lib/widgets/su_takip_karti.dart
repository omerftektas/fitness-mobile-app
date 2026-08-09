// ============================================================
// DOSYA: su_takip_karti.dart
// AÇIKLAMA: Kullanıcının günlük içtiği suyu takip ettiği araçtır.
// ============================================================

import 'package:flutter/material.dart';
import '../services/veri_depolama_servisi.dart';

class SuTakipKarti extends StatefulWidget {
  final DateTime secilenTarih;

  const SuTakipKarti({super.key, required this.secilenTarih});

  @override
  State<SuTakipKarti> createState() => _SuTakipKartiState();
}

class _SuTakipKartiState extends State<SuTakipKarti> {
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();

  int _hedefSu = 2500; // Varsayılan hedef 2500 ml (2.5 Litre)
  int _icilenSu = 0; // O gün içilen toplam su

  @override
  void initState() {
    super.initState();
    _suVerisiniYukle(); // Sayfa açılınca verileri getir
  }

  // Takvimden başka gün seçilirse verileri yenile
  @override
  void didUpdateWidget(SuTakipKarti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secilenTarih != widget.secilenTarih) {
      _suVerisiniYukle();
    }
  }

  // Telefondan o günkü su verisini çeken fonksiyon
  Future<void> _suVerisiniYukle() async {
    final miktar = await _depolamaServisi.getWaterAmount(widget.secilenTarih);
    final hedef = await _depolamaServisi.getWaterTarget();
    if (mounted) {
      setState(() {
        _icilenSu = miktar;
        _hedefSu = hedef;
      });
    }
  }

  // Kullanıcı suyu arttırdığında çalışacak fonksiyon
  Future<void> _suEkle(int miktar) async {
    final yeniMiktar = _icilenSu + miktar;
    setState(() {
      _icilenSu = yeniMiktar;
    });
    // Yeni miktarı telefona kaydet
    await _depolamaServisi.saveWaterAmount(widget.secilenTarih, yeniMiktar);
  }

  // İçilen suyu sıfırlama fonksiyonu
  Future<void> _suyuSifirla() async {
    setState(() {
      _icilenSu = 0;
    });
    await _depolamaServisi.saveWaterAmount(widget.secilenTarih, 0);
  }

  @override
  Widget build(BuildContext context) {
    // İlerleme yüzdesi hesaplama (maksimum %100 yani 1.0 olabilir)
    final double ilerleme = (_icilenSu / _hedefSu).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım: Başlık ve Sıfırlama Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Su Tüketimi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                  onPressed: _suyuSifirla,
                  tooltip: 'Sıfırla', // Üzerine gelince çıkan yazı
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Orta Kısım: İlerleme Çubuğu ve Yazı
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: ilerleme,
                    minHeight: 12,
                    backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_icilenSu / $_hedefSu ml',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Alt Kısım: Su Ekleme Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _suEklemeButonu(200), // Bardak
                _suEklemeButonu(330), // Kutu
                _suEklemeButonu(500), // Şişe
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Su ekleme butonlarını oluşturan yardımcı fonksiyon
  Widget _suEklemeButonu(int miktar) {
    return ElevatedButton.icon(
      onPressed: () => _suEkle(miktar),
      icon: const Icon(Icons.add, size: 16),
      label: Text('${miktar}ml'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue,
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
        elevation: 0,
      ),
    );
  }
}
