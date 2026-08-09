// ============================================================
// DOSYA: makro_takip_karti.dart
// AÇIKLAMA: Günlük alınan Protein, Karbonhidrat ve Yağ miktarını takip eder.
// ============================================================

import 'package:flutter/material.dart';
import '../services/veri_depolama_servisi.dart';

class MakroTakipKarti extends StatefulWidget {
  final DateTime secilenTarih;
  
  const MakroTakipKarti({super.key, required this.secilenTarih});

  @override
  State<MakroTakipKarti> createState() => _MakroTakipKartiState();
}

class _MakroTakipKartiState extends State<MakroTakipKarti> {
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();
  
  // Güncel alınan değerler
  int _protein = 0;
  int _karb = 0;
  int _yag = 0;

  // Ulaşılmak istenen hedefler
  int _hedefProtein = 150;
  int _hedefKarb = 250;
  int _hedefYag = 80;

  @override
  void initState() {
    super.initState();
    _makrolariYukle();
  }

  @override
  void didUpdateWidget(MakroTakipKarti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.secilenTarih != widget.secilenTarih) {
      _makrolariYukle(); // Takvimden gün değişince verileri güncelle
    }
  }

  // Telefondan verileri çeken fonksiyon
  Future<void> _makrolariYukle() async {
    final makrolar = await _depolamaServisi.getMacros(widget.secilenTarih);
    final hedefler = await _depolamaServisi.getMacroTargets();
    
    if (mounted) {
      setState(() {
        _protein = makrolar['protein'] ?? 0;
        _karb = makrolar['karb'] ?? 0;
        _yag = makrolar['yag'] ?? 0;
        
        _hedefProtein = hedefler['protein'] ?? 150;
        _hedefKarb = hedefler['karb'] ?? 250;
        _hedefYag = hedefler['yag'] ?? 80;
      });
    }
  }

  // Ekrana tıklandığında veri girmek için açılan pencere (Dialog)
  void _makroGirisPenceresiAc() {
    // Form için metin kontrolcüleri
    final proteinKontrol = TextEditingController(text: _protein.toString());
    final karbKontrol = TextEditingController(text: _karb.toString());
    final yagKontrol = TextEditingController(text: _yag.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Makro Değerleri Gir'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Sadece gerektiği kadar yer kaplar
            children: [
              TextField(
                controller: proteinKontrol,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
              ),
              TextField(
                controller: karbKontrol,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Karbonhidrat (g)'),
              ),
              TextField(
                controller: yagKontrol,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Yağ (g)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Pencereyi kapat
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Metin kutularındaki yazıları tam sayıya çevirir, boşsa 0 yapar
                final p = int.tryParse(proteinKontrol.text) ?? 0;
                final k = int.tryParse(karbKontrol.text) ?? 0;
                final y = int.tryParse(yagKontrol.text) ?? 0;

                // Değerleri kaydet
                await _depolamaServisi.saveMacros(widget.secilenTarih, {
                  'protein': p,
                  'karb': k,
                  'yag': y,
                });

                setState(() {
                  _protein = p;
                  _karb = k;
                  _yag = y;
                });
                
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Toplam kalori formülü: (Protein*4) + (Karb*4) + (Yağ*9)
    final int toplamKalori = (_protein * 4) + (_karb * 4) + (_yag * 9);

    return InkWell(
      onTap: _makroGirisPenceresiAc, // Karta tıklayınca pencere açılır
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Makro & Kalori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    '$toplamKalori kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // İlerleme çubuklarını oluşturan yardımcı fonksiyonu çağırıyoruz
              _ilerlemeCubuguOlustur('Protein', _protein, _hedefProtein, Colors.red),
              const SizedBox(height: 8),
              _ilerlemeCubuguOlustur('Karbonhidrat', _karb, _hedefKarb, Colors.green),
              const SizedBox(height: 8),
              _ilerlemeCubuguOlustur('Yağ', _yag, _hedefYag, Colors.amber),
              
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Düzenlemek için dokun',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Makrolar için ilerleme çubuğu üreten yardımcı fonksiyon
  Widget _ilerlemeCubuguOlustur(String baslik, int mevcut, int hedef, Color renk) {
    final double ilerleme = (hedef > 0) ? (mevcut / hedef).clamp(0.0, 1.0) : 0;
    
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(baslik, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: ilerleme,
            color: renk,
            backgroundColor: renk.withValues(alpha: 0.2),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '$mevcut/$hedef',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
