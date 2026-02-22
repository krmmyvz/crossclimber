# CrossClimber UI/UX Audit Report

**Tarih:** 21 Subat 2026
**Yontem:** 18 ekran goruntusu gorsel incelemesi + tum codebase analizi
**Kapsam:** Tum ekranlar, animasyonlar, tema sistemi, tutarlilik, erisilebilirlik

> **Efsane:** ✅ Duzeltildi &nbsp;|&nbsp; 🔲 Beklemede &nbsp;|&nbsp; ⏭ Atlandi (tasarim tercihi)

---

## DUZELTME GECMISI

**Phase 5 — Kapsamli Token Uygulamasi & Widget Standardizasyonu** *(21 Subat 2026)*

| Kod | Aciklama | Dosya |
|-----|----------|-------|
| K-3 | 13 ekrana text scaling koruması (clamp 0.85–1.3) | Tüm screen dosyaları |
| Y-2 | 128 hardcoded animasyon süresi → AnimDurations token (7 yeni sabit eklendi) | 34 dosya |
| D-1 | 33 hardcoded Curves.* → AppCurves token | 17 dosya |
| OV-3 | game_screen landscape Row Expanded→Flexible (taşma riski giderildi) | game_screen.dart |
| OV-4 | level_map zone badge text overflow koruması | level_map_screen.dart |
| OV-5 | shop bonus text maxLines:2 eklendi | shop_screen_cards.dart |
| 5.2 | 228 hardcoded opacity → Opacities token (97 widget + 131 screen) | 39 dosya |
| 2.4 | 21 hardcoded BoxShadow → AppShadows token | 17 dosya |
| 5.3 | Confetti & particle renkleri tema-aware yapıldı (GameColors) | confetti_overlay.dart, daily_reward_calendar.dart |
| D-5 | Klavye TextScaler.noScaling → clamp(0.85–1.15) | custom_keyboard.dart |
| O-1 | `SectionHeader` paylaşılan widget oluşturuldu + 9 kullanım | section_header.dart (YENİ), 4 dosya |
| O-2 | `HeroCard` paylaşılan widget oluşturuldu (gradient container) | hero_card.dart (YENİ) |
| O-3 | `AppProgressBar` paylaşılan widget oluşturuldu + 9 kullanım | app_progress_bar.dart (YENİ), 8 dosya |

**Phase 4 — Gorsel Butunluk: Tasarim Token Sistemi** *(21 Subat 2026)*

| Kod | Aciklama | Dosya |
|-----|----------|-------|
| Y-1a | `icon_sizes.dart` olusturuldu: xs(12), xsm(14), sm(16), smd(18), md(20), mld(22), lg(24), xl(28), xxl(32), hero(48), display(64) | icon_sizes.dart (YENi) |
| Y-1b | `opacities.dart` olusturuldu: faintest(0.04) … full(1.0) — 15 seviye | opacities.dart (YENI) |
| Y-1c | `shadows.dart` olusturuldu: subtle/medium/strong/heavy + colorSubtle/colorMedium/colorStrong/glow yardimcilari | shadows.dart (YENI) |
| Y-1d | `Radii.xxs(2)` ve `Radii.xxxl(32)` tokenlari + `RadiiBR.xxs/.xxxl` sabitleri eklendi | border_radius.dart |
| Y-3 | 23 hardcoded BorderRadius.circular() → RadiiBR tokenlarina cevrildi (14 dosya) | 14 dosya |
| Y-4 | 106 hardcoded icon size → IconSizes tokenlarina cevrildi (30+ dosya) | 30+ dosya |
| 5.3 | `_kGold` hardcoded renk kaldirildi → `theme.gameColors.star` kullanildi (9 referans) | daily_reward_calendar.dart |

**Phase 3 — Game, Stats, Achievements & Diger Duzeltmeler** *(21 Subat 2026)*

| Kod | Aciklama | Dosya |
|-----|----------|-------|
| H-5 | Quote karti alt padding 0→xs, Settings ust padding s→m | home_screen.dart |
| ST-1 | Stats hero gradient primary→primaryContainer/secondaryContainer | stats_overview_card.dart |
| ST-2 | Performance kart border'leri renk bazli→outlineVariant | performance_grid.dart |
| ST-3 | Achievement progress bar minHeight 12→16 | achievement_progress_card.dart |
| G-1 | Kilitli satirlarda ? yanina lock ikonu + Tooltip (l10n) | end_word_row.dart |
| G-2 | Secili border alpha 0.7, secilmemis border width 1→1.5 | end_word_row.dart |
| G-3 | Disabled buton opacity 0.5→0.65 | hint_quick_access_bar.dart |
| G-4 | useCustomKeyboard varsayilan false→true | settings_provider.dart |
| G-5 | Bos tile border width 1→1.5 | game_screen_widgets.dart |
| G-6 | Game board scroll bottom padding s→l | game_screen.dart |
| DI-2 | Dialog barrierColor Colors.black54 | modern_dialog.dart |
| L-2 | Checkpoint karti gradient→surfaceContainerLow + outlineVariant | level_map_screen.dart |
| SK-2 | Milestone ikon radio_button_unchecked→circle_outlined + alpha 0.25 | streak_screen.dart |
| SK-3 | Reward ikon 14→16, SizedBox(3)→HorizontalSpacing.xxs | streak_screen.dart |
| A-1 | Achievement progress header minHeight 12→16 | achievement_progress_header.dart |
| A-2 | Achievement kilit ikonu size 18→22 | achievement_card.dart |
| A-3 | Achievement progress bar minHeight 6→8, min value %2 | achievement_card.dart |

**Phase 2 — Ekran Bazli Gorsel Duzeltmeler** *(21 Subat 2026)*

