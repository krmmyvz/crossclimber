# CrossClimber — Evolution Roadmap & Master Checklist

> **Oluşturulma Tarihi:** 2026-02-14  
> **Amaç:** Mevcut local-only oyunu, bulut destekli, gelir üreten, ölçeklenebilir bir ürüne dönüştürmek.  
> **Kural:** Her madde tamamlandığında `[ ]` → `[x]` olarak işaretlenir. Hiçbir adım atlanmaz.

---

## Phase 0: Code Quality & Housekeeping (Temizlik) ✅

- [x] `analysis_options.yaml` — `flutter_lints` + ekstra kurallar eklendi (15 kural)
- [x] `flutter analyze` çalıştırıldı → `dart fix --apply` tamamlandı.
- [x] Tüm `debugPrint` çağrıları `kDebugMode` guard ile sarıldı.

---

## Phase 1: Architecture Refactoring ✅

### 1.1 GameNotifier Refactoring ✅
### 1.2 Singleton → Riverpod Provider Dönüşümü ✅

### 1.3 Widget Decomposition (Büyük Widget'ları Parçala) ✅
#### 1.3.1 `game_screen.dart` ✅
#### 1.3.2 `statistics_screen.dart` ✅
- [x] `_buildOverviewCard` → ayrı `StatsOverviewCard` widget dosyası
- [x] `_buildPerformanceGrid` + `_buildStatCard` → ayrı `PerformanceGrid` widget dosyası
- [x] `_buildTimeStatsCard` + `_buildTimeStatRow` → ayrı `TimeStatsCard` widget dosyası
- [x] `_buildAchievementProgressCard` → ayrı `AchievementProgressCard` widget dosyası
- [x] `_buildWinRateCard` + `_buildWinLossItem` → ayrı `WinRateCard` widget dosyası
- [x] `_buildStarDistributionCard` + `_buildStarItem` → ayrı `StarDistributionCard` widget dosyası
- [x] `statistics_screen.dart`'ı yeniden yaz — sadece layout orchestration

#### 1.3.3 `achievements_screen.dart` ✅
- [x] `_buildProgressHeader` → ayrı widget
- [x] `_buildAchievementCard` → ayrı widget
- [x] Helper method'lar → `AchievementUtils` helper class

### 1.4 Provider Scoping ✅

---

## Phase 2: UI/UX Overflow Fixes & Polish ✅

- [x] 2.1 & 2.2 Responsive tasarım ve `Responsive` sınıfı eklendi.
- [x] 2.3 Erişilebilirlik (Semantics) etiketleri eklendi.

---

## Phase 3: Testing Altyapısı ✅

- [x] 3.1 Unit Testlerin tamamı yazıldı.
- [x] 3.2 Widget ve Entegrasyon testleri tamamlandı.
- [x] 3.3 Test yardımcıları ve GitHub Actions CI/CD kuruldu.

---

## Phase 4: Firebase Foundation ✅

### 4.1 Firebase Proje Kurulumu ✅
- [x] Android ve iOS paket adları güncellendi (`com.gelincik.crossclimber`).
- [x] `google-services.json` ve `GoogleService-Info.plist` yerleştirildi.

### 4.2 Flutter Firebase Bağımlılıkları ✅
- [x] `pubspec.yaml` güncellendi ve `main.dart` içinde Firebase ilklendirildi.

### 4.3 Remote Config — Static Level Data Taşıma ✅
- [x] `RemoteConfigService` oluşturuldu ve `LevelRepository` güncellendi.

### 4.4 Crashlytics & Analytics Kurulumu ✅
- [x] `AnalyticsService` oluşturuldu ve `GameNotifier` içine entegre edildi.

---

## Phase 5: Authentication & Account System [DEVAM EDİYOR]

- [x] `lib/services/auth_service.dart` [YENİ]: Anonim giriş ve hesap bağlama (Google/FB) fonksiyonları.
- [x] `main.dart` güncellemesi: Uygulama açılışında otomatik anonim giriş.
- [x] `SettingsScreen` güncellemesi: Kullanıcı bilgilerini görme ve hesap bağlama seçenekleri.
- [ ] İlerleme koruma: Anonim hesabı Google/FB ile bağlarken verilerin senkronize edilmesi.
