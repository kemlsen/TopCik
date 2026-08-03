# CLAUDE.md — TopCik: Matematik Grid Oyunu (Mobil)

Bu dosya, Claude Code (veya başka bir AI kodlama asistanı) ile bu projeyi geliştirirken referans alınacak proje tanımıdır. Oyunun tüm mekanikleri, kuralları ve teknik gereksinimleri burada tanımlıdır.

---

## 1. Oyun Konsepti

**Oyun Adı:** TopCik (alt başlık: Sayı Avı)

**Hedef Kitle:** Çocuklar (7-12 yaş), matematiksel zeka ve işlem hızı gelişimi

**Temel Fikir:**
Oyunun iki modu vardır — ikisi de aynı 4x6 grid (4 sütun, 6 satır), can ve süre mekaniğini paylaşır, sadece hücrelerle etkileşim kuralı değişir:

- **Sayı Avı modu:** Ekranda 4x6 boyutunda bir grid (24 hücre) bulunur. Her hücrede bir matematiksel işlem (örn: `7 + 5`, `12 - 4`, `3 x 6`) gösterilir. Oyuncuya ekranın üstünde (veya ayrı bir alanda) bir **hedef sayı** (cevap) gösterilir. Oyuncu, gridde bu hedef sayıya eşit sonucu veren hücreyi bulup dokunur.
  - **Doğru cevap** → o hücre yok olur (fade-out / patlama animasyonu), yeni bir işlem ve hedef sayı gelir.
  - **Yanlış cevap** → o hücre kırmızıya döner, ekranda "Yanlış!" yazısı belirir, kısa bir titreşim/ses efekti olur, hücre eski haline döner (işlemi kalır, tekrar denenebilir).
  - **Süre** sınırlıdır. Süre dolmadan mümkün olduğunca çok doğru cevap verilmeye çalışılır.
- **Eşleştirme modu:** (bkz. Bölüm 3a) Aynı 4x6 grid, ama hedef sayı yok. Grid, sonucu birbirine eşit olan iki farklı işlemden oluşan 12 çift içerir (örn. `3 + 4` ve `10 - 3`, ikisi de `7`). Oyuncu sırayla iki hücreye dokunarak sonucu aynı olan çifti bulmaya çalışır.

---

## 2. Temel Oyun Döngüsü (Game Loop)

1. Oyun başlar → 4x6 grid, 24 farklı matematik işlemiyle doldurulur.
2. Üstte/altta bir **hedef sayı** gösterilir (bu sayı, gridteki işlemlerden birinin doğru cevabıdır).
3. Süre sayacı başlar (örn. 90-135 saniye, seviyeye göre ayarlanabilir; büyütülmüş 24 hücrelik grid için 4x4/16 hücrelik özgün süre değerlerinin 1.5 katı).
4. Oyuncu doğru hücreye dokunur:
   - Hücre yok olma animasyonu oynatılır.
   - Skor artar.
   - O hücrenin yerine (opsiyonel) yeni bir işlem gelebilir **veya** grid azalarak devam eder (tasarım kararı — bkz. Bölüm 3).
   - Yeni bir hedef sayı belirlenir.
5. Oyuncu yanlış hücreye dokunursa:
   - Hücre kırmızı yanıp söner (0.3-0.5 sn).
   - "Yanlış!" mesajı / ikon gösterilir.
   - Can/skor cezası opsiyonel (bkz. Bölüm 6).
   - Hücre normale döner, işlem yerinde kalır.
6. Süre dolduğunda veya grid tamamen boşaldığında oyun biter → Skor ekranı gösterilir.

---

## 3. Grid Doldurma Mantığı (Önemli Tasarım Kararı)

İki seçenek var, birini seçip uygulayın:

### Seçenek A — "Sabit Grid, Yenilenen Hücre" (Önerilen, daha basit)
- Grid hep 4x6 (24 hücre) dolu kalır.
- Doğru cevap verilince o hücre boşalır, hemen ardından **yeni bir işlem** o hücreye yazılır.
- Yeni hedef sayı belirlenir (mutlaka gridteki 24 işlemden en az birinin cevabı olacak şekilde).
- Oyun süre bitene kadar sürer, skor = doğru cevap sayısı.

### Seçenek B — "Azalan Grid" (Daha zorlayıcı, seviye tamamlama hissi verir)
- Grid 24 işlemle başlar.
- Doğru cevap verildikçe hücreler gerçekten boşalıp yok olur (o pozisyon boş kalır).
- Tüm grid boşaldığında (24 doğru cevap) seviye biter → bir sonraki seviyeye geçilir (daha zor işlemler, belki 5x6 gibi büyüyen grid).
- Süre, seviyeyi bitirmek için verilen süredir. Süre dolarsa oyun biter.

**Öneri:** MVP için Seçenek B kullanılsın çünkü "bitirebilme" hissi ve seviye ilerlemesi çocuklar için daha motive edici. Seçenek A, sonsuz mod (endless mode) için kullanılabilir.

---

## 3a. Eşleştirme Modu (Uygulandı)

Sayı Avı moduna ek olarak, aynı seviye/işlem türü seçim akışını paylaşan ikinci bir oyun modu: **Eşleştirme**.

**Fikir:** 4x6 grid, 24 hücre = **12 çift**. Her çiftteki iki hücrenin işlemi farklıdır ama sonucu aynıdır (örn. `3 + 4` ve `10 - 3`, ikisi de `7`). Hedef sayı kutusu yoktur; onun yerine ekranda **kalan çift sayısı** gösterilir (örn. "Kalan çift: 5").

**Oynanış:**
1. Oyuncu bir hücreye dokunur → hücre vurgulanır (mavi glow + kalın kenarlık), "seçili" durumuna geçer.
2. Aynı hücreye tekrar dokunulursa seçim iptal olur (hücre normale döner).
3. Oyuncu ikinci bir hücreye dokunur:
   - **Sonuçlar eşitse** → iki hücre de yeşil parlama + küçülüp yok olma animasyonuyla kaybolur, skor artar, kalan çift sayısı azalır.
   - **Sonuçlar farklıysa** → iki hücre de kırmızıya döner, kısa süre "sallanır", "Eşleşmedi!" yazısı belirir, can bir azalır, sonra ikisi de normale döner (işlemler yerinde kalır).
4. Tüm 12 çift eşleştirilince seviye tamamlanır (Seçenek B ile aynı mantık). Süre dolarsa veya can biterse oyun biter.