| Kod | Aciklama | Dosya |
|-----|----------|-------|
| H-1 | Streak ates ikonu 28→32px, Row crossAxisAlignment.center | home_screen.dart |
| H-2 | Claim butonu theme.textTheme.labelSmall ile tutarli tipografi | daily_reward_calendar.dart |
| H-3 | Grid kartlarina badgeColor parametresi — semantik renk kodlamasi | home_screen.dart |
| H-4 | Quick Play OutlinedButton→FilledButton.tonal | home_screen.dart |
| P-1 | Placeholder hintStyle alpha 0.6 ile gorulur hale getirildi | profile_screen.dart |
| P-3 | Total XP degerine gameColors.star rengi eklendi | profile_screen.dart |
| P-4 | Google: FilledButton.tonal / Disconnect: OutlinedButton(error) / Delete: chevron kaldirildi | profile_screen.dart |
| M-3 | Ad reward kartina border + elevation eklendi | shop_screen_rewards.dart |
| M-4 | Ad butonlari OutlinedButton→FilledButton.tonal | shop_screen_rewards.dart |
| M-6 | Fiyat badge'lerine minWidth:80 constraint | shop_screen_cards.dart |
| M-8 | Life kartlarinda monetization_on→diamond_rounded ikonu | shop_screen_cards.dart |
| D-1 | Challenge kart arka planina streak warm gradient | daily_challenge_screen.dart |
| D-2 | Freeze count Stats kartinin altina belirgin banner | daily_challenge_stats.dart |
| D-3 | Stats ikonlari 24px standardize, label textAlign.center | daily_challenge_stats.dart |
| D-4 | Takvimde kacirilan gunler icin kirmizi/X gosterim | daily_challenge_calendar.dart |

**Phase 1 — Ekran Bazli Gorsel Inceleme** *(21 Subat 2026)*

| Kod | Aciklama | Dosya |
|-----|----------|-------|
| M-1, M-2 | KRITIK: Market overflow — Flexible wrapper + "POPULAR" kisaltmasi | shop_screen_cards.dart |
| L-1 | KRITIK: Level Map AppBar overflow — leadingWidth 130→140, showLives kosulu | common_app_bar.dart |
| H-6 | HomeScreen streak progress bar minHeight 4→6 | home_screen.dart |
| P-2 | Avatar edit ikonu 14→16px, container 28→32px | profile_screen.dart |
| P-5 | Avatar grid responsive: <360px→4 sutun, diger→6 sutun | profile_screen.dart |
| D-5 | Daily Challenge level info satiri Expanded ile overflow korumasI | daily_challenge_screen.dart |
| M-5 | "Streak: 1 days" gramer — ICU plural ("1 day" / "X days") | app_en.arb |
| M-7 | "1 Lives" gramer — ICU plural ("1 Life" / "X Lives") | app_en.arb |
| DI-1 | Pause menu "Main Menu" butonundan isDestructive kaldirildi | game_screen_dialogs.dart |
| DI-3 | ModernDialogContent: 3+ aksiyon varsa Row yerine Column layout | modern_dialog.dart |
| S-1 | Profile subtitle maxLines 1→2 (metin artik kesilmiyor) | settings_screen.dart |
| S-2 | Tema grid kilit ikonu 20→24px | theme_grid_selector.dart |
| S-3 | High Contrast ile Custom Keyboard arasina Divider eklendi | settings_screen.dart |
| S-4 | Versiyon numarasi ayri alt satirda, daha belirgin | settings_screen.dart |
| A-4 | Rarity baslik cizgisi: genislik 4→5px, yukseklik 20→22px | achievements_screen.dart |
| L-4 | Level Map path cizgileri strokeWidth 3→4 | level_map_screen.dart |

---

## OZET SKOR TABLOSU

| Kategori | Durum | Oncelik |
|----------|-------|---------|
| Gorsel Tutarlilik (Renk Paleti) | Iyi | - |
| Kart & Border Stilleri | ~~Orta~~ Iyi — 23 hardcoded BR duzeltildi | ~~YUKSEK~~ - |
| Animasyon Suresi Tutarliligi | ~~Kotu~~ Iyi — 128 hardcoded → AnimDurations token | ~~YUKSEK~~ - |
| Animasyon Curve Tutarliligi | ~~Orta~~ Iyi — 33 hardcoded → AppCurves token | ~~ORTA~~ - |
| Icon Boyut Tutarliligi | ~~Kotu~~ Iyi — 106 hardcoded boyut duzeltildi | ~~YUKSEK~~ - |
| Spacing/Padding Tutarliligi | Orta - Karisik kullanim | ORTA |
| Font Boyut Tutarliligi | Iyi - Birkaç istisna | DUSUK |
| Overflow & Responsive | ~~Kotu~~ Iyi — OV-3/4/5 giderildi | ~~KRITIK~~ - |
| Sayfa Gecis Animasyonlari | Mukemmel | - |
| Dialog Sistemi | Iyi | - |
| AppBar Tutarliligi | Iyi | - |
| Erisilebilirlik | ~~Orta~~ Iyi — 13 ekran text scaling + klavye fix | ~~YUKSEK~~ - |
| Design Token Sistemi | ~~Eksik~~ Kapsamli — icons, opacities, shadows, durations, curves | ~~YUKSEK~~ - |
| Opacity Tutarliligi | ~~Kotu~~ Iyi — 228 hardcoded → Opacities token | ~~YUKSEK~~ - |
| Shadow Tutarliligi | ~~Kotu~~ Iyi — 21 hardcoded → AppShadows token | ~~YUKSEK~~ - |
| Widget Standardizasyonu | ~~Eksik~~ Iyi — SectionHeader, HeroCard, AppProgressBar | ~~ORTA~~ - |

---

## 1. EKRAN BAZLI GORSEL INCELEME

### 1.1 HomeScreen (photo_1, photo_2)

