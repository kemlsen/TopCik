# CLAUDE.md — TopCik: Matematik Grid Oyunu (Mobil)

Bu dosya, Claude Code (veya başka bir AI kodlama asistanı) ile bu projeyi geliştirirken referans alınacak proje tanımıdır. Oyunun tüm mekanikleri, kuralları ve teknik gereksinimleri burada tanımlıdır.

---

## 1. Oyun Konsepti

**Oyun Adı:** TopCik (alt başlık: Sayı Avı)

**Hedef Kitle:** Çocuklar (7-12 yaş), matematiksel zeka ve işlem hızı gelişimi

**Temel Fikir:**
Oyunun üç modu vardır — üçü de aynı can mekaniğini ve aynı temel ilkeyi paylaşır: **bitiş koşulu her zaman süre veya canların tükenmesidir**, hiçbirinde "grid'i tamamen bitirince kazanılır" diye bir durum yoktur — her mod, o süre içinde ne kadar yapıp puan toplayabileceğine dayanan sürekli bir koşudur. Sayı Avı ve Tırmanış aynı "hedefi bul" etkileşimini paylaşır (grid boyutu ikisinde de aynı `gridShapeForLevel`/`climbGridShapeForRound` eşlemesinden gelir); farkları, Sayı Avı'nda seviye ve işlem türünün oyuncu tarafından seçilebilir olması ve grid boyutunun koşu boyunca seçilen seviyede sabit kalmasıdır — Tırmanış'ta ise seçim yoktur, grid boyutu ve zorluk bölüm numarasına göre otomatik büyür. Eşleştirme kendi çift-bulma etkileşimini ve kendi (seviyeye göre sabit) grid boyutunu/başlangıç süresini korur, ama o da aynı "tek eriyen süre + doğru cevapta bonus + tam yenilenen grid" ilkesini kullanır:

- **Sayı Avı modu:** Oyuncunun seçtiği seviyeye göre sabit boyutlu bir grid gösterilir (Kolay: 1x2, Orta: 2x2, Zor: 3x3, Uzman: 4x4 — bkz. Bölüm 2). Her hücrede bir matematiksel işlem (örn: `7 + 5`, `12 - 4`, `3 x 6`) gösterilir. Oyuncuya ekranın üstünde bir **hedef sayı** (cevap) gösterilir. Oyuncu, gridde bu hedef sayıya eşit sonucu veren hücreyi bulup dokunur.
  - **Doğru cevap** → grid anında tamamen yenilenir (yeni işlemler + yeni hedef sayı), tek eriyen süre sayacına küçük bir bonus eklenir.
  - **Yanlış cevap** → o hücre kırmızıya döner, ekranda "Yanlış!" yazısı belirir, kısa bir titreşim/ses efekti olur, hücre eski haline döner (işlemi kalır, tekrar denenebilir); süre etkilenmez, sadece can azalır.
  - **Süre**, tek bir eriyen sayaçtır (60 sn). Süre dolmadan (veya can bitmeden) 60 saniyede mümkün olduğunca çok doğru cevap vermeye çalışılır.
- **Eşleştirme modu:** (bkz. Bölüm 3a) Kendi seviyeye-göre-sabit grid boyutunu ve seviyeye göre sabit başlangıç süresini kullanır. Hedef sayı yoktur. Grid, sonucu birbirine eşit olan iki farklı işlemden oluşan çiftlerden oluşur (örn. `3 + 4` ve `10 - 3`, ikisi de `7`). Oyuncu sırayla iki hücreye dokunarak sonucu aynı olan çifti bulmaya çalışır; seçilen seviyenin tüm çiftleri eşleşince grid anında yeni bir çift setiyle değiştirilir (Sayı Avı gibi — o sürede ne kadar eşleştirip puan toplarsan skorun o olur).
- **Tırmanış modu:** (bkz. Bölüm 3b) Sayı Avı'nın "hedefi bul" etkileşimini kullanır, ama tek, sürekli akan bir koşuda grid boyutu ve zorluk bölüm bölüm büyür (1x2 → 2x2 → 3x3 → 4x4). Hedefi bulmak anında bir sonraki bölüme geçirir; tek bir eriyen süre sayacı, her doğru cevapta küçük bir bonusla beslenir.

---

## 2. Temel Oyun Döngüsü (Game Loop) — Sayı Avı

