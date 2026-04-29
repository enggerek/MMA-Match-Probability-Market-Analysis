# 🥊 MMA Maç Olasılık ve Piyasa Analizi

> Çoklu spor bahis piyasalarındaki olasılık fiyatlamasını inceleyen, Python, PostgreSQL ve Power BI ile geliştirilmiş canlı veri analizi projesi.

🇬🇧 [English version](README.md)

---

## 📋 Proje Özeti

Bu proje, 15 farklı piyasa operatörünün yaklaşan MMA maçlarını nasıl fiyatladığını analiz eder ve hangilerinin en verimli (en düşük spread'li) piyasaları sunduğunu ortaya koyar. Pipeline, The Odds API'den canlı veri çeker, PostgreSQL ve pandas ile işler ve içgörüleri etkileşimli bir Power BI dashboard'unda görselleştirir.

**İncelenen ana sorular:**
- Hangi operatörler en rekabetçi fiyatlamayı sunuyor?
- Aynı maç için piyasalar arasındaki fiyat farkı ne kadar?
- Tüm maçlardaki ima edilen olasılık dağılımı nasıl görünüyor?
- Piyasa overround'u (yapısal marj) nereden geliyor?

---

## 🎬 Dashboard Demosu

![Dashboard Demo](mma_dashboard1.gif)

---

## 📊 Dashboard Önizleme

![Dashboard Genel Görünüm](Ekran%20Resmi%202026-04-27%2014.49.36.png)

Dashboard şunları içerir:
- **KPI kartları:** toplam maç, toplam veri kaynağı, ortalama piyasa spread'i, minimum piyasa spread'i
- **Çubuk grafikler:** operatör başına ortalama spread, operatör başına maç kapsamı
- **Donut grafik:** maçların spread kategorilerine göre dağılımı (Düşük / Orta / Yüksek)
- **Dağılım grafiği:** her aktif maç için Dövüşçü 1 vs Dövüşçü 2 ima edilen kazanma olasılığı
- **Etkileşimli slicer:** tüm görselleri veri kaynağına göre filtreler

Tüm görseller cross-filtering destekler herhangi bir elemana tıklamak diğer grafikleri günceller.

---

## 🔍 Temel İçgörüler

- **Pinnacle** sürekli olarak en düşük piyasa spread'ini gösterir (~%103.7), bu da onu bahisçi için en verimli piyasa yapar
- **BetOnline.ag** en geniş maç kapsamına ve rekabetçi fiyatlamaya sahip
- **Betfair** sabit oranlı operatör değil bahis borsası olarak çalışır, bu da ham marj hesaplamalarını şişirir ve analiz sırasında filtreleme gerektirir
- İma edilen olasılık dağılım grafiği temiz bir ters ilişki gösterir piyasalar kendi içinde tutarlı
- Tüm maç operatör gözlemlerinin yaklaşık yarısı "Düşük Spread" kategorisinde, bu da çoğu operatörde tutarlı fiyatlama olduğunu gösterir

---

## 🛠️ Teknoloji Yığını

| Katman | Araç |
|---|---|
| Veri Kaynağı | The Odds API |
| Pipeline | Python (requests, pandas, SQLAlchemy, psycopg2) |
| Veritabanı | PostgreSQL (pgAdmin ile yönetildi) |
| Analiz | SQL + pandas |
| Görselleştirme | Power BI Desktop |
| IDE | PyCharm |

---

## 📁 Klasör Yapısı

mma-match-probability-analysis/
├── fetch_odds.py              # The Odds API'den PostgreSQL'e canlı veri çeker
├── analysis.py                # Veriyi okur, ima edilen olasılık ve marjları hesaplar, CSV'ye export eder
├── analysis_queries.sql       # Tam SQL analizi (8 bölüm, tamamen belgelenmiş)
├── mma_fight_analysis.csv     # Dashboard tarafından kullanılan en son snapshot
├── MMA_Probability_Analysis.pbix  # Power BI dashboard dosyası
├── mma_dashboard1.gif         # Dashboard etkileşim demosu
├── screenshots/               # Statik dashboard görüntüleri
├── requirements.txt           # Python bağımlılıkları
├── .env.example               # Ortam değişkenleri şablonu
└── .gitignore                 # Sürüm kontrolünden hariç tutulan dosyalar