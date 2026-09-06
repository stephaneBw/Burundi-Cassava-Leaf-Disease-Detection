// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'GreenHealer';

  @override
  String get farmerGreetingTitle => 'Merhaba! Ben GreenHealer.';

  @override
  String get farmerGreetingBody =>
      'Bitkilerin için geliştirilmiş yapay asistanınım. Bitkinde bir sorun mu var? Yaprağın fotoğrafını çek, sağlık durumunu kontrol edelim.';

  @override
  String get farmerAnalyzingBody =>
      'İlginç... Yapraklardaki detayları inceliyorum. Teşhisimi koymak üzereyim, çok az kaldı.';

  @override
  String farmerResultSuccess(Object confidence, Object label) {
    return 'Analizim bitti! %$confidence ihtimalle bu bir $label vakası. Tedavi yöntemlerini ve detaylı bilgileri senin için kütüphaneye not ettim, oraya bir göz atmanı öneririm.';
  }

  @override
  String farmerResultHealthy(Object confidence) {
    return 'Harika haber! %$confidence ihtimalle bitkin sağlıklı görünüyor. Herhangi bir hastalık belirtisine rastlamadım, harika bir iş çıkarıyorsun; bakımına aynen devam et!';
  }

  @override
  String get farmerErrorBody => 'Tüh, bir hata oluştu. Tekrar dener misin?';

  @override
  String get lblCamera => 'Kamera';

  @override
  String get lblGallery => 'Galeri';

  @override
  String get lblSearch => 'Ara...';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsGeneral => 'Genel';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get themeSystem => 'Sistem Varsayılanı';

  @override
  String get themeLight => 'Aydınlık Mod';

  @override
  String get themeDark => 'Karanlık Mod';

  @override
  String get langEnglish => 'İngilizce';

  @override
  String get langTurkish => 'Türkçe';

  @override
  String get historyEmpty => 'Henüz geçmiş tarama yok.';

  @override
  String get dialogClearTitle => 'Geçmişi Temizle';

  @override
  String get dialogClearMessage =>
      'Tüm tarama geçmişini silmek istediğine emin misin? Bu işlem geri alınamaz.';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionDelete => 'Sil';

  @override
  String get filterTitle => 'Filtrele';

  @override
  String get filterReset => 'Sıfırla';

  @override
  String get filterApply => 'Uygula';

  @override
  String get filterDate => 'Tarih Aralığı';

  @override
  String get filterStatus => 'Hastalık Durumu';

  @override
  String get filterPlants => 'Bitki Türü';

  @override
  String get filterAllTime => 'Tüm Zamanlar';

  @override
  String get filterLast15Min => 'Son 15 Dakika';

  @override
  String get filterLast1Hour => 'Son 1 Saat';

  @override
  String get filterLast24Hours => 'Son 24 Saat';

  @override
  String get filterLast7Days => 'Son 7 Gün';

  @override
  String get filterLast30Days => 'Son 30 Gün';

  @override
  String get filterAllStatus => 'Tümü';

  @override
  String get filterHealthyOnly => 'Sadece Sağlıklı';

  @override
  String get filterInfectedOnly => 'Sadece Hasta';

  @override
  String get btnViewInLibrary => 'Kütüphanede İncele';

  @override
  String get btnQuestionHow => 'Nasıl teşhis koyuyorsun?';

  @override
  String get btnQuestionPlants => 'Hangi bitkilerden anlıyorsun?';

  @override
  String get ansQuestionHow =>
      'Tecrübeli bir gözle yapraktaki lekeleri ve değişimleri inceliyorum. Sorunu tespit edip, bitkinin tekrar canlanması için gereken bakım önerilerini seninle paylaşıyorum.';

  @override
  String get ansQuestionPlants =>
      'Uzmanlık alanım, bahçelerin vazgeçilmezi olan domates, elma ve üzüm gibi 14 bitkiyi kapsıyor. Tam listeyi senin için Kütüphane bölümünde hazırladım, oradan inceleyebilirsin.';

  @override
  String get dsAppleScab => 'Elma: Karaleke Hastalığı';

  @override
  String get dsAppleBlackRot => 'Elma: Siyah Çürüklük';

  @override
  String get dsAppleCedarRust => 'Elma: Memeli Pas Hastalığı';

  @override
  String get dsAppleHealthy => 'Elma: Sağlıklı';

  @override
  String get dsBlueberryHealthy => 'Yaban Mersini: Sağlıklı';

  @override
  String get dsCherryPowderyMildew => 'Kiraz: Külleme Hastalığı';

  @override
  String get dsCherryHealthy => 'Kiraz: Sağlıklı';

  @override
  String get dsCornCercospora => 'Mısır: Cercospora Yaprak Lekesi';

  @override
  String get dsCornCommonRust => 'Mısır: Pas Hastalığı';

  @override
  String get dsCornNorthernBlight => 'Mısır: Kuzey Yaprak Yanıklığı';

  @override
  String get dsCornHealthy => 'Mısır: Sağlıklı';

  @override
  String get dsGrapeBlackRot => 'Üzüm: Siyah Çürüklük';

  @override
  String get dsGrapeEsca => 'Üzüm: Kav Hastalığı (Esca)';

  @override
  String get dsGrapeLeafBlight => 'Üzüm: Isariopsis Yaprak Yanıklığı';

  @override
  String get dsGrapeHealthy => 'Üzüm: Sağlıklı';

  @override
  String get dsOrangeHLB => 'Portakal: Turunçgil Yeşillenme Hastalığı';

  @override
  String get dsPeachBacterialSpot => 'Şeftali: Bakteriyel Leke Hastalığı';

  @override
  String get dsPeachHealthy => 'Şeftali: Sağlıklı';

  @override
  String get dsPepperBacterialSpot => 'Biber: Bakteriyel Leke Hastalığı';

  @override
  String get dsPepperHealthy => 'Biber: Sağlıklı';

  @override
  String get dsPotatoEarlyBlight => 'Patates: Erken Yanıklık';

  @override
  String get dsPotatoLateBlight => 'Patates: Geç Yanıklık (Mildiyö)';

  @override
  String get dsPotatoHealthy => 'Patates: Sağlıklı';

  @override
  String get dsRaspberryHealthy => 'Ahududu: Sağlıklı';

  @override
  String get dsSoybeanHealthy => 'Soya Fasulyesi: Sağlıklı';

  @override
  String get dsSquashPowderyMildew => 'Kabak: Külleme Hastalığı';

  @override
  String get dsStrawberryLeafScorch => 'Çilek: Yaprak Yanıklığı';

  @override
  String get dsStrawberryHealthy => 'Çilek: Sağlıklı';

  @override
  String get dsTomatoBacterialSpot => 'Domates: Bakteriyel Leke Hastalığı';

  @override
  String get dsTomatoEarlyBlight => 'Domates: Erken Yanıklık';

  @override
  String get dsTomatoLateBlight => 'Domates: Geç Yanıklık (Mildiyö)';

  @override
  String get dsTomatoLeafMold => 'Domates: Yaprak Küfü';

  @override
  String get dsTomatoSeptoria => 'Domates: Septorya Yaprak Lekesi';

  @override
  String get dsTomatoSpiderMites => 'Domates: İki Noktalı Kırmızı Örümcek';

  @override
  String get dsTomatoTargetSpot => 'Domates: Hedef Leke Hastalığı';

  @override
  String get dsTomatoYellowCurl => 'Domates: Sarı Yaprak Kıvırcıklık Virüsü';

  @override
  String get dsTomatoMosaic => 'Domates: Mozaik Virüsü';

  @override
  String get dsTomatoHealthy => 'Domates: Sağlıklı';

  @override
  String get dsUnknown => 'Bilinmeyen Durum';

  @override
  String get plantApple => 'Elma';

  @override
  String get plantBlueberry => 'Yaban Mersini';

  @override
  String get plantCherry => 'Kiraz';

  @override
  String get plantCorn => 'Mısır';

  @override
  String get plantGrape => 'Üzüm';

  @override
  String get plantOrange => 'Portakal';

  @override
  String get plantPeach => 'Şeftali';

  @override
  String get plantPepper => 'Biber';

  @override
  String get plantPotato => 'Patates';

  @override
  String get plantRaspberry => 'Ahududu';

  @override
  String get plantSoybean => 'Soya';

  @override
  String get plantSquash => 'Kabak';

  @override
  String get plantStrawberry => 'Çilek';

  @override
  String get plantTomato => 'Domates';

  @override
  String get tabSymptoms => 'Belirtiler';

  @override
  String get tabTreatment => 'Tedavi';

  @override
  String get tabPrevention => 'Önlemler';

  @override
  String get diseaseInfoPending => 'Hastalık bilgileri yükleniyor...';
}