1. Oyuncu Mod Seç → Seviye Seç → İşlem Türü Seç akışıyla bir kombinasyon hazırlar (veya Ana Menü'deki "Oyna" en son kaydedilen kombinasyonu kullanır) → seçilen seviyeye göre sabit boyutlu bir grid doldurulur: Kolay 1x2, Orta 2x2, Zor 3x3, Uzman 4x4 (bkz. `gridShapeForLevel`, Tırmanış'ın Bölüm 3b'de kullandığı eşlemeyle aynı kaynak).
2. Üstte bir **hedef sayı** gösterilir (bu sayı, gridteki işlemlerden birinin doğru cevabıdır — grid her turda tamamen taze üretildiği için tüm hücreler aday olabilir).
3. Tek bir **eriyen süre sayacı** başlar: 60 saniye (`GameController.initialTimeBudgetSeconds`).
4. Oyuncu doğru hücreye dokunur:
   - Hücre yok olma animasyonu oynatılır, skor artar.
   - Süre sayacına +1 saniye bonus eklenir (`GameController.timeBonusPerCorrectSeconds`).
   - Grid tamamen yeni bir işlem setiyle değiştirilir (aynı boyut, aynı seviye/işlem türleri), yeni bir hedef sayı belirlenir.
5. Oyuncu yanlış hücreye dokunursa:
   - Hücre kırmızı yanıp söner (0.3-0.5 sn), "Yanlış!" mesajı gösterilir.
   - Can bir azalır (bkz. Bölüm 6); **süre etkilenmez**.
   - Hücre normale döner, grid/hedef değişmez.
6. Süre dolduğunda veya canlar tükendiğinde oyun biter → Skor ekranı gösterilir (kaç doğru cevap verildiği = mod özeti).

Bu döngü, Tırmanış modunun (Bölüm 3b) mekaniğiyle birebir aynıdır — tek fark Tırmanış'ta grid boyutu/zorluğun bölüm numarasına göre otomatik büyümesi, Sayı Avı'nda ise oyuncunun seçtiği seviyede sabit kalmasıdır (seviye ve işlem türü seçilebilir olmaya devam eder). Eşleştirme modu (Bölüm 3a) kendi çift-bulma etkileşimini kullanır ama aynı "süre/can bitene kadar sür, grid tamamen bitince anında yenilen" ilkesini izler (bkz. Bölüm 3).

---

## 3. Grid Doldurma Mantığı

Üç modun hepsi aynı ilkeyi paylaşır: **bitiş koşulu her zaman süre veya canların tükenmesidir**, "grid tamamen bitirildi" diye bir kazanma durumu hiçbir modda yoktur — her mod, o süre içinde ne kadar yapıp puan toplayabileceğine dayanan sürekli bir koşudur. Farklı olan, bir "tur"un nasıl tamamlanıp yenilendiğidir:

### Sayı Avı ve Tırmanış — Tam Yenilenen Grid
- Grid boyutu sabittir (Sayı Avı: seçilen seviyeye göre; Tırmanış: bölüm numarasına göre — bkz. Bölüm 2, 3b).
- Doğru cevap verilince **tüm grid** anında yeni bir işlem setiyle değiştirilir (tek hücre boşaltılıp beklenmez); yeni hedef sayı bu taze gridden seçilir.

### Eşleştirme modu — Azalan Grid, Tamamlanınca Anında Yenilenen
- Grid, seviyeye göre sabit sayıda çiftle başlar (bkz. `matchGridShapeForLevel`, Bölüm 3a), boyutu sabit kalır.
- Doğru eşleştirmelerde iki hücre gerçekten boşalıp yok olur (Seçenek B'nin özü, ama tek bir "tur"un içinde).
- Seçilen seviyenin tüm çiftleri eşleşince (grid tamamen boşalınca) **oyun bitmez** — grid anında aynı boyutta taze bir çift setiyle değiştirilir ve koşu devam eder.

Her üç modda da süre tek bir eriyen sayaçtır (60 sn'den başlar — bkz. Bölüm 7), doğru cevapta/eşleştirmede küçük bir bonusla beslenir; yanlış cevapta/eşleştirmede süre cezası yoktur, sadece can gider (bkz. Bölüm 6).

---

## 3a. Eşleştirme Modu (Uygulandı)

Sayı Avı moduna ek olarak, aynı seviye/işlem türü seçim akışını paylaşan ikinci bir oyun modu: **Eşleştirme**.

**Fikir:** Grid boyutu, seçilen seviyeye göre sabittir (bkz. `matchGridShapeForLevel`, Sayı Avı'nın `gridShapeForLevel`'ıyla aynı büyüme mantığı): Kolay 2x2 (2 çift), Orta 2x4 (4 çift), Zor 3x4 (6 çift), Uzman 4x6 (12 çift — oyunun özgün sabit boyutu). Her çiftteki iki hücrenin işlemi farklıdır ama sonucu aynıdır (örn. `3 + 4` ve `10 - 3`, ikisi de `7`). Hedef sayı kutusu yoktur; onun yerine ekranda **kalan çift sayısı** gösterilir (örn. "Kalan çift: 5").

**Oynanış:**
1. Oyuncu bir hücreye dokunur → hücre vurgulanır (mavi glow + kalın kenarlık), "seçili" durumuna geçer.
2. Aynı hücreye tekrar dokunulursa seçim iptal olur (hücre normale döner).
3. Oyuncu ikinci bir hücreye dokunur:
   - **Sonuçlar eşitse** → iki hücre de yeşil parlama + küçülüp yok olma animasyonuyla kaybolur, skor artar, kalan çift sayısı azalır.
   - **Sonuçlar farklıysa** → iki hücre de kırmızıya döner, kısa süre "sallanır", "Eşleşmedi!" yazısı belirir, can bir azalır, sonra ikisi de normale döner (işlemler yerinde kalır).
4. Seçilen seviyenin tüm çiftleri eşleştirilince grid **anında** yeni bir çift setiyle değiştirilir (Sayı Avı'nın tam-yenileme ilkesiyle aynı, bkz. Bölüm 3) — oyun bitmez, koşu devam eder. Süre dolarsa veya can biterse oyun biter.

**Kurallar:**
- Gridteki ifadeler birbirinden farklı olmalı (görsel çeşitlilik — Bölüm 5 ile aynı kural), ama **cevaplar** paylaşılabilir: hatta bazen 2'den fazla hücre aynı cevaba sahip olabilir (örn. iki farklı çiftin ikisi de `12` cevabını verirse), bu durumda oyuncu bu hücrelerden **herhangi ikisini** eşleştirebilir — bu, Bölüm 4'teki "birden fazla hücre aynı sonuçsa ikisi de geçerlidir" prensibinin eşleştirme moduna uyarlanmış hâlidir.
- Uzman seviyesinin iki adımlı ifadeleri (`(3+2)x4` gibi) eşleştirme modunda **üretilmez** — rastgele bir sonuca uyan ikinci bir iki-adımlı ifade türetmek gereksiz karmaşıklık katar; bu seviyede de tek adımlı işlemler kullanılır.
- Can sistemi (bkz. Bölüm 6), seviye/işlem türü seçim akışı ve "tek eriyen süre + doğru cevapta bonus + tam grid yenileme" ilkesi diğer modlarla birebir aynıdır; farkı sadece kendi grid boyutunu (`matchGridShapeForLevel`, bkz. Bölüm 2) korumasıdır — başlangıç süre bütçesi (`MatchGameController.initialTimeBudgetSeconds`, 60 sn) diğer iki modla aynıdır, seviyeye göre değişmez (bkz. Bölüm 3, 7). Skor formülü (kombo + hız bonusu) diğer modlarla aynı hesaplamayı kullanır (bkz. Bölüm 6).
- En iyi skorlar moda göre ayrı tutulur (Sayı Avı ve Eşleştirme'nin skor tabloları birbirinden bağımsızdır).

**Uygulama:** `lib/logic/match_game_controller.dart` (`MatchGameController`), seviye→grid boyutu eşlemesi `lib/logic/grid_shape.dart` içindeki `matchGridShapeForLevel`, grid üretimi `lib/logic/problem_generator.dart` içindeki `generateMatchGrid`/`_forAnswer`, ekranlar `lib/screens/match_game_screen.dart` ve `lib/screens/match_result_screen.dart`. Ana menüdeki "Mod Seç" butonuyla açılan `ModeSelectScreen`'den (bkz. Bölüm 10) seçilir, aynı Seviye Seç / İşlem Türü Seç ekranlarını (`GameMode` parametresiyle) kullanır.

---

## 3b. Tırmanış Modu (Uygulandı)

Sayı Avı ve Eşleştirme'ye ek olarak üçüncü bir mod: **Tırmanış**. Diğer ikisinden farkı, sabit bir seviye/işlem türü seçimi yerine tek, sürekli akan bir koşuda kolaydan zora doğru otomatik ilerlemesidir.

**Fikir:** Tek bir koşu, art arda gelen kısa "bölüm"lere ayrılır. Her bölüm, Sayı Avı'nın "hedefi bul" etkileşiminin tek bir turu: bir grid ve bir hedef sayı gösterilir, doğru hücreye dokunmak **anında bir sonraki bölüme** geçirir (Sayı Avı'nın aksine, tek hücre boşaltıp aynı gridde devam etmez — her bölümde grid tamamen yenilenir). Mod Seç ekranından doğrudan oyuna girilir; Seviye Seç / İşlem Türü Seç ekranları **atlanır**, çünkü hem grid boyutu hem işlem zorluğu bölüm numarasına göre otomatik belirlenir.

**Oynanış — grid boyutu ve zorluk eşlemesi (bölüm numarasına göre):**

| Bölüm aralığı | Grid boyutu | Sayı aralığı (mevcut `DifficultyLevel`) | İşlem türleri |
|---|---|---|---|
| 1-20 | 1x2 (tek hücrede gerçek bir seçim olmaz, en az iki hücre) | Kolay | Sadece toplama/çıkarma |
| 21-50 | 2x2 | Orta | Sadece toplama/çıkarma |
| 51-100 | 3x3 | Zor | Toplama/çıkarma/çarpma/bölme |
| 101+ | 4x4 (orada sabit kalır, sonsuza kadar büyümez) | Uzman | Toplama/çıkarma/çarpma/bölme |

Eşikler bilerek geniş tutulur: ilkokulda matematiğe yeni başlayan bir çocuk ilk bölümlerde zorlanmadan uzun süre ilerleyip daha ileri bölümlere ulaşabilsin diye. Çarpma ve bölme, mevcut `DifficultyLevel.operations`'tan bağımsız bir climb'e özel havuzla (`climbOperationsForRound`) yalnızca Zor katmanından itibaren açılır — Kolay ve Orta katmanları her zaman sadece toplama/çıkarma içerir.

**Süre mekaniği:** Diğer iki modun aksine bölüm başına ayrı bir süre yoktur — koşunun tamamı boyunca **tek bir eriyen sayaç** vardır (başlangıç: 60 saniye). Her doğru cevapta sayaca **+1 saniye** bonus eklenir; **yanlış cevapta süre cezası yoktur**, sadece can gider.

**Kurallar:**
- Yanlış cevapta hücre kırmızıya döner, can bir azalır, ama **bölüm/grid/hedef değişmez** — Sayı Avı'ndaki yanlış cevap davranışının birebir aynısı, sadece "bölüm ilerlemez" ek kuralıyla.
- Bitiş koşulları sadece süre dolması veya canların tükenmesidir — Seçenek B'deki gibi bir "tam temizleme/seviye tamamlandı" kazanma durumu **yoktur** (Tırmanış sonsuz bir hayatta kalma modudur).
- Can, kombo/hız skor bonusu Sayı Avı ile birebir aynı mekanikleri kullanır (bkz. Bölüm 6).
- En iyi skorlar diğer modlardan bağımsız, ayrı iki rekorla tutulur: **en iyi ulaşılan bölüm** ve **en iyi skor** (diğer modlardaki gibi seviye başına ayrı bir tablo yoktur, çünkü Tırmanış'ta seçilebilir bir seviye kavramı yoktur).
- Katman değişimlerinde (bölüm 21, 51, 101) ekranda herhangi bir uyarı/kutlama gösterilmez — grid/zorluk sessizce büyür, oyuncunun akışı bölünmez.
- Az satırlı gridlerde (özellikle 1x2) hücrelerin aşırı uzayıp garip görünmesini önlemek için `GridWidget` hücre en-boy oranını makul bir aralığa sıkıştırır ve grid'i dikeyde ortalar (bkz. `lib/widgets/grid_widget.dart`).

**Uygulama:** `lib/logic/climb_game_controller.dart` (`ClimbGameController`), bölüm→(grid boyutu, zorluk, işlem havuzu) eşlemesi `lib/logic/climb_progression.dart` (`climbGridShapeForRound`/`climbLevelForRound`/`climbOperationsForRound`), grid üretimi mevcut `lib/logic/problem_generator.dart`'taki `generateGrid` (değişiklik gerekmedi, `count`/`operations` zaten parametrik), ekranlar `lib/screens/climb_game_screen.dart` ve `lib/screens/climb_result_screen.dart`, bölüm rozeti `lib/widgets/climb_status_widget.dart`. Skor kaydı `lib/services/score_service.dart`'taki `getClimbBestRound`/`submitClimbBestRound`/`getClimbBestScore`/`submitClimbBestScore`. `ModeSelectScreen`'deki (bkz. Bölüm 10) "Tırmanış" kartından seçilir; kart, diğer modların aksine `LevelSelectScreen`/`OperationSelectScreen` akışını atlar (Tırmanış'ta seçilebilir bir seviye/işlem türü olmadığı için), ama oyunu da doğrudan başlatmaz — diğer modlarla aynı ilkeyle, "son oynanan mod" olarak kaydedip Ana Menü'ye döner; oyun yalnızca Ana Menü'deki "Oyna" butonuyla başlar (bkz. `ModeSelectScreen._handleModeTap`, `MainMenuScreen._quickPlay`).

---

## 4. Hedef Sayı Seçim Mantığı

- Sayı Avı ve Tırmanış'ta grid her turda tamamen yenilendiği için hedef sayı, taze üretilen gridin **tüm** hücrelerinden rastgele seçilir (hepsi zaten çözülmemiş/idle durumdadır).
- **Önemli edge case:** Eğer birden fazla hücrenin sonucu aynıysa (örn. `3+4=7` ve `10-3=7`), hedef sayı `7` olduğunda oyuncu **ikisinden birine** dokunabilmeli, ikisi de doğru sayılmalı.
- Hedef sayı her zaman gridte en az bir karşılığı olacak şekilde üretilmeli (asla çözümsüz hedef sayı çıkmamalı) — hedef, gridin kendi hücrelerinden seçildiği için bu otomatik sağlanır.

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
- **Can sistemi (uygulandı):** Oyuncuya **3 deneme hakkı** verilir (kalp ikonlarıyla gösterilir). Her yanlış cevapta bir hak düşer, 4. yanlış cevapta oyun biter ve Sonuç Ekranı'na geçilir ("Deneme Hakkın Bitti!"). Süre dolması hâlâ ayrı bir bitiş koşulu olarak kalır ("Süre Doldu!"). Uygulama: `lib/logic/game_constants.dart` içindeki `maxLives` (3) sabiti ve controller'lardaki `livesRemaining` alanı; UI karşılığı `lib/widgets/lives_badge.dart` içindeki `LivesBadge`.
- **Combo/Streak bonusu:** Art arda doğru cevaplarda combo sayacı artar, ekstra puan/animasyon (yıldız, konfeti vb.) verilir.
- **Süre bonusu (üç modda da):** Ayrı bir bitiş bonusu yoktur; onun yerine her doğru cevapta/eşleştirmede doğrudan tek eriyen sayaca +1 saniye eklenir (bkz. Bölüm 7), bu da dolaylı olarak daha fazla doğru cevap = daha yüksek skor demektir.

---

## 7. Süre Mekaniği

- Ekranın üst kısmında bir **countdown timer** (dairesel progress bar) gösterilir.
- Üç modda da süre **tek bir eriyen sayaçtır** — hiçbir modda "grid'i bitir, süre bonusu al" diye ayrı bir tamamlama ödülü yoktur, sayaç sürekli işler ve her doğru cevapta/eşleştirmede küçük bir bonusla beslenir; yanlış cevapta/eşleştirmede süre cezası yoktur (sadece can gider).
- Üç modda da sayaç aynı 60 saniyelik bütçeyle başlar (`initialTimeBudgetSeconds`, her modun kendi controller'ında tanımlı), her doğru cevapta/eşleştirmede +1 saniye bonus eklenir (`timeBonusPerCorrectSeconds`).
- Son 10 saniyede sayaç kırmızıya dönüp yanıp sönmeli, hafif tik-tak sesi çalmalı (aciliyet hissi, ama korkutucu olmamalı).
- Süre dolduğunda: grid donar, "Süre Doldu!" ekranı + skor özeti gösterilir.

---

## 8. Görsel & Animasyon Gereksinimleri

- **Doğru cevap animasyonu:** Hücre parlar (yeşil glow) → küçülerek/patlayarak yok olur (scale + fade + particle efekti). Küçük bir "ding" sesi.
- **Yanlış cevap animasyonu:** Hücre kırmızıya boyanır → shake (sallanma) efekti → "Yanlış!" texti belirip kaybolur → hücre normale döner. Kısa "buzzer" sesi (ama fazla rahatsız edici olmamalı, çocuk dostu).
- **Hedef sayı gösterimi:** Ekranın üstünde büyük, renkli, dikkat çekici bir kutu içinde (örn: "Bul: 12").
- **Renk paleti:** Çocuklara hitap eden canlı, pastel-parlak renkler (mavi, sarı, turuncu, yeşil). Kırmızı sadece yanlış cevap için kullanılmalı.
- **Karakter/Maskot (uygulandı):** Cik adında dost bir baykuş maskotu — sürekli hafifçe zıplayıp göz kırpar (idle), doğru cevapta sevinçle zıplayıp etrafına yıldız saçar (happy), yanlış cevapta üzülüp sallanır (sad). Üç oyun ekranında da (Sayı Avı, Eşleştirme, Tırmanış) grid'in sağ alt köşesinde belirir ve o modun `wrongIndex`/`wrongPair` ile `CellState.correct` durumundan türetilen ana anlık ruh haline tepki verir; sonuç ekranlarında `outOfLives`'a göre kalıcı happy/sad ifadesiyle görünür; Ana Menü'de ise arada bir kendiliğinden zıplayıp değişen bir karşılama balonuyla (bkz. `_MenuMascot`) karşılar. Saf vektör şekillerinden çizilir, görsel asset gerektirmez. Uygulama: `lib/widgets/mascot_widget.dart` (`MascotWidget`, `MascotMood`).
- **Yüzen sembol arka planı (uygulandı):** Mor gradientli ekranlarda (Ana Menü, Sonuç Ekranları) içeriğin arkasında, çok düşük opaklıkta (≈%8-19) küçük `+ − × ÷` sembolleri yavaşça süzülür — hafif dikey/yatay sürüklenme + yumuşak dönüş, sabit rastgele tohumla (aynı dağılım her açılışta), tek bir sonsuz döngü `AnimationController` ile (sin/cos tabanlı, ek paket gerektirmez). Dokunma olaylarını engellememesi için `IgnorePointer` ile sarılıdır. Uygulama: `lib/widgets/floating_symbols_background.dart` (`FloatingSymbolsBackground`), `main_menu_screen.dart`, `result_screen.dart` ve `match_result_screen.dart` içinde gradient `Container`'ın `Stack` çocuğu olarak, `SafeArea` içeriğinin arkasında kullanılır.

---

## 9. Ses Tasarımı

- Doğru cevap: kısa, neşeli "ding" veya "coin" sesi.
- Yanlış cevap: yumuşak "buzz" (agresif olmayan).
- Süre bitişi: nötr bir "zamanlayıcı durdu" sesi.
- Arka plan müziği: hafif, enerjik, döngüsel (loop) çocuk dostu müzik. Ses açma/kapama butonu olmalı.

---

## 10. Ekranlar (Screens)

1. **Ana Menü:** Oyna, Mod Seç, Skor Tablosu, Ayarlar + üstte bir **seri/rütbe rozeti** ("🔥 5 gün — Çarpım Kahramanı", bkz. Bölüm 17), dokununca Günlük Hedefler Ekranı'nı açar. Oyun **yalnızca** "Oyna" butonuna basıldığında başlar; Mod Seç akışının kendisi oyunu başlatmaz (bkz. madde 2-4) — Tırmanış da dahil, üç mod da bu ilkeye uyar.
2. **Mod Seçim Ekranı (uygulandı):** "Seviye Seç" (Sayı Avı), "Eşleştirme Modu" ve "Tırmanış" kartlarının birleştiği tek giriş noktası — Sayı Avı / Eşleştirme kartları ortak Seviye Seçim Ekranı'na yönlenir; **Tırmanış kartı bu akışı atlar** (grid boyutu/zorluk bölüm numarasına göre otomatik belirlendiği için ayrı bir seviye/işlem türü seçimi gerekmez — bkz. Bölüm 3b) ama oyunu da başlatmaz — diğer modların "Kaydet" adımıyla aynı ilkeyle, doğrudan "son oynanan mod" olarak kaydedilip Ana Menü'ye dönülür ("Hazır! Başlamak için 'Oyna'ya dokun" bildirimiyle). Daha önce bu iki mod (Sayı Avı, Eşleştirme) ana menüde ayrı butonlardan (ve "Oyna" her zaman doğrudan Sayı Avı'na atlayarak) seçiliyordu; bu tutarsızlık giderildi. Uygulama: `lib/screens/mode_select_screen.dart` (`ModeSelectScreen`).
3. **Seviye Seçim Ekranı:** Kolay / Orta / Zor / Uzman kartları. Sayı Avı ve Eşleştirme modu bu ekranı `GameMode` parametresiyle paylaşır (Tırmanış kullanmaz). Bir seviye seçildiğinde mod da "son oynanan" olarak kaydedilir (`ScoreService.setLastLevel` / `setLastMode`).
4. **İşlem Türü Seç Ekranı:** Toplama/Çıkarma/Çarpma/Bölme seçimi; Sayı Avı ve Eşleştirme tarafından paylaşılır (Tırmanış kullanmaz). **"Kaydet"e basmak oyunu başlatmaz** — seçilen işlem türlerini kaydeder (`ScoreService.setLastOperations`) ve doğrudan Ana Menü'ye döner ("Hazır! Başlamak için 'Oyna'ya dokun" bildirimiyle). Mod Seç akışının (mod → seviye → işlem türü) tek görevi, "Oyna" butonunun kullanacağı kombinasyonu hazırlamaktır; asıl oyun her zaman Ana Menü'deki "Oyna" butonuyla başlar — bu, en son kaydedilen mod + seviye + işlem türü kombinasyonunu okuyup (`MainMenuScreen._quickPlay`) hiçbir ara ekran göstermeden ilgili oyun ekranına gider (Tırmanış son oynanan modsa level/operations hiç okunmadan doğrudan `ClimbGameScreen`'e gider).
5. **Oyun Ekranı (Sayı Avı):** Seçilen seviyeye göre sabit boyutlu grid (Kolay 1x2, Orta 2x2, Zor 3x3, Uzman 4x4) + üstte hedef sayı + tek eriyen süre sayacı (60 sn, doğru cevapta +1 sn bonus) + skor.
6. **Oyun Ekranı (Eşleştirme):** Seçilen seviyeye göre sabit boyutlu grid (2x2/2x4/3x4/4x6) + üstte kalan çift sayısı + süre sayacı (60 sn) + skor (bkz. Bölüm 3a).
7. **Oyun Ekranı (Tırmanış):** Bölüme göre büyüyen grid (1x2→2x2→3x3→4x4) + üstte hedef sayı + bölüm rozeti ("Bölüm: 7") + tek eriyen süre sayacı + skor (bkz. Bölüm 3b).
8. **Sonuç Ekranı:** Toplam skor, doğru/yanlış (veya eşleşen çift/yanlış deneme, veya ulaşılan bölüm/doğru) sayısı, en iyi skor (Tırmanış'ta ayrıca en iyi bölüm), "Tekrar Oyna" / "Ana Menü" butonları. Her modun kendi sonuç ekranı vardır.
9. **Skor Tablosu:** Sayı Avı ve Eşleştirme için seviye başına en iyi skorları (açıkça "En yüksek skor" etiketiyle, bir kupa/rozet sayacı değil) ayrı ayrı gösterir; Tırmanış için (seçilebilir bir seviye olmadığından) tek bir özet kart — "En iyi bölüm" ve "En iyi skor" — gösterir.
10. **Ayarlar:** Ses aç/kapa, zorluk varsayılanı, dil seçimi (opsiyonel çoklu dil desteği).
11. **Günlük Hedefler Ekranı (uygulandı):** Bugünün 3 hedefi (ilerleme çubuklarıyla), seri (streak) kartı ve mevcut rütbe + bir sonraki rütbeye kalan gün sayısı (bkz. Bölüm 17). Ana Menü'deki seri rozetinden açılır. Uygulama: `lib/screens/daily_goals_screen.dart` (`DailyGoalsScreen`).

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
    game_mode.dart          // GameMode: hunt (Sayı Avı) / match (Eşleştirme) / climb (Tırmanış)
    daily_goal.dart          // DailyGoalKind (hedef havuzu) + DailyRank (rütbeler) — bkz. Bölüm 17
  logic/
    problem_generator.dart      // rastgele işlem üretimi + eşleştirme çift üretimi
    game_controller.dart        // Sayı Avı state yönetimi (skor, tek eriyen süre, tam-yenilenen grid)
    match_game_controller.dart  // Eşleştirme modu state yönetimi (bkz. Bölüm 3a)
    climb_game_controller.dart  // Tırmanış modu state yönetimi (bkz. Bölüm 3b)
    climb_progression.dart      // bölüm -> (zorluk, işlem havuzu) eşlemesi (bkz. Bölüm 3b)
    grid_shape.dart              // seviye -> grid boyutu eşlemesi: gridShapeForLevel (Sayı Avı + Tırmanış, climb_progression.dart üzerinden) ve matchGridShapeForLevel (Eşleştirme)
    game_constants.dart         // GameStatus, maxLives — üç mod da paylaşır
    grid_playable.dart          // GridWidget'ın ihtiyaç duyduğu ortak arayüz (columns dahil)
  screens/
    main_menu_screen.dart
    mode_select_screen.dart      // "Oyna" ve mod seçiminin tek giriş noktası
    level_select_screen.dart     // mode: GameMode parametresiyle Sayı Avı/Eşleştirme için kullanılır
    operation_select_screen.dart // mode: GameMode parametresiyle Sayı Avı/Eşleştirme için kullanılır
    game_screen.dart             // Sayı Avı oyun ekranı
    match_game_screen.dart       // Eşleştirme modu oyun ekranı
    climb_game_screen.dart       // Tırmanış modu oyun ekranı
    result_screen.dart           // Sayı Avı sonuç ekranı
    match_result_screen.dart     // Eşleştirme modu sonuç ekranı
    climb_result_screen.dart     // Tırmanış modu sonuç ekranı
    scoreboard_screen.dart
    settings_screen.dart
    daily_goals_screen.dart      // Günlük Hedefler ekranı (bkz. Bölüm 17)
  widgets/
    grid_widget.dart
    grid_cell_widget.dart
    timer_widget.dart
    target_number_widget.dart   // Sayı Avı ve Tırmanış: "Bul: 12"
    match_status_widget.dart    // Eşleştirme: "Kalan çift: 5"
    climb_status_widget.dart    // Tırmanış: "Bölüm: 7"
    lives_badge.dart            // üç mod da paylaşır
    mascot_widget.dart          // maskot (Cik the owl) — üç mod + Ana Menü + sonuç ekranları paylaşır
  services/
    audio_service.dart
    score_service.dart      // yerel skor kaydı (shared_preferences), moda göre ayrı anahtar
    daily_goals_service.dart // günlük hedef ilerlemesi + seri + rütbe (shared_preferences) — bkz. Bölüm 17
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

- [x] Sayı Avı'nda seçilen seviyeye göre sabit boyutlu grid (1x2/2x2/3x3/4x4) düzgün render ediliyor, tüm hücreler dokunulabilir (Eşleştirme modunda seviyeye göre 2x2/2x4/3x4/4x6).
- [x] Her hücrede geçerli, çözülebilir bir matematik işlemi var.
- [x] Hedef sayı her zaman gridteki en az bir hücrenin cevabına eşit.
- [x] Sayı Avı'nda doğru dokunuşta skor artıyor, tek eriyen süre sayacına +1 sn bonus ekleniyor, tüm grid + hedef sayı anında yenileniyor.
- [x] Yanlış dokunuşta hücre kırmızıya dönüyor, "Yanlış!" gösteriliyor, sonra normale dönüyor; süre etkilenmiyor, sadece can azalıyor.
- [x] Süre sayacı çalışıyor, süre bitince oyun sonlanıyor (üç modda da 60 sn'lik tek eriyen sayaç).
- [x] Oyuncuya 3 deneme (can) hakkı veriliyor, 4. yanlış cevapta oyun sonlanıyor.
- [x] Hiçbir modda "grid tamamen bitince seviye tamamlandı" diye bir kazanma durumu yok; üçünde de bitiş her zaman süre veya canların tükenmesi. Eşleştirme'de grid tamamen boşalırsa (Seçenek B'nin özü) oyun bitmiyor, grid anında yeni bir çift setiyle değiştiriliyor (Sayı Avı'nın tam-yenileme ilkesiyle aynı).
- [ ] Sonuç ekranında skor ve tekrar oyna seçeneği var.
- [ ] En az 3 zorluk seviyesi mevcut.
- [ ] Ses efektleri çalışıyor ve kapatılabiliyor.
- [x] Eşleştirme modu: seviyeye göre sabit boyutlu grid, sonucu eşit iki hücre eşleştirilince ikisi de yok oluyor; yanlış eşleştirmede ikisi de kırmızıya dönüp normale dönüyor.
- [x] Eşleştirme modunda da seviye ve işlem türü seçilebiliyor; can mekaniği, skor formülü, başlangıç süresi (60 sn) ve "tek eriyen süre + doğru eşleştirmede bonus + tam grid yenileme" ilkesi diğer modlarla birebir aynı, sadece kendi grid boyutu (seviyeye göre) korunuyor (bkz. Bölüm 3a).
- [x] Tırmanış modu: grid boyutu bölüm numarasına göre büyüyor (1x2→2x2→3x3→4x4, orada sabitleniyor), işlem zorluğu aynı eşiklerde otomatik artıyor.
- [x] Tırmanış modunda tek bir eriyen süre sayacı var, doğru cevapta küçük bir bonusla besleniyor; yanlış cevap sadece can azaltıyor, bölümü/gridi sıfırlamıyor.
- [x] Tırmanış modunda en iyi ulaşılan bölüm ve en iyi skor ayrı ayrı kaydediliyor ve Skor Tablosu'nda gösteriliyor.
- [x] Skor Tablosu, Sayı Avı ve Eşleştirme'de seviye başına toplam bir kupa/rozet sayacı değil, açıkça etiketlenmiş "En yüksek skor" değerini listeliyor.
- [x] Günlük Hedefler: her gün 3 hedef çıkıyor, ilerlemesi oyun sonuçlarından otomatik besleniyor, hepsi tamamlanınca seri bir artıyor; bir gün atlanırsa (veya hedefler tamamlanmazsa) seri sıfırlanıyor; seri uzunluğuna göre matematik temalı bir rütbe gösteriliyor (bkz. Bölüm 17).

---

## 15. Gelecek Geliştirmeler (Nice-to-have)

- Çoklu oyuncu / arkadaşla yarışma modu.
- Günlük hedeflerin gerçek bir bildirim/hatırlatma sistemiyle desteklenmesi (bkz. Bölüm 17 — şu an sadece uygulama içi, pasif bir seri takibi var, "bugün henüz oynamadın" gibi push bildirimleri yok).
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

## 17. Günlük Hedefler, Seri (Streak) ve Rütbeler (Uygulandı)

Çocuğu her gün en az birkaç dakika geri getirmek için üç parçalı bir motivasyon sistemi: her gün küçük, ulaşılabilir **hedefler** çıkar; hepsi tamamlanınca o gün **seri** (streak) bir artar; seri belirli eşiklere ulaştıkça matematik temalı **rütbeler** açılır. Bir gün hedefler tamamlanmazsa (veya gün tamamen atlanırsa) seri sıfırlanır.

**Hedefler nasıl seçilir:** Sabit bir 5'lik havuzdan (`DailyGoalKind`), her gün **3 tanesi** tarihe göre sabit (deterministic) bir tohumla seçilir — aynı gün içinde uygulama kaç kez açılırsa açılsın hedefler aynı kalır, ertesi gün değişir. Havuzdaki her hedef, zaten var olan oyun sonucu alanlarından (skor, doğru sayısı, eşleşen çift, ulaşılan bölüm) beslenir — yeni bir oyun mekaniği gerektirmez:

| Hedef | Hedef değeri | Nasıl ilerler |
|---|---|---|
| Bugün en az 2 oyun oyna | 2 | Her koşuda +1 (hangi mod olursa olsun) |
| Bugün toplam 150 puan topla | 150 | Her koşunun skoru toplanır (hangi mod olursa olsun) |
| Sayı Avı'nda 15 doğru cevap ver | 15 | Sayı Avı koşularının `correctCount` toplamı |
| Eşleştirme'de 10 çift bul | 10 | Eşleştirme koşularının `matchedPairs` toplamı |
| Tırmanış'ta 10. bölüme ulaş | 10 | Tek bir Tırmanış koşusunda ulaşılan en yüksek `round` (toplanmaz, en iyisi tutulur) |

**İlerleme takibi:** Canlı (oyun içi anlık) takip yoktur — her modun `onGameEnd` sonucu (`GameResult`/`MatchGameResult`/`ClimbGameResult`), oyun bitince tek seferde günün ilerlemesine eklenir (bkz. `DailyGoalsService.recordHuntResult`/`recordMatchResult`/`recordClimbResult`, çağrıldığı yer: her oyun ekranının `_handleGameEnd`'i).

**Seri (streak) mantığı:** Günün 3 hedefi de tamamlanınca `lastCompletedDate = bugün` yazılır ve seri bir artar (dünden devam ediyorsa) veya 1'e sıfırlanıp yeniden başlar (bir gün atlanmışsa). Ayrı bir arka plan görevi veya bildirim yoktur — kontrol tamamen pasif: uygulama her açıldığında (veya bir oyun sonucu kaydedildiğinde), bugünün tarihiyle son tamamlanan gün karşılaştırılır; aradan bir günden fazla geçmişse (dün tamamlanmamışsa) seri sıfırlanır.

**Rütbeler:** Seri uzunluğuna bağlı bir merdiven (`rankForStreak`):

| Seri (gün) | Rütbe |
|---|---|
| 0-2 | Sayı Çırağı |
| 3-6 | Toplama Ustası |
| 7-13 | Çarpım Kahramanı |
| 14-29 | Bölme Büyücüsü |
| 30+ | Matematik Dahisi |

Rütbe, seri sıfırlanınca da en baştaki seviyeye düşer (ayrı bir "en yüksek ulaşılan rütbe" onur listesi tutulmaz — bu bilinçli bir MVP kapsam kararı, bkz. Bölüm 15).

**Kurallar:**
- Aynı gün içinde hedefler tamamlandıktan sonra oynanmaya devam edilirse seri tekrar işlenmez (yanlışlıkla sıfırlanıp 1'e düşmesin diye — bkz. `DailyGoalsService._checkStreakCompletion`).
- Uygulamanın ilk hiç açılışında (henüz kayıtlı tarih yoksu) seri bayatlık kontrolü atlanır, hedefler 0'dan başlar.
- Bu sistem üç modu da (Sayı Avı, Eşleştirme, Tırmanış) kapsar; hiçbiri diğerinden ayrıcalıklı değildir.

**Uygulama:** `lib/models/daily_goal.dart` (`DailyGoalKind`, `DailyGoalProgress`, `DailyRank`, `rankForStreak`), `lib/services/daily_goals_service.dart` (`DailyGoalsService`, `DailyGoalsSnapshot`), ekran `lib/screens/daily_goals_screen.dart` (`DailyGoalsScreen`) ve Ana Menü'deki seri rozeti `lib/screens/main_menu_screen.dart` içindeki `_StreakBanner`. Üç oyun ekranı (`game_screen.dart`, `match_game_screen.dart`, `climb_game_screen.dart`) `_handleGameEnd` içinde ilgili `recordXResult` çağrısını yapar.

---
