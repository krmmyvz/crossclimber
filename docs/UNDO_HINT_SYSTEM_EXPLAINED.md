# Undo ve Hint Sistemi Açıklaması

## 🔄 Undo Sistemi - Nasıl Çalışıyor?

### Mantık:
Oyunda **maksimum 5 undo hakkınız** var. Her doğru tahmin yaptığınızda sistem o anki oyun durumunun bir "fotoğrafını" çekiyor (snapshot).

### Neden Böyle?
1. **Oyun Dengesini Korumak**: Sınırsız undo olsaydı oyun çok kolay olurdu
2. **Stratejik Karar Verme**: Undo'yu ne zaman kullanacağınızı düşünmenizi gerektirir
3. **Performans**: Çok fazla snapshot hafızayı doldurur

### Detaylı Akış:

```
📝 Doğru Tahmin Yaptınız
   ↓
💾 Sistem snapshot kaydeder (önceki durumu)
   ↓
✅ Yeni kelime eklenir
   ↓
🔙 Undo'ya basarsanız: Snapshot'tan önceki duruma döner
   ↓
📊 undosUsed sayacı +1 artar (max 5)
```

### Snapshot'ta Kaydedilen Veriler:
- Orta kelimeler listesi
- Hangi kelimelerin tahmin edildiği
- Üst ve alt tahminler
- Yanlış denemeler sayısı

### Sorun mu?
Eğer **saçma** diyorsanız, muhtemelen şu konular kafanızı karıştırıyordur:

1. **"Neden snapshot'ı ÖNCE kaydediyorsun?"**
   - Çünkü undo yaptığınızda *tahmin yapmadan önceki* duruma dönmek istiyorsunuz
   - Snapshot = "Bu tahmini yapmadan önceki halim"

2. **"Neden kullanım limiti var?"**
   - Oyunu kolaylaştırmamak için
   - Alternatif: Limitsiz undo ama kredi harcar

---

## 💡 Hint (İpucu) Sistemi - Neden Açılmıyor?

### Mevcut Kod Analizi:

```dart
FutureBuilder<int>(
  future: ref.read(progressRepositoryProvider).getCredits(),
  builder: (context, snapshot) {
    final credits = snapshot.data ?? 0;
    return _StatusItem(
      key: _hintsKey,
      icon: Icons.monetization_on,
      label: '$credits',
      onTap: credits > 0 && _selectedRowIndex != null  // ❌ SORUN BURADA
          ? () async {
              // Advanced Hint Selector açılır
            }
          : null,  // ❌ Tıklama devre dışı
    );
  },
),
```

### Sorun:
Hint açılması için **2 koşul** var:
1. ✅ `credits > 0` - Krediniz olmalı
2. ❌ `_selectedRowIndex != null` - **Bir kelime SEÇİLİ olmalı**

### Çözüm:
Şu anda **hiçbir kutucuğa tıklamadıysanız** hint butonu pasif kalıyor!

**Nasıl Düzeltilmeli:**
1. Önce bir orta kelime kutucuğuna tıklayın
2. Sonra kredi ikonuna tıklayın
3. Advanced Hint Selector açılacak

### Alternatif Düzeltme (Önerilen):

Hint butonunun her zaman tıklanabilir olması ama seçim yoksa uyarı vermesi:

```dart
onTap: credits > 0
    ? () async {
        if (_selectedRowIndex == null) {
          // Uyarı göster: "Önce bir kelime seçin"
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Önce tahmin etmek istediğiniz kutucuğa tıklayın')),
          );
          return;
        }
        // Advanced Hint Selector aç
      }
    : null,
```

---

## 🎯 Advanced Hint Selector - Nerede?

Kodda **ZATEN MEVCUT** ama **kullanıcı akışında gizli** kalıyor!

### Hint Türleri (Kodda mevcut):
1. **Reveal Letter** - Bir harf gösterir
2. **Reveal Word** - Tüm kelimeyi gösterir
3. **Remove Wrong Letters** - Yanlış harfleri kaldırır

### Neden Görmüyorsunuz?
```dart
AdvancedHintSelector.show(
  context,
  availableHints: credits,
  onHintSelected: (hint) {
    selectedHint = hint;
  },
);
```

Bu kod SADECE `_selectedRowIndex != null` olduğunda çalışıyor.

---

## 🛠️ Önerilen İyileştirmeler

### 1. Undo Sistemi İyileştirmesi

**Seçenek A:** Kullanım sayacını daha görünür yap
```dart
// Status bar'da göster: 
"Undo: 2/5" // 2 undo kaldı, 5'ten
```

**Seçenek B:** Kredi sistemi ile entegre et
```dart
// Undo kullanmak 1 kredi harcar
// Limitsiz undo ama maliyetli
```

### 2. Hint Butonu İyileştirmesi

**Sorun:** Seçim yapmadan hint isteyemiyorsunuz

**Çözüm:** Butona her zaman tıklanabilir yap ama:
- Seçim yoksa: "Önce bir kutucuk seçin" uyarısı
- Kredi yoksa: "Kredi almak için günlük challenge oynayın"

### 3. UX İyileştirmesi

```dart
// Hint ikonuna tooltip ekle
Tooltip(
  message: _selectedRowIndex == null 
      ? 'Önce bir kelime seçin'
      : 'İpucu al ($credits kredi)',
  child: _StatusItem(...),
)
```

---

## 📝 Sonuç

### Undo "Saçma" Değil:
- Oyun dengesini koruyor
- Stratejik düşünmeyi teşvik ediyor
- Snapshot mantığı doğru çalışıyor

### Hint "Açılmıyor" Çünkü:
- Önce bir kelime seçmeniz gerekiyor
- UI'da bu açık değil
- Kullanıcı akışı iyileştirilmeli

### Öneriler:
1. ✅ Undo sayacını status bar'da göster
2. ✅ Hint butonuna tooltip ekle
3. ✅ Seçim yokken hint butonuna basınca uyarı göster
4. ✅ Kredi kazanma yollarını daha görünür yap

---

**Ek Notlar:**
- Kredi sistemi: Günlük challenge tamamlayınca +5 kredi
- Her gün giriş yaptığınızda +2 kredi
- Hint kullanımı kredi harcar (RevealLetter: -1, RevealWord: -3)