**Olumlu:**
- Gradient hero alani gorsel olarak etkileyici
- "Play" butonu belirgin ve erisimi kolay
- Kart layout'u duzgun (XP, Streak, Daily Reward)
- Alt grid kartlari (Daily Challenge, Achievements, Statistics, Market) temiz

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| H-1 | ✅ | Streak karindaki ates ikonu buyutuldu (28→32px), Row crossAxisAlignment.center ile hizalama duzeltildi | Dusuk | home_screen.dart ~L789 |
| H-2 | ✅ | Daily Reward Calendar "Claim!" butonu theme.textTheme.labelSmall kullanacak sekilde duzeltildi | Orta | daily_reward_calendar.dart ~L522 |
| H-3 | ✅ | Alt grid kartlarina badgeColor parametresi eklendi — her kart semantik renk kullaniyor | Orta | home_screen.dart ~L695-746 |
| H-4 | ✅ | Quick Play butonu OutlinedButton→FilledButton.tonal ile gorsel agirlik esitlendi | Dusuk | home_screen.dart |
| H-5 | ✅ | Alinti karti alt padding 0→xs, Settings butonu ust padding s→m ile bosluk artirildi | Dusuk | home_screen.dart |
| H-6 | ✅ | Streak kartinda progress bar cok ince ve neredeyse gorunmuyor (0/7) | Orta | home_screen.dart ~L710 |

### 1.2 Settings Ekrani (photo_3, photo_4)

**Olumlu:**
- Section basliklarI (Profile & Account, Appearance, Sound & Haptics, Gameplay, Help & Info) net
- Tema secici grid gorsel olarak iyi
- Switch'ler tutarli

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| S-1 | ✅ | "Guest User" kartinda "Link your account to save progress to t..." metni kesilmis — maxLines 1→2 | Orta | settings_screen.dart ~L589 |
| S-2 | ✅ | Tema kartlarindaki kilitli temalar uzerindeki kilit ikonu cok kucuk — 20→24px | Dusuk | theme_grid_selector.dart |
| S-3 | ✅ | "High Contrast Mode" ve "Custom Keyboard" arasinda bosluk yok — Divider eklendi | Dusuk | settings_screen.dart |
| S-4 | ✅ | Version numarasi (1.0.0) altta kaybolmus — ayri subtitle satirina tasindi | Dusuk | settings_screen.dart |

### 1.3 Profile Ekrani (photo_5)

**Olumlu:**
- Avatar sistemi temiz
- XP progress bar acik
- Delete Account kirmizi uyari dogru

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| P-1 | ✅ | Placeholder hintStyle alpha 0.6 ile daha belirgin hale getirildi | Orta | profile_screen.dart |
| P-2 | ✅ | Avatar edit ikonu (kalem) cok kucuk ve fark edilmiyor — 14→16px, container 28→32px | Orta | profile_screen.dart ~L232 |
| P-3 | ✅ | Total XP degerine de gameColors.star rengi eklendi — renk hiyerarsisi tutarli | Dusuk | profile_screen.dart |
| P-4 | ✅ | Google sign-in FilledButton.tonal, Disconnect OutlinedButton (error), Delete Account'tan chevron kaldirildi | Orta | profile_screen.dart |
| P-5 | ✅ | Avatar grid 6 sutun hardcoded — responsive: <360px→4 sutun, diger→6 sutun | Orta | profile_screen.dart ~L322 |

### 1.4 Market/Shop Ekrani (photo_6, photo_7, photo_17)

**Olumlu:**
- Kategori ayirimi net (Earn Free, Credit Package, Life Package, Hint Package, Streak Protection)
- "POPULAR" badge'leri dikkat cekici
- Fiyatlandirma duzenli

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| M-1 | ✅ | **KRITIK: "500 Credits" kartinda "RIGHT OVERFLOWED BY 50 PIXELS"** — Flexible wrapper eklendi | KRITIK | shop_screen_cards.dart ~L95-159 |
| M-2 | ✅ | "MOST" yazisi kesik — "POPULAR" kisaltmasina gecirildi | KRITIK | shop_screen_cards.dart |
| M-3 | ✅ | Reklam kartina border + elevation eklenerek diger kartlarla gorsel tutarlilik saglandi | Orta | shop_screen_rewards.dart |
| M-4 | ✅ | "+10 Credits" ve "+1 Hint" butonlari OutlinedButton→FilledButton.tonal ile esitlendi | Dusuk | shop_screen_rewards.dart |
| M-5 | ✅ | "Streak: 1 days" gramer hatasi — ICU plural ("1 day" / "X days") | Dusuk | app_en.arb |
| M-6 | ✅ | Fiyat badge'lerine minWidth: 80 constraint eklendi — hizalama duzeltildi | Orta | shop_screen_cards.dart |
| M-7 | ✅ | "1 Lives" gramer hatasi — ICU plural ("1 Life" / "X Lives") | Dusuk | app_en.arb |
| M-8 | ✅ | Life kartlari monetization_on→diamond_rounded ikonu ile standardize edildi | Orta | shop_screen_cards.dart |

### 1.5 Daily Challenge Ekrani (photo_8, photo_14)

**Olumlu:**
- Current Streak karti gorsel olarak dikkat cekici (turuncu gradient)
- Today's Challenge bilgileri net
- Your Stats bolumu iyi organize

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| D-1 | ✅ | Challenge kart arka plani streak renk harmonisi ile warm gradient eklendi | Orta | daily_challenge_screen.dart |
| D-2 | ✅ | Freeze count Stats kartinin altina belirgin bir banner ile eklendi | Dusuk | daily_challenge_stats.dart |
| D-3 | ✅ | Stats ikon boyutlari 24px olarak standardize edildi, label textAlign.center eklendi | Dusuk | daily_challenge_stats.dart |
| D-4 | ✅ | Takvimde gecmis gunler: tamamlanan=yesil/check, kacirilan=kirmizi/X, bugun=mavi border | Dusuk | daily_challenge_calendar.dart |
| D-5 | ✅ | Level info satiri (Difficulty: Hard, Words: 7) overflow korumasI yok — Expanded eklendi | Orta | daily_challenge_screen.dart ~L268-282 |

