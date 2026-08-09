// ============================================================
// DOSYA: haftalik_istatistik_sayfasi.dart
// AÇIKLAMA: Son 7 günün antrenman, su ve kalori verilerini grafikte gösterir.
//   - fl_chart paketi kullanılarak basit çizgi (LineChart) 
//     ve sütun (BarChart) grafikleri çizilir.
// ============================================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Grafik çizim kütüphanesi
import 'package:intl/intl.dart'; // Tarih formatlama işlemleri için
import '../models/egzersiz_modeli.dart';
import '../services/veri_depolama_servisi.dart';

class HaftalikIstatistikSayfasi extends StatefulWidget {
  const HaftalikIstatistikSayfasi({super.key});

  @override
  State<HaftalikIstatistikSayfasi> createState() => _HaftalikIstatistikSayfasiState();
}

class _HaftalikIstatistikSayfasiState extends State<HaftalikIstatistikSayfasi> {
  final VeriDepolamaServisi _depolamaServisi = VeriDepolamaServisi();
  
  // Tüm geçmiş egzersizler burada tutulur
  List<Egzersiz> _tumEgzersizler = [];
  
  // Son 7 günün su ve kalori değerleri
  List<int> _haftalikSuVerisi = List.filled(7, 0);
  List<int> _haftalikKaloriVerisi = List.filled(7, 0);
  
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _istatistikleriYukle(); // Sayfa açılınca verileri getir
  }

  // Telefona kaydedilen verileri okuyup grafiklere hazırlayan fonksiyon
  Future<void> _istatistikleriYukle() async {
    final egzersizler = await _depolamaServisi.getExercises();
    
    List<int> suVerisi = List.filled(7, 0);
    List<int> kaloriVerisi = List.filled(7, 0);
    
    final bugun = DateTime.now();
    
    // Son 7 gün için döngü (Döngü 0'dan 6'ya kadar çalışır)
    for (int i = 0; i < 7; i++) {
      // Bugünden i gün çıkararak geçmiş günleri buluruz
      final tarih = bugun.subtract(Duration(days: 6 - i));
      
      // O günkü su miktarı
      final su = await _depolamaServisi.getWaterAmount(tarih);
      suVerisi[i] = su;
      
      // O günkü kaloriyi formülle hesapla
      final makrolar = await _depolamaServisi.getMacros(tarih);
      final kalori = (makrolar['protein'] ?? 0) * 4 + 
                     (makrolar['karb'] ?? 0) * 4 + 
                     (makrolar['yag'] ?? 0) * 9;
      kaloriVerisi[i] = kalori;
    }
    
    if (mounted) {
      setState(() {
        _tumEgzersizler = egzersizler;
        _haftalikSuVerisi = suVerisi;
        _haftalikKaloriVerisi = kaloriVerisi;
        _yukleniyor = false; // Yükleme bitti
      });
    }
  }

  // Son 7 gün içinde hangi gün kaç egzersiz yapıldığını hesaplar
  List<int> _haftalikAntrenmanVerisiGetir() {
    List<int> veri = List.filled(7, 0);
    final bugun = DateTime.now();
    
    for (var egzersiz in _tumEgzersizler) {
      // Egzersiz tarihi ile bugün arasındaki gün farkı
      final fark = bugun.difference(egzersiz.tarih).inDays;
      if (fark >= 0 && fark < 7) {
        // Grafikte en sağ taraf (index 6) bugünü temsil eder
        veri[6 - fark]++;
      }
    }
    return veri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişim Grafiği'),
      ),
      // Veriler yüklenirken dönen yuvarlak göster, yüklenince sayfayı göster
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Antrenman Sütun Grafiği
                        _antrenmanGrafigiKarti(),
                        const SizedBox(height: 16),
                        
                        // Su Tüketimi Çizgi Grafiği
                        _cizgiGrafikKarti(
                          baslik: 'Su Tüketimi (ml)',
                          renk: Colors.blue,
                          veri: _haftalikSuVerisi,
                        ),
                        const SizedBox(height: 16),
                        
                        // Kalori Çizgi Grafiği
                        _cizgiGrafikKarti(
                          baslik: 'Alınan Kalori (kcal)',
                          renk: Colors.orange,
                          veri: _haftalikKaloriVerisi,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // ALT KISIM: Geçmiş Antrenmanların Listesi
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Tüm Geçmiş Egzersizler',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _tumEgzersizler.isEmpty
                    ? const SliverFillRemaining(
                        child: Center(child: Text('Henüz egzersiz kaydı yok.')),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // En son yapılanı en üstte göstermek için listeyi ters çevir
                            final egzersiz = _tumEgzersizler.reversed.toList()[index];
                            // Tarihi gün/ay/yıl saat:dakika şeklinde formatla
                            final tarihMetni = DateFormat('dd MMM yyyy - HH:mm').format(egzersiz.tarih);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: ListTile(
                                leading: Icon(egzersiz.kategori.ikon),
                                title: Text(egzersiz.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('$tarihMetni\n${egzersiz.set} Set × ${egzersiz.tekrar} Tekrar'),
                                isThreeLine: true,
                              ),
                            );
                          },
                          childCount: _tumEgzersizler.length,
                        ),
                      ),
              ],
            ),
    );
  }

  // Antrenmanları Sütun (Bar) grafik olarak çizen yardımcı fonksiyon
  Widget _antrenmanGrafigiKarti() {
    final veri = _haftalikAntrenmanVerisiGetir();
    // Y ekseninin (yukarı) maksimum değerini belirle
    double maxY = (veri.reduce((a, b) => a > b ? a : b) + 2).toDouble();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Haftalık Antrenman Sayısı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          // Alt kısımda gün isimlerini göster (Pzt, Sal vb.)
                          final bugun = DateTime.now();
                          final tarih = bugun.subtract(Duration(days: 6 - value.toInt()));
                          final bugunMu = value.toInt() == 6;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              bugunMu ? 'Bugün' : DateFormat('E').format(tarih), // E: Günün kısa adı
                              style: TextStyle(fontSize: 12, fontWeight: bugunMu ? FontWeight.bold : FontWeight.normal),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: veri[i].toDouble(),
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Su ve Kalori için Çizgi (Line) grafik çizen yardımcı fonksiyon
  Widget _cizgiGrafikKarti({
    required String baslik,
    required Color renk,
    required List<int> veri,
  }) {
    double maxY = veri.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxY == 0) maxY = 100; // Boşsa standart bir yükseklik
    maxY = maxY * 1.2; // Grafik üstte yapışmasın diye %20 boşluk

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final bugun = DateTime.now();
                          final tarih = bugun.subtract(Duration(days: 6 - value.toInt()));
                          final bugunMu = value.toInt() == 6;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              bugunMu ? 'Bgn' : DateFormat('E').format(tarih).substring(0, 3),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(7, (i) => FlSpot(i.toDouble(), veri[i].toDouble())),
                      isCurved: false, // Düz çizgiler
                      color: renk,
                      barWidth: 3,
                      dotData: FlDotData(show: true), // Noktaları göster
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
