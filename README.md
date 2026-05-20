# 🍽️ Bi'Yemek — Flutter Yemek Sipariş Uygulaması

Bi'Yemek, Flutter ile geliştirilmiş, gerçek konuma dayalı restoran listesi sunan tam özellikli bir mobil yemek sipariş uygulamasıdır. Firebase Authentication, Cloud Firestore ve OpenStreetMap tabanlı veri kaynaklarını kullanır.

---

## 📱 Özellikler

- **Kullanıcı Kimlik Doğrulama** — E-posta/şifre ve Google ile giriş, e-posta doğrulama
- **Gerçek Konuma Dayalı Restoranlar** — OpenStreetMap / Overpass API ile yakındaki restoranları listeler
- **Kategori Filtreleme** — Mutfak türüne göre filtreleme
- **Sepet Yönetimi** — Ürün ekleme/çıkarma, not ekleme, promosyon kodu uygulama
- **Promosyon Kodları** — Kategori kısıtlamalı, ilk siparişe özel kodlar (BIYEMEK30, KAHVE15, SOKAK25, HOSGELDIN)
- **Sipariş Simülasyonu** — Gerçek zamanlı durum takibi (Onaylandı → Hazırlanıyor → Yolda → Teslim Edildi)
- **Anlık Bildirimler** — Uygulama içi banner + zamanlanmış yerel bildirimler
- **E-posta Bildirimleri** — EmailJS ile sipariş onayı ve teslim bildirimi
- **Harita Entegrasyonu** — Google Maps ile restoran konumu ve rota
- **Değerlendirme Sistemi** — Teslim edilen siparişlere yorum ve puanlama
- **Canlı Destek** — Sipariş durumu, iptal talebi ve şikayet akışları
- **Kayıtlı Adresler** — Çoklu teslimat adresi yönetimi
- **Kayıtlı Kartlar** — Ödeme kartı saklama (yerel)
- **Profil Yönetimi** — Hesap düzenleme, şifre değiştirme, hesap silme
- **Karanlık / Açık Tema** — Tam tema desteği
- **İnternet Bağlantısı Kontrolü** — Splash ekranında bağlantı kontrolü ve yeniden deneme

---

## 🛠️ Kullanılan Teknolojiler

| Katman | Teknoloji |
|---|---|
| Uygulama Çerçevesi | Flutter 3 (Dart) |
| Durum Yönetimi | Provider |
| Kimlik Doğrulama | Firebase Authentication |
| Veritabanı | Cloud Firestore |
| Yerel Depolama | SharedPreferences |
| Haritalar | Google Maps Flutter, Flutter Map (OpenStreetMap) |
| Konum | Geolocator, Permission Handler |
| Bildirimler | flutter_local_notifications |
| E-posta | EmailJS REST API |
| Animasyon | Lottie |
| HTTP | Dart http paketi |
| Yazı Tipleri | Google Fonts |

---

## 🌐 Kullanılan API'ler

| API | Amaç |
|---|---|
| [Firebase Authentication](https://firebase.google.com/docs/auth) | Kullanıcı girişi (e-posta + Google OAuth) |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Sipariş, değerlendirme ve kullanıcı verisi |
| [Overpass API](https://overpass-api.de) | OpenStreetMap'ten yakın restoran verisi |
| [Nominatim](https://nominatim.openstreetmap.org) | Koordinattan şehir/ilçe çözümleme |
| [Google Maps Platform](https://developers.google.com/maps) | Harita görüntüleme ve rota |
| [EmailJS](https://www.emailjs.com) | Sipariş onayı ve teslim e-postası |

---

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio veya VS Code
- Firebase projesi

### Adımlar

**1. Repoyu klonla**
```bash
git clone https://github.com/kullanici-adi/bi_yemek.git
cd bi_yemek
```

**2. Bağımlılıkları yükle**
```bash
flutter pub get
```

**3. Firebase kurulumu**

- [Firebase Console](https://console.firebase.google.com)'da yeni proje oluştur
- Android uygulaması ekle (package name: `com.biyemek.app`)
- `google-services.json` dosyasını indirip `android/app/` klasörüne koy
- Firebase Authentication ve Cloud Firestore'u etkinleştir
- Authentication → Sign-in methods: **E-posta/Şifre** ve **Google**'ı aç

**4. EmailJS kurulumu** *(isteğe bağlı — e-posta bildirimleri için)*

`lib/services/email_service.dart` dosyasını aç ve sabit değerleri doldur:

```dart
static const _publicKey          = 'YOUR_EMAILJS_PUBLIC_KEY';
static const _serviceId          = 'YOUR_EMAILJS_SERVICE_ID';
static const _orderTemplateId    = 'YOUR_ORDER_TEMPLATE_ID';
static const _deliveryTemplateId = 'YOUR_DELIVERY_TEMPLATE_ID';
```

**5. Google Maps API anahtarı**

`android/app/src/main/AndroidManifest.xml` içinde:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**6. Uygulamayı çalıştır**
```bash
flutter run
```

---

## 📂 Proje Yapısı

```
lib/
├── main.dart
├── models/          # Veri modelleri (OrderModel, Restaurant, ...)
├── providers/       # Durum yönetimi (AuthProvider, CartProvider, OrderProvider, ...)
├── screens/         # UI ekranları
├── services/        # API servisleri (Firebase, EmailJS, Overpass, ...)
├── theme/           # Uygulama teması
└── widgets/         # Paylaşılan widget'lar
```