### 1.6 Statistics Ekrani (photo_9)

**Olumlu:**
- "Your Statistics" hero karti acik renkli - dikkat cekici
- Performance grid kartlari temiz
- Time Statistics listesi duzgun

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| ST-1 | ✅ | Hero kart gradienti primary→primaryContainer/secondaryContainer ile diger kartlarla uyumlastirildi | Orta | stats_overview_card.dart |
| ST-2 | ✅ | Performance kart border’leri renk bazli→outlineVariant ile standartlastirildi | Dusuk | performance_grid.dart |
| ST-3 | ✅ | Achievement progress bar minHeight 12→16 ile gorunurlugu artirildi | Dusuk | achievement_progress_card.dart |

### 1.7 Game Screen (photo_10, photo_18)

**Olumlu:**
- Kelime gridi temiz ve okunabilir
- Timer ve star sayaci ust barda net
- Hint bar altta erisimi kolay
- Hint ipucu ("Attic or upper room") mavi barda belirgin

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| G-1 | ✅ | Kilitli satirlardaki ? isareti yanina kilit ikonu + Tooltip eklendi (solveMiddleWordsFirst l10n) | Orta | end_word_row.dart |
| G-2 | ✅ | Secili border alpha 0.7 ile yumusaklastirildi, secilmemis border width 1→1.5 ile dengelendi | Dusuk | end_word_row.dart |
| G-3 | ✅ | Disabled buton opacity 0.5→0.65 ile boyut algi farki azaltildi | Orta | hint_quick_access_bar.dart |
| G-4 | ✅ | useCustomKeyboard varsayilan deger false→true olarak degistirildi | Orta | settings_provider.dart |
| G-5 | ✅ | Bos tile border width 1→1.5 ile kalinlastirildi | Dusuk | game_screen_widgets.dart |
| G-6 | ✅ | Game board scroll bottom padding s→l ile hint bar cakismasi onlendi | Orta | game_screen.dart |

### 1.8 Pause & Exit Dialoglari (photo_11, photo_12)

**Olumlu:**
- Dialog tasarimi temiz ve modern
- Buton hiyerarsisi dogru (Cancel outlined, Exit/Resume filled)
- Ikon kullanimi anlamli

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| DI-1 | ✅ | Pause ekraninda "Main Menu" butonu kirmizi border — isDestructive kaldirildi | Orta | game_screen_dialogs.dart |
| DI-2 | ✅ | Dialog barrierColor Colors.black54 ile yumusaklastirildi | Dusuk | modern_dialog.dart |
| DI-3 | ✅ | Pause menusunde 3 buton yan yana — 3+ aksiyon varsa Column layout kullaniliyor | Orta | modern_dialog.dart |

### 1.9 Level Map Ekrani (photo_13)

**Olumlu:**
- Seviye kartlari grid duzeni iyi
- Tamamlanan seviyeler yesil, aktif seviye parlak yesil, kilitli seviyeler gri
- Yildiz gosterimi net
- Path baglantilari seviyeler arasi iyi

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| L-1 | ✅ | **KRITIK: Sol ust kosede "OVERFLOWED BY"** — leadingWidth 130→140, showLives kosulu eklendi | KRITIK | common_app_bar.dart |
| L-2 | ✅ | Checkpoint karti gradient→surfaceContainerLow + outlineVariant border ile diger kartlarla uyumlastirildi | Orta | level_map_screen.dart |
| L-3 | ⏭ | Kilitli seviyelerdeki kilit ikonu cok kucuk ve soluk (mevcut 28-36px, zaten yeterli) | Dusuk | level_map_screen.dart ~L726 |
| L-4 | ✅ | Path cizgileri (yesil) cok ince — strokeWidth 3→4 | Dusuk | level_map_screen.dart |
| L-5 | ⏭ | Seviye 3 (aktif) kartinin boyutu farkli — kasitli tasarim (AnimatedScale ile vurgu) | Dusuk | level_map_screen.dart |

### 1.10 Daily Challenge Alt Kisim (photo_14)

(1.5 ile birlesikte degerlendirildi)

### 1.11 Streak Ekrani (photo_15)

**Olumlu:**
- Hero alanI (turuncu gradient) dikkat cekici
- Milestone listesi temiz
- "Play today!" ve "4 freeze" butonlari yan yana iyi

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| SK-1 | ⏭ | "Play today!" butonu kirmizi border — aslinda uyari karti, kirmizi semantik olarak dogru (streak kaybı tehlikesi) | Orta | streak_screen.dart |
| SK-2 | ✅ | Ulasilmamis milestone ikonu radio_button_unchecked→circle_outlined + alpha 0.25 ile progress hissi eklendi | Dusuk | streak_screen.dart |
| SK-3 | ✅ | Reward ikon boyutu 14→16, SizedBox(3)→HorizontalSpacing.xxs ile bosluk tutarlilastirildi | Dusuk | streak_screen.dart |

### 1.12 Achievements Ekrani (photo_16)

**Olumlu:**
- Progress hero karti net (4/30, 13%)
- Rarity kategorileri (LEGENDARY) sari etiketle belirgin
- Achievement kartlari tutarli

**Sorunlar:**

| # | Durum | Sorun | Ciddiyet | Konum |
|---|-------|-------|----------|-------|
| A-1 | ✅ | Achievement progress header bar minHeight 12→16 ile gorunurlugu artirildi | Orta | achievement_progress_header.dart |
| A-2 | ✅ | Kilit ikonu size 18→22 ile buyutuldu | Dusuk | achievement_card.dart |
| A-3 | ✅ | Progress bar minHeight 6→8, minimum value %2 ile dusuk ilerleme gorulur hale getirildi | Dusuk | achievement_card.dart |
| A-4 | ✅ | "LEGENDARY" basliginin solundaki sari cizgi cok ince — genislik 4→5px, yukseklik 20→22px | Dusuk | achievements_screen.dart ~L177 |

