# CrossClimber — UI/UX Evolution Roadmap & Analiz Raporu

> **Oluşturulma Tarihi:** 2026-02-19  
> **Amaç:** CrossClimber'ı rakip kelime oyunlarının (Wordle, Wordscapes, Word Cookies, CodyCross) UX kalitesine ulaştırmak ve aşmak.  
> **Kural:** Her madde tamamlandığında `[ ]` → `[x]` olarak işaretlenir. Hiçbir adım atlanmaz.

---

## Mevcut Durum Özeti

| Metrik | Değer |
|--------|-------|
| Toplam Ekran | 9 (Home, LevelMap, Game, LevelCompletion, DailyChallenge, Achievements, Statistics, Settings, Shop) |
| Paylaşılan Widget | 13+ |
| Tema Varyantı | 6 (Light, Dark, Dracula, Nord, Gruvbox, Monokai) |
| Dil Desteği | 2 (EN, TR) |
| Lokalize String | ~160 anahtar |
| Tutorial Adımı | 8 |
| Ses Efekti | 7 |
| Dokunsal Geri Bildirim | 7 pattern |
| Erişilebilirlik (Semantics) | Sadece 5 lokasyon |
| Tespit Edilen UI/UX Sorunu | 28 |

---

## Rakip Analizi & Benchmark

### Referans Uygulamalar

| Uygulama | Güçlü Yönler | CrossClimber'da Eksik |
|----------|-------------|----------------------|
| **Wordle** | Minimalist & temiz UI, paylaşılabilir grid emoji, günlük bağımlılık döngüsü, tek ekran odak | Emoji grid paylaşımı yok, paylaşım metni düz text |
| **Wordscapes** | Premium onboarding, progressive difficulty grafiği, çiçek/bahçe tarzı visual reward sistemi, daily puzzle takvimi | Görsel ödül sistemi yok, ilerleme görselleştirmesi zayıf |
| **CodyCross** | Karakter maskotu, hikaye modu, bölüm temaları, zengin animasyonlar | Maskot/karakter yok, bölüm teması yok |
| **Word Cookies** | Günlük bonus takvimi (açılabilir hediyeler), tournament sistemi, arkadaşlarla yarışma | Turnuva yok, sosyal karşılaştırma yok |
| **Quordle** | Çoklu grid aynı anda, advanced paylaşım formatı, streak sistemi | Multi-grid yok (farklı oyun), streak görseli zayıf |
| **Spelling Bee (NYT)** | Genius rank sistemi, topluluk istatistikleri, Queen Bee rozeti | Rank/seviye sistemi yok, topluluk verisi yok |