**Kurallar:**
- Gridteki 24 ifade birbirinden farklı olmalı (görsel çeşitlilik — Bölüm 5 ile aynı kural), ama **cevaplar** paylaşılabilir: hatta bazen 2'den fazla hücre aynı cevaba sahip olabilir (örn. iki farklı çiftin ikisi de `12` cevabını verirse), bu durumda oyuncu bu hücrelerden **herhangi ikisini** eşleştirebilir — bu, Bölüm 4'teki "birden fazla hücre aynı sonuçsa ikisi de geçerlidir" prensibinin eşleştirme moduna uyarlanmış hâlidir.
- Uzman seviyesinin iki adımlı ifadeleri (`(3+2)x4` gibi) eşleştirme modunda **üretilmez** — rastgele bir sonuca uyan ikinci bir iki-adımlı ifade türetmek gereksiz karmaşıklık katar; bu seviyede de tek adımlı işlemler kullanılır.
- Can, süre, skor (kombo + hız bonusu) ve seviye/işlem türü seçimi Sayı Avı moduyla birebir aynı mekanikleri kullanır (bkz. Bölüm 6, 7).
- En iyi skorlar moda göre ayrı tutulur (Sayı Avı ve Eşleştirme'nin skor tabloları birbirinden bağımsızdır).

**Uygulama:** `lib/logic/match_game_controller.dart` (`MatchGameController`), grid üretimi `lib/logic/problem_generator.dart` içindeki `generateMatchGrid`/`_forAnswer`, ekranlar `lib/screens/match_game_screen.dart` ve `lib/screens/match_result_screen.dart`. Ana menüdeki "Mod Seç" butonuyla açılan `ModeSelectScreen`'den (bkz. Bölüm 10) seçilir, aynı Seviye Seç / İşlem Türü Seç ekranlarını (`GameMode` parametresiyle) kullanır.

---

## 4. Hedef Sayı Seçim Mantığı

- Her turda, gridte **hâlâ çözülmemiş** hücrelerin sonuçlarından rastgele biri hedef sayı olarak seçilir.
- **Önemli edge case:** Eğer birden fazla hücrenin sonucu aynıysa (örn. `3+4=7` ve `10-3=7`), hedef sayı `7` olduğunda oyuncu **ikisinden birine** dokunabilmeli, ikisi de doğru sayılmalı.
- Hedef sayı her zaman gridte en az bir karşılığı olacak şekilde üretilmeli (asla çözümsüz hedef sayı çıkmamalı).

---

## 5. Matematik İşlemleri ve Zorluk Seviyeleri

Yaş grubuna göre işlem havuzu ayarlanmalı. Zorluk arttıkça:

| Seviye | Yaş Aralığı | İşlemler | Sayı Aralığı |
|--------|-------------|----------|---------------|
| 1 - Kolay | 6-7 | Toplama, Çıkarma | 1-10 |
| 2 - Orta | 8-9 | Toplama, Çıkarma, Çarpma (basit) | 1-20 |
| 3 - Zor | 10-11 | Toplama, Çıkarma, Çarpma, Bölme (tam sayı) | 1-50 |
| 4 - Uzman | 12+ | Karışık işlemler, 2 adımlı (örn: `(3+2)x4`) | 1-100 |

**Kurallar:**
- Bölme işlemleri her zaman tam sayı sonuç vermeli (kalansız).
- Sonuçlar negatif olmamalı (çıkarma işleminde büyük sayıdan küçük sayı çıkarılmalı).
- Aynı grid içinde tekrar eden işlem üretilmemeli (görsel çeşitlilik için).

---

## 6. Skor, Can ve Bonus Sistemi

- **Skor:** Her doğru cevap +10 puan (kalan süreye göre bonus çarpanı eklenebilir — hızlı doğru cevap daha çok puan).
- **Can sistemi (uygulandı):** Oyuncuya **3 deneme hakkı** verilir (kalp ikonlarıyla gösterilir). Her yanlış cevapta bir hak düşer, 4. yanlış cevapta oyun biter ve Sonuç Ekranı'na geçilir ("Deneme Hakkın Bitti!"). Süre dolması hâlâ ayrı bir bitiş koşulu olarak kalır ("Süre Doldu!"). Uygulama: `lib/logic/game_controller.dart` içindeki `maxLives` (3) sabiti ve `livesRemaining` alanı; UI karşılığı `lib/screens/game_screen.dart` içindeki `_LivesBadge`.
- **Combo/Streak bonusu:** Art arda doğru cevaplarda combo sayacı artar, ekstra puan/animasyon (yıldız, konfeti vb.) verilir.
- **Süre bonusu:** Grid tamamen bitirilirse kalan süreye göre ekstra puan.

---

## 7. Süre Mekaniği

- Ekranın üst kısmında bir **countdown timer** (dairesel progress bar veya klasik sayaç) gösterilir.
- Süre seviyeye göre ayarlanabilir (örn. Seviye 1: 90 sn, Seviye 4: 60 sn).
- Son 10 saniyede sayaç kırmızıya dönüp yanıp sönmeli, hafif tik-tak sesi çalmalı (aciliyet hissi, ama korkutucu olmamalı).
- Süre dolduğunda: grid donar, "Süre Doldu!" ekranı + skor özeti gösterilir.

---

## 8. Görsel & Animasyon Gereksinimleri

- **Doğru cevap animasyonu:** Hücre parlar (yeşil glow) → küçülerek/patlayarak yok olur (scale + fade + particle efekti). Küçük bir "ding" sesi.
- **Yanlış cevap animasyonu:** Hücre kırmızıya boyanır → shake (sallanma) efekti → "Yanlış!" texti belirip kaybolur → hücre normale döner. Kısa "buzzer" sesi (ama fazla rahatsız edici olmamalı, çocuk dostu).
- **Hedef sayı gösterimi:** Ekranın üstünde büyük, renkli, dikkat çekici bir kutu içinde (örn: "Bul: 12").
- **Renk paleti:** Çocuklara hitap eden canlı, pastel-parlak renkler (mavi, sarı, turuncu, yeşil). Kırmızı sadece yanlış cevap için kullanılmalı.
- **Karakter/Maskot (opsiyonel ama önerilir):** Basit bir maskot (örn. bir baykuş/robot) doğru/yanlış cevaplara tepki versin (mutlu zıplama / üzgün sallama).
- **Yüzen sembol arka planı (uygulandı):** Mor gradientli ekranlarda (Ana Menü, Sonuç Ekranları) içeriğin arkasında, çok düşük opaklıkta (≈%8-19) küçük `+ − × ÷` sembolleri yavaşça süzülür — hafif dikey/yatay sürüklenme + yumuşak dönüş, sabit rastgele tohumla (aynı dağılım her açılışta), tek bir sonsuz döngü `AnimationController` ile (sin/cos tabanlı, ek paket gerektirmez). Dokunma olaylarını engellememesi için `IgnorePointer` ile sarılıdır. Uygulama: `lib/widgets/floating_symbols_background.dart` (`FloatingSymbolsBackground`), `main_menu_screen.dart`, `result_screen.dart` ve `match_result_screen.dart` içinde gradient `Container`'ın `Stack` çocuğu olarak, `SafeArea` içeriğinin arkasında kullanılır.

---

## 9. Ses Tasarımı

- Doğru cevap: kısa, neşeli "ding" veya "coin" sesi.
- Yanlış cevap: yumuşak "buzz" (agresif olmayan).
- Süre bitişi: nötr bir "zamanlayıcı durdu" sesi.
- Arka plan müziği: hafif, enerjik, döngüsel (loop) çocuk dostu müzik. Ses açma/kapama butonu olmalı.

---

## 10. Ekranlar (Screens)

1. **Ana Menü:** Oyna, Mod Seç, Skor Tablosu, Ayarlar. Oyun **yalnızca** "Oyna" butonuna basıldığında başlar; Mod Seç akışının kendisi oyunu başlatmaz (bkz. madde 2-4).
2. **Mod Seçim Ekranı (uygulandı):** "Seviye Seç" (Sayı Avı) ve "Eşleştirme Modu" butonlarının birleştiği tek giriş noktası — oyuncu önce Sayı Avı / Eşleştirme kartlarından birine dokunur, ardından ortak Seviye Seçim Ekranı'na yönlenir. Daha önce bu iki mod ana menüde ayrı butonlardan (ve "Oyna" her zaman doğrudan Sayı Avı'na atlayarak) seçiliyordu; bu tutarsızlık giderildi. Uygulama: `lib/screens/mode_select_screen.dart` (`ModeSelectScreen`).
3. **Seviye Seçim Ekranı:** Kolay / Orta / Zor / Uzman kartları. Hem Sayı Avı hem Eşleştirme modu bu ekranı `GameMode` parametresiyle paylaşır. Bir seviye seçildiğinde mod da "son oynanan" olarak kaydedilir (`ScoreService.setLastLevel` / `setLastMode`).
4. **İşlem Türü Seç Ekranı:** Toplama/Çıkarma/Çarpma/Bölme seçimi; iki mod tarafından da paylaşılır. **"Kaydet"e basmak oyunu başlatmaz** — seçilen işlem türlerini kaydeder (`ScoreService.setLastOperations`) ve doğrudan Ana Menü'ye döner ("Hazır! Başlamak için 'Oyna'ya dokun" bildirimiyle). Mod Seç akışının (mod → seviye → işlem türü) tek görevi, "Oyna" butonunun kullanacağı kombinasyonu hazırlamaktır; asıl oyun her zaman Ana Menü'deki "Oyna" butonuyla başlar — bu, en son kaydedilen mod + seviye + işlem türü kombinasyonunu okuyup (`MainMenuScreen._quickPlay`) hiçbir ara ekran göstermeden ilgili oyun ekranına gider.
5. **Oyun Ekranı (Sayı Avı):** 4x6 grid + üstte hedef sayı + süre sayacı + skor.
6. **Oyun Ekranı (Eşleştirme):** 4x6 grid + üstte kalan çift sayısı + süre sayacı + skor (bkz. Bölüm 3a).
7. **Sonuç Ekranı:** Toplam skor, doğru/yanlış (veya eşleşen çift/yanlış deneme) sayısı, en iyi skor, "Tekrar Oyna" / "Ana Menü" butonları. Her modun kendi sonuç ekranı vardır.
8. **Skor Tablosu:** Her iki modun (Sayı Avı, Eşleştirme) seviye başına en iyi skorlarını ayrı ayrı gösterir.
9. **Ayarlar:** Ses aç/kapa, zorluk varsayılanı, dil seçimi (opsiyonel çoklu dil desteği).