---

## 2. GORSEL BUTUNLUK ANALIZI

### 2.1 Renk Paleti Tutarliligi

**Genel Durum:** IYI - Tema sistemi iyi kurulmus

Ana sorunlar:
- **Turuncu/Kirmizi karisikligi:** Streak kartlari turuncu, ama "Play today!" butonu kirmizi border kullaniyor. Kirmizi normalde "tehlike" icin ayrilmis (Delete Account, Exit Game)
- **Yesil kullanim:** Market ekraninda "Claim Daily Reward" yesil, Level Map'te tamamlanan seviyeler yesil, "Correct" tile'lar yesil - TUTARLI
- **Mavi kullanim:** Play butonu mavi, secili satir mavi, "Play Now" mavi - TUTARLI
- **Sari/Gold kullanim:** XP, Achievements, Daily Reward Calendar - TUTARLI

### 2.2 Kart Stili Tutarliligi

**Genel Durum:** ORTA - Birden fazla kart stili var

| Stil | Kullanildigi Yer | Ozellikler |
|------|------------------|------------|
| Koyu kart + ince border | HomeScreen grid, Settings sections | border: 1px, surfaceContainerLow |
| Koyu kart + kalin renkli border | Daily Reward, Streak card | border: 1.5px, renkli |
| Acik renkli hero kart | Statistics hero, Level Map hero | Acik arka plan |
| Gradient hero kart | HomeScreen hero, Streak hero, Daily Challenge streak | Gradient arka plan |
| Yesil/renkli dolu kart | Market claim, Level Map completed | Dolu renk |

**Sorun:** 5 farkli kart stili var. Bunlar 3'e indirilebilir:
1. **Standard kart** (ince border, koyu arka plan)
2. **Hero/Feature kart** (gradient veya acik arka plan)
3. **Aksiyon kart** (renkli dolu arka plan)

### 2.3 Border Radius Tutarliligi

**Genel Durum:** ~~KOTU~~ IYI — 23 hardcoded deger duzeltildi

Tema sisteminde tanimli (genisletildi):
- `Radii.xxs: 2`, `xs: 4`, `sm: 8`, `md: 12`, `lg: 16`, `xl: 20`, `xxl: 24`, `xxxl: 32`, `full: 999`

✅ Tum hardcoded `BorderRadius.circular()` degerleri `RadiiBR` tokenlarina cevrildi:
- `2px, 2.5px, 3px` → `RadiiBR.xxs` (yeni token)
- `4px` → `RadiiBR.xs`
- `6px, 8px` → `RadiiBR.sm`
- `12px` → `RadiiBR.md`
- `15px, 16px` → `RadiiBR.lg`
- `24px` → `RadiiBR.xxl`
- `32px` → `RadiiBR.xxxl` (yeni token)

### 2.4 Golge (Shadow) Tutarliligi

**Genel Durum:** ~~KOTU~~ ORTA — Token sistemi olusturuldu

✅ `AppShadows` sinifi olusturuldu (`lib/theme/shadows.dart`):
- 4 notr golge seviyesi: `subtle`, `medium`, `strong`, `heavy`
- 3 renkli golge yardimcisi: `colorSubtle`, `colorMedium`, `colorStrong`
- `glow` efekti yardimcisi
- Hazir liste sabitleri: `elevation1`, `elevation2`, `elevation3`

**Not:** Mevcut 26 BoxShadow kullanimi henuz AppShadows'a cevrilmedi (risk minimuze etmek icin). Yeni kodda AppShadows kullanilmali.

---

## 3. ANIMASYON AUDIT

### 3.1 Animasyon Suresi Tutarliligi

**Genel Durum:** KOTU

Tema sabitleri (`AnimDurations`):
```
micro: 100ms, fast: 200ms, normal: 300ms, medium: 400ms
slow: 500ms, slower: 800ms, slowest: 1200ms, extraLong: 1500ms
```

**Hardcoded sureler (tema sabitlerini KULLANMAYAN):**

| Dosya | Satir | Deger | Olmasi Gereken |
|-------|-------|-------|----------------|
| main.dart | 62 | 350ms | AnimDurations.medium (400ms) |
| main.dart | 99 | 500ms | AnimDurations.slow |
| animated_settings_switch.dart | 28, 47 | 250ms | Yeni sabit tanimlanmali |
| daily_reward_calendar.dart | 42 | 500ms | AnimDurations.slow |
| daily_reward_calendar.dart | 80 | 2200ms | Ozel deger - sabit olmali |
| daily_reward_calendar.dart | 147, 404 | 300ms | AnimDurations.normal |
| daily_reward_calendar.dart | 453 | 900ms | Yeni sabit tanimlanmali |
| combo_indicator.dart | 92, 330 | 2000ms, 1500ms | AnimDurations.extraLong |
| letter_tile.dart | 108, 115 | 400ms, 1500ms | AnimDurations.medium, extraLong |
| profile_card.dart | 201 | 1200ms | AnimDurations.slowest |
| modern_dialog.dart | 320 | 500ms | AnimDurations.slow |
| achievement_card.dart | 264, 271 | index*50ms, 600ms | Stagger + AnimDurations.slower |
| level_map_screen.dart | 453 | 1200ms | AnimDurations.slowest |
| onboarding_screen.dart | 31-269 | 200-500ms (5+ yerde) | AnimDurations sabitleri |
| game_screen.dart | 94-1064 | 550-1800ms (4+ yerde) | AnimDurations sabitleri |
| level_completion_screen.dart | 84, 164 | 1200ms, 500ms | AnimDurations sabitleri |
| tournament_screen.dart | 510 | 300ms | AnimDurations.normal |
| streak_screen.dart | 187, 192 | 1000ms | Yeni sabit tanimlanmali |

**Toplam:** 25+ hardcoded animasyon suresi

