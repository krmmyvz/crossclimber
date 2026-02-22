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
  String get tutorialResetSuccess => 'Tutorial ilerlemesi sıfırlandı.';

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
  String get buyOneLife => '1 Can Al (50 Kredi)';

  @override
  String get buyAllLives => 'Tüm Canları Al (100 Kredi)';

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
  String get dailyRewardClaim => 'Günlük Ödülünü Al!';

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
  String get achievementStreak7Days => 'Haftanın Savaşçısı';

  @override
  String get achievementStreak14Days => 'İki Hafta';

  @override
  String get achievementStreak30Days => 'Aylık Şampiyon';

  @override
  String get achievementStreak60Days => '2 Aylık Seri';

  @override
  String get achievementStreak100Days => 'Yüzüncü Gün';

  @override
  String get achievementCombo5x => 'Kombo Başlangıcı';

  @override
  String get achievementCombo8x => 'Kombo Ustası';

  @override
  String get achievementCombo10x => 'Kombo Efsanesi';

  @override
  String get achievementSpeed60s => 'Hızlı Koşucu';

  @override
  String get achievementSpeed45s => 'Yıldırım';

  @override
  String get achievementAllLevels => 'Tüm Seviyeler Tamam';

  @override
  String get achievementLegendaryRank => 'Efsanevi';

  @override
  String get achievementShareResults => 'Paylaşımcı';

  @override
  String get achievementDailyChallengeFirst => 'Günlük Meydan Okuyucu';

  @override
  String get achievementDailyChallenge30 => 'Günlük Şampiyon';

  @override
  String get achievementDescStreak7Days => '7 gün üst üste giriş yap';

  @override
  String get achievementDescStreak14Days => '14 gün üst üste giriş yap';

  @override
  String get achievementDescStreak30Days => '30 gün üst üste giriş yap';

  @override
  String get achievementDescStreak60Days => '60 gün üst üste giriş yap';

  @override
  String get achievementDescStreak100Days => '100 gün üst üste giriş yap';

  @override
  String get achievementDescCombo5x => '5x kombo yap';

  @override
  String get achievementDescCombo8x => '8x kombo yap';

  @override
  String get achievementDescCombo10x => '10x kombo yap';

  @override
  String get achievementDescSpeed60s => 'Bir seviyeyi 60 saniyede tamamla';

  @override
  String get achievementDescSpeed45s => 'Bir seviyeyi 45 saniyede tamamla';

  @override
  String get achievementDescAllLevels => 'Tüm mevcut seviyeleri tamamla';

  @override
  String get achievementDescLegendaryRank => 'Efsanevi rütbesine ulaş';

  @override
  String get achievementDescShareResults => 'Sonuçlarını 5 kez paylaş';

  @override
  String get achievementDescDailyChallengeFirst =>
      'İlk günlük meydan okumanı tamamla';

  @override
  String get achievementDescDailyChallenge30 =>
      '30 günlük meydan okuma tamamla';

  @override
  String get achievementRarityCommon => 'Yaygın';

  @override
  String get achievementRarityRare => 'Nadir';

  @override
  String get achievementRarityLegendary => 'Efsanevi';

  @override
  String get achievementBadgeSelect => 'Rozet Seç';

  @override
  String get achievementBadgeActive => 'Aktif Rozet';

  @override
  String get achievementBadgeRemove => 'Rozeti Kaldır';

  @override
  String get achievementBadgeRemoved => 'Rozet kaldırıldı';

  @override
  String get achievementBadgeSelected => 'Rozet seçildi!';

  @override
  String get achievementUnlocked => 'Başarım Açıldı';

  @override
  String get streakMilestoneTitle => 'Seri Kilometre Taşı!';

  @override
  String streakMilestoneDesc(int days, int credits) {
    return '$days günlük seri! +$credits kredi!';
  }

  @override
  String get streakFreezeTitle => 'Seri Dondurma';

  @override
  String get streakFreezeDesc => 'Harcanan 1 gün için serini korur';

  @override
  String streakFreezeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dondurma mevcut',
      one: '1 dondurma mevcut',
    );
    return '$_temp0';
  }

  @override
  String get streakFreezeAutoUsed => 'Seri dondurma kullanıldı! Serin güvende.';

  @override
  String get streakLossWarningTitle => 'Serin tehlikede!';

  @override
  String get streakLossWarning => 'Serini kaybetme! Bugün oyna!';

  @override
  String get streakDays => 'günlük seri';

  @override
  String get streakTodayCompleted => 'Bugün tamam';

  @override
  String get streakTodayIncomplete => 'Bugün oyna!';

  @override
  String get streakFreezeAvailable => 'dondurma';

  @override
  String streakNextMilestone(int days) {
    return 'Sonraki hedef: $days gün';
  }

  @override
  String streakMilestoneReward(int credits) {
    return 'Ödül: $credits kredi';
  }

  @override
  String get streakMilestones => 'Kilometre Taşları';

  @override
  String get streakAllMilestonesReached => 'Tüm hedeflere ulaşıldı!';

  @override
  String get streakFreezeShopTitle => 'Seri Koruması';

  @override
  String get streakFreezeShopSubtitle => 'Bir daha seri asla kaybetme';

  @override
  String get buyStreakFreeze1 => '1 Dondurma';

  @override
  String get buyStreakFreeze3 => '3 Dondurma';

  @override
  String get streakFreezePurchased => 'Seri dondurma satın alındı!';

  @override
  String get streakFreezeZero => 'Dondurma yok';

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

  @override
  String comboLabel(int count) {
    return '$count KOMBO';
  }

  @override
  String comboMultiplierLabel(String multiplier) {
    return '${multiplier}x Çarpan';
  }

  @override
  String comboXLabel(int count, String multiplier) {
    return 'Kombo x$count (${multiplier}x)';
  }

  @override
  String get comboBreak => 'KOMBO BOZULDU';

  @override
  String comboLostLabel(int count) {
    return '${count}x kombo kaybedildi';
  }

  @override
  String undoTooltipMessage(String action, int count) {
    return 'Geri Al: $action\n$count geri alma hakkı kaldı';
  }

  @override
  String get noUndosAvailable => 'Geri alma hakkı kalmadı';

  @override
  String get undoConfirmTitle => 'Geri Al?';

  @override
  String undoConfirmMessageWithAction(String action, int count) {
    return 'Bu işlemi geri alacaksınız:\n\n\"$action\"\n\nKalan geri alma hakkı: $count';
  }

  @override
  String undoConfirmMessage(int count) {
    return 'Son işleminizi geri almak istiyor musunuz?\n\nKalan geri alma hakkı: $count';
  }

  @override
  String get undoReverted => 'İşlem geri alındı';

  @override
  String undosRemainingCount(int count) {
    return '$count geri alma hakkı kaldı';
  }

  @override
  String rewardCreditsLabel(int amount) {
    return '+$amount Kredi';
  }

  @override
  String rewardRevealHints(int count) {
    return '+$count Reveal İpucu';
  }

  @override
  String rewardUndoHints(int count) {
    return '+$count Undo İpucu';
  }

  @override
  String get dailyAdLimitReached => 'Günlük limit doldu! (5/5)';

  @override
  String creditsEarnedNotification(int amount) {
    return '+$amount kredi kazandın!';
  }

  @override
  String get revealHintEarned => '+1 Reveal ipucu kazandın!';

  @override
  String get undoHintEarned => '+1 Undo ipucu kazandın!';

  @override
  String hintsPurchasedNotification(int amount) {
    return '$amount ipucu satın alındı!';
  }

  @override
  String livesPurchasedNotification(int amount) {
    return '$amount can satın alındı!';
  }

  @override
  String creditPurchaseComingSoon(int amount, String price) {
    return 'Gerçek para ile $amount kredi satın alma: $price (Yakında!)';
  }

  @override
  String get levelsLabel => 'Seviyeler';

  @override
  String get streakLabel => 'Seri';

  @override
  String get creditsEarnedLabel => 'Kazanılan Kredi';

  @override
  String get completedToday => 'Bugün Tamamlandı!';

  @override
  String get todaysChallenge => 'Bugünün Challenge\'ı';

  @override
  String shareResultHeader(int levelId) {
    return 'CrossClimber Seviye $levelId Tamamlandı!';
  }

  @override
  String get shareAchievementUnlocked => 'Başarım Açıldı!';

  @override
  String get shareAchievementCTA =>
      'CrossClimber oynuyorum - En zorlu kelime bulmaca oyunu!';

  @override
  String get shareDailyChallengeTitle => 'CrossClimber Günlük Challenge';

  @override
  String shareDailyLevelCompleted(int levelId) {
    return 'Seviye $levelId: Tamamlandı!';
  }

  @override
  String shareDailyLevelFailed(int levelId) {
    return 'Seviye $levelId: Başarısız';
  }

  @override
  String get shareDailyChallengeCTA => 'Günlük challenge\'a katıl!';

  @override
  String get shareMyStatsTitle => 'CrossClimber İstatistiklerim';

  @override
  String get shareStatsCTA => 'CrossClimber\'da benimle yarış!';

  @override
  String get shareStatisticsCTA => 'Benim istatistiklerimi geçebilir misin?';

  @override
  String get onboardingPage1Title => 'Kelimeleri Tırman!';

  @override
  String get onboardingPage1Desc =>
      'Başlangıç kelimesinden bitiş kelimesine gizli adımlarla tırman!';

  @override
  String get onboardingPage2Title => 'Tahmin Et, Sırala, Çöz!';

  @override
  String get onboardingPage2Desc =>
      '3 adımda kazan: Gizli kelimeleri tahmin et → Doğru sırala → Son kelimeyi çöz!';

  @override
  String get onboardingPage3Title => 'Günlük Meydan Okuma';

  @override
  String get onboardingPage3Desc =>
      'Her gün yeni bir bulmaca. Serisini kır, rekorunu geçmeye bak!';

  @override
  String get onboardingPage4Title => 'Kombo Zinciri Kur!';

  @override
  String get onboardingPage4Desc =>
      'Art arda doğru tahminler puanını çarpar — 2x, 3x, 4x bonus puan kazan!';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingStart => 'Başla!';

  @override
  String get tutorialDontShowAgain => 'Bir daha gösterme';

  @override
  String get emptyAchievementsTitle => 'Henüz Başarım Yok';

  @override
  String get emptyAchievementsDesc =>
      'Başarımları açmak ve bonus kredi kazanmak için oynamaya başla!';

  @override
  String get emptyStatisticsTitle => 'Henüz İstatistik Yok';

  @override
  String get emptyStatisticsDesc =>
      'İstatistiklerin ilk oyunun ardından burada görünecek.';

  @override
  String get dailyMotivationTitle => 'Bugünün Meydan Okumasına Hazır mısın?';

  @override
  String get dailyMotivationDesc =>
      'Her gün yeni bir bulmaca. Serini devam ettirmek için tamamla!';

  @override
  String get dailyMotivationButton => 'Hemen Oyna';

  @override
  String get discoveryShopTitle => 'Mağazaya Hoş Geldin!';

  @override
  String get discoveryShopDesc =>
      'Kredilerinle ipucu ve can satın al. Reklamlar izleyerek günlük ücretsiz ödüller kazan!';

  @override
  String get discoveryAchievementsTitle => 'Başarımları Aç!';

  @override
  String get discoveryAchievementsDesc =>
      'Dönüm noktalarını tamamlayarak rozetler aç ve bonus kredi kazan.';

  @override
  String get discoveryDailyTitle => 'Serini Gündeme Taşı!';

  @override
  String get discoveryDailyDesc =>
      'Serinizi canlı tutmak ve ödüller kazanmak için günlük meydan okumayı her gün tamamlayın.';

  @override
  String get discoveryGotIt => 'Anlaştık!';

  @override
  String get homeSubtitle => 'Kelimelere zirveye tırman!';

  @override
  String get homeQuickPlay => 'Hızlı Oyna';

  @override
  String homeLevelsWithProgress(int level) {
    return 'Seviyeler (Level $level)';
  }

  @override
  String homeContinueLevel(int level) {
    return 'Devam Et: Level $level';
  }

  @override
  String homeStreakDays(int days) {
    return '$days';
  }

  @override
  String homeTotalStars(int count) {
    return '$count';
  }

  @override
  String homeAchievementsProgress(int unlocked, int total) {
    return '$unlocked/$total';
  }

  @override
  String zoneProgress(int completed, int total) {
    return '$completed/$total tamamlandı';
  }

  @override
  String get phaseSortBanner => 'Şimdi Sırala!';

  @override
  String get phaseFinalBanner => 'Son Kelimeleri Bul!';

  @override
  String get completion3Stars => 'Mükemmel! Tüm yıldızlar!';

  @override
  String get completion2Stars => 'Harika iş!';

  @override
  String get completion1Star =>
      'Fena değil! Daha fazla yıldız için tekrar dene.';

  @override
  String get completion0Stars => 'Devam et, yapabilirsin! Tekrar dene.';

  @override
  String get completionHintSuggestion =>
      'İpucu: Puanını artırmak için ipucu kullan.';

  @override
  String get sharePreviewTitle => 'Sonucu Paylaş';

  @override
  String get sharePreviewCopy => 'Kopyala';

  @override
  String get sharePreviewCopied => 'Kopyalandı!';

  @override
  String get sharePreviewClose => 'Kapat';

  @override
  String get settingsHighContrast => 'Yüksek Kontrast Modu';

  @override
  String get settingsHighContrastDesc =>
      'Daha iyi okunabilirlik için renk kontrastını artır';

  @override
  String get semanticsDragInstruction =>
      'Sürükleyip yeniden sıralamak için çift dokunun ve basılı tutun';

  @override
  String semanticsComboMultiplier(int count, String multiplier) {
    return 'Kombo: arka arkaya $count, ${multiplier}x çarpan';
  }

  @override
  String semanticsLevelCard(int id, String status, int stars) {
    return 'Level $id, $status, $stars yıldız';
  }

  @override
  String get semanticsLocked => 'kilitli';

  @override
  String get semanticsUnlocked => 'kilidi açık';

  @override
  String get semanticsCompleted => 'tamamlandı';

  @override
  String get semanticsActionPlay => 'oyna';

  @override
  String get semanticsActionOpen => 'aç';

  @override
  String get semanticsActionAddLetter => 'harf ekle';

  @override
  String get rankNovice => 'Acemi';

  @override
  String get rankWordStudent => 'Kelime Öğrencisi';

  @override
  String get rankWordMaster => 'Kelime Ustası';

  @override
  String get rankPuzzleSolver => 'Bulmaca Çözücü';

  @override
  String get rankMountainClimber => 'Dağ Tırmanıcısı';

  @override
  String get rankWordEagle => 'Kelime Kartalı';

  @override
  String get rankWordKing => 'Kelime Kralı';

  @override
  String get rankDiamondMind => 'Elmas Zeka';

  @override
  String get rankLegend => 'Efsane';

  @override
  String get rankCrossClimberMaster => 'CrossClimber Ustası';

  @override
  String xpGained(int amount) {
    return '+$amount XP';
  }

  @override
  String totalXpLabel(int amount) {
    return 'Toplam XP: $amount';
  }

  @override
  String get rankUpTitle => 'Seviye Atladın!';

  @override
  String rankUpMessage(String rankName) {
    return '$rankName seviyesine ulaştın!';
  }

  @override
  String get profileCardTitle => 'Oyuncu Profili';

  @override
  String xpProgress(int current, int target) {
    return '$current / $target XP';
  }

  @override
  String get dailyChallengeXp => 'Günlük Meydan Okuma XP';

  @override
  String comboXpBonus(int amount) {
    return 'Kombo Bonusu: +$amount XP';
  }

  @override
  String get dailyCalendarTitle => 'Günlük Ödül Takvimi';

  @override
  String dailyCalendarDay(int day) {
    return '$day. Gün';
  }

  @override
  String get dailyCalendarClaim => 'Al!';

  @override
  String get dailyCalendarClaimed => 'Alındı';

  @override
  String dailyCalendarNextIn(String time) {
    return 'Sıradaki: $time';
  }

  @override
  String get dailyCalendarStreakReset => 'Seri sıfırlandı — 1. Güne dönüldü!';

  @override
  String dailyCalendarRewardCredits(int amount) {
    return '$amount kredi';
  }

  @override
  String get dailyCalendarRewardReveal => '1 İpucu';

  @override
  String get dailyCalendarRewardUndo => '1 Geri Al';

  @override
  String get dailyCalendarRewardSpecial => 'Özel Tema!';

  @override
  String get dailyCalendarRewardSummary => 'Ödül alındı!';

  @override
  String get dailyCalendarFomoWarning => 'Yarını kaçırma!';

  @override
  String get tournamentTitle => 'Haftalık Turnuva';

  @override
  String tournamentWeek(String week) {
    return 'Hafta $week';
  }

  @override
  String get tournamentActive => 'Aktif';

  @override
  String get tournamentEnded => 'Bitti';

  @override
  String tournamentEndsIn(String time) {
    return 'Bitiş: $time';
  }

  @override
  String tournamentNextIn(String time) {
    return 'Sıradaki: $time';
  }

  @override
  String get tournamentLeaderboard => 'Sıralama';

  @override
  String get tournamentLevels => 'Turnuva Seviyeleri';

  @override
  String get tournamentMyRank => 'Sıralamanız';

  @override
  String tournamentRank(int rank) {
    return '#$rank';
  }

  @override
  String tournamentScore(int score) {
    return '$score puan';
  }

  @override
  String get tournamentRewards => 'Ödüller';

  @override
  String get tournamentPlay => 'Oyna';

  @override
  String get tournamentLevelCompleted => 'Tamam';

  @override
  String get tournamentNotParticipating => 'Henüz katılmadınız';

  @override
  String tournamentLevelsProgress(int count) {
    return '$count/7 seviye';
  }

  @override
  String tournamentCreditsReward(int amount) {
    return '$amount Kredi';
  }

  @override
  String get tournamentParticipation => 'Katılım';

  @override
  String get tournamentOffline => 'Turnuva internet bağlantısı gerektiriyor';

  @override
  String get tournamentLoadError => 'Turnuva yüklenemedi';

  @override
  String get tournamentScoreSubmitted => 'Puanın sıralamaya kaydedildi!';

  @override
  String get tournamentHomeBanner => 'Haftalık Turnuva';

  @override
  String get tournamentJoin => 'Katıl!';

  @override
  String get tournamentDifficultyEasy => 'Kolay';

  @override
  String get tournamentDifficultyMedium => 'Orta';

  @override
  String get tournamentDifficultyHard => 'Zor';

  @override
  String get idleMotivation1 => 'Bir kelime daha?';

  @override
  String get idleMotivation2 => 'Yapabilirsin!';

  @override
  String get idleMotivation3 => 'Farklı bir yaklaşım dene?';

  @override
  String get settingsGroupProfile => 'Profil & Hesap';

  @override
  String get settingsGroupAppearance => 'Görünüm';

  @override
  String get settingsGroupGameplay => 'Oyun Ayarları';

  @override
  String get settingsGroupSoundHaptic => 'Ses & Dokunsal';

  @override
  String get settingsGroupHelp => 'Yardım & Bilgi';

  @override
  String get chooseTheme => 'Tema Seç';

  @override
  String get premiumTheme => 'Premium';

  @override
  String get unlockInShop => 'Mağazadan Aç';

  @override
  String get themeUnlocked => 'Tema açıldı!';

  @override
  String get profileTitle => 'Profil';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get chooseAvatar => 'Avatar Seç';

  @override
  String get displayName => 'Görünen Ad';

  @override
  String get displayNameHint => 'Adınızı girin';

  @override
  String get saveProfile => 'Kaydet';

  @override
  String get profileSaved => 'Profil kaydedildi!';

  @override
  String get connectedAccounts => 'Bağlı Hesaplar';

  @override
  String get googleConnected => 'Google — Bağlı';

  @override
  String get googleNotConnected => 'Google — Bağlı değil';

  @override
  String get connectGoogle => 'Bağla';

  @override
  String get disconnectGoogle => 'Bağlantıyı Kes';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountDesc =>
      'Hesabınızı ve tüm verilerinizi kalıcı olarak silin. Bu işlem geri alınamaz.';

  @override
  String get deleteAccountConfirm =>
      'Hesabınızı silmek istediğinizden emin misiniz? Tüm ilerleme, başarımlar ve satın almalar kalıcı olarak kaybolacak.';

  @override
  String get deleteAccountButton => 'Kalıcı Olarak Sil';

  @override
  String get rankLabel => 'Rütbe';

  @override
  String get totalXp => 'Toplam XP';

  @override
  String get faq => 'SSS';

  @override
  String get licenses => 'Lisanslar';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String unlockThemeTitle(String themeName) {
    return '$themeName Kilidini Aç';
  }

  @override
  String unlockThemeDesc(int cost) {
    return 'Bu premium temayı $cost kredi ile açın.';
  }

  @override
  String get unlockButton => 'Kilidi Aç';

  @override
  String yourCredits(int amount) {
    return 'Krediniz: $amount';
  }

  @override
  String get solveMiddleWordsFirst =>
      'Kilidi açmak için ortadaki kelimeleri çözün';

  @override
  String get offlineBanner =>
      'Çevrimdışısınız. Bazı özellikler kullanılamayabilir.';

  @override
  String get backOnline => 'Tekrar çevrimiçisiniz!';

  @override
  String get doubleRewards => 'Ödülleri İkiye Katla';

  @override
  String get watchAdForLife => 'Reklam İzle, Can Kazan';

  @override
  String get adNotAvailable =>
      'Reklam şu anda mevcut değil. Lütfen daha sonra tekrar deneyin.';
}