### CrossClimber'ın Mevcut Avantajları
- ✅ 6 tema seçeneği (rakiplerden fazla)
- ✅ Kombo sistemi (Wordle/Wordscapes'te yok)
- ✅ Sürükle-bırak sıralama mekanizması (benzersiz)
- ✅ Detaylı istatistik ekranı
- ✅ Hint sistemi (Reveal + Undo) stok bazlı

---

## Phase 1: Kritik UX Düzeltmeleri (Acil)

> **Hedef:** Mevcut kullanıcı deneyimini kıran hataları düzeltmek.

### 1.1 Lokalizasyon Tutarsızlıkları
- [x] `combo_indicator.dart` — `'COMBO'`, `'Multiplier'`, `'COMBO BREAK'` → l10n'a taşındı
- [x] `undo_button.dart` — Karışık dil (EN label + TR dialog) → tamamen l10n'a taşındı
- [x] `shop_screen.dart` — Türkçe hardcoded stringler (`'Günlük limit doldu!'`, `'+$credits kredi kazandın!'`) → l10n'a taşındı
- [x] `shop_screen_cards.dart` — `'$amount Kredi'`, `'$amount Can'` → `nCredits`/`nLives` l10n'a taşındı
- [x] `level_map_screen.dart` — `'Levels'`, `'Stars'`, `'Streak'` → l10n'a taşındı
- [x] `level_completion_screen.dart` — `'Credits Earned'` → l10n'a taşındı
- [x] `share_service.dart` — Tüm paylaşım metinleri lokalize edildi (AppLocalizations l10n parametresi eklendi)
- [x] `daily_challenge_screen.dart` — `'Completed Today!'`, `'Today\'s Challenge'` → l10n'a taşındı

### 1.2 Ölü Kod Temizliği
- [x] `game_keyboard.dart` — Kullanılmayan `GameKeyboard` widget'ını kaldır veya deprecated işaretle
- [x] `game_screen_hints.dart` — Boş deprecated mixin'i temizle, `GameScreen`'den kaldır
- [x] Kullanılmayan import'ları temizle (`dart fix --apply`)

### 1.3 Ses Sistemi Düzeltmesi
- [ ] `sound_service.dart` — Tek `AudioPlayer` yerine audio pool (en az 3 player) kullan
- [ ] Ses dosyaları preload/cache mekanizması ekle (uygulama başlangıcında)
- [ ] `assets/sounds/` klasörüne ses dosyalarını ekle ve `pubspec.yaml`'da aktifleştir
- [ ] Sound ve Haptic state'ini `SettingsProvider` ile senkronize et (çift kaynak problemi)

---

## Phase 2: Onboarding & İlk Deneyim (Wordle/Wordscapes Seviyesi)

> **Hedef:** İlk açılışta kullanıcıyı kaybetmemek. Rakipler 30 saniyede oyunu öğretiyor.

### 2.1 Splash → Onboarding Akışı
- [x] Native splash → Flutter geçişi düzgün animate et (fade-through)
- [x] İlk açılış tespiti (`SharedPreferences` ile `isFirstLaunch` flag)
- [x] 3-4 sayfalık onboarding carousel tasarla:
  - Sayfa 1: "Kelimeleri Tırman!" — Oyun konsepti görseli
  - Sayfa 2: "Tahmin Et, Sırala, Çöz!" — 3 faz görseli
  - Sayfa 3: "Günlük Meydan Okuma" — Daily Challenge tanıtımı
  - Sayfa 4: "Kombo Zinciri Kur!" — Kombo sistemi tanıtımı
- [x] Onboarding skip butonu (sağ üst) + son sayfada "Başla!" butonu
- [x] Onboarding animasyonları: her sayfa `flutter_animate` ile `fadeIn` + `slideX`
- [x] Onboarding tamamlandıktan sonra otomatik ilk level'a yönlendirme

### 2.2 Tutorial İyileştirmesi
- [x] Eksik kombo tutorial adımını aktifleştir (`tutorial_combo_intro_*` stringler mevcut ama kullanılmıyor)
- [x] Tutorial dışı özellikler için keşif ipuçları ekle:
  - Shop'a ilk girişte context tooltip
  - Achievements'a ilk girişte kısa açıklama
  - Daily Challenge ilk girişte streak açıklaması
- [x] Tutorial adımlarında progress dots (●●●○○) göster
- [x] Tutorial "Bir daha gösterme" checkbox'ı her adımda

### 2.3 Empty States (Boş Durumlar)
- [x] 0 başarım açılmış → İllüstrasyon + "İlk başarımına ulaşmak için oynamaya başla!" mesajı
- [x] 0 oyun oynandı (Statistics) → İllüstrasyon + "İstatistiklerin burada görünecek"
- [x] Daily Challenge tamamlanmamış → Motivasyon kartı
- [x] Her empty state için tutarlı illüstrasyon stili (outlined, tema renkleriyle uyumlu)

---

## Phase 3: Görsel Kimlik & Polish (CodyCross/Wordscapes Seviyesi)

> **Hedef:** Profesyonel, mağaza vitrinine layık görsel kalite.

### 3.1 HomeScreen Yeniden Tasarım
- [x] Hero banner: Animasyonlu gradient arka plan + CrossClimber logo
- [x] "Oyna" butonu: Büyük, merkezi, pulsing glow efekti (mevcut ama geliştirilecek)
- [x] Quick access butonları: İkon kartları yerine **grid layout** (2×2):
  - 📅 Günlük Meydan Okuma (streak badge ile)
  - 🏆 Başarımlar (kilit açma yüzdesi ile)
  - 📊 İstatistikler (toplam yıldız ile)
  - 🛒 Mağaza (kredi sayısı ile)
- [x] Alt kısım: "Devam Et" butonu (son kaldığın level) + "Hızlı Oyna" (rastgele level)
- [x] HomeScreen loading state: Skeleton loading ekle (diğer ekranlarda var, burada yok)
- [x] Günün sözü / motivasyon kartı (opsiyonel, Firebase Remote Config ile)

### 3.2 Level Map Yeniden Tasarım  
- [x] Mevcut grid → **yol/patika bazlı** ilerleme haritası (Wordscapes benzeri)
- [x] Zorluk bölgeleri: Kolay (yeşil), Orta (mavi), Zor (mor), Uzman (kırmızı) renk kodlaması
- [x] Kilitli level'larda kilit ikonu + hafif blur/desatürasyon
- [x] Mevcut level vurgulama: Parlayan border + pulsing animasyon
- [x] Bölüm arası "Boss Level" veya "Checkpoint" görselleştirmesi
- [x] İlerleme çubuğu: Her zorluk bölgesinin üst kısmında mini progress bar
- [x] Level kartında: Yıldızlar altın renkli (mevcut), en iyi süre küçük text, tamamlanma tarihi tooltip
- [x] Scroll pozisyonunu kaydet: Kullanıcı geri geldiğinde son kaldığı yer

### 3.3 Game Screen Polish
- [x] Kelime satırları arası **bağlantı çizgisi** veya merdiven görselleştirmesi
- [x] Doğru tahmin: Confetti particle (küçük, lokal — level sonu confetti'den farklı)
- [x] Yanlış tahmin: Kırmızı flash + hafif ekran sallanması (screen shake)
- [x] Sıralama fazı geçişi: Phase banner animasyonu ("Şimdi Sırala!" slide-in + fade-out)
- [x] Final çözüm fazı geçişi: Dramatik reveal (üst/alt kelimeler kilit açma animasyonuyla ortaya çıkar)
- [x] Timer: Son 30 saniyede kırmızıya dönsün + hafif pulse
- [x] Skor artışı: Sayı artış animasyonu (count-up, mevcut LevelCompletion'da var ama game içinde yok)

### 3.4 Level Completion Screen Polish
- [x] 3 yıldız → Tam ekran confetti + altın parıltı efekti (mevcut confetti geliştirilecek)
- [x] 2 yıldız → Hafif confetti + "Harika!" mesajı
- [x] 1 yıldız → Minimal kutlama + "Tekrar Dene" vurgusu
- [x] 0 yıldız → Teşvik mesajı + ipucu önerisi
- [x] Yıldız animasyonu: Her yıldız sırayla dolsun (1→2→3) + bounce + shimmer
- [x] XP bar / Rank ilerleme göstergesi (Phase 6 ile entegre)
- [x] "Sonraki Level" butonuna otomatik ön-yükleme (level verisini)

### 3.5 Wordle-Tarzı Emoji Grid Paylaşımı
- [x] Level tamamlandığında emoji grid oluştur:
  ```
  CrossClimber #42 ⭐⭐⭐
  🟩🟩🟩🟩 (doğru tahmin)
  🟨🟨🟨🟨 (sıralama düzeltildi)
  🟥🟨🟩🟩 (yanlış → doğru)
  ⏱️ 2:35 | 🔥 x5 Combo
  #CrossClimber
  ```
- [x] Paylaşım butonuna basınca önce preview göster, sonra paylaş
- [x] Clipboard'a kopyalama seçeneği (Share Sheet'e ek olarak)

---

## Phase 4: Erişilebilirlik (A11y) — WCAG 2.1 AA Hedefi

> **Hedef:** Tüm kullanıcıların oyunu oynayabilmesi. App Store'da erişilebilirlik puanı artırma.

### 4.1 Semantics Kapsamını Genişlet
- [x] `ComboIndicator` — Combo durumu ve çarpan bilgisi için `Semantics` ekle
- [x] `GameStatusBar` — Timer, skor, combo için `Semantics` sarmalayıcı
- [x] `HintQuickAccessBar` — Her buton için `Semantics(label, button: true)`
- [x] `CommonAppBar` status chip'leri — Kredi, can, streak için `Semantics`
- [x] Level kartları (`LevelMapScreen`) — Level numarası, yıldız, durum
- [x] `HomeScreen` quick access butonları — Her birine `Semantics(label, button: true)`
- [x] `TutorialOverlay` — Tutorial içerik kartı + navigasyon butonları
- [x] `ConfettiOverlay` — `excludeSemantics: true` (dekoratif)
- [x] `CustomKeyboard` — Her harf tuşuna `Semantics(label: 'Harf X', button: true)`
- [x] `ShopScreen` — Tüm ürün kartları ve butonlar

### 4.2 Metin Ölçekleme Güvenliği
- [x] `MediaQuery.textScaleFactorOf(context)` ile kritik alanlarda max scale kontrolü
- [x] Tüm önemli label'larda `maxLines` + `overflow: TextOverflow.ellipsis`
- [x] Büyük metin (200%+) koruma: `textScaler: TextScaler.noScaling` klavye tuşlarında + level kartı numarasında; `GameStatusBar`'da 1.3x clamp
- [x] `LetterTile` font boyutunu text scale factor'a göre clamp et

### 4.3 Renk & Kontrast
- [x] WCAG AA uyum: `_LevelCard` metin rengini arka plan parlaklığına göre adaptif seç (`ThemeData.estimateBrightnessForColor`) — level numarası, yıldız ve ikon artık koyu/açık zemin üzerinde otomatik kontrast sağlar
- [x] Renk körlüğü alternatifleri: Sıralama fazında geçerli/geçersiz sıra için renk + ikon kombinasyonu
- [x] Yüksek kontrast modu ekle (Settings'e toggle olarak)
- [ ] Her temada WCAG AA kontrast oranlarını manuel doğrula (4.5:1 metin, 3:1 büyük metin) — tema bazlı cihaz testi gerekir

### 4.4 Ekran Okuyucu Desteği  
- [ ] TalkBack (Android) ve VoiceOver (iOS) ile tam oyun akışı testi — cihaz testi gerekir
- [x] Sıralama fazında: "Kelimeyi yukarı/aşağı taşımak için çift dokunun ve sürükleyin" talimatı
- [x] Focus sıralaması: `ReadingOrderTraversalPolicy` ile `FocusTraversalGroup` — HomeScreen grid + GameScreen içeriği
- [x] Semantics aksiyonları: `onTapHint` → tüm interaktif öğelerde eklendi (`LetterTile`, `CustomKeyboard` tuşları, `LevelCard`, `_GridCard`)

---

## Phase 5: Responsive & Platform Uyumu

> **Hedef:** Tüm ekran boyutlarında kusursuz deneyim. Tablet + Web desteği.

### 5.1 Landscape Modu
- [x] `Responsive.isLandscape` kullanarak landscape layout:
  - Game ekranı: Keyboard sağda, game board solda (yan yana) — `_buildLandscapeLayout` + `_buildPortraitLayout`
  - Level map: Daha geniş grid, landscape'te 4-5 sütun — `Responsive.getLevelMapColumns()`
  - Home: Yatayda grid 4 sütuna genişler — `Responsive.getHomeGridColumns()`
- [x] Landscape'te üst/alt safe area yerine sağ/sol safe area — `SafeArea` widget ile otomatik
- [x] Game screen: Landscape'te `Row` layout + `Expanded` game area (flex:55) + `Expanded` keyboard (flex:45)

### 5.2 Tablet Optimizasyonu (≥ 600px)
- [x] Level haritası: Tablet'te kart yüksekliği 110px, sütun sayısı 4-5 — `Responsive.getLevelMapColumns()`
- [x] Game board: Max genişlik constraint (600px) + merkezi hizalama — `Responsive.getGameBoardMaxWidth()`
- [x] Keyboard: Tablet'te max genişlik 600px aktif — `Responsive.getKeyboardMaxWidth()` + `ConstrainedBox`
- [x] Dialog'lar: Tablet'te max genişlik 500px — `Responsive.getDialogMaxWidth()` ile `ModernDialogContent`
- [x] Settings: Tablet'te iki sütunlu layout — `Row` + `Expanded` + `VerticalDivider`

### 5.3 Compact Cihaz İyileştirmesi (< 360px)
- [x] Keyboard: Compact'ta tuş yüksekliği 36px (normal 44px), padding sıkıştırıldı
- [x] Game status bar: Compact'ta küçük font (`bodySmall`) — `StatusItem` güncellendi
- [x] HintQuickAccessBar: Compact'ta 36px buton, 18px ikon boyutu
- [x] LetterTile: Min boyutu 24px'e düşürüldü — `Responsive.getTileSize` clamp güncellendi

### 5.4 Safe Area & Notch Desteği
- [x] Game content alanını `SafeArea` ile sar (tüm layout, `top: false` çünkü AppBar handle ediyor)
- [x] Dynamic Island (iPhone 14 Pro+) — Flutter `SafeArea` otomatik handle eder
- [x] Alt gesture bar (Android 10+) — `CustomKeyboard` `SafeArea` ile sarılı, keyboard çakışması yok

### 5.5 Web Platform (Gelecek)
- [x] Klavye kısayolları: Enter (submit), Backspace (sil), Escape (pause) — `KeyboardListener` + `_handleHardwareKey`
- [x] Mouse hover efektleri: Level kartlarında `MouseRegion` + `AnimatedScale` hover efekti, Home grid kartlarında `hoverColor` + `MouseRegion`
- [x] Responsive breakpoint eklentisi: Desktop (>1200px) — `Responsive.isDesktop()` breakpoint eklendi
- [ ] URL routing: go_router ile deep linking desteği — Phase 8'e ertelendi (büyük refactor)

---

## Phase 6: Oyunlaştırma & Bağımlılık Döngüsü (Wordscapes/Word Cookies Seviyesi)

> **Hedef:** Kullanıcı tutma (retention) oranını artırmak. DAU/MAU optimize.

### 6.1 Oyuncu Profili & Rank Sistemi
- [x] XP (Experience Points) sistemi ekle:
  - Level tamamlama: 100 × zorluk çarpanı XP
  - Daily Challenge: 200 XP + streak bonus
  - 3 yıldız: 50 bonus XP
  - Kombo: Kombo çarpanı × 10 XP
- [x] Rank seviyeleri tasarla (10 seviye):
  - 🌱 Acemi (0-500 XP)
  - 📖 Kelime Öğrencisi (500-1500 XP)
  - ✍️ Kelime Ustası (1500-3000 XP)
  - 🧩 Bulmaca Çözücü (3000-6000 XP)
  - 🏔️ Dağ Tırmanıcısı (6000-10000 XP)
  - 🦅 Kelime Kartalı (10000-18000 XP)
  - 👑 Kelime Kralı (18000-30000 XP)
  - 💎 Elmas Zeka (30000-50000 XP)
  - 🔥 Efsane (50000-80000 XP)
  - ⭐ CrossClimber Ustası (80000+ XP)
- [x] Profil kartı: Avatar + rank rozeti + XP progress bar
- [x] Rank yükselme animasyonu: Tam ekran kutlama + yeni rozet reveal

### 6.2 Günlük Ödül Takvimi (Word Cookies Benzeri)
- [x] 7 günlük dönen ödül takvimi:
  - Gün 1: 50 kredi
  - Gün 2: 1 Reveal ipucu
  - Gün 3: 100 kredi
  - Gün 4: 1 Undo ipucu
  - Gün 5: 150 kredi
  - Gün 6: 1 Reveal + 1 Undo ipucu
  - Gün 7: 300 kredi + **Özel Tema** (haftalık dönen)
- [x] Takvim UI: Grid kartları, bugünkü vurgulu, geçmişler checksumlu
- [x] Kaçırılan gün: Takvim sıfırlanır (FOMO mekanizması)
- [x] Claim animasyonu: Kart açılma + ödül yağmuru partikülleri

### 6.3 Haftalık Turnuva
- [x] Her pazartesi yeni turnuva başlasın (7 level, artan zorluk)
- [x] Skor tablosu: Top 100 + kullanıcının sırası
- [x] Turnuva ödülleri: 1-3. sıra → özel rozet + kredi, 4-10. → kredi, katılım → minimal
- [x] Turnuva UI: Özel ekran + countdown timer + leaderboard animasyonları
- [x] Firebase Firestore ile gerçek zamanlı sıralama

### 6.4 Başarım Sistemi Genişletme ✅
- [x] Mevcut 15 → 30 başarıma çıkar:
  - Streak başarımları: 7, 14, 30, 60, 100 gün
  - Kombo başarımları: 5x, 8x, 10x kombo
  - Hız başarımları: 60s, 45s altında tamamlama
  - Koleksiyoncu: Tüm seviyeler, Legendary rank
  - Sosyal: Paylaşım, günlük challenge başarımları
- [x] Nadir (Rare) ve Efsanevi (Legendary) başarım kategorileri
- [x] Başarım rozeti: Profil kartında gösterilecek seçilebilir rozet
- [x] Başarım unlock animasyonu: Toast notification + badge glow

### 6.5 Streak Sistemi Güçlendirme ✅
- [x] Streak milestone ödülleri: 7, 14, 30, 60, 100 gün
- [x] Streak freeze: 1 gün atlama hakkı (kredi ile satın alınır, mevcut stok gösterilir)
- [x] Streak UI: Ana ekranda ateş animasyonlu streak badge
- [x] Streak kaybı: Yumuşak uyarı ("Streak'ini kaybetme! Bugün oyna!")
- [ ] Push notification: Akşam 20:00'de "Günlük challenge'ını tamamlamadın!" (opsiyonel)

---

## Phase 7: Mikro-Etkileşimler & Animasyon Premium ✅

> **Hedef:** Her dokunuşta "canlılık" hissi. Rakiplerden ayrıştırıcı UI kalitesi.

### 7.1 Dokunma Geri Bildirimi
- [x] Tüm butonlarda `InkWell` ripple + scale-down (0.95) animation
- [x] Uzun basma: Bilgi tooltip'i (level kartında detaylı istatistik)
- [x] Keyboard tuşları: Basıldığında mini bounce + ses
- [x] Sürükle-bırak: Sürüklenen öğe gölgesi + hafif rotasyon (±3°)

### 7.2 Geçiş Animasyonları
- [x] Hero animasyonları: Level kartı → Game Screen (kart genişler)
- [x] Shared element transition: Yıldızlar level kartından completion screen'e
- [x] Tab arası geçiş: Staggered fade (öğeler sırayla belirsin)
- [x] Bottom sheet açılma: Spring physics (`Curves.easeOutBack`)

### 7.3 Ambient Animasyonlar
- [x] HomeScreen arka plan: Yavaş gradient shift (10s döngü)
- [x] Level map: Mevcut level pulse efekti (parlama)
- [x] Streak ateş ikonu: Continuous flame particle efekti (lottie veya custom)
- [x] Idle state: Uzun süre etkileşim yoksa → motivasyon tooltip ("Bir kelime daha?")

### 7.4 Feedback Animasyonları
- [x] Doğru harf: Tile yeşile dönerken 3D flip efekti (Wordle benzeri)
- [x] Tüm kelime doğru: Satır boyunca wave bounce (soldan sağa, sırayla)
- [x] Sıralama doğru: Tüm satırlar yeşile döner + satisfaction pulse
- [x] Level unlock: Kilit kırılma animasyonu (2-parça fragment + fade)

---

## Phase 8: Navigasyon Modernizasyonu

> **Hedef:** Deep linking, state restoration, web uyumu.

### 8.1 go_router Geçişi
- [ ] `go_router` paketini ekle
- [ ] Route tanımları:
  - `/` → HomeScreen
  - `/levels` → LevelMapScreen
  - `/game/:levelId` → GameScreen
  - `/game/:levelId/complete` → LevelCompletionScreen
  - `/daily` → DailyChallengeScreen
  - `/achievements` → AchievementsScreen
  - `/statistics` → StatisticsScreen
  - `/settings` → SettingsScreen
  - `/shop` → ShopScreen
- [ ] Mevcut `Navigator.push` çağrılarını `context.go()` / `context.push()` ile değiştir
- [ ] Custom page transitions koruyarak route animasyonları ayarla

### 8.2 Deep Linking
- [ ] Push notification → belirli ekrana yönlendirme (Daily Challenge)
- [ ] Paylaşılan link → ilgili level'a yönlendirme (`crossclimber://game/42`)
- [ ] Android App Links + iOS Universal Links konfigürasyonu

### 8.3 State Restoration
- [ ] `RestorationMixin` ile oyun state'ini kaydet (app kill + restore senaryosu)
- [ ] Route history'yi restore et
- [ ] Aktif timer state'ini kaydet/geri yükle

---

## Phase 9: Settings & Kişiselleştirme Premium

> **Hedef:** Settings ekranını modern, kullanıcı dostu bir deneyime dönüştürmek.

### 9.1 Settings Yeniden Tasarım
- [x] Mevcut düz `ListView` → **Grouped card sections** (iOS Settings benzeri):
  - 👤 Profil & Hesap
  - 🎨 Görünüm (Tema, Dil)
  - 🎮 Oyun Ayarları (Keyboard, Auto-check, Auto-sort, Timer)
  - 🔊 Ses & Dokunsal
  - 📚 Yardım (Tutorial sıfırla, SSS)
  - ℹ️ Hakkında (Versiyon, Lisanslar, Gizlilik)
- [x] Her grubun başlığı: İkon + başlık + alt çizgi
- [x] Toggle'larda animasyonlu switch (mevcut `SwitchListTile` → custom animated)
- [x] Tema seçici: Dropdown yerine **görsel grid** (tema preview kartları)

### 9.2 Tema Preview
- [x] Her tema kartı: Mini game board preview görseli
- [x] Tema değişimi: `AnimatedTheme` ile yumuşak geçiş
- [x] Tema kilidi: Premium temalar → Shop'tan satın alınabilir (Phase 6 ile)

### 9.3 Profil Sayfası
- [x] Avatar seçimi: 12 preset avatar ikonu
- [x] Kullanıcı adı düzenleme (Firebase Auth display name)
- [x] Rank rozeti ve XP bilgisi
- [x] Bağlı hesaplar (Google, Facebook) durumu
- [x] Hesap silme seçeneği (GDPR uyumu)

---

## Phase 10: Performans & Teknik UX

> **Hedef:** Algılanan performansı artırma. 60 FPS her yerde.

### 10.1 Loading States
- [ ] HomeScreen: Skeleton loading ekle (mevcut değil)
- [ ] Level load: Shimmer placeholder → veri gelince crossfade
- [ ] Sayfa geçişlerinde: Geçiş animasyonu bitene kadar veri yükleme spinner gösterme
- [ ] Error states: Tüm ekranlarda tutarlı hata kartı + "Tekrar Dene" butonu + hata detayı (collapsible)

### 10.2 Perceived Performance
- [x] Sayfa pre-fetch: Sonraki level verisini game screen'de iken yükle
- [x] Image/font cache: Google Fonts offline fallback
- [x] Skeleton loading: Tüm FutureBuilder kullanan ekranlarda tutarlı skeleton

### 10.3 Animation Performance
- [x] `RepaintBoundary` ekle: StatusBar, Keyboard, ComboIndicator
- [x] Shimmer/glow animasyonları: `isRepaintBoundary: true`
- [ ] Profiling: Flutter DevTools ile 60 FPS doğrulaması
- [x] Gereksiz rebuild'leri tespit et: `const` constructor'lar, `select` ile provider

### 10.4 Offline Deneyim
- [x] Level verisi: İlk yüklemede local cache (mevcut kısmen var)
- [x] Offline durumda: Banner uyarısı + local özellikler çalışsın
- [x] İnternet gelince: Senkronizasyon + queue'daki aksiyonları gönder

---

## Önceliklendirme Matrisi

| Phase | Etki | Efor | Öncelik | Tahmini Süre |
|-------|------|------|---------|-------------|
| **Phase 1** Kritik Düzeltmeler | 🔴 Yüksek | 🟢 Düşük | **P0 — Hemen** | 2-3 gün |
| **Phase 2** Onboarding | 🔴 Yüksek | 🟡 Orta | **P1 — Bu sprint** | 5-7 gün |
| **Phase 3** Görsel Polish | 🟡 Orta | 🔴 Yüksek | **P2 — Sonraki sprint** | 10-14 gün |
| **Phase 4** Erişilebilirlik | 🟡 Orta | 🟡 Orta | **P2 — Sonraki sprint** | 5-7 gün |
| **Phase 5** Responsive | 🟡 Orta | 🟡 Orta | **P3 — Planlı** | 7-10 gün |
| **Phase 6** Oyunlaştırma | 🔴 Yüksek | 🔴 Yüksek | **P3 — Planlı** | 15-20 gün |
| **Phase 7** Animasyon Premium | 🟢 Düşük | 🟡 Orta | **P4 — Nice-to-have** | 7-10 gün |
| **Phase 8** Navigasyon Modern. | 🟢 Düşük | 🟡 Orta | **P4 — Nice-to-have** | 5-7 gün |
| **Phase 9** Settings Premium | 🟢 Düşük | 🟢 Düşük | **P4 — Nice-to-have** | 3-5 gün |
| **Phase 10** Performans | 🟡 Orta | 🟡 Orta | **P3 — Planlı** | 5-7 gün |

---

## Başarı Metrikleri (KPI)

| Metrik | Mevcut (Tahmin) | Hedef (6 ay) | Ölçüm Yöntemi |
|--------|----------------|-------------|---------------|
| **D1 Retention** | ~30% | ≥50% | Firebase Analytics |
| **D7 Retention** | ~10% | ≥25% | Firebase Analytics |
| **D30 Retention** | ~5% | ≥15% | Firebase Analytics |
| **Ortalama Oturum Süresi** | ~3dk | ≥8dk | Firebase Analytics |
| **Günlük Challenge Katılım** | ~20% DAU | ≥50% DAU | Custom event |
| **Paylaşım Oranı** | ~1% level tamamlama | ≥5% | Custom event |
| **App Store Puanı** | N/A | ≥4.5 | Store feedback |
| **Erişilebilirlik Skoru** | ~40% | ≥80% | Manual audit |
| **60 FPS Frame Rate** | ~90% frame | ≥99% frame | DevTools profiler |

---

## Teknik Bağımlılıklar

| Yeni Paket | Kullanım Yeri | Phase |
|------------|--------------|-------|
| `go_router` | Navigasyon modernizasyonu | Phase 8 |
| `lottie` | Premium animasyonlar (ateş, kilit kırılma) | Phase 7 |
| `cached_network_image` | Avatar, remote görseller | Phase 6 |
| `flutter_svg` | Illüstrasyonlar, rozetler | Phase 3 |
| `smooth_page_indicator` | Onboarding carousel dots | Phase 2 |
| `audio_players` (pool) | Ses sistemi iyileştirmesi | Phase 1 |

---

> **Not:** Bu roadmap yaşayan bir belgedir. Her phase tamamlandığında `[ ]` → `[x]` olarak işaretlenmelidir. Önceliklendirme, kullanıcı geri bildirimlerine ve analitik verilerine göre güncellenebilir.
