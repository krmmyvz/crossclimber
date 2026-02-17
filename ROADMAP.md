# CrossClimber — Evolution Roadmap & Master Checklist

> **Oluşturulma Tarihi:** 2026-02-14  
> **Amaç:** Mevcut local-only oyunu, bulut destekli, gelir üreten, ölçeklenebilir bir ürüne dönüştürmek.  
> **Kural:** Her madde tamamlandığında `[ ]` → `[x]` olarak işaretlenir. Hiçbir adım atlanmaz.

---

## Phase 0: Code Quality & Housekeeping (Temizlik)

> Yeni özellik eklemeden önce mevcut teknik borçları temizle.

### 0.1 Lint & Static Analysis ✅

- [x] `analysis_options.yaml` — `flutter_lints` + ekstra kurallar eklendi (15 kural)
  - [x] `prefer_const_constructors`
  - [x] `prefer_const_declarations`
  - [x] `avoid_print` (debug print'leri kaldır)
  - [x] `always_use_package_imports`
- [x] `flutter analyze` çalıştırıldı → `dart fix --apply` ile 273 fix uygulandı, 37 dosya güncellendi → **0 issue** ✅
- [x] Tüm `debugPrint` çağrıları `kDebugMode` guard ile sarıldı (`level_repository.dart`)

### 0.2 Branding Tutarlılığı ✅

- [x] `lib/services/share_service.dart` — "WordClimb" referansları "CrossClimber" olarak değiştirildi
  - [x] `shareResult()` — text + subject düzeltildi
  - [x] `shareAchievement()` — text ve hashtag düzeltildi
  - [x] `shareDailyChallenge()` — text ve hashtag düzeltildi
  - [x] `shareStats()` — text ve hashtag düzeltildi
- [x] `app_en.arb` — `appTitle`, `tutorial_intro_welcome_title`, `tutorial_complete_congrats_desc` düzeltildi
- [x] `app_tr.arb` — Aynı 3 key CrossClimber olarak güncellendi
- [x] `flutter gen-l10n` ile lokalizasyon dosyaları yeniden oluşturuldu
- [x] `BRANDING.md` — App Store / Play Store açıklamaları, ASO anahtar kelimeleri, renk paleti ve ton rehberi oluşturuldu

### 0.3 Lokalizasyon (i18n) Eksiklikleri ✅

- [x] `lib/screens/settings_screen.dart` — Hardcoded Türkçe stringler düzeltildi:
  - [x] `'Kelimeyi tamamladığınızda otomatik kontrol edilsin'` → `l10n.autoCheckDesc`
  - [x] `'Tüm kelimeleri bulduğunuzda otomatik sıralama başlasın'` → `l10n.autoSortDesc`
- [x] `lib/l10n/app_en.arb` — `autoCheckDesc`, `autoSortDesc`, `appearance` key'leri eklendi
- [x] `lib/l10n/app_tr.arb` — Aynı key'ler Türkçe değerlerle eklendi
- [x] `_SettingsSection` widget'ındaki `'Appearance'` → `l10n.appearance` olarak lokalize edildi
- [x] `lib/services/advanced_hint_service.dart` — `getHintDescription()` hiçbir yerde çağrılmıyor, kullanıldığında lokalize edilecek
- [x] Tüm dosyalarda hardcoded string taraması yapıldı — sadece tema isimleri (Dracula, Nord, Gruvbox, Monokai gibi özel isimler) kaldı

### 0.4 Design Token Uyumu ✅

#### 0.4.1 BorderRadius — `BorderRadius.circular()` → `RadiiBR.*` Token

- [x] `lib/screens/daily_challenge/daily_challenge_screen.dart` — `BorderRadius.circular` → `RadiiBR` token
- [x] `lib/screens/game/game_screen.dart` — tüm `BorderRadius.circular` kullanımları
- [x] `lib/screens/game/game_screen_hints.dart` — tüm `BorderRadius.circular` kullanımları
- [x] `lib/screens/game/game_screen_widgets.dart` — tüm `BorderRadius.circular` kullanımları
- [x] `lib/widgets/undo_button.dart` — `BorderRadius.circular` → `RadiiBR`
- [x] `lib/widgets/tutorial_dialog.dart` — `BorderRadius.circular` → `RadiiBR`
- [x] `lib/widgets/letter_tile.dart` — `BorderRadius.circular` → `RadiiBR`
- [x] `lib/widgets/modern_dialog.dart` — `BorderRadius.circular` → `RadiiBR`
- [x] `lib/widgets/custom_keyboard.dart` — `BorderRadius.circular` → `RadiiBR`
- [x] `lib/widgets/game_keyboard.dart` — `BorderRadius.circular` → `RadiiBR`
- [x] Son kontrol: `grep -rn "BorderRadius.circular" lib/` → 0 sonuç (sadece token tanımları kaldı)

#### 0.4.2 Spacing — Hardcoded `SizedBox` → `VerticalSpacing` / `HorizontalSpacing`

- [x] `lib/screens/shop/shop_screen_cards.dart` — hardcoded spacing düzeltildi
- [x] `lib/widgets/tutorial_overlay.dart` — hardcoded spacing düzeltildi
- [x] `lib/widgets/tutorial_dialog.dart` — hardcoded spacing düzeltildi
- [x] `lib/widgets/custom_keyboard.dart` — hardcoded spacing düzeltildi
- [x] `lib/widgets/game_keyboard.dart` — hardcoded spacing düzeltildi
- [x] Son kontrol: Manuel audit tamamlandı

#### 0.4.3 EdgeInsets — Hardcoded padding → `SpacingInsets.*` / `Spacing.*`

- [x] Tüm dosyalarda `EdgeInsets.all(` / `EdgeInsets.symmetric(` taraması yapıldı
- [x] Hardcoded piksel değerleri `Spacing.*` token'ları ile değiştirildi
- [x] `SpacingInsets` preset'leri uygun yerlerde kullanıldı

---

## Phase 1: Architecture Refactoring

> God class'ları parçala, singleton'ları Riverpod'a taşı, testlerle güvence altına al.

### 1.1 GameNotifier Refactoring (823 → 629 satır) ✅

- [x] `lib/services/word_validator.dart` [YENİ] — Kelime doğrulama (isOneLetterDiff, isCorrectMiddleGuess, isCorrectFinalGuess)
- [x] `lib/services/combo_tracker.dart` [YENİ] — Kombo sistemi (increment, reset, getMultiplier)
- [x] `lib/services/score_calculator.dart` [YENİ] — Skor hesaplama (calculateFinalScore, calculateCredits)
- [x] `lib/services/undo_manager.dart` [YENİ] — Geri alma sistemi (saveSnapshot, performUndo, getLastAction)
- [x] `lib/services/sorting_engine.dart` [YENİ] — Sıralama fazı (reorderWords, validateOrder, isFullChainValid)
- [x] `lib/services/game_timer_service.dart` [YENİ] — Timer yönetimi (start, stop, dispose)
- [x] `lib/services/life_manager.dart` [YENİ] — Can sistemi (decreaseLife, restoreLife, checkRegeneration)
- [x] `lib/services/hint_manager.dart` [YENİ] — İpucu yönetimi (revealWord, useAdvancedHint)
- [x] `lib/providers/game_provider.dart` — Orchestrator olarak yeniden yazıldı
- [x] 5 test dosyası, 53 birim testi — hepsi geçiyor

### 1.2 Singleton → Riverpod Provider Dönüşümü

- [x] `lib/services/sound_service.dart` — Singleton pattern'ı kaldır
  - [x] `SoundService._internal()` constructor'ını kaldır
  - [x] `factory SoundService()` → normal constructor
  - [x] `soundServiceProvider` oluştur: `Provider<SoundService>((ref) => SoundService())`
  - [x] Tüm `SoundService()` çağrılarını `ref.read(soundServiceProvider)` ile değiştir
- [x] `lib/services/haptic_service.dart` — Singleton pattern'ı kaldır
  - [x] `HapticService._internal()` constructor'ını kaldır
  - [x] `factory HapticService()` → normal constructor
  - [x] `hapticServiceProvider` oluştur
  - [x] Tüm `HapticService()` çağrılarını provider ile değiştir
- [x] Dosya taraması: `grep -rn "SoundService()" lib/` ve `grep -rn "HapticService()" lib/` → 0 sonuç

### 1.3 Widget Decomposition (Büyük Widget'ları Parçala)

#### 1.3.1 `game_screen.dart` (1,057 satır)

- [x] `_GameScreenState._buildStatusBar` → ayrı `GameStatusBar` widget
- [x] `_GameScreenState._buildMiddleWords` + `_buildMiddleWordItem` → ayrı `MiddleWordsSection` widget
- [x] `_GameScreenState._buildMiddleWordContent` + `_getMiddleWordDecoration` → `MiddleWordTile` widget
- [x] `_GameScreenState._buildEndWordRow` → ayrı `EndWordRow` widget
- [x] `_GameScreenState._buildKeyboardSection` → ayrı `GameKeyboardSection` widget
- [x] `_GameScreenState._buildGameContent` → ana orchestrator, sadece child widget'ları birleştirmeli
- [x] `_GameScreenState` controller mantığı (`_handleInputChange`, `_handleInputSubmit`, `_selectMiddleWord`, `_selectEndWord`, `_saveCurrentInput`) → ya widget'lara taşı ya da ayrı controller sınıfına çıkar

#### 1.3.2 `statistics_screen.dart` (700 satır)

- [x] `_buildOverviewCard` → ayrı `StatsOverviewCard` widget dosyası
- [x] `_buildPerformanceGrid` + `_buildStatCard` → ayrı `PerformanceGrid` widget dosyası
- [x] `_buildTimeStatsCard` + `_buildTimeStatRow` → ayrı `TimeStatsCard` widget dosyası
- [x] `_buildAchievementProgressCard` → ayrı `AchievementProgressCard` widget dosyası
- [x] `_buildWinRateCard` + `_buildWinLossItem` → ayrı `WinRateCard` widget dosyası
- [x] `_buildStarDistributionCard` + `_buildStarItem` → ayrı `StarDistributionCard` widget dosyası
- [x] `statistics_screen.dart`'ı yeniden yaz — sadece layout orchestration

#### 1.3.3 `achievements_screen.dart` (451 satır)

- [x] `_buildProgressHeader` → ayrı widget
- [x] `_buildAchievementCard` → ayrı widget
- [x] Helper method'lar (`_getAchievementIcon`, `_getAchievementTitle`, `_getAchievementDescription`) → `AchievementUtils` helper class

### 1.4 Provider Scoping

- [x] `GameScreen`'i `ProviderScope` ile sar → `gameProvider` otomatik dispose olsun
- [x] `DailyChallengeScreen` için gerekiyorsa ayrı scope

---

## Phase 2: UI/UX Overflow Fixes & Polish

> Layout sorunlarını düzelt, küçük ekranlarda test et.

### 2.1 Overflow Risk Düzeltmeleri

- [x] `lib/screens/game/game_screen.dart` — Küçük ekran (< 5", 320dp genişlik) düzeltmesi:
  - [x] Middle words alanını `Expanded` + `ListView` ile sar (şu anda sabit yükseklik riski var)
  - [x] Keyboard ile oyun alanı arasında `Flexible` kullanarak alan paylaşımı yap
  - [x] 4+ middle word'lü level'larda test et
  - [x] `LayoutBuilder` veya `MediaQuery` ile tile boyutunu ekran boyutuna göre dinamik ayarla
- [x] `lib/screens/home_screen.dart` — Quick Access Buttons:
  - [x] Icon boyutu `32` hardcoded → `MediaQuery` veya `Spacing.iconSize` ile responsive yap
  - [x] Dar ekranlarda buton label'larının kesilmemesini doğrula
  - [x] `overflow: TextOverflow.ellipsis` + `maxLines: 2` yeterli mi test et
- [x] `lib/screens/level_map_screen.dart` — `_LevelCard`:
  - [x] Kart içi layout'u küçük ekranlarda test et
  - [x] Stars row + time + difficulty bilgisi taşma yapıyor mu kontrol et
- [x] `lib/screens/statistics_screen.dart` — Performance Grid:
  - [x] `GridView.count(crossAxisCount: 2)` — dar ekranlarda `_buildStatCard` text clip olabilir
  - [x] `FittedBox` veya `AutoSizeText` ile metin boyutunu otomatik ayarla

### 2.2 Responsive Design İyileştirmeleri

- [x] Ekran boyutu breakpoint'leri tanımla (`lib/theme/responsive.dart` [YENİ]):
  - [x] `compact`: < 360dp
  - [x] `medium`: 360-600dp
  - [x] `expanded`: > 600dp (tablet)
- [x] Game screen tile boyutunu breakpoint'e göre ayarla
- [x] Keyboard tuş boyutunu breakpoint'e göre ayarla
- [x] Font scale faktörünü breakpoint'e göre ayarla

### 2.3 Erişilebilirlik (Accessibility)

- [x] Tüm interaktif elementlere `Semantics` label ekle
- [x] Kontrast oranlarını kontrol et (WCAG AA minimum)
- [x] `ExcludeSemantics` kullanılmış mı kontrol et — gereksiz olanları kaldır
- [x] TalkBack / VoiceOver ile temel akışları test et

---

## Phase 3: Testing Altyapısı

> Refactoring ve migration güvenliği için test coverage'ı artır.

### 3.1 Unit Tests

- [x] `test/services/word_validator_test.dart` [YENİ]
  - [x] `isOneLetterDiff` — true/false senaryolar
  - [x] Edge case: farklı uzunlukta kelimeler
  - [x] Edge case: boş stringler
- [x] `test/services/score_calculator_test.dart` [YENİ]
  - [x] Zaman bonusu hesabı
  - [x] Kombo çarpanı hesabı
  - [x] Yıldız eşikleri (3★, 2★, 1★)
  - [x] Ceza hesabı (wrong attempts, hints)
- [x] `test/services/combo_tracker_test.dart` [YENİ]
  - [x] Kombo artışı ve çarpan eşikleri
  - [x] Kombo reset
- [x] `test/services/life_manager_test.dart` [YENİ]
  - [x] Can azaltma, ekleme, tam restore
  - [x] Kredi ile can alma
  - [x] Regen timer mantığı
- [x] `test/services/daily_challenge_service_test.dart` [YENİ]
  - [x] Seed üretimi determinizmi
  - [x] Streak hesabı
  - [x] Gün değişimi
- [ ] `test/services/achievement_service_test.dart` [YENİ]
  - [ ] Achievement unlock koşulları (15 tür)
  - [ ] Duplicate unlock engeli
  - [ ] Progress tracking
- [x] `test/services/statistics_repository_test.dart` [YENİ]
  - [x] `recordGameComplete` — istatistik güncelleme
  - [x] Best time güncelleme mantığı
  - [x] Win streak hesabı
- [x] `test/services/daily_reward_service_test.dart` [YENİ]
  - [x] Streak bonusu
  - [x] 7. gün özel ödülü
  - [x] Streak reset (gün atlama)
- [x] `test/providers/game_provider_test.dart` [YENİ]
  - [x] `startLevel` — state initialization
  - [x] `submitMiddleGuess` — correct/incorrect
  - [ ] `checkSorting` — doğru/yanlış sıralama
  - [x] `submitFinalGuess` — top/bottom
  - [x] `_completeLevel` — skor hesabı, kredi, yıldız
  - [x] `useHint` — stok azalması (kısmen, refactoring gerekebilir)
  - [x] `performUndo` — state geri dönüşü
- [x] `test/models/level_test.dart` [YENİ]
  - [x] `Level.fromJson` — normal format
  - [x] `Level.fromJson` — daily challenge String format
  - [x] Hatalı JSON exception handling

### 3.2 Widget / Integration Tests

- [x] `test/screens/home_screen_test.dart` [YENİ]
  - [x] Tüm butonlar render ediliyor mu
  - [x] Navigation çalışıyor mu
- [x] `test/screens/settings_screen_test.dart` [YENİ]
  - [x] Dil değişimi
  - [x] Theme değişimi
  - [x] Switch toggle'lar
- [x] `test/widgets/letter_tile_test.dart` [YENİ]
  - [x] Doğru/yanlış renk durumları
  - [x] Animasyon tetiklenmesi

### 3.3 Test Altyapısı

- [x] `test/helpers/` dizini oluştur
  - [x] `test/helpers/test_providers.dart` — mock provider override'lar
  - [x] `test/helpers/test_data.dart` — örnek Level, GameState verileri
- [x] `pubspec.yaml` — `mocktail` veya `mockito` ekle (dev_dependencies)
- [x] CI/CD pipeline'da `flutter test` otomatik çalıştırma kuralı (GitHub Actions)

---

## Phase 4: Firebase Foundation

> Firebase projesini kur, core bağımlılıkları ekle, Remote Config ile level data'yı taşı.

### 4.1 Firebase Proje Kurulumu

- [ ] Firebase Console'da yeni proje oluştur: `crossclimber-prod`
- [ ] Android app ekle (`com.kerem.crossclimber`)
  - [ ] `google-services.json` indir → `android/app/` dizinine koy
  - [ ] `android/build.gradle` — Google services plugin ekle
  - [ ] `android/app/build.gradle` — plugin apply et
- [ ] iOS app ekle (`com.kerem.crossclimber`)
  - [ ] `GoogleService-Info.plist` indir → `ios/Runner/` dizinine koy
  - [ ] Xcode'da plist'i projeye ekle
- [ ] Firebase Console'da gerekli servisleri aktif et:
  - [ ] Authentication (Anonymous, Google, Facebook)
  - [ ] Cloud Firestore
  - [ ] Remote Config
  - [ ] Crashlytics
  - [ ] Analytics

### 4.2 Flutter Firebase Bağımlılıkları

- [ ] `pubspec.yaml` — Yeni bağımlılıklar ekle:
  ```yaml
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_remote_config: ^latest
  firebase_crashlytics: ^latest
  firebase_analytics: ^latest
  google_sign_in: ^latest
  flutter_facebook_auth: ^latest
  ```
- [ ] `flutter pub get` çalıştır
- [ ] `lib/main.dart` — Firebase initialization ekle:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(const ProviderScope(child: CrossclimbApp()));
  }
  ```
- [ ] Build'in başarılı olduğunu doğrula (Android + iOS)

### 4.3 Remote Config — Static Level Data Taşıma

- [ ] Firebase Console → Remote Config'e key'leri ekle:
  - [ ] `levels_en_v1` — `assets/levels/levels_en.json` içeriği
  - [ ] `levels_tr_v1` — `assets/levels/levels_tr.json` içeriği
  - [ ] `daily_levels_en_v1` — `assets/levels/daily_levels_en.json` içeriği
  - [ ] `daily_levels_tr_v1` — `assets/levels/daily_levels_tr.json` içeriği
  - [ ] `economy_config` — Ekonomi parametreleri JSON:
    ```json
    {
      "dailyLoginReward": 20,
      "dailyChallengeReward": 50,
      "adRewardCredits": 25,
      "lifeCost": 50,
      "allLivesCost": 100,
      "maxAdsPerDay": 5
    }
    ```
  - [ ] `content_version` — `"1.0.0"` (level güncelleme takibi)
- [ ] `lib/services/remote_config_service.dart` [YENİ]:
  - [ ] `initialize()` — fetch & activate
  - [ ] `getLevels(String languageCode)` — Remote Config'den level listesi
  - [ ] `getDailyLevels(String languageCode)` — günlük challenge level listesi
  - [ ] `getEconomyConfig()` — ekonomi parametreleri
  - [ ] `getContentVersion()` — versiyon kontrolü
  - [ ] Fallback: Remote Config hata verirse local asset'ten oku (offline desteği)
- [ ] `lib/services/level_repository.dart` — GÜNCELLE:
  - [ ] Önce Remote Config'den oku
  - [ ] Remote Config başarısızsa local JSON'dan fallback oku
  - [ ] Cache mekanizması: 12 saat geçerli
- [ ] Test: Uçak modunda uygulama açıldığında local fallback çalışıyor mu?

### 4.4 Crashlytics & Analytics Kurulumu

- [ ] `lib/main.dart` — Crashlytics initialization:
  ```dart
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  ```
- [ ] `lib/services/analytics_service.dart` [YENİ]:
  - [ ] `logLevelStart(int levelId, String difficulty)`
  - [ ] `logLevelComplete(int levelId, int stars, Duration time, int score)`
  - [ ] `logLevelFail(int levelId, String reason)`
  - [ ] `logHintUsed(String hintType)`
  - [ ] `logAdWatched(String placement)`
  - [ ] `logPurchase(String itemType, int amount)`
  - [ ] `logDailyChallengeComplete(int streak)`
- [ ] `analyticsServiceProvider` oluştur
- [ ] Key event'lere analytics çağrılarını ekle:
  - [ ] Level başlatma
  - [ ] Level tamamlama
  - [ ] Level başarısızlık
  - [ ] İpucu kullanımı
  - [ ] Reklam izleme
  - [ ] Mağaza işlemi
  - [ ] Günlük challenge tamamlama

---

## Phase 5: Authentication & Account System

> Misafir giriş, sosyal giriş, hesap bağlama.

### 5.1 Auth Service

- [ ] `lib/services/auth_service.dart` [YENİ]:
  - [ ] `signInAnonymously()` — İlk açılışta otomatik
  - [ ] `signInWithGoogle()` — Google OAuth
  - [ ] `signInWithFacebook()` — Facebook OAuth
  - [ ] `linkAnonymousToGoogle(GoogleSignInAccount account)` — Hesap bağlama
  - [ ] `linkAnonymousToFacebook(AccessToken token)` — Hesap bağlama
  - [ ] `signOut()` — Oturum kapatma
  - [ ] `deleteAccount()` — Hesap silme (GDPR uyumu)
  - [ ] `getCurrentUser()` — Mevcut kullanıcı
  - [ ] `authStateChanges` — Stream<User?> dinleme
  - [ ] `isAnonymous` — Misafir mi, bağlı hesap mı
- [ ] `lib/providers/auth_provider.dart` [YENİ]:
  - [ ] `authServiceProvider` — AuthService Provider
  - [ ] `authStateProvider` — StreamProvider<User?> (auth state değişiklikleri)
  - [ ] `currentUserProvider` — mevcut kullanıcı bilgisi
  - [ ] `isGuestProvider` — misafir mi kontrolü

### 5.2 Auth UI

- [ ] `lib/screens/auth/login_screen.dart` [YENİ]:
  - [ ] Google ile giriş butonu (branding standartlarına uygun)
  - [ ] Facebook ile giriş butonu (branding standartlarına uygun)
  - [ ] "Misafir olarak devam et" butonu
  - [ ] Animasyonlu giriş ekranı tasarımı
- [ ] `lib/widgets/auth_guard.dart` [YENİ]:
  - [ ] Auth durumuna göre route koruması
  - [ ] Anonymous user redirect mantığı
- [ ] `lib/screens/settings_screen.dart` GÜNCELLE:
  - [ ] Profil bölümü ekle (avatar, isim, e-posta)
  - [ ] "Hesabı Bağla" butonu (misafirler için)
  - [ ] "Çıkış Yap" butonu
  - [ ] "Hesabı Sil" butonu (onay dialog ile)
- [ ] `lib/screens/home_screen.dart` GÜNCELLE:
  - [ ] AppBar'da kullanıcı avatarı veya misafir ikonu göster
  - [ ] Avatar'a tıklandığında profil/giriş ekranına git

### 5.3 İlk Açılış (First Launch) Akışı

- [ ] App başlatıldığında:
  - [ ] Firebase Auth durumunu kontrol et
  - [ ] Kullanıcı yoksa → `signInAnonymously()` çağır
  - [ ] Kullanıcı varsa → devam et
- [ ] İlk kez oynayan kullanıcı → tutorial ve oyuna yönlendir (giriş zorlama yok)
- [ ] Ayarlar > "Hesabı Bağla" → Login Screen aç → bağlama akışı

---

## Phase 6: Cloud Sync & Data Migration

> Local veriyi buluta taşı, offline-first mimari kur.

### 6.1 Firestore Schema Oluşturma

- [ ] Firebase Console → Firestore Security Rules yaz:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /users/{userId}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  ```
- [ ] Firestore Indexes oluştur (gerekiyorsa)

### 6.2 Cloud Sync Service

- [ ] `lib/services/cloud_sync_service.dart` [YENİ]:
  - [ ] `syncProgress(String userId)` — progress document oku/yaz
  - [ ] `syncStatistics(String userId)` — statistics document oku/yaz
  - [ ] `syncAchievements(String userId)` — achievements document oku/yaz
  - [ ] `syncAll(String userId)` — tümünü senkronize et
  - [ ] `getLastSyncTime()` — son senkronizasyon zamanı
  - [ ] `uploadLocalData(String userId)` — local → cloud (ilk senkronizasyon)
  - [ ] `downloadCloudData(String userId)` — cloud → local
  - [ ] Error handling: network hatası, quota aşımı, timeout

### 6.3 Conflict Resolution

- [ ] `lib/services/conflict_resolver.dart` [YENİ]:
  - [ ] `mergeProgress(local, cloud)`:
    - [ ] `highestLevel` → `max(local, cloud)`
    - [ ] `totalScore` → `max(local, cloud)`
    - [ ] `credits` → `max(local, cloud)`
    - [ ] `lives` → `max(local, cloud)`
    - [ ] `hintStocks` → her tür için `max(local, cloud)`
    - [ ] `levelStars` → her level için `max(local[i], cloud[i])`
  - [ ] `mergeStatistics(local, cloud)`:
    - [ ] Kümülatif alanlar (totalGamesPlayed, totalStarsEarned) → `max()`
    - [ ] Best alanlar (bestTimeSeconds, bestWinStreak) → `min()` veya `max()` uygun olanı
  - [ ] `mergeAchievements(local, cloud)`:
    - [ ] Unlocked kümesi → Union (birleşim)
    - [ ] Hiçbir achievement tekrar kilitlenmemeli
  - [ ] `mergeSettings(local, cloud)`:
    - [ ] Her zaman local'i tercih et (kullanıcı en son bunu değiştirdi)
- [ ] Çakışma çözüm testleri yaz

### 6.4 Repository Katmanı Güncelleme (Hybrid: Local + Cloud)

- [ ] `lib/services/progress_repository.dart` GÜNCELLE:
  - [ ] Her okuma: önce local SharedPreferences → cache hit
  - [ ] Her yazma: local SharedPreferences'a yaz + dirty flag set et
  - [ ] `syncToCloud()`: dirty flag varsa cloud'a gönder, flag'ı temizle
  - [ ] Level tamamlandığında batch write yap (progress + statistics + achievements tek seferde)
- [ ] `lib/services/statistics_repository.dart` GÜNCELLE:
  - [ ] Aynı hybrid pattern: local-first, cloud-sync on complete
- [ ] `lib/services/achievement_service.dart` GÜNCELLE:
  - [ ] Achievement unlock'ta local yaz + sync queue'ya ekle
- [ ] `lib/services/daily_challenge_service.dart` GÜNCELLE:
  - [ ] Challenge tamamlama: local yaz + cloud'a sync et

### 6.5 Sync UI Göstergeleri

- [ ] `lib/widgets/sync_indicator.dart` [YENİ]:
  - [ ] Senkronizasyon durumu ikonu (synced ✓ / syncing ↻ / offline ⚠)
  - [ ] Son senkronizasyon zamanı tooltip'i
- [ ] `CommonAppBar`'a sync indicator ekle
- [ ] Settings'e "Şimdi Senkronize Et" manuel butonu ekle
- [ ] Settings'e "Son senkronizasyon: X dakika önce" bilgisi ekle

### 6.6 Offline-First Garantisi

- [ ] İnternet yokken tüm oyun fonksiyonları local'de çalışmaya devam etmeli
- [ ] İnternet geldiğinde otomatik sync tetiklenmeli
- [ ] `connectivity_plus` paketi ile bağlantı durumu dinleme
- [ ] Sync queue mekanizması: offline'da biriken değişiklikler online olunca sırayla gönderilmeli

---

## Phase 7: Monetization & Ad Integration

> Gerçek reklam entegrasyonu, gelir modeli kurma.

### 7.1 AdMob Kurulumu

- [ ] AdMob hesabı oluştur / mevcut hesapla uygulamayı kaydet
- [ ] Ad Unit ID'leri oluştur:
  - [ ] Rewarded Video — Credits için
  - [ ] Rewarded Video — Hint için
  - [ ] Rewarded Video — Life Restore için
  - [ ] Interstitial — Level arası
  - [ ] Banner — Level Map ekranı
- [ ] Test Ad Unit ID'lerini not al (geliştirme sırasında kullanılacak)
- [ ] `pubspec.yaml` — `google_mobile_ads: ^latest` ekle
- [ ] Android: `AndroidManifest.xml` — AdMob App ID ekle
- [ ] iOS: `Info.plist` — `GADApplicationIdentifier` ekle

### 7.2 Ad Service Abstraction Layer

- [ ] `lib/services/ad_service.dart` [YENİ] — Abstract interface:
  ```dart
  abstract class AdService {
    Future<void> initialize();
    Future<bool> isRewardedAdReady(String placement);
    Future<bool> showRewardedAd({required String placement, required Function onReward});
    Future<void> showInterstitial();
    Widget buildBannerAd({required String placement});
    void dispose();
  }
  ```
- [ ] `lib/services/admob_ad_service.dart` [YENİ] — Gerçek AdMob implementasyonu:
  - [ ] `initialize()` — MobileAds.instance.initialize()
  - [ ] `_loadRewardedAd(String placement)` — preload rewarded video
  - [ ] `showRewardedAd()` — göster + onReward callback
  - [ ] `_loadInterstitial()` — preload interstitial
  - [ ] `showInterstitial()` — göster
  - [ ] `buildBannerAd()` — BannerAdWidget oluştur
  - [ ] Ad lifecycle management: load → show → reload
  - [ ] Error handling: ad load failure, timeout
- [ ] `lib/services/mock_ad_service.dart` [YENİ] — Debug/test için mock:
  - [ ] Sahte 2 saniyelik delay ile ödül ver
  - [ ] UI'da "Ad Mock" göstergesi
- [ ] `lib/providers/ad_provider.dart` [YENİ]:
  ```dart
  final adServiceProvider = Provider<AdService>((ref) {
    if (kDebugMode) return MockAdService();
    return AdMobAdService();
  });
  ```

### 7.3 Mevcut Mock Ad Service'i Değiştir

- [ ] `lib/services/ad_reward_service.dart` — KALDIR veya refactor et
  - [ ] İçindeki günlük limit mantığını `AdMobAdService`'e taşı
  - [ ] `watchAdForCredits()` → `showRewardedAd(placement: 'credits')`
  - [ ] `watchAdForHint()` → `showRewardedAd(placement: 'hint')`
- [ ] Mevcut tüm `AdRewardService()` referanslarını `adServiceProvider` ile değiştir

### 7.4 Ad Yerleştirme Noktaları

- [ ] Shop Screen — "Reklam İzle → 25 Kredi" butonu:
  - [ ] Rewarded video tetikle
  - [ ] Başarılı izleme → kredi ekle + animasyon
  - [ ] Günlük limit kontrolü (maxAdsPerDay)
  - [ ] Kalan reklam hakkı göstergesi
- [ ] Game Over / Lives = 0 durumu — "Reklam İzle → +1 Can" butonu:
  - [ ] Rewarded video tetikle
  - [ ] Başarılı izleme → 1 can ekle + oyuna devam
- [ ] Hint paneli — "Reklam İzle → Ücretsiz İpucu" butonu:
  - [ ] Rewarded video tetikle
  - [ ] Başarılı izleme → hint stock +1
- [ ] Level tamamlama sonrası — Interstitial:
  - [ ] Her 3. level tamamlamada göster (frequency cap)
  - [ ] `SharedPreferences` ile sayaç tut
  - [ ] Günlük max 5 interstitial sınırı
- [ ] Level Map ekranı — Banner Ad:
  - [ ] Ekranın altına banner yerleştir
  - [ ] `SafeArea` ile uyumlu
  - [ ] Oyun ekranında banner gösterme (ASLA)
- [ ] Premium/Ad-Free seçenek (gelecek):
  - [ ] Tüm reklamları kaldırma özelliği (in-app purchase)

### 7.5 UX Koruma Kuralları

- [ ] Reklam yüklenmemişse butonu devre dışı bırak (grayout + loading indicator)
- [ ] Reklam gösterilirken oyun pause olmalı
- [ ] Reklam kapatıldıktan sonra state bozulmamalı (lifecycle management)
- [ ] Reklam timeout'u (30 saniye yüklenmediyse alternatif sun)
- [ ] User feedback: reklam sonrası net "Ödülünüz eklendi!" animasyonu

---

## Phase 8: Daily Challenge Expansion

> Günlük challenge havuzunu genişlet, sosyal özellikler ekle.

### 8.1 Level Havuzu Genişletme

- [ ] Mevcut 30 günlük challenge → minimum 90'a çıkar
- [ ] Level üretim sistemi:
  - [ ] Word ladder generator script oluştur (Python veya Dart CLI)
  - [ ] İngilizce kelime listesi + tek harf farkı kontrolü
  - [ ] Türkçe kelime listesi + tek harf farkı kontrolü
  - [ ] Zorluk derecesi otomatik hesaplama
- [ ] Yeni level'ları Remote Config'e yükle (app update gerektirmeden)

### 8.2 Sosyal Özellikler (İsteğe Bağlı, Gelecek)

- [ ] Günlük challenge leaderboard (Firestore):
  - [ ] Arkadaşlar arası sıralama
  - [ ] Global sıralama (top 100)
  - [ ] Maliyet analizi: leaderboard read'leri DB maliyetini artırabilir
- [ ] Challenge sonucu paylaşma — mevcut `ShareService` kullanılacak

---

## Phase 9: Platform & Store Hazırlığı

> App Store / Play Store'a yükleme öncesi hazırlık.

### 9.1 App Store Optimize

- [ ] App icon tasarımı (mevcut `assets/icon/icon.png` güncel mi?)
- [ ] Splash screen tasarımı (`flutter_native_splash` config güncel mi?)
- [ ] App Store screenshot'ları hazırla (her ekran boyutu için)
- [ ] Play Store tanıtım görselleri
- [ ] App açıklaması (EN + TR)
- [ ] Anahtar kelime optimizasyonu

### 9.2 Yasal Gereksinimler

- [ ] Gizlilik Politikası (Privacy Policy) sayfası oluştur
  - [ ] Firebase Analytics veri toplama açıklaması
  - [ ] AdMob reklam verisi açıklaması
  - [ ] Kullanıcı verisi saklama politikası
- [ ] Kullanım Koşulları (Terms of Service) sayfası oluştur
- [ ] KVKK / GDPR uyumu:
  - [ ] Hesap silme özelliği (Phase 5'te yapıldı)
  - [ ] Veri export özelliği
  - [ ] Rıza yönetimi (consent management)
- [ ] COPPA uyumu (eğer 13 yaş altı hedef kitlesi varsa)

### 9.3 Release Build & CI/CD

- [ ] Android release signing key oluştur
- [ ] iOS provisioning profile ve certificate oluştur
- [ ] `flutter build apk --release` başarılı mı?
- [ ] `flutter build ipa` başarılı mı?
- [ ] GitHub Actions CI/CD pipeline:
  - [ ] `flutter analyze`
  - [ ] `flutter test`
  - [ ] `flutter build apk --release`
  - [ ] Artifact olarak APK kaydet

---

## Phase 10: Git & Version Control

> Her phase tamamlandığında commit + push.

### 10.1 Repository Yönetimi

- [ ] GitHub remote: `git remote add github git@github.com:krmmyvz/crossclimber.git`
- [ ] Gitea remote: `git remote add gitea git@192.168.1.17:3000:kerem/crossclimber.git`
- [ ] `.gitignore` — Firebase config dosyaları (google-services.json, GoogleService-Info.plist) eklenmeli mi kontrol et
  - [ ] Eğer private repo ise → eklemeye gerek yok
  - [ ] Eğer public repo ise → `.gitignore`'a ekle + template oluştur

### 10.2 Commit Stratejisi

Her phase tamamlandığında:

```bash
# Phase 0 örneği:
git add -A
git commit -m "refactor: clean up design tokens, fix l10n, branding consistency"
git push github main
git push gitea main

# Phase 1 örneği:
git commit -m "refactor: decompose GameNotifier into focused services"
git push github main && git push gitea main

# Phase 4 örneği:
git commit -m "feat: add Firebase foundation with Remote Config level loading"
git push github main && git push gitea main
```

### 10.3 Branch Stratejisi (Önerilen)

- [ ] `main` — Stabil, yayınlanabilir kod
- [ ] `develop` — Geliştirme branch'i
- [ ] `feature/firebase-auth` — Phase 5
- [ ] `feature/cloud-sync` — Phase 6
- [ ] `feature/ads` — Phase 7
- [ ] Her feature branch'i tamamlandığında `develop`'a merge, sonra `main`'e

---

## Milestone Özeti

| Phase | Hedef | Tahmini Süre | Bağımlılık |
|---|---|---|---|
| Phase 0 | Kod temizliği, token uyumu | 2-3 gün | — |
| Phase 1 | Architecture refactoring | 4-5 gün | Phase 0 |
| Phase 2 | UI/UX overflow fix | 2-3 gün | Phase 0 |
| Phase 3 | Test altyapısı | 3-4 gün | Phase 1 |
| Phase 4 | Firebase foundation | 3-4 gün | Phase 0 |
| Phase 5 | Authentication | 4-5 gün | Phase 4 |
| Phase 6 | Cloud sync | 5-6 gün | Phase 4 + 5 |
| Phase 7 | Monetization | 3-4 gün | Phase 4 |
| Phase 8 | Daily challenge expansion | 2-3 gün | Phase 4 |
| Phase 9 | Store hazırlığı | 3-4 gün | Tümü |
| Phase 10 | Git & CI/CD | Sürekli | — |

**Toplam tahmini süre: 5-7 hafta** (tam zamanlı, tek geliştirici)

---

> 📋 **Kullanım:** Bu dosya üzerinde `[ ]` → `[x]` olarak madde madde ilerleyin. Her oturumda nerede kaldığınızı bu dosyadan takip edin. Hiçbir adım atlanmamalı.
