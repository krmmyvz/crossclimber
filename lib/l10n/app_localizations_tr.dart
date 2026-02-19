// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'CrossClimber';

  @override
  String get play => 'Oyna';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get english => 'İngilizce';

  @override
  String get turkish => 'Türkçe';

  @override
  String level(int levelNumber) {
    return 'Seviye $levelNumber';
  }

  @override
  String get nextLevel => 'Sonraki Seviye';

  @override
  String get allLevelsCompleted => 'Harika! Tüm Seviyeleri Tamamladın!';

  @override
  String allLevelsCompletedDesc(int totalLevels) {
    return '$totalLevels seviyenin tümünü tamamladın! Yakında yeni zorluklar için takipte kal.';
  }

  @override
  String get hint => 'İpucu';

  @override
  String get correct => 'Doğru!';

  @override
  String get wrong => 'Yanlış!';

  @override
  String get congratulations => 'Tebrikler!';

  @override
  String get youWon => 'Seviyeyi tamamladın!';

  @override
  String get phase1Title => 'Kelimeleri Tahmin Et';

  @override
  String get phase2Title => 'Kelimeleri Sırala';

  @override
  String get phase3Title => 'Son Kelimeleri Bul';

  @override
  String phaseProgress(int current, int total) {
    return 'Adım $current / $total';
  }

  @override
  String wordsFound(int found, int total) {
    return '$found / $total kelime bulundu';
  }

  @override
  String get pause => 'Duraklat';

  @override
  String get resume => 'Devam Et';

  @override
  String get restart => 'Yeniden Başla';

  @override
  String get mainMenu => 'Ana Menü';

  @override
  String get paused => 'Duraklatıldı';

  @override
  String get useHint => 'İpucu Kullan';

  @override
  String hintsRemaining(int count) {
    return '$count ipucu kaldı';
  }

  @override
  String get noHintsLeft => 'İpucu kalmadı';

  @override
  String get hintUsed => 'İpucu kullanıldı!';

  @override
  String get tapToGuess => 'Tahmin etmek için dokun';

  @override
  String get enterWord => 'Kelimeyi gir';

  @override
  String get locked => 'Kilitli';

  @override
  String get completed => 'Tamamlandı!';

  @override
  String get timeElapsed => 'Geçen Süre';

  @override
  String get yourScore => 'Skorun';

  @override
  String stars(int count) {
    return '$count Yıldız';
  }

  @override
  String get newBestTime => 'Yeni Rekor Süre!';

  @override
  String get playAgain => 'Tekrar Oyna';

  @override
  String get dragToReorder => 'Sıralamak için sürükle';

  @override
  String get checkOrder => 'Sıralamayı Kontrol Et';

  @override
  String get orderCorrect => 'Sıralama doğru!';

  @override
  String get orderIncorrect => 'Sıralama yanlış, tekrar dene';

  @override
  String get invalidWord => 'Geçersiz kelime!';

  @override
  String get alreadyGuessed => 'Bu kelime zaten bulundu';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get vibration => 'Titreşim';

  @override
  String get showTimer => 'Zamanlayıcıyı Göster';

  @override
  String get autoCheck => 'Otomatik Kontrol';

  @override
  String get autoCheckDesc =>
      'Kelimeyi tamamladığınızda otomatik kontrol edilsin';

  @override
  String get autoSort => 'Otomatik Sıralama';

  @override
  String get autoSortDesc =>
      'Tüm kelimeleri bulduğunuzda otomatik sıralama başlasın';

  @override
  String get appearance => 'Görünüm';

  @override
  String get soundEffects => 'Ses Efektleri';

  @override
  String get music => 'Müzik';

  @override
  String get tutorial => 'Nasıl Oynanır';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Versiyon';

  @override
  String get difficulty => 'Zorluk';

  @override
  String get easy => 'Kolay';

  @override
  String get medium => 'Orta';

  @override
  String get hard => 'Zor';

  @override
  String get achievements => 'Başarımlar';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get dailyChallenge => 'Günlük Challenge';

  @override
  String get profile => 'Profil';

  @override
  String get guestUser => 'Misafir Kullanıcı';

  @override
  String loggedInAs(String email) {
    return 'Giriş yapıldı: $email';
  }

  @override
  String get linkAccount => 'Hesabı Bağla';

  @override
  String get linkAccountDesc =>
      'İlerlemeni buluta kaydetmek için hesabını bağla.';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get googleSignIn => 'Google ile Giriş Yap';

  @override
  String get tutorial_intro_welcome_title => 'CrossClimber\'a Hoş Geldiniz!';

  @override
  String get tutorial_intro_welcome_desc =>
      'Bu eğlenceli kelime bulmaca oyununu nasıl oynayacağınızı öğrenin. Her seferde bir harf değiştirerek kelimeleri bağlayın!';

  @override
  String get tutorial_intro_objective_title => 'Oyun Amacı';

  @override
  String get tutorial_intro_objective_desc =>
      'Hedefiniz BAŞLANGIÇ ve BİTİŞ kelimeleri arasındaki eksik kelimeleri bulmaktır. Her kelime bir öncekinden tam olarak bir harf farklıdır.';

  @override
  String get tutorial_intro_rule_title => 'Altın Kural';

  @override
  String get tutorial_intro_rule_desc =>
      'Her seferinde sadece BİR harf değiştirebilirsiniz. Örneğin: KAL → BAL → BAT → BAŞ';

  @override
  String get tutorial_guess_intro_title => 'Faz 1: Tahmin Etme';

  @override
  String get tutorial_guess_intro_desc =>
      'Önce tüm orta kelimeleri tahmin etmelisiniz. Tahmininize başlamak için boş bir slota dokunun.';

  @override
  String get tutorial_guess_success_title => 'Harika İş!';

  @override
  String get tutorial_guess_success_desc =>
      'İlk kelimeyi buldun! Bulmacayı tamamlamak için devam et.';

  @override
  String get tutorial_guess_keyboard_title => 'Tahmininizi Yazın';

  @override
  String get tutorial_guess_keyboard_desc =>
      'Klavyeyi kullanarak bir kelime yazın. Unutmayın: komşu kelimelerden sadece bir harf farklı olmalı!';

  @override
  String get tutorial_guess_hints_title => 'Yardıma İhtiyacınız Var mı?';

  @override
  String get tutorial_guess_hints_desc =>
      'Seviye başına 3 ipucunuz var. Takıldığınızda harfleri açığa çıkarmak veya ipucu almak için onları akıllıca kullanın.';

  @override
  String get tutorial_guess_timer_title => 'Zamanla Yarışın';

  @override
  String get tutorial_guess_timer_desc =>
      'Daha hızlı tamamlama daha fazla yıldız kazandırır! Merak etmeyin, zaman sınırı yok.';

  @override
  String get tutorial_combo_intro_title => 'Combo Sistemi!';

  @override
  String get tutorial_combo_intro_desc =>
      'Doğru tahminlerinizi sürdürerek combo yapın ve skorunuzu katlayın! Her doğru cevap art arda çarpanınızı artırır.';

  @override
  String get tutorial_sort_intro_title => 'Faz 2: Sıralama';

  @override
  String get tutorial_sort_intro_desc =>
      'Mükemmel! Tüm ara kelimeleri buldun. Şimdi bunları doğru sıraya diz - her kelime bir sonrakinden sadece BİR harf farklı olmalı.';

  @override
  String get tutorial_sort_action_title => 'Gerçek Zamanlı Doğrulama';

  @override
  String get tutorial_sort_action_desc =>
      'Kelimeleri sürükleyip sırala. Doğru konumdakiler yeşil, yanlış olanlar kırmızı kenarlıkla gösterilecek. Tüm kelimeler yeşil olunca BAŞLANGIÇ ve BİTİŞ otomatik açılır!';

  @override
  String get tutorial_final_intro_title => 'Faz 3: Final Meydan Okuması';

  @override
  String get tutorial_final_intro_desc =>
      'Neredeyse bitti! Şimdi sıralanmış orta kelimelere dayanarak BAŞLANGIÇ ve BİTİŞ kelimelerinin ne olduğunu bulun.';

  @override
  String get tutorial_final_start_title => 'Başlangıç Kelimesini Tahmin Edin';

  @override
  String get tutorial_final_start_desc =>
      'İlk orta kelimeden önce hangi kelime gelir? Bir harf farklı olmalı.';

  @override
  String get tutorial_final_end_title => 'Bitiş Kelimesini Tahmin Edin';

  @override
  String get tutorial_final_end_desc =>
      'Son orta kelimeden sonra hangi kelime gelir? Merdiveni tamamlayın!';

  @override
  String get tutorial_complete_congrats_title => 'Hazırsınız!';

  @override
  String get tutorial_complete_congrats_desc =>
      'Tebrikler! Artık CrossClimber\'ı nasıl oynayacağınızı biliyorsunuz. İyi eğlenceler ve kendinize meydan okuyun!';

  @override
  String get skipTutorial => 'Tutorial\'ı Atla';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get showTips => 'İpuçlarını Göster';

  @override
  String get resetTutorial => 'Tutorial\'ı Sıfırla';

  @override
  String get outOfLivesTitle => 'Canın Bitti!';

  @override
  String get outOfLivesMessage =>
      'Canın bitti. Yenilenmesini bekleyebilir veya kredi kullanarak devam edebilirsin.';

  @override
  String nextLifeIn(String time) {
    return 'Sonraki can: $time';
  }

  @override
  String get buyOneLife => '1 Can Al (50 💰)';

  @override
  String get buyAllLives => 'Tüm Canları Al (100 💰)';

  @override
  String get exitGame => 'Oyundan Çık';

  @override
  String get returnToMainMenu => 'Ana Menüye Dön?';

  @override
  String get progressLostWarning =>
      'Mevcut ilerlemeniz kaybolacak. Emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get exit => 'Çık';

  @override
  String get startEndUnlocked => 'BAŞLANGIÇ & BİTİŞ Açıldı!';

  @override
  String get shopTitle => 'Market';

  @override
  String get freeCreditsTitle => 'Ücretsiz Kazan';

  @override
  String get freeCreditsSubtitle => 'Reklam izle, bedava kredi kazan';

  @override
  String get creditPackageTitle => 'Kredi Paketi';

  @override
  String get creditPackageSubtitle => 'Gerçek para ile kredi satın al';

  @override
  String get lifePackageTitle => 'Can Paketi';

  @override
  String get lifePackageSubtitle => 'Kredi ile can satın al';

  @override
  String get hintPackageTitle => 'İpucu Paketi';

  @override
  String get hintPackageSubtitle => 'Kredi ile ipucu satın al';

  @override
  String nCredits(int amount) {
    return '$amount Kredi';
  }

  @override
  String get mostPopular => 'EN POPÜLER';

  @override
  String get popularLabel => 'POPÜLER';

  @override
  String nLives(int amount) {
    return '$amount Can';
  }

  @override
  String get buyOneLifeDesc => 'Tek can satın al';

  @override
  String get buyFiveLives => '5 cana çıkar';

  @override
  String get revealWord => 'Kelimeyi Göster';

  @override
  String get revealWordDesc => 'Seçili kelimeyi tamamen açar';

  @override
  String get undoMove => 'Geri Al';

  @override
  String get undoMoveDesc => 'Son yaptığın hareketi geri alır';

  @override
  String get dailyRewardClaim => 'Günlük Ödülünü Al! 🎁';

  @override
  String get dailyRewardAmount => '20+ Kredi + Bonuslar';

  @override
  String dailyRewardStreak(int days) {
    return 'Streak: $days gün';
  }

  @override
  String get watchAdsTitle => 'Reklam İzle, Kazan';

  @override
  String get watchAdsSubtitle => 'Günde 5 reklam izleyebilirsin';

  @override
  String get watchAdCredits => '+10 Kredi';

  @override
  String get watchAdHint => '+1 İpucu';

  @override
  String get dailyRewardTitle => 'Günlük Ödül!';

  @override
  String get alreadyClaimedToday => 'Bugünkü ödülünü zaten aldın!';

  @override
  String get notEnoughCredits => 'Yeterli kredin yok!';

  @override
  String get livesAlreadyFull => 'Canın zaten dolu!';

  @override
  String get great => 'Harika!';

  @override
  String get share => 'Paylaş';

  @override
  String get shareResult => 'Sonucu Paylaş';

  @override
  String get customKeyboard => 'Özel Klavye';

  @override
  String get customKeyboardDesc => 'Oyun içi QWERTY klavyeyi kullan';

  @override
  String get hapticFeedback => 'Dokunsal Geri Bildirim';

  @override
  String get hapticFeedbackDesc => 'Titreşim ve dokunsal geri bildirim';

  @override
  String get gotIt => 'Anladım!';

  @override
  String get skipLabel => 'Atla';

  @override
  String get progress => 'İlerleme';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get achievementFirstWin => 'İlk Zafer';

  @override
  String get achievementTenLevels => 'On Seviye';

  @override
  String get achievementSpeedDemon => 'Hız Şeytanı';

  @override
  String get achievementMarathonRunner => 'Maraton Koşucusu';

  @override
  String get achievementThirtyLevels => 'Otuz Seviye';

  @override
  String get achievementPerfectStreak5 => '5\'li Mükemmel Seri';

  @override
  String get achievementCenturyClub => 'Yüzler Kulübü';

  @override
  String get achievementHintlessHero => 'İpucusuz Kahraman';

  @override
  String get achievementErrorFree => 'Hatasız';

  @override
  String get achievementEarlyBird => 'Sabah Kuşu';

  @override
  String get achievementNightOwl => 'Gece Kuşu';

  @override
  String get achievementPerfectStreak10 => '10\'lu Mükemmel Seri';

  @override
  String get achievementFiftyLevels => 'Elli Seviye';

  @override
  String get achievementThreeStarPerfectionist => 'Üç Yıldız Mükemmeliyetçisi';

  @override
  String get achievementNoHintsMaster => 'İpucu Ustası';

  @override
  String get achievementDescFirstWin => 'İlk seviyeni tamamla';

  @override
  String get achievementDescTenLevels => '10 seviye tamamla';

  @override
  String get achievementDescSpeedDemon =>
      'Bir seviyeyi 30 saniyenin altında tamamla';

  @override
  String get achievementDescMarathonRunner => 'Tek oturumda 10 seviye oyna';

  @override
  String get achievementDescThirtyLevels => '30 seviye tamamla';

  @override
  String get achievementDescPerfectStreak5 => 'Ardışık 5 seviyede 3 yıldız al';

  @override
  String get achievementDescCenturyClub => '100 seviye tamamla';

  @override
  String get achievementDescHintlessHero =>
      'İpucu kullanmadan 10 seviye tamamla';

  @override
  String get achievementDescErrorFree =>
      'Hiç hata yapmadan bir seviyeyi tamamla';

  @override
  String get achievementDescEarlyBird => 'Sabah 9\'dan önce bir seviye tamamla';

  @override
  String get achievementDescNightOwl => 'Gece 11\'den sonra bir seviye tamamla';

  @override
  String get achievementDescPerfectStreak10 =>
      'Ardışık 10 seviyede 3 yıldız al';

  @override
  String get achievementDescFiftyLevels => '50 seviye tamamla';

  @override
  String get achievementDescThreeStarPerfectionist => '20 seviyede 3 yıldız al';

  @override
  String get achievementDescNoHintsMaster =>
      'İpucu kullanmadan 50 seviye tamamla';

  @override
  String get yourStatistics => 'İstatistiklerin';

  @override
  String get gamesPlayed => 'Oynanan Oyun';

  @override
  String get gamesWon => 'Kazanılan Oyun';

  @override
  String get performance => 'Performans';

  @override
  String get winRate => 'Kazanma Oranı';

  @override
  String get avgStars => 'Ort. Yıldız';

  @override
  String get timeStatistics => 'Zaman İstatistikleri';

  @override
  String get totalTimePlayed => 'Toplam Oynama Süresi';

  @override
  String get bestTime => 'En İyi Süre';

  @override
  String get averageTime => 'Ortalama Süre';

  @override
  String get starDistribution => 'Yıldız Dağılımı';

  @override
  String get totalStarsEarned => 'Toplam Kazanılan Yıldız';

  @override
  String get perfectGames => 'Mükemmel Oyunlar';

  @override
  String get noGamesPlayedYet => 'Henüz oyun oynamamışsın';

  @override
  String get wins => 'Kazanma';

  @override
  String get losses => 'Kaybetme';

  @override
  String get shareStatistics => 'İstatistikleri Paylaş';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get failedToLoadDailyChallenge => 'Günlük challenge yüklenemedi';

  @override
  String get failedToLoadChallenge => 'Challenge yüklenemedi';

  @override
  String get difficultyLabel => 'Zorluk';

  @override
  String get wordsLabel => 'Kelimeler';

  @override
  String get starsLabel => 'Yıldızlar';

  @override
  String get timeLabel => 'Süre';

  @override
  String get scoreLabel => 'Puan';

  @override
  String get viewResult => 'Sonucu Gör';

  @override
  String get playNow => 'Hemen Oyna';

  @override
  String get expert => 'Uzman';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get monthJanuary => 'Ocak';

  @override
  String get monthFebruary => 'Şubat';

  @override
  String get monthMarch => 'Mart';

  @override
  String get monthApril => 'Nisan';

  @override
  String get monthMay => 'Mayıs';

  @override
  String get monthJune => 'Haziran';

  @override
  String get monthJuly => 'Temmuz';

  @override
  String get monthAugust => 'Ağustos';

  @override
  String get monthSeptember => 'Eylül';

  @override
  String get monthOctober => 'Ekim';

  @override
  String get monthNovember => 'Kasım';

  @override
  String get monthDecember => 'Aralık';

  @override
  String get yourStats => 'İstatistiklerin';

  @override
  String get completedLabel => 'Tamamlanan';

  @override
  String get bestStreak => 'En İyi Seri';
}
