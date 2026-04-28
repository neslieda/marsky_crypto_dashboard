// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Marsky Crypto';

  @override
  String get coins => 'Coinler';

  @override
  String get favorites => 'Favoriler';

  @override
  String get search => 'Coin ara...';

  @override
  String get sortCoins => 'Sıralama';

  @override
  String get apply => 'Uygula';

  @override
  String get ascending => 'Artan';

  @override
  String get descending => 'Azalan';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get noCoins => 'Gösterilecek coin yok.';

  @override
  String get noFavorites =>
      'Henüz favori yok.\nFavorilere eklemek için bir coin\'in yıldızına dokun.';

  @override
  String get addFavorite => 'Favorilere ekle';

  @override
  String get removeFavorite => 'Favorilerden çıkar';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get signOutConfirm => 'Çıkış yapmak istediğine emin misin?';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get welcomeBack => 'Tekrar hoş geldin';

  @override
  String get signInSubtitle => 'Favori coin\'lerini takip etmek için giriş yap';

  @override
  String get createAccount => 'Hesap oluştur';

  @override
  String get createAccountSubtitle => 'Sadece birkaç saniyeni alır';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get confirmPassword => 'Şifre tekrarı';

  @override
  String get emailRequired => 'E-posta gerekli';

  @override
  String get invalidEmail => 'Geçersiz e-posta';

  @override
  String get passwordMin => 'Şifre en az 6 karakter olmalı';

  @override
  String get passwordsDontMatch => 'Şifreler eşleşmiyor';

  @override
  String get noAccountYet => 'Hesabın yok mu? Kayıt ol';

  @override
  String get haveAccount => 'Zaten hesabın var mı? Giriş yap';

  @override
  String get forgotPassword => 'Şifreni mi unuttun?';

  @override
  String get resetPassword => 'Şifreyi sıfırla';

  @override
  String get resetPasswordSent => 'Şifre sıfırlama e-postası gönderildi.';

  @override
  String get resetPasswordSubtitle => 'Sana sıfırlama bağlantısı göndereceğiz.';

  @override
  String get send => 'Gönder';

  @override
  String get high => 'En yüksek';

  @override
  String get low => 'En düşük';

  @override
  String get marketCap => 'Piyasa Değeri';

  @override
  String get volume24h => '24s Hacim';

  @override
  String get description => 'Açıklama';

  @override
  String get website => 'Web sitesi';

  @override
  String get allTimeHigh => 'Tüm zamanların en yükseği';

  @override
  String rank(int n) {
    return 'Sıra #$n';
  }

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeSystem => 'Sistem';

  @override
  String addedOn(String date) {
    return 'Eklendi: $date';
  }

  @override
  String get language => 'Dil';

  @override
  String get portfolio => 'Portföy';

  @override
  String get news => 'Haberler';

  @override
  String get compare => 'Karşılaştır';

  @override
  String get currency => 'Para birimi';

  @override
  String get biometric => 'Biyometrik giriş';

  @override
  String get biometricUnavailable =>
      'Bu cihazda biyometrik kimlik doğrulama kullanılamıyor.';

  @override
  String get all => 'Tümü';

  @override
  String get assignCategory => 'Kategori ata';

  @override
  String get categoryHint => 'örn. DeFi, Layer 1';

  @override
  String get clear => 'Temizle';

  @override
  String get save => 'Kaydet';

  @override
  String get addHolding => 'Pozisyon ekle';

  @override
  String get editHolding => 'Pozisyonu düzenle';

  @override
  String get portfolioEmpty =>
      'Henüz pozisyon yok.\nEklemek için + simgesine dokun.';

  @override
  String get totalValue => 'Toplam değer';

  @override
  String get totalCost => 'Toplam maliyet';

  @override
  String get profitLoss => 'K/Z';

  @override
  String get amount => 'Miktar';

  @override
  String get amountRequired => 'Miktar gerekli';

  @override
  String get amountInvalid => 'Geçersiz miktar';

  @override
  String get buyPriceOptional => 'Ort. alış fiyatı (opsiyonel)';

  @override
  String get selectCoin => 'Coin seç';

  @override
  String get coin => 'Coin';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get deleteConfirm => 'Bu pozisyon silinsin mi?';

  @override
  String get newsEmpty => 'Haber yok.';

  @override
  String get copyLink => 'Bağlantı kopyalandı';

  @override
  String get compareHint => 'Karşılaştırmak için iki coin seç';

  @override
  String get price => 'Fiyat';

  @override
  String get change24h => '24s değişim';

  @override
  String get confirmEmailTitle => 'E-postanı doğrula';

  @override
  String confirmEmailBody(String email) {
    return '$email adresine bir doğrulama bağlantısı gönderdik. Hesabını etkinleştirmek için posta kutunu kontrol edip bağlantıya tıkla.';
  }

  @override
  String get resendConfirmation => 'Doğrulama e-postasını yeniden gönder';

  @override
  String get backToSignIn => 'Girişe dön';

  @override
  String get confirmationResent => 'Doğrulama e-postası yeniden gönderildi.';
}
