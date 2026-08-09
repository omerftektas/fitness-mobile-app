// ============================================================
// DOSYA: dinlenme_zamanlayici_karti.dart 
// AÇIKLAMA: Set aralarında dinlenme süresini sayan basit geri sayım aracıdır.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';

class DinlenmeZamanLayiciKarti extends StatefulWidget {
  const DinlenmeZamanLayiciKarti({super.key});

  @override
  State<DinlenmeZamanLayiciKarti> createState() => _DinlenmeZamanLayiciKartiState();
}

class _DinlenmeZamanLayiciKartiState extends State<DinlenmeZamanLayiciKarti> {
  int _kalanSaniye = 0;
  int _toplamSaniye = 0;
  Timer? _zamanlayici; // Timer: Belirli aralıklarla kod çalıştırmayı sağlar

  // Sayaç başlatma metodu
  void _sayaciBaslat(int saniye) {
    _zamanlayici?.cancel(); // Varsa eski sayacı durdur
    setState(() {
      _kalanSaniye = saniye;
      _toplamSaniye = saniye;
    });

    // Her 1 saniyede bir içindeki fonksiyonu çalıştırır
    _zamanlayici = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalanSaniye > 0) {
        setState(() {
          _kalanSaniye--;
        });
      } else {
        timer.cancel(); // Süre bitince sayacı iptal et
        _sureBittiMesajiGoster();
      }
    });
  }

  // Sayacı manuel olarak durdurma metodu
  void _sayaciDurdur() {
    _zamanlayici?.cancel();
    setState(() {
      _kalanSaniye = 0;
      _toplamSaniye = 0;
    });
  }

  // Süre bittiğinde alt taraftan çıkan küçük mesaj (SnackBar)
  void _sureBittiMesajiGoster() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dinlenme süresi bitti! Antrenmana devam!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _zamanlayici?.cancel(); // Sayfa kapanırsa bellekte yer kaplamaması için sayacı kapat
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Eğer sayaç çalışıyorsa
    if (_kalanSaniye > 0) {
      final ilerleme = _toplamSaniye > 0 ? (_kalanSaniye / _toplamSaniye) : 0.0;
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dinlenme Süresi', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '$_kalanSaniye saniye kaldı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: _sayaciDurdur,
                    child: const Text('Durdur', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // İlerleme Çubuğu
              LinearProgressIndicator(
                value: ilerleme,
                minHeight: 6,
              ),
            ],
          ),
        ),
      );
    }

    // Sayaç çalışmıyorsa butonları göster
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Dinlenme:', style: TextStyle(fontWeight: FontWeight.bold)),
            _zamanlayiciButonu(30),
            _zamanlayiciButonu(60),
            _zamanlayiciButonu(90),
          ],
        ),
      ),
    );
  }

  // Süre seçme butonlarını oluşturan yardımcı widget
  Widget _zamanlayiciButonu(int saniye) {
    return ElevatedButton(
      onPressed: () => _sayaciBaslat(saniye),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
      child: Text('${saniye}s'),
    );
  }
}
