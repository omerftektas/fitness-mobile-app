// ============================================================
// DOSYA: egzersiz_modeli.dart (eskiden: exercise.dart)
// AÇIKLAMA: Egzersiz verilerini temsil eden temel sınıftır.
//   - Nesne tabanlı programlama mantığıyla veriler burada modellenir.
//   - JSON formatına dönüştürme ve okuma işlemleri burada yapılır.
// ============================================================

import 'package:flutter/material.dart';

// Egzersiz kategorilerini tanımlayan enum (Numaralandırma)
enum EgzersizKategorisi {
  gogus('Göğüs', Icons.fitness_center),
  sirt('Sırt', Icons.accessibility_new),
  bacak('Bacak', Icons.directions_run),
  kol('Kol', Icons.sports_gymnastics),
  karin('Karın', Icons.sports_martial_arts),
  kardiyo('Kardiyo', Icons.directions_bike),
  diger('Diğer', Icons.more_horiz);

  final String etiket; // Ekranda görünecek isim
  final IconData ikon; // Ekranda görünecek ikon
  
  const EgzersizKategorisi(this.etiket, this.ikon);

  // Veritabanından okurken string veriyi enum'a çeviren yardımcı metod
  factory EgzersizKategorisi.metinden(String deger) {
    return EgzersizKategorisi.values.firstWhere(
      (e) => e.name == deger,
      orElse: () => EgzersizKategorisi.diger,
    );
  }
}

// Bir egzersizin hangi verileri taşıyacağını belirleyen sınıf
class Egzersiz {
  final String id;           // Benzersiz kimlik numarası
  final String ad;           // Egzersizin adı
  final int set;             // Kaç set yapılacağı
  final int tekrar;          // Kaç tekrar yapılacağı
  final DateTime tarih;      // Egzersizin yapılacağı gün
  final EgzersizKategorisi kategori; // Hangi bölge çalıştırılıyor
  final bool favori;         // Favorilere eklendi mi?

  // Sınıfın kurucu metodu (Constructor)
  Egzersiz({
    required this.id,
    required this.ad,
    required this.set,
    required this.tekrar,
    required this.tarih,
    this.kategori = EgzersizKategorisi.diger,
    this.favori = false,
  });

  // Veriyi güncellerken mevcut nesneyi bozmadan kopyasını çıkartan metod
  Egzersiz kopyala({
    String? id,
    String? ad,
    int? set,
    int? tekrar,
    DateTime? tarih,
    EgzersizKategorisi? kategori,
    bool? favori,
  }) {
    return Egzersiz(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      set: set ?? this.set,
      tekrar: tekrar ?? this.tekrar,
      tarih: tarih ?? this.tarih,
      kategori: kategori ?? this.kategori,
      favori: favori ?? this.favori,
    );
  }

  // Veriyi telefona (SharedPreferences) kaydetmek için JSON formatına çevirir
  Map<String, dynamic> jsonaCevir() {
    return {
      'id': id,
      'ad': ad,
      'set': set,
      'tekrar': tekrar,
      'tarih': tarih.toIso8601String(), // Tarihi metne çevirir
      'kategori': kategori.name,
      'favori': favori,
    };
  }

  // Telefondan okunan JSON verisini Egzersiz nesnesine dönüştürür
  factory Egzersiz.jsondan(Map<String, dynamic> json) {
    return Egzersiz(
      id: json['id'],
      ad: json['ad'],
      set: json['set'],
      tekrar: json['tekrar'],
      tarih: DateTime.parse(json['tarih']), // Metni tarihe çevirir
      kategori: json['kategori'] != null 
          ? EgzersizKategorisi.metinden(json['kategori']) 
          : EgzersizKategorisi.diger,
      favori: json['favori'] ?? false,
    );
  }
}