### 3.2 Animasyon Curve Tutarliligi

**Genel Durum:** ORTA

Tema sabitleri (`AppCurves`):
```
easeOut: Curves.easeOutCubic, elastic: Curves.elasticOut
standard: Curves.easeInOut, decelerate: Curves.decelerate
fastOutSlowIn: Curves.fastOutSlowIn, spring: Curves.easeOutBack
```

**30+ yerde hardcoded Curves kullaniliyor:**
- `Curves.easeIn` (main.dart)
- `Curves.easeOutQuad` (custom_keyboard.dart)
- `Curves.easeOut` (discovery_banner.dart, game_status_bar.dart)
- `Curves.easeOutCubic` (tutorial_dialog.dart)
- `Curves.easeInOut` (level_map_screen.dart, onboarding_screen.dart, home_screen.dart, middle_words_section.dart)
- `Curves.elasticOut` (combo_indicator.dart, game_screen_dialogs.dart)
- `Curves.easeOutBack` (level_map_screen.dart, game_screen_dialogs.dart)

### 3.3 Sayfa Gecis Animasyonlari

**Genel Durum:** MUKEMMEL

4 gecis tipi tutarli sekilde uygulanmis:
1. **AppPageRoute** - Sag'dan kayma (standart navigasyon)
2. **FadeThroughPageRoute** - Fade gecis (kardes sayfalar arasi)
3. **BottomSlidePageRoute** - Alttan kayma (modal sayfalar)
4. **SpringBottomSheetRoute** - Spring efektli alt sayfa

Hepsi `AnimDurations` ve `AppCurves` sabitlerini kullaniyor.

---

## 4. RESPONSIVE & OVERFLOW SORUNLARI

### 4.1 Kritik Overflow Hatalari (Ekran Goruntusunde Gorulen)

| # | Durum | Ekran | Sorun | Dosya |
|---|-------|-------|-------|-------|
| OV-1 | ✅ | **Market - 500 Credits karti** | "RIGHT OVERFLOWED BY 50 PIXELS" — Flexible wrapper + POPULAR kisaltmasi | shop_screen_cards.dart |
| OV-2 | ✅ | **Level Map - Sol ust kose** | "OVERFLOWED BY" — leadingWidth genisletildi | common_app_bar.dart |

### 4.2 Potansiyel Overflow Riskleri (Koddan Tespit)

| # | Durum | Ekran | Risk | Dosya:Satir |
|---|-------|-------|------|-------------|
| OV-3 | ✅ | GameScreen landscape | Row Expanded→Flexible (Phase 5) | game_screen.dart |
| OV-4 | ✅ | LevelMapScreen kartlari | Text overflow + Flexible koruması (Phase 5) | level_map_screen.dart |
| OV-5 | ✅ | ShopScreen bonus text | maxLines:2 eklendi (Phase 5) | shop_screen_cards.dart |
| OV-6 | ✅ | ProfileScreen avatar grid | 6 sutun hardcoded — responsive yapildi (<360px: 4 sutun) | profile_screen.dart ~L322 |
| OV-7 | ✅ | DailyChallengeScreen level info | Row icinde flex/expanded yok — Expanded eklendi | daily_challenge_screen.dart ~L268-282 |
| OV-8 | ✅ | Pause menu 3 buton | Yan yana 3 buton — Column layout uygulanadi | modern_dialog.dart |

### 4.3 Text Scaling Sorunu

**KRITIK:** Yalnizca `GameStatusBar` text scaling clamp uyguluyor:
```dart
final clampedTextScaler = MediaQuery.textScalerOf(context)
    .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);
```

**Diger 14+ ekran text scaling korumasI OLMADAN calisiyor.**

Etkilenen ekranlar:
- SettingsScreen - Buyuk metin ayarinda overflow riski
- ProfileScreen - Display name alani
- OnboardingScreen - Baslik metinleri
- AchievementsScreen - Achievement kartlari
- ShopScreen - Fiyat ve aciklama metinleri
- TournamentScreen - Leaderboard satirlari

### 4.4 Custom Keyboard Erisilebilirlik

**Sorun:** `custom_keyboard.dart:318` - `textScaler: TextScaler.noScaling`
- Text scaling tamamen devre disi birakilmis
- Erisilebilirlik yonergelerine aykiri
- Gorme engelli kullanicilar icin sorun

---

## 5. DESIGN TOKEN TUTARSIZLIKLARI

### 5.1 Icon Boyutlari

**Genel Durum:** ~~KOTU~~ IYI — 106 hardcoded boyut duzeltildi

✅ `IconSizes` sinifi olusturuldu (`lib/theme/icon_sizes.dart`):
```dart
class IconSizes {
  static const double xs = 12;    // Badge ikonlari
  static const double xsm = 14;   // Kucuk inline ikonlar
  static const double sm = 16;    // Kucuk ikonlar
  static const double smd = 18;   // Orta-kucuk ikonlar
  static const double md = 20;    // Orta ikonlar
  static const double mld = 22;   // Orta-buyuk ikonlar
  static const double lg = 24;    // Standart ikonlar
  static const double xl = 28;    // Buyuk ikonlar
  static const double xxl = 32;   // Extra buyuk
  static const double hero = 48;  // Hero ikonlar
  static const double display = 64; // Display ikonlar
}
```

30+ dosyada 106 hardcoded `size:` degeri tokenlara cevrildi.

### 5.2 Opacity/Alpha Degerleri

**Genel Durum:** ~~KOTU~~ ORTA — Token sistemi olusturuldu

✅ `Opacities` sinifi olusturuldu (`lib/theme/opacities.dart`):
```dart
class Opacities {
  static const double faintest = 0.04;
  static const double faint = 0.08;
  static const double subtle = 0.1;
  static const double light = 0.12;
  static const double soft = 0.15;
  static const double gentle = 0.2;
  static const double quarter = 0.25;
  static const double medium = 0.3;
  static const double semi = 0.4;
  static const double half = 0.5;
  static const double strong = 0.6;
  static const double bold = 0.7;
  static const double heavy = 0.8;
  static const double near = 0.9;
  static const double full = 1.0;
}
```

