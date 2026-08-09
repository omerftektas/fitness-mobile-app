// ============================================================
// DOSYA: motivasyon_karti.dart 
// AÇIKLAMA: Ana sayfada rastgele motivasyon sözü gösteren kart widget'ıdır.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';

class MotivasYonKarti extends StatefulWidget {
  const MotivasYonKarti({super.key});

  @override
  State<MotivasYonKarti> createState() => _MotivasYonKartiState();
}

class _MotivasYonKartiState extends State<MotivasYonKarti> {
  // Gösterilecek sözlerin listesi
  final List<String> _sozler = [
    "Daha iyi bir sen için durma, sadece başla!",
    "Başarı, her gün tekrarlanan küçük çabaların toplamıdır.",
    "Ter, yağın ağlamasıdır.",
    "Vücuduna iyi bak, yaşamak zorunda olduğun tek yer orasıdır.",
    "En zor antrenman, başlamadığın antrenmandır.",
    "Dünkü sen, bugünkü senin tek rakibindir.",
    "Zorluklar seni bitirmez, seni şekillendirir.",
  ];

  late String _guncelSoz;

  @override
  void initState() {
    super.initState();
    // Ekran açıldığında listeden rastgele bir söz seç
    _guncelSoz = _sozler[Random().nextInt(_sozler.length)];
  }

  // Yenileme butonuna basıldığında farklı söz getir
  void _sozuYenile() {
    setState(() {
      _guncelSoz = _sozler[Random().nextInt(_sozler.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.primary, // Düz ana renk
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.format_quote_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _guncelSoz,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _sozuYenile, // Butona basılınca çalışacak fonksiyon
            ),
          ],
        ),
      ),
    );
  }
}