---

## 11. Teknik Yığın Önerisi

Mobil oyun için önerilen teknolojiler (proje ihtiyacına göre biri seçilmeli):

- **Flutter (Dart):** Tek kod tabanından iOS + Android, animasyonlar için güçlü (Flutter'ın widget/animation sistemi bu tarz grid oyunları için çok uygun). Önerilen seçim.
- **React Native:** JS/TS bilenler için hızlı geliştirme, `react-native-reanimated` ile animasyonlar yapılabilir.
- **Unity (C#):** Daha oyun-motoru odaklı, ses/animasyon/particle efektleri için en güçlü seçenek ama öğrenme eğrisi daha yüksek.

**Öneri:** Flutter — basit UI, hızlı prototipleme, güçlü animasyon desteği ve tek kod tabanı sunduğu için bu proje için en dengeli seçim.

---

## 12. Önerilen Proje Yapısı (Flutter örneği)

```
lib/
  main.dart
  models/
    math_problem.dart       // işlem, sonuç, zorluk seviyesi modeli
    grid_cell.dart          // hücre durumu (idle, selected, correct, wrong, empty)
    difficulty_level.dart   // seviye + işlem türü tanımları
    game_mode.dart          // GameMode: hunt (Sayı Avı) / match (Eşleştirme)
  logic/
    problem_generator.dart      // rastgele işlem üretimi + eşleştirme çift üretimi
    game_controller.dart        // Sayı Avı state yönetimi (skor, süre, grid durumu)
    match_game_controller.dart  // Eşleştirme modu state yönetimi (bkz. Bölüm 3a)
    game_constants.dart         // GameStatus, gridSize, maxLives — iki mod da paylaşır
    grid_playable.dart          // GridWidget'ın ihtiyaç duyduğu ortak arayüz
  screens/
    main_menu_screen.dart
    mode_select_screen.dart      // "Oyna" ve mod seçiminin tek giriş noktası
    level_select_screen.dart     // mode: GameMode parametresiyle her iki mod için de kullanılır
    operation_select_screen.dart // mode: GameMode parametresiyle her iki mod için de kullanılır
    game_screen.dart             // Sayı Avı oyun ekranı
    match_game_screen.dart       // Eşleştirme modu oyun ekranı
    result_screen.dart           // Sayı Avı sonuç ekranı
    match_result_screen.dart     // Eşleştirme modu sonuç ekranı
    scoreboard_screen.dart
    settings_screen.dart
  widgets/
    grid_widget.dart
    grid_cell_widget.dart
    timer_widget.dart
    target_number_widget.dart   // Sayı Avı: "Bul: 12"
    match_status_widget.dart    // Eşleştirme: "Kalan çift: 5"
    lives_badge.dart            // iki mod da paylaşır
  services/
    audio_service.dart
    score_service.dart      // yerel skor kaydı (shared_preferences), moda göre ayrı anahtar
    app_messenger.dart      // ekranlar arası SnackBar için paylaşılan ScaffoldMessengerKey
assets/
  sounds/
  images/
```

---

## 13. Veri Modeli Örneği

```dart
class MathProblem {
  final String expression; // "7 + 5"
  final int answer;        // 12
}

enum CellState { idle, correct, wrong, empty }

class GridCell {
  final MathProblem problem;
  CellState state;
}
```

---

## 14. Kabul Kriterleri (Acceptance Criteria) — MVP

- [ ] 4x6 grid ekranda düzgün render ediliyor, tüm hücreler dokunulabilir.
- [ ] Her hücrede geçerli, çözülebilir bir matematik işlemi var.
- [ ] Hedef sayı her zaman gridteki en az bir hücrenin cevabına eşit.
- [ ] Doğru dokunuşta hücre animasyonla yok oluyor, skor artıyor, yeni hedef sayı geliyor.
- [ ] Yanlış dokunuşta hücre kırmızıya dönüyor, "Yanlış!" gösteriliyor, sonra normale dönüyor.
- [ ] Süre sayacı çalışıyor, süre bitince oyun sonlanıyor.
- [x] Oyuncuya 3 deneme (can) hakkı veriliyor, 4. yanlış cevapta oyun sonlanıyor.
- [ ] Grid tamamen boşalırsa (Seçenek B) seviye tamamlanıyor.
- [ ] Sonuç ekranında skor ve tekrar oyna seçeneği var.
- [ ] En az 3 zorluk seviyesi mevcut.
- [ ] Ses efektleri çalışıyor ve kapatılabiliyor.
- [x] Eşleştirme modu: 4x6 grid, sonucu eşit iki hücre eşleştirilince ikisi de yok oluyor; yanlış eşleştirmede ikisi de kırmızıya dönüp normale dönüyor.
- [x] Eşleştirme modunda da seviye ve işlem türü seçilebiliyor, can/süre mekaniği Sayı Avı ile aynı.

---

## 15. Gelecek Geliştirmeler (Nice-to-have)

- Çoklu oyuncu / arkadaşla yarışma modu.
- Günlük görevler ve ödül sistemi (yıldız, rozet).
- Ebeveyn paneli: çocuğun ilerlemesini, hangi işlem tipinde zorlandığını gösteren istatistikler.
- Özelleştirilebilir maskot/karakter kıyafetleri (kazanılan puanlarla açılan).
- Farklı grid boyutları (3x3 kolay mod, 5x5 zor mod).
- Bulut senkronizasyonu (skor ve ilerleme kaydı).

---

## 16. Notlar / Geliştirme Prensipleri

- Çocuk hedef kitlesi olduğu için **stres yaratmayan** bir ton korunmalı: yanlış cevap cezalandırıcı değil, öğretici olmalı (belki doğru cevabı gösteren bir ipucu sistemi eklenebilir).
- Metinler basit, büyük punto, yüksek kontrast — okuma güçlüğü olan çocuklar için de erişilebilir olmalı.
- Reklam/IAP eklenecekse ebeveyn onay ekranı (yaş doğrulama / matematik sorusu gibi basit bir kapı) kullanılmalı — bu tür oyunlarda COPPA/KVKK gibi çocuk gizliliği kurallarına dikkat edilmeli.
- Performans: 4x6 grid çok ağır değil, ama animasyonlar düşük FPS'li cihazlarda bile akıcı çalışmalı.

---