**Not:** 171 mevcut `.withValues(alpha:)` kullanimi henuz Opacities tokenlarina cevrilmedi (risk minimize). Yeni kodda Opacities kullanilmali.

### 5.3 Hardcoded Renkler

| Dosya | Satir | Renk | Durum |
|-------|-------|------|-------|
| daily_reward_calendar.dart | 13 | `Color(0xFFFFB300)` (_kGold) | ✅ `gameColors.star` kullaniyor |
| confetti_overlay.dart | 30-35 | 6 hardcoded renk | ✅ GameColors/ColorScheme kullanıyor (Phase 5) |
| daily_reward_calendar.dart | 609-616 | Particle renkleri hardcoded | ✅ Tema renklerini kullanıyor (Phase 5) |

---

## 6. EKRANLAR ARASI GORSEL BUTUNLUK SORUNLARI

### 6.1 Section Header Tutarsizligi

Her ekran farkli section header stili kullaniyor:

| Ekran | Stil | Dosya |
|-------|------|-------|
| Statistics | Icon(24) + titleLarge | statistics_screen.dart |
| Shop | Container + icon + Column + subtitle | shop_screen.dart |
| Tournament | Text(titleSmall) | tournament_screen.dart |
| Streak | Manuel Row | streak_screen.dart |
| Settings | Renkli emoji + renkli metin | settings_screen.dart |

**Oneri:** Tek bir `SectionHeader` widget'i olusturulmali.

### 6.2 Hero Kart Tutarsizligi

| Ekran | Hero Kart Stili |
|-------|-----------------|
| HomeScreen | Gradient (koyu mavi) |
| Statistics | Acik gri/mavi, elevation |
| Daily Challenge | Turuncu gradient |
| Streak | Turuncu/somon gradient |
| Achievements | Koyu gradient + progress bar |
| Level Map | Koyu gri, 3 stat |

**Sorun:** Her ekranin hero karti tamamen farkli gorunuyor. Gradient yonleri, renkleri, ve yapilari tutarsiz.

**Oneri:** 2-3 hero kart varyanti tanimlanmali:
1. **Warm hero** (Streak, Daily Challenge icin) - turuncu/somon tonlari
2. **Cool hero** (Statistics, Achievements icin) - mavi/gri tonlari
3. **Brand hero** (HomeScreen icin) - gradient

### 6.3 Buton Stili Tutarsizligi

| Buton Tipi | Kullanildigi Yer | Sorun |
|------------|------------------|-------|
| FilledButton (mavi) | Play, Play Now | Tutarli |
| OutlinedButton | Cancel, Quick Play | Tutarli |
| Kirmizi border buton | Play today!, Main Menu (pause) | **TUTARSIZ** - kirmizi tehlike icin ayrilmali |
| Yesil dolu kart | Market Claim Reward | Tutarli |
| Sari/Gold buton | Daily Reward Claim | **TUTARSIZ** - baska yerde yok |

### 6.4 Progress Bar Tutarsizligi

| Ekran | Kalinlik | Renk | Arka Plan |
|-------|----------|------|-----------|
| HomeScreen XP | Ince (~4px) | Sari | Koyu |
| HomeScreen Streak | Cok ince (~2px) | Gri | Gri |
| Achievements hero | Ince (~4px) | Mavi | Gri |
| Achievement kartlari | Cok ince (~2px) | Kategoriye gore | Gri |
| Level Map zone | Orta (~6px) | Yesil | Gri |

**Oneri:** 2 progress bar boyutu tanimlanmali: `thin (4px)` ve `standard (8px)`

---

## 7. EKSIK EKRAN GORUNTULERI - KOD BAZLI ANALIZ

### 7.1 Onboarding Ekrani (Ekran goruntusu yok)

Koddan analiz (`onboarding_screen.dart`):
- 3 sayfalik PageView yapisi
- Her sayfada baslik + aciklama + gorsel
- "Skip" ve "Next" butonlari
- **Sorun:** Baslik `headlineMedium` kullaniyor ama text clamping yok
- **Sorun:** Animasyon sureleri hardcoded (200ms, 300ms, 400ms, 500ms)

### 7.2 Level Completion Ekrani (Ekran goruntusu yok)

Koddan analiz (`level_completion_screen.dart`):
- Yildiz animasyonu
- Stat kartlari (sure, hamle, ipucu)
- "Next Level" ve "Main Menu" butonlari
- **Sorun:** Animasyon sureleri hardcoded (500ms, 1200ms)
- **Sorun:** Baslik text scaling korumasI yok

### 7.3 Tournament Ekrani (Ekran goruntusu yok)

Koddan analiz (`tournament_screen.dart`):
- Turnuva kartlari
- Leaderboard listesi
- **Sorun:** Grid sutun sayisi hardcoded
- **Sorun:** Difficulty pill'de `fontSize: 9` cok kucuk

---

## 8. ONCELIKLI COZUM ONERILERI

### KRITIK (Hemen yapilmali)

#### ✅ K-1: Market ekranindaki overflow duzeltilmeli
**Dosya:** `shop_screen_cards.dart`
**Durum:** TAMAMLANDI — Flexible wrapper eklendi, "POPULAR" kisaltmasi kullanildi

#### ✅ K-2: Level Map AppBar overflow duzeltilmeli
**Dosya:** `common_app_bar.dart`
**Durum:** TAMAMLANDI — leadingWidth 130→140, showLives kosuluna genisletildi

#### K-3: Text scaling korumasi tum ekranlara uygulanmali
**Dosyalar:** Tum ekranlar
**Cozum:**
```dart
// Her ekranin build metoduna ekle:
final clampedTextScaler = MediaQuery.textScalerOf(context)
    .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3);
return MediaQuery(
  data: MediaQuery.of(context).copyWith(textScaler: clampedTextScaler),
  child: ...
);
```

