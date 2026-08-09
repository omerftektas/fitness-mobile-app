// ============================================================
// DOSYA: veri_depolama_servisi.dart (eskiden: storage_service.dart)
// AÇIKLAMA: Uygulamadaki tüm verileri telefonda kalıcı olarak saklar.
//   - SharedPreferences kütüphanesi kullanılır.
//   - İnternet/Sunucu bağlantısı olmadan verileri telefona kaydeder.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/egzersiz_modeli.dart';

class VeriDepolamaServisi {
  // Kaydedilecek verilerin anahtar isimleri (Sabit / Constant)
  static const String _anahtarEgzersizler = 'egzersizler';
  static const String _anahtarTemaModu = 'tema_modu';
  static const String _anahtarProfil = 'profil_verisi';
  static const String _anahtarSuHedefi = 'su_hedefi';
  static const String _anahtarMakroHedefleri = 'makro_hedefleri';

  // --- EGZERSİZ İŞLEMLERİ ---

  // Yeni bir egzersizi listeye ekler ve kaydeder
  Future<void> saveExercise(Egzersiz egzersiz) async {
    final prefs = await SharedPreferences.getInstance();
    List<Egzersiz> egzersizler = await getExercises();
    egzersizler.add(egzersiz); // Listeye yeni egzersizi ekle

    // Nesneleri JSON metnine dönüştürüp listeyi kaydet
    List<String> jsonListesi = egzersizler.map((e) => json.encode(e.jsonaCevir())).toList();
    await prefs.setStringList(_anahtarEgzersizler, jsonListesi);
  }

  // Mevcut bir egzersizin verilerini günceller
  Future<void> updateExercise(Egzersiz egzersiz) async {
    final prefs = await SharedPreferences.getInstance();
    List<Egzersiz> egzersizler = await getExercises();
    
    // Güncellenecek egzersizi listede bul
    final index = egzersizler.indexWhere((e) => e.id == egzersiz.id);
    if (index != -1) {
      egzersizler[index] = egzersiz; // Üzerine yaz
      List<String> jsonListesi = egzersizler.map((e) => json.encode(e.jsonaCevir())).toList();
      await prefs.setStringList(_anahtarEgzersizler, jsonListesi);
    }
  }

  // Kayıtlı tüm egzersizleri getirir
  Future<List<Egzersiz>> getExercises() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonListesi = prefs.getStringList(_anahtarEgzersizler);
    
    // Eğer henüz kayıt yoksa boş liste döndür
    if (jsonListesi == null) {
      return [];
    }

    // JSON metinlerini tekrar Egzersiz nesnelerine çevirir
    return jsonListesi.map((e) => Egzersiz.jsondan(json.decode(e))).toList();
  }

  // ID'si verilen egzersizi siler
  Future<void> deleteExercise(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<Egzersiz> egzersizler = await getExercises();
    
    egzersizler.removeWhere((eleman) => eleman.id == id);
    
    List<String> jsonListesi = egzersizler.map((e) => json.encode(e.jsonaCevir())).toList();
    await prefs.setStringList(_anahtarEgzersizler, jsonListesi);
  }

  // Sadece belirli bir güne ait egzersizleri getirir
  Future<List<Egzersiz>> getExercisesByDate(DateTime tarih) async {
    List<Egzersiz> tumEgzersizler = await getExercises();
    return tumEgzersizler.where((eleman) {
      // Yıl, ay ve gün eşitliğini kontrol et
      return eleman.tarih.year == tarih.year &&
             eleman.tarih.month == tarih.month &&
             eleman.tarih.day == tarih.day;
    }).toList();
  }

  // --- TEMA AYARLARI ---

  Future<void> saveThemeMode(ThemeMode mod) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_anahtarTemaModu, mod.index);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_anahtarTemaModu);
    if (index == null) return ThemeMode.system; // Varsayılan sistem teması
    return ThemeMode.values[index];
  }

  // --- KULLANICI PROFİLİ ---

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anahtarProfil, json.encode(data));
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_anahtarProfil);
    if (dataString == null) return null;
    return json.decode(dataString);
  }

  // --- SU TAKİBİ ---

  // Her gün için farklı bir anahtar oluşturur (Örn: su_2023_5_20)
  String _suAnahtariOlustur(DateTime tarih) {
    return 'su_${tarih.year}_${tarih.month}_${tarih.day}';
  }

  Future<void> saveWaterAmount(DateTime tarih, int miktar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_suAnahtariOlustur(tarih), miktar);
  }

  Future<int> getWaterAmount(DateTime tarih) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_suAnahtariOlustur(tarih)) ?? 0;
  }

  Future<void> saveWaterTarget(int hedef) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_anahtarSuHedefi, hedef);
  }

  Future<int> getWaterTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_anahtarSuHedefi) ?? 2500; // Varsayılan 2.5 Litre
  }

  // --- MAKRO (BESİN) TAKİBİ ---

  String _makroAnahtariOlustur(DateTime tarih) {
    return 'makrolar_${tarih.year}_${tarih.month}_${tarih.day}';
  }

  Future<void> saveMacros(DateTime tarih, Map<String, int> makrolar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_makroAnahtariOlustur(tarih), json.encode(makrolar));
  }

  Future<Map<String, int>> getMacros(DateTime tarih) async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_makroAnahtariOlustur(tarih));
    if (dataString == null) return {'protein': 0, 'karb': 0, 'yag': 0};
    final decoded = json.decode(dataString) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> saveMacroTargets(Map<String, int> hedefler) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_anahtarMakroHedefleri, json.encode(hedefler));
  }

  Future<Map<String, int>> getMacroTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_anahtarMakroHedefleri);
    if (dataString == null) return {'protein': 150, 'karb': 250, 'yag': 80}; // Varsayılan hedefler
    final decoded = json.decode(dataString) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }
}
