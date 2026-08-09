// ============================================================
// DOSYA: bmi_hesaplayici_sayfasi.dart (eskiden: bmi_calculator_page.dart)
// AÇIKLAMA: Vücut Kitle İndeksini (BMI) hesaplar.
//   - Boy ve kilo bilgilerini alır.
//   - Formüle göre hesaplama yapar: Kilo / (Boy(m) * Boy(m))
//   - Zayıf, Normal, Fazla Kilolu veya Obez sonucunu verir.
// ============================================================

import 'package:flutter/material.dart';

// StatefulWidget kullanıldı çünkü kullanıcının girdiği boy/kiloya göre ekrandaki sonuç değişecek
class BmiHesaplayiciSayfasi extends StatefulWidget {
  const BmiHesaplayiciSayfasi({super.key});

  @override
  State<BmiHesaplayiciSayfasi> createState() => _BmiHesaplayiciSayfasiState();
}

class _BmiHesaplayiciSayfasiState extends State<BmiHesaplayiciSayfasi> {
  // Metin kutularındaki verileri almak için kontrolcüler
  final _boyKontrolcusu = TextEditingController();
  final _kiloKontrolcusu = TextEditingController();
  
  double? _hesaplananBmi;
  String _kategori = '';
  Color _kategoriRengi = Colors.grey;

  // BMI Hesaplama Fonksiyonu
  void _bmiHesapla() {
    // Metinleri ondalıklı sayıya çevir (geçersiz yazılırsa null döner)
    final boyCm = double.tryParse(_boyKontrolcusu.text);
    final kiloKg = double.tryParse(_kiloKontrolcusu.text);

    // Eğer veriler düzgünse ve 0'dan büyükse hesaplama yap
    if (boyCm != null && kiloKg != null && boyCm > 0 && kiloKg > 0) {
      final boyMetre = boyCm / 100; // Santimetreyi metreye çevir
      final bmi = kiloKg / (boyMetre * boyMetre); // BMI Formülü
      
      // setState ile ekranı güncelle
      setState(() {
        _hesaplananBmi = bmi;
        
        // BMI Değerine göre kategori belirleme (Dünya Sağlık Örgütü standartları)
        if (bmi < 18.5) {
          _kategori = 'Zayıf';
          _kategoriRengi = Colors.blue;
        } else if (bmi < 24.9) {
          _kategori = 'Normal Kilo';
          _kategoriRengi = Colors.green;
        } else if (bmi < 29.9) {
          _kategori = 'Fazla Kilolu';
          _kategoriRengi = Colors.orange;
        } else {
          _kategori = 'Obez';
          _kategoriRengi = Colors.red;
        }
      });
    } else {
      // Veriler hatalıysa mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli boy ve kilo giriniz.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vücut Kitle İndeksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BİLGİ GİRİŞ KARTI
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.monitor_weight_outlined, size: 48, color: Colors.blueGrey),
                    const SizedBox(height: 16),
                    const Text(
                      'BMI Hesaplayıcı',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Boy Girişi
                    TextField(
                      controller: _boyKontrolcusu,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Boy (cm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Kilo Girişi
                    TextField(
                      controller: _kiloKontrolcusu,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilo (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Hesapla Butonu
                    ElevatedButton(
                      onPressed: _bmiHesapla, // Tıklanınca hesaplama fonksiyonu çalışır
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50), // Geniş buton
                      ),
                      child: const Text('Hesapla', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            
            // SONUÇ GÖSTERİM KARTI (Sadece hesaplama yapıldıysa görünür)
            if (_hesaplananBmi != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                color: _kategoriRengi.withValues(alpha: 0.1), // Arka planı hafif renkli yap
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Sonuç',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      // Çıkan BMI Skoru
                      Text(
                        _hesaplananBmi!.toStringAsFixed(1), // Virgülden sonra 1 basamak (Örn: 24.5)
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _kategoriRengi,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Kategori Etiketi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _kategoriRengi,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _kategori,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