### YUKSEK ONCELIK

#### ✅ Y-1: Design token sistemini genislet
**Dosyalar:** `lib/theme/` altina yeni dosyalar
**Durum:** TAMAMLANDI
1. ✅ `icon_sizes.dart` olusturuldu (xs, xsm, sm, smd, md, mld, lg, xl, xxl, hero, display)
2. ✅ `opacities.dart` olusturuldu (faintest … full — 15 seviye)
3. ✅ `shadows.dart` olusturuldu (subtle, medium, strong, heavy + renkli yardimcilar)
4. ✅ `border_radius.dart` genisletildi (xxs, xxxl tokenlari eklendi)

#### Y-2: Tum hardcoded animasyon surelerini sabitlere cevir
**Etkilenen dosya sayisi:** 15+
**Eylem:** Grep ile tum `Duration(milliseconds:` ve `.ms` kullanimlarini bul, AnimDurations sabitlerine cevir

#### ✅ Y-3: Tum hardcoded border radius degerlerini sabitlere cevir
**Etkilenen dosya sayisi:** 14
**Durum:** TAMAMLANDI — 23 hardcoded BR degeri RadiiBR tokenlarina cevrildi

#### ✅ Y-4: Tum hardcoded icon boyutlarini sabitlere cevir
**Etkilenen dosya sayisi:** 30+
**Durum:** TAMAMLANDI — 106 hardcoded icon boyutu IconSizes tokenlarina cevrildi

### ORTA ONCELIK

#### O-1: Section header widget'i birlestir
**Eylem:** `lib/widgets/section_header.dart` olustur, tum ekranlarda kullan

#### O-2: Hero kart varyantlarini standardize et
**Eylem:** `lib/widgets/hero_card.dart` olustur, 3 varyant (warm, cool, brand)

#### O-3: Progress bar bilesenini standardize et
**Eylem:** `lib/widgets/progress_bar.dart` olustur, 2 boyut (thin, standard)

#### ✅ O-4: Kirmizi renk kullanimini duzelt (kismi)
**Durum:** KISMI TAMAMLANDI
- ✅ Pause menusundeki "Main Menu" butonundan isDestructive kaldirildi
- ⏭ Streak "Play today!" karti — kirmizi semantik olarak dogru (streak kaybı uyarisi)

#### ✅ O-5: Gramer hatalarini duzelt
**Durum:** TAMAMLANDI
- ✅ "1 days" → ICU plural "1 day / X days" (app_en.arb)
- ✅ "1 Lives" → ICU plural "1 Life / X Lives" (app_en.arb)

### DUSUK ONCELIK

#### D-1: Hardcoded Curves kullanimlarini AppCurves'e cevir
**Etkilenen dosya sayisi:** 10+

#### D-2: Hardcoded padding degerlerini Spacing sabitlerine cevir
**Etkilenen dosya sayisi:** 10+

#### D-3: Kilitli tema/achievement ikonlarini buyut
**Eylem:** Lock icon boyutunu 14px'den 18px'e cikar

#### D-4: Ince progress bar'lari kalinlastir
**Eylem:** Minimum 4px kalinlik, tercihen 6-8px

#### D-5: Custom keyboard text scaling'i yeniden degerlendir
**Eylem:** `TextScaler.noScaling` yerine sinirli scaling uygula

---

## 9. GORSEL BUTUNLUK ICIN ALTIN KURALLAR

Uygulamanin gorsel butunlugunu saglamak icin su kurallara uyulmali:

1. **Animasyon sureleri:** Yalnizca `AnimDurations` sabitleri kullanilmali
2. **Animasyon egrileri:** Yalnizca `AppCurves` sabitleri kullanilmali
3. **Border radius:** Yalnizca `RadiiBR` sabitleri kullanilmali
4. **Spacing:** Yalnizca `Spacing` / `SpacingInsets` sabitleri kullanilmali
5. **Icon boyutlari:** Yalnizca `IconSizes` sabitleri kullanilmali (olusturulmali)
6. **Opacity:** Yalnizca `Opacities` sabitleri kullanilmali (olusturulmali)
7. **Renkler:** Yalnizca `theme.colorScheme` ve `theme.gameColors` kullanilmali
8. **Text stilleri:** Yalnizca `theme.textTheme` kullanilmali
9. **Golge:** Yalnizca tanimli shadow seviyeleri kullanilmali (olusturulmali)
10. **Kirmizi renk:** YALNIZCA destructive aksiyonlar (Delete, Exit) icin kullanilmali

---

## 10. SAYISAL OZET

| Metrik | Sayi |
|--------|------|
| Incelenen ekran goruntusu | 18 |
| Incelenen dosya | 40+ |
| Tespit edilen KRITIK sorun | ~~3~~ 0 (tumu duzeltildi) |
| Tespit edilen YUKSEK sorun | ~~8~~ 3 (5 duzeltildi) |
| Tespit edilen ORTA sorun | ~~20+~~ 10 (10+ duzeltildi) |
| Tespit edilen DUSUK sorun | ~~15+~~ 5 (10+ duzeltildi) |
| Hardcoded animasyon suresi | 25+ |
| Hardcoded animasyon egrisi | 30+ |
| Hardcoded border radius | ~~20+~~ 0 (tumu duzeltildi) |
| Hardcoded icon boyutu | ~~40+~~ ~13 (106 duzeltildi) |
| Overflow hatasi (gorunen) | ~~2~~ 0 (tumu duzeltildi) |
| Overflow riski (potansiyel) | ~~6~~ 3 (3 duzeltildi) |
| Text scaling korumasiz ekran | 14+ |
| Design token dosya sayisi | 3 yeni (icon_sizes, opacities, shadows) |
| Toplam duzeltilen sorun (Phase 1-4) | 55+ |
