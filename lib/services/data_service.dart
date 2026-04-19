import 'dart:math';
import '../models/restaurant.dart';

class DataService {
  static final Random _rng = Random(42);
  static List<Restaurant>? _cache;

  // ─── YORUM ÜRETİCİ ───────────────────────────────────────────
  static final List<String> _reviewNames = [
    'Ahmet Y.','Fatma K.','Mehmet A.','Ayşe D.','Mustafa T.',
    'Zeynep Ş.','İbrahim C.','Hatice Ö.','Ali R.','Emine B.',
    'Hasan M.','Elif G.','Hüseyin N.','Meryem P.','Ömer F.',
  ];

  static final List<String> _positiveComments = [
    'Çok lezzetliydi, kesinlikle tekrar sipariş vereceğim!',
    'Hızlı teslimat, sıcak geldi. Harika!',
    'Porsiyon büyüklüğü mükemmeldi, fiyat da makul.',
    'Her zamanki gibi harika. Favorim!',
    'Ambalaj çok özenli yapılmış, yemekler bozulmamış.',
    'Lezzetli ve taze. Tavsiye ederim.',
    'Beklentimin üzerinde bir deneyimdi.',
    'Söz verilen süreden önce geldi, aferin!',
  ];

  static final List<String> _midComments = [
    'Lezzet iyi ama teslimat biraz geç kaldı.',
    'Güzel yemekler ancak fiyat biraz yüksek.',
    'Genel olarak memnun kaldım, tekrar denerim.',
    'İdare eder, özel bir şey yok.',
  ];

  static List<Review> _generateReviews(double rating, int count, Random rng) {
    final now = DateTime.now();
    return List.generate(count.clamp(0, 6), (i) {
      final isPositive = rating >= 4.0;
      final comments = isPositive ? _positiveComments : _midComments;
      return Review(
        id: 'rv_${rng.nextInt(999999)}',
        userName: _reviewNames[rng.nextInt(_reviewNames.length)],
        rating: rating >= 4.0 ? (4.0 + rng.nextDouble()) : (2.5 + rng.nextDouble() * 1.5),
        comment: comments[rng.nextInt(comments.length)],
        createdAt: now.subtract(Duration(days: rng.nextInt(60))),
      );
    });
  }


  // ─── TÜRK ŞEHİRLERİ ─────────────────────────────────────────
  static const List<Map<String, dynamic>> _cities = [
    {'name':'İstanbul','lat':41.01,'lng':28.97,'pop':15000000},
    {'name':'Ankara','lat':39.92,'lng':32.85,'pop':5700000},
    {'name':'İzmir','lat':38.42,'lng':27.14,'pop':4400000},
    {'name':'Bursa','lat':40.18,'lng':29.06,'pop':3100000},
    {'name':'Antalya','lat':36.90,'lng':30.70,'pop':2500000},
    {'name':'Adana','lat':37.00,'lng':35.32,'pop':2200000},
    {'name':'Gaziantep','lat':37.06,'lng':37.38,'pop':2100000},
    {'name':'Konya','lat':37.87,'lng':32.48,'pop':2200000},
    {'name':'Mersin','lat':36.80,'lng':34.63,'pop':1800000},
    {'name':'Diyarbakır','lat':37.91,'lng':40.22,'pop':1750000},
    {'name':'Kayseri','lat':38.72,'lng':35.49,'pop':1400000},
    {'name':'Eskişehir','lat':39.77,'lng':30.52,'pop':900000},
    {'name':'Samsun','lat':41.29,'lng':36.33,'pop':1350000},
    {'name':'Trabzon','lat':41.00,'lng':39.72,'pop':800000},
    {'name':'Malatya','lat':38.35,'lng':38.31,'pop':800000},
    {'name':'Şanlıurfa','lat':37.16,'lng':38.79,'pop':2000000},
    {'name':'Van','lat':38.49,'lng':43.38,'pop':1100000},
    {'name':'Denizli','lat':37.78,'lng':29.09,'pop':1000000},
    {'name':'Manisa','lat':38.62,'lng':27.43,'pop':1400000},
    {'name':'Sakarya','lat':40.69,'lng':30.44,'pop':1000000},
    {'name':'Tekirdağ','lat':40.98,'lng':27.51,'pop':1100000},
    {'name':'Balıkesir','lat':39.64,'lng':27.89,'pop':1250000},
    {'name':'Muğla','lat':37.22,'lng':28.36,'pop':1000000},
    {'name':'Kahramanmaraş','lat':37.58,'lng':36.94,'pop':1150000},
    {'name':'Hatay','lat':36.40,'lng':36.35,'pop':1650000},
    {'name':'Kocaeli','lat':40.85,'lng':29.88,'pop':2000000},
    {'name':'Elazığ','lat':38.68,'lng':39.22,'pop':600000},
    {'name':'Erzincan','lat':39.75,'lng':39.50,'pop':370000},
    {'name':'Erzurum','lat':39.91,'lng':41.27,'pop':800000},
    {'name':'Ordu','lat':40.98,'lng':37.88,'pop':750000},
    {'name':'Rize','lat':41.02,'lng':40.52,'pop':350000},
    {'name':'Artvin','lat':41.18,'lng':41.82,'pop':175000},
    {'name':'Ağrı','lat':39.72,'lng':43.05,'pop':550000},
    {'name':'Aksaray','lat':38.37,'lng':34.03,'pop':450000},
    {'name':'Amasya','lat':40.65,'lng':35.84,'pop':340000},
    {'name':'Ardahan','lat':41.11,'lng':42.70,'pop':100000},
    {'name':'Bartın','lat':41.64,'lng':32.34,'pop':200000},
    {'name':'Batman','lat':37.88,'lng':41.13,'pop':600000},
    {'name':'Bayburt','lat':40.26,'lng':40.22,'pop':82000},
    {'name':'Bilecik','lat':40.15,'lng':29.98,'pop':230000},
    {'name':'Bingöl','lat':38.88,'lng':40.50,'pop':280000},
    {'name':'Bitlis','lat':38.40,'lng':42.12,'pop':340000},
    {'name':'Bolu','lat':40.74,'lng':31.61,'pop':320000},
    {'name':'Burdur','lat':37.72,'lng':30.29,'pop':270000},
    {'name':'Çanakkale','lat':40.15,'lng':26.40,'pop':550000},
    {'name':'Çankırı','lat':40.60,'lng':33.62,'pop':195000},
    {'name':'Çorum','lat':40.55,'lng':34.95,'pop':530000},
    {'name':'Edirne','lat':41.68,'lng':26.56,'pop':410000},
    {'name':'Giresun','lat':40.91,'lng':38.39,'pop':440000},
    {'name':'Gümüşhane','lat':40.46,'lng':39.48,'pop':175000},
    {'name':'Hakkari','lat':37.57,'lng':43.74,'pop':280000},
    {'name':'Iğdır','lat':39.92,'lng':44.04,'pop':198000},
    {'name':'Isparta','lat':37.76,'lng':30.55,'pop':440000},
    {'name':'Karabük','lat':41.20,'lng':32.62,'pop':245000},
    {'name':'Karaman','lat':37.18,'lng':33.22,'pop':265000},
    {'name':'Kars','lat':40.60,'lng':43.10,'pop':280000},
    {'name':'Kastamonu','lat':41.38,'lng':33.78,'pop':380000},
    {'name':'Kilis','lat':36.72,'lng':37.12,'pop':145000},
    {'name':'Kırıkkale','lat':39.85,'lng':33.51,'pop':280000},
    {'name':'Kırklareli','lat':41.73,'lng':27.22,'pop':360000},
    {'name':'Kırşehir','lat':39.14,'lng':34.16,'pop':240000},
    {'name':'Mardin','lat':37.31,'lng':40.74,'pop':850000},
    {'name':'Muş','lat':38.73,'lng':41.49,'pop':400000},
    {'name':'Nevşehir','lat':38.62,'lng':34.71,'pop':300000},
    {'name':'Niğde','lat':37.97,'lng':34.68,'pop':360000},
    {'name':'Osmaniye','lat':37.07,'lng':36.25,'pop':530000},
    {'name':'Siirt','lat':37.93,'lng':41.94,'pop':320000},
    {'name':'Sinop','lat':42.02,'lng':35.15,'pop':225000},
    {'name':'Sivas','lat':39.75,'lng':37.01,'pop':630000},
    {'name':'Şırnak','lat':37.52,'lng':42.46,'pop':550000},
    {'name':'Tokat','lat':40.31,'lng':36.55,'pop':600000},
    {'name':'Tunceli','lat':39.11,'lng':39.55,'pop':85000},
    {'name':'Uşak','lat':38.68,'lng':29.41,'pop':370000},
    {'name':'Yalova','lat':40.66,'lng':29.27,'pop':280000},
    {'name':'Yozgat','lat':39.82,'lng':34.81,'pop':430000},
    {'name':'Zonguldak','lat':41.45,'lng':31.79,'pop':600000},
    {'name':'Adıyaman','lat':37.76,'lng':38.28,'pop':630000},
    {'name':'Afyonkarahisar','lat':38.76,'lng':30.54,'pop':740000},
    {'name':'Aydın','lat':37.84,'lng':27.85,'pop':1100000},
    {'name':'Düzce','lat':40.84,'lng':31.16,'pop':400000},
    {'name':'Kütahya','lat':39.42,'lng':29.98,'pop':580000},
  ];

  // ─── RESTORAN İSİM PARÇALARI ──────────────────────────────────
  static const List<String> _prefixes = [
    'Usta','Baba','Hacı','Memur','Şef','Hoca','Demir','Öz',
    'Anadolu','Boğaz','Çarşı','Pazar','Köşe','Merkez','Lezzet',
    'Altın','Gümüş','Yıldız','Güneş','Ay','Bulut','Deniz',
    'Dağ','Orman','Çayır','Yeşil','Kırmızı','Beyaz','Mavi',
    'Eski','Yeni','Modern','Klasik','Geleneksel','Doğal',
    'Sıcak','Taze','Ev','Köy','Kasaba','Şehir',
  ];

  static const Map<String, List<String>> _cuisineNames = {
    'Pizza': ['Pizzacı','Pizza Evi','Pizza House','Forno','Napoli','Roma','Pizza Dünyası','Capri','Napoli Fırın'],
    'Burger': ['Burger Lab','Smash House','Burger Joint','Beef Bros','Grillhouse','Kasap Burger','Et Burger','Stack House'],
    'Döner': ['Dönerci','Et Döner','Iskender Evi','Döner Dünyası','Kebapçı','Mangal','Ocakbaşı','Izgara Evi'],
    'Tavuk': ['Tavukçu','Kanat Evi','Piliç Evi','Çıtır House','Kanat & Kanat','Broast','Izgara Tavuk'],
    'Pide & Lahmacun': ['Pideci','Fırın','Lahmacuncu','Pide Evi','Hamur İşleri','Fırın Ustası','Ekmek Fırını'],
    'Et': ['Kasap','Et Lokantası','Mangalcı','Izgaracı','Steakhouse','Et & Kebap','Çiğ Et Evi','Kuzu Evi'],
    'Deniz Ürünleri': ['Balıkçı','Deniz Restaurant','Liman Balık','Meze Evi','Tekne','İskele','Balık Evi'],
    'Vegan & Vejetaryen': ['Yeşil Tabak','Vegan Mutfak','Sağlıklı Yaşam','Green Bowl','Salad Bar','Detoks Cafe','Organik'],
    'Kahvaltı': ['Kahvaltıcı','Serpme Kahvaltı','Köy Kahvaltısı','Sabah Evi','Çiftlik Sofrası','Kahvaltı Dünyası','Gözlemeci','Menemen Evi','Kahvaltı & Gözleme'],
    'Sokak Lezzetleri': ['Kumpirci','Kokoreçci','Tantunicu','Islak Burger Evi','Sokak Lezzetleri','Nostaljik Köşe'],
    'Mantı & Makarna': ['Mantıcı','Ev Mantısı','Makarna Evi','Pasta e Basta','Hamur Evi','El Yapımı Mantı'],
    'Kahve & İçecek': ['Café','Coffee Shop','Çay Evi','Nargile Café','Bistro','Lounge','Tea House'],
    'Pastane & Fırın': ['Pastane','Fırın','Pâtisserie','Börekçi','Unlu Mamüller','Tatlıcı','Şekerleme','Börekçilik','Pastacı','Fırıncı'],
    'Aperatif': ['Mezeci','Meze Evi','Salata Bar','Söğüş','Zeytinlik','Tabak','Aperatif Dünyası','Meyhane','Ocakbaşı'],
    'Ev Yemekleri': ['Lokanta','Ev Yemeği','Anneannenin Mutfağı','Ev Sofrası','Günlük Yemek','Bereket Lokantası','Esnaf Lokantası'],
    'Çiğ Köfte': ['Çiğ Köfteci','Çiğ Köfte Evi','Çiğköfte Dur','Lezzetli Çiğköfte','Çiğ Köfte & Dürüm','Komagene Bayisi'],
    'Dünya Mutfakları': ['Sushi Bar','Thai Kitchen','Çin Lokantası','Japon Restaurant','Hint Mutfağı','Meksika Grill','İtalyan Mutfağı','Wok House','Noodle Bar'],
    'Tatlı': ['Tatlıcı','Dondurma','Baklava Evi','Tatlı Dünyası','Şekerleme','Pastane','Şerbetli Tatlılar','Çikolata Atölyesi'],
  };

  // ─── ZİNCİR RESTORANLAR ───────────────────────────────────────
  static const List<Map<String, dynamic>> _chains = [
    {'name':"McDonald's",'cuisine':'Burger','fee':0.0,'min':75.0,'img':0},
    {'name':"Burger King",'cuisine':'Burger','fee':0.0,'min':80.0,'img':1},
    {'name':"KFC",'cuisine':'Tavuk','fee':4.99,'min':70.0,'img':2},
    {'name':"Popeyes",'cuisine':'Tavuk','fee':4.99,'min':75.0,'img':3},
    {'name':"Domino's Pizza",'cuisine':'Pizza','fee':0.0,'min':100.0,'img':4},
    {'name':"Pizza Hut",'cuisine':'Pizza','fee':9.99,'min':120.0,'img':5},
    {'name':"Little Caesars",'cuisine':'Pizza','fee':4.99,'min':90.0,'img':6},
    {'name':"Tavuk Dünyası",'cuisine':'Tavuk','fee':4.99,'min':70.0,'img':7},
    {'name':"Köfteci Yusuf",'cuisine':'Et','fee':7.99,'min':80.0,'img':8},
    {'name':"Simit Sarayı",'cuisine':'Pastane & Fırın','fee':4.99,'min':50.0,'img':9},
    {'name':"Starbucks",'cuisine':'Kahve & İçecek','fee':9.99,'min':80.0,'img':10},
    {'name':"Kahve Dünyası",'cuisine':'Kahve & İçecek','fee':4.99,'min':60.0,'img':11},
    {'name':"Caribou Coffee",'cuisine':'Kahve & İçecek','fee':7.99,'min':70.0,'img':12},
    {'name':"Sbarro",'cuisine':'Pizza','fee':7.99,'min':80.0,'img':13},
    {'name':"Smash Bros Burger",'cuisine':'Burger','fee':9.99,'min':100.0,'img':14},
    {'name':"Komagene",'cuisine':'Çiğ Köfte','fee':4.99,'min':60.0,'img':2},
    {'name':"Baydöner",'cuisine':'Döner','fee':4.99,'min':80.0,'img':8},
    {'name':"Arby's",'cuisine':'Burger','fee':7.99,'min':90.0,'img':0},
    {'name':"Simitçi Dünyası",'cuisine':'Pastane & Fırın','fee':4.99,'min':50.0,'img':9},
    {'name':"Bereket Döner",'cuisine':'Döner','fee':0.0,'min':70.0,'img':8},
    {'name':"Subway",'cuisine':'Dünya Mutfakları','fee':7.99,'min':90.0,'img':13},
  ];

  static const List<String> _imgUrls = [
    'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500', // 0 burger
    'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=500', // 1 bk
    'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=500', // 2 kfc
    'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500', // 3 chicken
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500', // 4 pizza
    'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500', // 5 pizza2
    'https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=500', // 6 pizza3
    'https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=500', // 7 chicken2
    'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500', // 8 kofte
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500', // 9 simit
    'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500', // 10 starbucks
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500', // 11 coffee
    'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500', // 12 coffee2
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500', // 13 restaurant
    'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=500', // 14 smash
  ];

  static const Map<String, String> _cuisineImgUrl = {
    'Pizza'            : 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
    'Burger'           : 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    'Döner'            : 'assets/food/doner.jpg',
    'Tavuk'            : 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=500',
    'Pide & Lahmacun'  : 'assets/food/pide_lahmacun.jpg',
    'Et'               : 'assets/food/et.jpg',
    'Deniz Ürünleri'   : 'assets/food/deniz_urunleri.jpg',
    'Vegan & Vejetaryen': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
    'Kahvaltı'         : 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500',
    'Sokak Lezzetleri' : 'assets/food/kokorec.jpg',
    'Mantı & Makarna'  : 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=500',
    'Kahve & İçecek'   : 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500',
    'Pastane & Fırın'  : 'assets/food/pastane_firin.jpg',
    'Aperatif'         : 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=500',
    'Ev Yemekleri'     : 'assets/food/ev_yemekleri.jpg',
    'Çiğ Köfte'        : 'assets/food/cig_kofte.jpg',
    'Dünya Mutfakları' : 'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=500',
    'Tatlı'            : 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
  };

  // ─── MAHALLE / SOKAK İSİMLERİ ────────────────────────────────
  static const List<String> _streets = [
    'Atatürk Cd.','İnönü Cd.','Cumhuriyet Cd.','Fatih Cd.','Yıldız Cd.',
    'Bahçelievler Sk.','Çiçek Sk.','Gül Sk.','Lale Sk.','Karanfil Sk.',
    'Bağlar Mah.','Merkez Mah.','Yeni Mah.','Eski Mah.','Çarşı Mah.',
    'Kızılay Cd.','Sakarya Cd.','Millet Cd.','Vatan Cd.','Barış Sk.',
  ];


  // ─── VARYANT MENÜLER ───────────────────────────────────────
  static final Map<String, List<List<MenuCategory>>> _menuVariants = {
    'burger': [
      // Varyant A - Klasik Smash
      [
        MenuCategory(id:'bma1', name:'🍔 İmza Burgerler', items:[
          _mi('bba1','Classic Smash',370.00,'180gr dana, cheddar, özel sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true,opts:[MenuOption(id:'bo1',name:'Ekstra Cheddar',price:25),MenuOption(id:'bo2',name:'Bacon',price:40),MenuOption(id:'bo3',name:'Soğan',isRemovable:true)]),
          _mi('bba2','Double Smash',470.00,'Çift et, çift peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bba3','Crispy Chicken',350.00,'Çıtır tavuk, coleslaw, turşu','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
          _mi('bba4','Veggie Deluxe',350.00,'Sebze köftesi, avokado, feta','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bba5','Mushroom Swiss',390.00,'Dana, mantar, swiss peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bba6','Bacon BBQ',420.00,'Dana, bacon, BBQ sos, soğan halkası','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bba7','Spicy Jalapeno',380.00,'Dana, jalapeño, acı sos, pepper jack','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',spicy:true),
          _mi('bba8','Truffle Smash',500.00,'Dana, trüf sosu, karamelize soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        ]),
        MenuCategory(id:'bma2', name:'🍟 Yanlar', items:[
          _mi('bsa1','Patates Küçük',90.00,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsa2','Patates Büyük',120.00,'Büyük boy','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsa3','Onion Rings 8',130.00,'8 adet + sos','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsa4','Mozza Sticks 6',140.00,'6 adet + marinara','https://images.unsplash.com/photo-1548340748-6af3e4b89898?w=400',veg:true),
          _mi('bsa5','Acı Kanatlar 6',150.00,'Baharatlı kanat + dip','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',spicy:true),
          _mi('bsa6','Sweet Potato Fries',120.00,'Tatlı patates + chipotle mayo','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        ]),
        MenuCategory(id:'bma3', name:'🧁 Tatlılar', items:[
          _mi('btd1','Çikolatalı Shake',180.00,'Milkshake, 400ml','https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400',veg:true),
          _mi('btd2','Cheesecake',220.00,'NY style cheesecake','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
          _mi('btd3','Brownie',190.00,'Sıcak brownie + vanilya dondurma','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        ]),
        _drinksEx('bda'),
      ],
      // Varyant B - Korean & Gourmet
      [
        MenuCategory(id:'bmb1', name:'🌶️ Signature Burgerler', items:[
          _mi('bbb1','Korean BBQ',450.00,'Bulgogi sos, kimchi mayo, çıtır soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',spicy:true,pop:true),
          _mi('bbb2','Truffle Deluxe',520.00,'Siyah trüf sosu, gruyère, arugula','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbb3','Nashville Hot',420.00,'Nashville acı tavuk, pickle, brioche','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',spicy:true),
          _mi('bbb4','Smoked Brisket',550.00,'Tütsülenmiş brisket, coleslaw, pickles','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbb5','Plant-Based Smash',360.00,'Bitki bazlı et, vegan sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bbb6','Breakfast Smash',380.00,'Dana, yumurta, cheddar, sosis','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbb7','Blue Cheese Burger',460.00,'Angus, gorgonzola, ceviz, roka','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbb8','Lamb Burger',510.00,'Kuzu kıyma, harissa, tzatziki','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        ]),
        MenuCategory(id:'bmb2', name:'🍟 Smash Yanlar', items:[
          _mi('bsb1','Skin-on Fries',100.00,'Kabuklu patates, tuz, karabiber','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsb2','Smash Nuggets 8',150.00,'8 adet et top + dip sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bsb3','Halloumi Fries',140.00,'Kızarmış hellim + nane sosu','https://images.unsplash.com/photo-1548340748-6af3e4b89898?w=400',veg:true),
          _mi('bsb4','Truffle Mac & Cheese',180.00,'Kremalı makarna, trüf, parmesan','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',veg:true),
          _mi('bsb5','Wedge Salata',130.00,'Iceberg, blue cheese, cherry domates','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        ]),
        _drinksEx('bdb'),
      ],
      // Varyant C - Wagyu & Premium
      [
        MenuCategory(id:'bmc1', name:'👑 Premium Burgerler', items:[
          _mi('bbc1','Wagyu Burger',600.00,'A5 wagyu, trüf mayo, altın soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbc2','Angus Classic',480.00,'Black Angus, karamelize soğan, brie','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbc3','Surf & Turf',640.00,'Dana + karides, garlic butter','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbc4','Portobello Gourmet',380.00,'Portobello mantar, feta, pesto','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bbc5','Foie Gras',650.00,'Angus, foie gras, sautéed elma','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbc6','Smash Royale',540.00,'Triple smash, özel tatlı sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbc7','Vegan Royale',360.00,'Jackfruit, smoky mayo, crispy onion','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bbc8','Signature Stack',620.00,'Çift wagyu, triple peynir, bacon','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        ]),
        MenuCategory(id:'bmc2', name:'🥂 Premium Yanlar', items:[
          _mi('bsc1','Gourmet Fries',130.00,'Parmesan, trüf yağı, maydanoz','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsc2','Bone Marrow',220.00,'Fırın kemik iliği, kızarmış ekmek','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('bsc3','Tuna Tartar',250.00,'Taze ton balığı, avokado, çıtır ekmek','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('bsc4','Lobster Bisque',200.00,'Istakoz çorbası, krema, kruvasan','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        ]),
        _drinksEx('bdc'),
      ],
    ],
    'pizza': [
      [
        MenuCategory(id:'pma1', name:'🍕 Klasik Pizzalar', items:[
          _mi('pba1','Margarita',300.00,'Domates, mozzarella, fesleğen','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true,veg:true,opts:[MenuOption(id:'po1',name:'Ekstra Peynir',price:30),MenuOption(id:'po2',name:'İnce Hamur'),MenuOption(id:'po3',name:'Kalın Hamur')]),
          _mi('pba2','Karışık',390.00,'Sucuk, mantar, biber, zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
          _mi('pba3','BBQ Tavuk',370.00,'BBQ sos, tavuk, soğan, taze biber','https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400'),
          _mi('pba4','4 Peynirli',420.00,'Mozza, cheddar, parmesan, gouda','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pba5','Pepperoni',380.00,'Bol pepperoni, mozzarella','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
          _mi('pba6','Vegetariana',340.00,'Renkli biber, mantar, zeytin, mısır','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pba7','Prosciutto',450.00,'Prosciutto, roka, parmesan','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('pba8','Diavola',360.00,'Acılı salam, mozzarella','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
        ]),
        MenuCategory(id:'pma2', name:'🥗 Başlangıçlar', items:[
          _mi('psa1','Garlic Bread',100.00,'Sarımsaklı ekmek','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('psa2','Sezar Salata',150.00,'Romain, crouton, parmesan','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('psa3','Mozzarella Sticks 6',140.00,'Kızarmış mozza + marinara','https://images.unsplash.com/photo-1548340748-6af3e4b89898?w=400',veg:true),
          _mi('psa4','Bruschetta 3',120.00,'Domates, fesleğen, sarımsak','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
        ]),
        _drinksEx('pda'),
      ],
      [
        MenuCategory(id:'pmb1', name:'🍕 Napoliten Pizzalar', items:[
          _mi('pbb1','Margherita DOC',320.00,'San Marzano domates, bufala mozza','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true,veg:true),
          _mi('pbb2','Marinara',300.00,'Domates, sarımsak, origano','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pbb3','Napoli',360.00,'Ançuez, kapari, siyah zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
          _mi('pbb4','Quattro Stagioni',420.00,'Mantar, jambon, enginar, zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
          _mi('pbb5','Bianca Funghi',380.00,'Beyaz sos, karışık mantar, trüf','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true,pop:true),
          _mi('pbb6','Salame Piccante',400.00,'Acı salam, nduja','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
          _mi('pbb7','Prosciutto Rucola',450.00,'San Daniele, roka, grana padano','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('pbb8','Puttanesca',370.00,'Domates, ançuez, siyah zeytin, kapari','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',spicy:true),
        ]),
        MenuCategory(id:'pmb2', name:'🥙 Calzone & Focaccia', items:[
          _mi('psb1','Calzone Klasik',350.00,'Kapalı pizza, ricotta, salam, ıspanak','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('psb2','Focaccia Rosmarino',150.00,'Biberiye, deniz tuzu','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('psb3','Stromboli',330.00,'Sarılı pizza, salam, biber, peynir','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
        ]),
        _drinksEx('pdb'),
      ],
      [
        MenuCategory(id:'pmc1', name:'🍕 Türk Fusion Pizzalar', items:[
          _mi('pbc1','Sucuklu Kaşar',360.00,'Türk sucuğu, kaşar, domates','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true),
          _mi('pbc2','Lahmacun Pizza',330.00,'İnce kıymalı lahmacun pizza','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',spicy:true),
          _mi('pbc3','Döner Pizza',400.00,'Döner et, domates sos, soğan, biber','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
          _mi('pbc4','Pastırmalı',430.00,'Türk pastırması, yumurta, kaşar','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('pbc5','Ispanaklı Beyaz',350.00,'Beyaz sos, ıspanak, feta','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pbc6','Karadeniz Fındıklı',370.00,'Fındık ezmesi, feta, bal, arugula','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pbc7','Acılı Bonfile',460.00,'Bonfile dilimi, acı biber sosu, roka','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
          _mi('pbc8','Kuzulu Özel',490.00,'Kuzu döner, sumak soğanı, nar ekşisi','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true),
        ]),
        MenuCategory(id:'pmc2', name:'🥗 Mezeler', items:[
          _mi('psc1','Domates Çorbası',100.00,'Taze domates, krema, fesleğen','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
          _mi('psc2','Humus & Pita',120.00,'Ev yapımı humus, taze pita','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        ]),
        _drinksEx('pdc'),
      ],
    ],
    'doner': [
      [
        MenuCategory(id:'doa1', name:'🌯 Dürüm & Döner', items:[
          _mi('doa1','Et Dürüm',450.00,'Dana döner, lavaş, sebze, sos','assets/menu/doner.png',pop:true),
          _mi('doa2','Tavuk Dürüm',250.00,'Tavuk döner, lavaş, yoğurt sos','assets/menu/doner.png'),
          _mi('doa3','Karışık Dürüm',480.00,'Et+tavuk, közlenmiş sebze','assets/menu/doner.png',pop:true),
          _mi('doa4','İskender Dürüm',520.00,'İskender sos, tereyağı, yoğurt','assets/menu/doner.png',pop:true),
          _mi('doa5','Et Porsiyon',500.00,'200gr döner + pilav + salata','assets/food/doner.jpg'),
          _mi('doa6','Tavuk Porsiyon',270.00,'200gr tavuk döner + pilav','assets/food/doner.jpg'),
          _mi('doa7','Yarım Ekmek Döner',420.00,'Yarım ekmek, et döner','assets/food/doner.jpg'),
          _mi('doa8','Döner Tabak',550.00,'Et döner, bulgur, közlenmiş domates','assets/food/doner.jpg'),
        ]),
        MenuCategory(id:'doa2', name:'🥗 Mezeler & Çorbalar', items:[
          _mi('dos1','Mercimek Çorbası',90.00,'Ev yapımı, sıcak','assets/menu/mercimek_corba.png',veg:true),
          _mi('dos2','Cacık',80.00,'Yoğurt, salatalık, nane','https://images.unsplash.com/photo-1460306855393-a4056d5f740b?w=400',veg:true),
          _mi('dos3','Közlenmiş Patlıcan',100.00,'Sarımsaklı yoğurt, nar ekşisi','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        ]),
        _drinksEx('doda'),
      ],
      [
        MenuCategory(id:'dob1', name:'🥙 Kebap Çeşitleri', items:[
          _mi('dob1','Adana Kebap',420.00,'Acılı kıyma, közlenmiş biber, lavaş','assets/food/doner.jpg',spicy:true,pop:true),
          _mi('dob2','Urfa Kebap',400.00,'Tatlı kıyma, soğan, domates','assets/food/doner.jpg'),
          _mi('dob3','Tavuk Şiş',280.00,'Marine edilmiş tavuk şiş','assets/food/doner.jpg',pop:true),
          _mi('dob4','Kuzu Şiş',500.00,'Közlenmiş kuzu parça','assets/food/doner.jpg'),
          _mi('dob5','Karışık Izgara',580.00,'Adana+urfa+şiş tabağı','assets/food/doner.jpg',pop:true),
          _mi('dob6','Patlıcanlı Kebap',450.00,'Döner + közlenmiş patlıcan','assets/food/doner.jpg'),
        ]),
        MenuCategory(id:'dob2', name:'🍚 Pilav & Ekstra', items:[
          _mi('dob7','Bulgur Pilavı',90.00,'Nohutlu bulgur pilavı','assets/menu/pilav.png',veg:true),
          _mi('dob8','Pirinç Pilav',80.00,'Tereyağlı pirinç','assets/menu/pilav.png',veg:true),
          _mi('dob9','Lavaş Ekmek',40.00,'Taze lavaş','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
        ]),
        _drinksEx('dodb'),
      ],
      [
        MenuCategory(id:'doc1', name:'🌮 Wrap & Sandviç', items:[
          _mi('doc1','Tavuk Wrap',260.00,'Izgara tavuk, mısır, salata, sezar','assets/food/doner.jpg',pop:true),
          _mi('doc2','Et Wrap',460.00,'Döner et, domates, turşu, sos','assets/food/doner.jpg'),
          _mi('doc3','Falafel Wrap',220.00,'Vegan falafel, humus, sebze','assets/food/doner.jpg',veg:true),
          _mi('doc4','Kokoreç Sandviç',250.00,'Klasik kokoreç, ekmek','assets/food/kokorec.jpg',spicy:true),
          _mi('doc5','Midye Tava Sandviç',200.00,'Taze midye tava, limon','assets/food/doner.jpg'),
          _mi('doc6','Balık Ekmek',280.00,'Izgara balık, soğan, biber','assets/food/doner.jpg'),
        ]),
        _drinksEx('dodc'),
      ],
    ],
    'tavuk': [
      [
        MenuCategory(id:'tva1', name:'🍗 Çıtır Tavuk', items:[
          _mi('tva1','Crispy Tavuk Menu',320.00,'3 parça çıtır + patates + içecek','assets/food/tavuk_dunyasi.jpg',pop:true),
          _mi('tva2','Tavuk Burger',280.00,'Çıtır tavuk, coleslaw, turşu','assets/food/tavuk_dunyasi.jpg',pop:true),
          _mi('tva3','Spicy Tavuk',300.00,'Acılı baharat, sriracha mayo','assets/food/tavuk_dunyasi.jpg',spicy:true),
          _mi('tva4','Kanat 6 Parça',250.00,'BBQ veya buffalo sos','assets/food/tavuk_dunyasi.jpg',pop:true),
          _mi('tva5','Nugget 9',260.00,'9 adet nugget + sos','assets/food/tavuk_dunyasi.jpg'),
          _mi('tva6','Tender 5',270.00,'5 adet fileto tender','assets/food/tavuk_dunyasi.jpg'),
          _mi('tva7','Jumbo Kanat 12',380.00,'12 adet jumbo kanat','assets/food/tavuk_dunyasi.jpg',pop:true),
        ]),
        MenuCategory(id:'tva2', name:'🍟 Yanlar', items:[
          _mi('tvs1','Patates Küçük',90.00,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('tvs2','Patates Büyük',120.00,'Büyük boy','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('tvs3','Coleslaw',90.00,'Lahana salatası','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        ]),
        _drinksEx('tvda'),
      ],
      [
        MenuCategory(id:'tvb1', name:'🔥 Izgara Tavuk', items:[
          _mi('tvb1','Fırın Tavuk Yarım',350.00,'Yarım közlenmiş piliç + pilav','assets/food/tavuk_dunyasi.jpg',pop:true),
          _mi('tvb2','Tavuk Şiş',290.00,'4 şiş, lavaş, acı sos','assets/food/tavuk_dunyasi.jpg'),
          _mi('tvb3','Tavuk Döner Tabak',270.00,'Döner, pilav, salata','assets/food/tavuk_dunyasi.jpg'),
          _mi('tvb4','Tavuk Sote',310.00,'Mantar, biber, krema sosu','assets/food/tavuk_dunyasi.jpg',pop:true),
          _mi('tvb5','Soslu Tavuk Parça',260.00,'3 parça, sos seçimi','assets/food/tavuk_dunyasi.jpg'),
        ]),
        _drinksEx('tvdb'),
      ],
    ],
    'pide': [
      [
        MenuCategory(id:'pia1', name:'🫓 Pide Çeşitleri', items:[
          _mi('pia1','Kıymalı Pide',200.00,'İnce kıyma, domates, biber','assets/food/pide_lahmacun.jpg',pop:true),
          _mi('pia2','Kaşarlı Pide',180.00,'Bol kaşar peyniri','assets/food/pide_lahmacun.jpg',veg:true),
          _mi('pia3','Kuşbaşılı Pide',280.00,'Dana kuşbaşı, biber, domates','assets/food/pide_lahmacun.jpg',pop:true),
          _mi('pia4','Karışık Pide',240.00,'Kıyma + kaşar + sucuk','assets/food/pide_lahmacun.jpg'),
          _mi('pia5','Sucuklu Yumurtalı',220.00,'Sucuk, yumurta, kaşar','assets/food/pide_lahmacun.jpg'),
          _mi('pia6','Ispanaklı Peynirli',190.00,'Ispanak, beyaz peynir, yumurta','assets/food/pide_lahmacun.jpg',veg:true),
        ]),
        MenuCategory(id:'pia2', name:'🌮 Lahmacun', items:[
          _mi('pil1','Lahmacun 3 Adet',150.00,'İnce kıymalı klasik','assets/food/pide_lahmacun.jpg',pop:true,spicy:true),
          _mi('pil2','Acısız Lahmacun 3',150.00,'Tatlı biber, az baharatlı','assets/food/pide_lahmacun.jpg'),
          _mi('pil3','Simit Sarayı Lahmacun',170.00,'Extra kıyma + nar ekşisi','assets/food/pide_lahmacun.jpg',spicy:true),
        ]),
        _drinksEx('pida'),
      ],
      [
        MenuCategory(id:'pib1', name:'🫓 Karadeniz Pidesi', items:[
          _mi('pib1','Karadeniz Kaşar Pide',200.00,'Sürme tereyağı, taze kaşar','assets/food/pide_lahmacun.jpg',pop:true,veg:true),
          _mi('pib2','Hamsi Pidesi',250.00,'Taze hamsi, mısır, karabiber','assets/food/pide_lahmacun.jpg'),
          _mi('pib3','Tereyağlı Yumurtalı',180.00,'Sürme tereyağı, köy yumurtası','assets/food/pide_lahmacun.jpg',veg:true),
          _mi('pib4','Kıymalı Karadeniz',220.00,'Kıyma, soğan, Karadeniz baharatı','assets/food/pide_lahmacun.jpg'),
        ]),
        _drinksEx('pidb'),
      ],
    ],
    'et': [
      [
        MenuCategory(id:'eta1', name:'🥩 Izgara Et Lezzetleri', items:[
          _mi('eta1','Antrikot 250gr',600.00,'Wagyu/Angus, garnitür + salata','assets/food/et.jpg',pop:true),
          _mi('eta2','Ribeye 300gr',680.00,'Mermer yağlı ribeye, sote mantar','assets/food/et.jpg',pop:true),
          _mi('eta3','Dana Köfte 3',380.00,'El yapımı köfte, közlenmiş sebze','assets/food/et.jpg'),
          _mi('eta4','Kuzu Pirzola 4',650.00,'Fırın kuzu, biberiye, sarımsak','assets/food/et.jpg'),
          _mi('eta5','Bonfile 200gr',560.00,'Tenderloin, trüf sosu','assets/food/et.jpg',pop:true),
          _mi('eta6','Kuzu Tandır',480.00,'Fırın kuzu tandır + pilav','assets/food/et.jpg'),
        ]),
        MenuCategory(id:'eta2', name:'🥗 Garnitürler', items:[
          _mi('ets1','Sote Mantar',100.00,'Tereyağlı sote mantar','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
          _mi('ets2','Patates Rösti',110.00,'Fırın patates rösti','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('ets3','Izgara Sebze',120.00,'Kabak, biber, patlıcan ızgara','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
        ]),
        _drinksEx('etda'),
      ],
    ],
    'deniz': [
      [
        MenuCategory(id:'dena1', name:'🐟 Balık Çeşitleri', items:[
          _mi('dena1','Izgara Levrek',480.00,'Taze levrek, limon, roka','assets/food/deniz_urunleri.jpg',pop:true),
          _mi('dena2','Izgara Çipura',460.00,'Akdeniz çipura, zeytinyağı','assets/food/deniz_urunleri.jpg'),
          _mi('dena3','Somon Izgara',540.00,'Norveç somon, dereotu sos','assets/food/deniz_urunleri.jpg',pop:true),
          _mi('dena4','Tava Hamsi',360.00,'Karadeniz hamsisi, mısır unu','assets/food/deniz_urunleri.jpg'),
          _mi('dena5','Kalamar Tava',400.00,'Çıtır kalamar, tartar sos','assets/food/deniz_urunleri.jpg'),
          _mi('dena6','Midye Tava 10',350.00,'10 adet midye tava, limon','assets/food/deniz_urunleri.jpg'),
          _mi('dena7','Ahtapot Izgara',500.00,'Közlenmiş ahtapot, zeytinyağı','assets/food/deniz_urunleri.jpg',pop:true),
        ]),
        MenuCategory(id:'dena2', name:'🦐 Deniz Ürünleri', items:[
          _mi('dens1','Karides Sote',420.00,'Tereyağı, sarımsak, limon','assets/food/deniz_urunleri.jpg',pop:true),
          _mi('dens2','Paella',580.00,'İspanyol pirinç, deniz ürünleri','assets/food/deniz_urunleri.jpg'),
          _mi('dens3','Balık Çorbası',150.00,'Günlük taze balık çorbası','assets/food/deniz_urunleri.jpg'),
        ]),
        _drinksEx('denrda'),
      ],
    ],
    'vegan': [
      [
        MenuCategory(id:'vga1', name:'🌱 Ana Yemekler', items:[
          _mi('vga1','Buddha Bowl',260.00,'Quinoa, avokado, edamame, nar','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
          _mi('vga2','Falafel Tabak',240.00,'6 adet falafel, humus, tabbule','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
          _mi('vga3','Jackfruit Burger',270.00,'Vegan et alternatifi, smash bun','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true,pop:true),
          _mi('vga4','Vegan Pizza',290.00,'Cashew mozzarella, sebze bol','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('vga5','Sebzeli Wrap',220.00,'Izgara sebze, humus, roka','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
          _mi('vga6','Mercimek Köftesi',200.00,'Kırmızı mercimek, bulgur','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        ]),
        MenuCategory(id:'vga2', name:'🥣 Salatalar & Kaseler', items:[
          _mi('vgs1','Yeşil Salata',200.00,'Miks yeşillik, nar, ceviz, balsamik','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
          _mi('vgs2','Ton Balığı Salatası',240.00,'Limon sos, kapari, zeytin','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400'),
          _mi('vgs3','Acai Bowl',260.00,'Açai, granola, taze meyve, chia','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
        ]),
        _drinksEx('vgda'),
      ],
    ],
    'kahvalti': [
      [
        MenuCategory(id:'kaa1', name:'☀️ Serpme Kahvaltı', items:[
          _mi('kaa1','Serpme 1 Kişi',129.90,'15 çeşit: peynir, zeytin, bal, reçel...','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('kaa2','Serpme 2 Kişi',239.90,'25 çeşit kahvaltılık + çay','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('kaa3','Menemen',74.90,'Domates, biber, yumurta, sac','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
          _mi('kaa4','Sucuklu Yumurta',79.90,'Türk sucuğu, sürme tereyağı','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('kaa5','Çılbır',84.90,'Poşe yumurta, yoğurt, tereyağı, pul biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('kaa6','Avokado Toast',89.90,'Somon + avokado + poşe yumurta','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('kaa7','Waffle Tatlı',84.90,'Çikolata, muz, dondurma, nut.','https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',veg:true),
        ]),
        _drinksEx('kaada'),
      ],
      [
        MenuCategory(id:'kab1', name:'☕ Brunch Menüleri', items:[
          _mi('kab1','Eggs Benedict',99.90,'Jambon, hollandaise, İngiliz muffin','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('kab2','Full Kahvaltı',129.90,'Bacon, yumurta, sosis, fasulye, toast','assets/menu/kahvalti.png'),
          _mi('kab3','Granola Bowl',79.90,'Ev granolası, yoğurt, meyveler','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
          _mi('kab4','French Toast',89.90,'Brioche, akçaağaç, taze meyve','https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',veg:true),
          _mi('kab5','Pancakes 3',84.90,'Üçlü pancake, butter, syrup','https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',veg:true,pop:true),
        ]),
        _drinksEx('kadb'),
      ],
    ],
    'sokak': [
      [
        MenuCategory(id:'ska1', name:'🌽 Sokak Lezzetleri', items:[
          _mi('ska1','Kumpir Büyük',300.00,'Patates, 5 malzeme, sos','assets/food/kumpir.jpg',pop:true),
          _mi('ska2','Kokoreç ½ Ekmek',250.00,'Bağırsak, baharatlar, ekmek','assets/food/kokorec.jpg',spicy:true,pop:true),
          _mi('ska3','Midye Dolma 10',200.00,'10 adet, limon, acı sos','assets/food/kokorec.jpg'),
          _mi('ska4','Simit Sandviç',120.00,'Kaşar + domates + zeytin','assets/food/kokorec.jpg',veg:true),
          _mi('ska5','Balık Ekmek',280.00,'Boğaz balığı, soğan, maydanoz','assets/food/kokorec.jpg'),
          _mi('ska6','Islak Burger',200.00,'Domates soslu ıslak burger','assets/food/kokorec.jpg',pop:true),
          _mi('ska7','Mısır (Büyük)',100.00,'Fırın mısır, tereyağı','assets/food/kokorec.jpg',veg:true),
          _mi('ska8','Tost Karışık',150.00,'Kaşar + sucuk + domates','assets/food/kokorec.jpg'),
        ]),
        _drinksEx('skda'),
      ],
      [
        MenuCategory(id:'skb1', name:'🥙 Simit & Açık Büfe', items:[
          _mi('skb1','Pide Tost',130.00,'Pide ekmeğinde karışık tost','assets/food/kokorec.jpg'),
          _mi('skb2','Gözleme Peynirli',150.00,'El açması, taze peynir','assets/food/kokorec.jpg',veg:true,pop:true),
          _mi('skb3','Gözleme Kıymalı',170.00,'El açması, kıyma, biber','assets/food/kokorec.jpg',spicy:true),
          _mi('skb4','Börek Peynirli',140.00,'Yufka, beyaz peynir, bol ot','assets/food/kokorec.jpg',veg:true,pop:true),
          _mi('skb5','Çiğ Köfte Dürüm',120.00,'Acılı/acısız, nar ekşisi','assets/menu/doner.png',veg:true),
        ]),
        _drinksEx('skdb'),
      ],
    ],
    'manti': [
      [
        MenuCategory(id:'mna1', name:'🥟 Mantı Çeşitleri', items:[
          _mi('mna1','Kayseri Mantısı',280.00,'El yapımı, yoğurt, kırmızı tereyağı','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',pop:true),
          _mi('mna2','Sulu Mantı',260.00,'Et suyu, yoğurt, pul biber','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',pop:true),
          _mi('mna3','Kızartma Mantı',290.00,'Kızartılmış, üzerine yoğurt','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400'),
          _mi('mna4','Vegan Mantı',250.00,'Sebze iç harçlı, cashew yoğurt','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',veg:true),
        ]),
        MenuCategory(id:'mna2', name:'🍝 Makarna', items:[
          _mi('mns1','Spaghetti Bolognese',280.00,'Dana kıyma, domates sos, parmesan','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400'),
          _mi('mns2','Carbonara',300.00,'Guanciale, yumurta sarısı, pecorino','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',pop:true),
          _mi('mns3','Penne Arrabbiata',260.00,'Acı domates sos, sarımsak','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',veg:true,spicy:true),
          _mi('mns4','Fettuccine Alfredo',280.00,'Kremalı, parmesan, karabiber','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',veg:true),
          _mi('mns5','Türk Makarna',240.00,'Kıymalı, domates sos, kaşar','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',pop:true),
        ]),
        _drinksEx('mnda'),
      ],
    ],
    'kahve': [
      [
        MenuCategory(id:'kfa1', name:'☕ Sıcak İçecekler', items:[
          _mi('kfa1','Espresso',150.00,'Double shot, koyu kavrum','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa2','Flat White',180.00,'Ristretto bazlı, ince süt köpüğü','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true,pop:true),
          _mi('kfa3','Latte',185.00,'Espresso + bol süt','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa4','Cappuccino',180.00,'Espresso + sütlü köpük','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa5','Matcha Latte',220.00,'Japon matcha, oat milk','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true,pop:true),
          _mi('kfa6','Türk Kahvesi',160.00,'Geleneksel, lokum ile','assets/menu/kahve.png',veg:true),
          _mi('kfa7','Sıcak Çikolata',200.00,'Yoğun kakao, kremalı','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        ]),
        MenuCategory(id:'kfa2', name:'🧊 Soğuk İçecekler', items:[
          _mi('kfs1','Cold Brew',200.00,'12 saat demleme, soğuk servis','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
          _mi('kfs2','Iced Latte',190.00,'Espresso, buz, soğuk süt','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
          _mi('kfs3','Frappuccino',220.00,'Blended, çikolata/karamel','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
          _mi('kfs4','Smoothie Mango',210.00,'Mango, portakal, zencefil','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        ]),
        MenuCategory(id:'kfa3', name:'🥐 Atıştırmalık', items:[
          _mi('kfp1','Kruvasan',160.00,'Tereyağlı, içi boş veya dolgulu','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('kfp2','Avokado Toast',220.00,'Ekşi maya, avokado, za''atar','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true,pop:true),
          _mi('kfp3','Tiramisu',200.00,'Mascarpone, espresso, kakao','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
          _mi('kfp4','Cheesecake',210.00,'NY style, çilek sosu','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        ]),
      ],
    ],
  
  };

  static List<MenuCategory> getMenuForRestaurant(String restaurantId, String cuisine) {
    final key = _cuisineMenuKey[cuisine] ?? 'burger';
    int h = 0;
    for (int i = 0; i < restaurantId.length; i++) {
      h = (h * 31 + restaurantId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final variants = _menuVariants[key];
    if (variants != null && variants.isNotEmpty) {
      return variants[h % variants.length];
    }
    return _menus[key] ?? _menus['burger']!;
  }

  // Restoran adına göre spesifik menü seç
  static List<MenuCategory> getMenuForRestaurantByName(String restaurantId, String cuisine, String restaurantName) {
    final nameLower = restaurantName.toLowerCase();

    // ── Zincir restoran menüleri ────────────────────────────
    if (nameLower.contains('mcdonald') || nameLower.contains('mc donald')) return _menus['mcdonalds']!;
    if (nameLower.contains('burger king') || nameLower.contains('burgerking')) return _menus['burgerking']!;
    if (nameLower.contains('kfc') || nameLower.contains('kentucky')) return _menus['kfc']!;
    if (nameLower.contains('popeyes') || nameLower.contains("popeye's")) return _menus['popeyes']!;
    if (nameLower.contains("domino's") || nameLower.contains('dominos') || (nameLower.contains('domino') && nameLower.contains('pizza'))) return _menus['dominos']!;
    if (nameLower.contains('starbucks')) return _menus['starbucks']!;
    if (nameLower.contains('simit sarayı') || nameLower.contains('simit sarayi')) return _menus['simitSarayi']!;
    if (nameLower.contains('simitçi dünyası') || nameLower.contains('simitci dunyasi') || nameLower.contains('simitçi dünya')) return _menus['simitciDunyasi']!;
    if (nameLower.contains('komagene')) return _menus['komagene']!;
    if (nameLower.contains('baydöner') || nameLower.contains('baydoner')) return _menus['baydoner']!;
    if (nameLower.contains('tavuk dünyası') || nameLower.contains('tavuk dunyasi')) return _menus['tavukdunyasi']!;
    if (nameLower.contains('köfteci yusuf') || nameLower.contains('kofteci yusuf')) return _menus['kofteciyusuf']!;
    if (nameLower.contains('subway')) return _menus['subway']!;
    if (nameLower.contains('aspava')) return _menus['aspava']!;
    if (nameLower.contains('bülent börekçilik') || nameLower.contains('bulentborekci') || nameLower.contains('bülent börek')) return _menus['bulentborekci']!;

    // ── Tür bazlı özel menüler ───────────────────────────────
    if (nameLower.contains('kumpir') || nameLower.contains('kumpirci')) return _menus['kumpir']!;
    if (nameLower.contains('çiğ köfte') || nameLower.contains('çiğköfte') || nameLower.contains('cigkofte') || nameLower.contains('çiğköfteci') || nameLower.contains('cigkofteci')) return _menus['cigkofte']!;
    if (nameLower.contains('kokoreç') || nameLower.contains('kokorec')) return _menus['kokoreç'] ?? _menus['sokak']!;
    if (nameLower.contains('tantuni')) return _menus['tantuni'] ?? _menus['doner']!;
    if (nameLower.contains('lahmacun') && !nameLower.contains('pide')) return _menus['lahmacun'] ?? _menus['pide']!;
    if (nameLower.contains('sushi') || nameLower.contains('suşi') || nameLower.contains('japon') || nameLower.contains('ramen')) return _menus['dunya']!;
    if (nameLower.contains('döner') || nameLower.contains('iskender')) return _menus['doner']!;
    if (nameLower.contains('steakhouse') || nameLower.contains('steak')) return _menus['steak'] ?? _menus['et']!;
    if (nameLower.contains('köfteci') || (nameLower.contains('köfte') && !nameLower.contains('pizza'))) return _menus['kofte'] ?? _menus['et']!;
    if (nameLower.contains('mantı') || nameLower.contains('manti')) return _menus['manti']!;
    if (nameLower.contains('tatlı') || nameLower.contains('tatlic') || nameLower.contains('dondurma') || nameLower.contains('baklava') || nameLower.contains('pastacı')) return _menus['tatli']!;

    // Generic fallback by cuisine
    return getMenuForRestaurant(restaurantId, cuisine);
  }

  static MenuCategory _drinksEx(String pfx) => MenuCategory(
    id:'${pfx}_d', name:'🥤 İçecekler', items:[
      MenuItem(id:'${pfx}d1',name:'Ayran',description:'Soğuk ayran 300ml',price:55.00,imageUrl: 'assets/menu/icecekler.png'),
      MenuItem(id:'${pfx}d2',name:'Cola 330ml',description:'Gazlı içecek',price:65.00,imageUrl: 'assets/menu/icecekler.png'),
      MenuItem(id:'${pfx}d3',name:'Sprite 330ml',description:'Limonlu gazlı',price:65.00,imageUrl: 'assets/menu/icecekler.png'),
      MenuItem(id:'${pfx}d4',name:'Su 500ml',description:'Kaynak suyu',price:50.00,imageUrl: 'assets/menu/su.png'),
      MenuItem(id:'${pfx}d5',name:'Taze Portakal Suyu',description:'100% taze sıkılmış',price:90.00,imageUrl: 'assets/menu/portakal_suyu.png'),
      MenuItem(id:'${pfx}d6',name:'Limonata',description:'Taze limon, nane, soda',price:80.00,imageUrl: 'assets/menu/icecekler.png'),
      MenuItem(id:'${pfx}d7',name:'Ice Tea',description:'Şeftali veya limon',price:70.00,imageUrl: 'assets/menu/icecekler.png'),
    ],
  );

  // ─── MENÜLER ─────────────────────────────────────────────────
  static final Map<String, List<MenuCategory>> _menus = {
    // ── ÖZEL MENÜLER ───────────────────────────────────────────
    'kumpir': [
      MenuCategory(id:'kmp1', name:'🥔 Kumpir', items:[
        _mi('kmp1','Kumpir Küçük',250.00,'Fırın patates, tereyağı, kaşar, 3 malzeme seçimi','assets/food/kumpir.jpg',pop:true,
          opts:[MenuOption(id:'km1',name:'Mısır'),MenuOption(id:'km2',name:'Rus Salatası'),MenuOption(id:'km3',name:'Zeytin'),MenuOption(id:'km4',name:'Turşu'),MenuOption(id:'km5',name:'Sucuk',price:20),MenuOption(id:'km6',name:'Sosis',price:20)]),
        _mi('kmp2','Kumpir Büyük',300.00,'Fırın patates, tereyağı, kaşar, 5 malzeme seçimi','assets/food/kumpir.jpg',pop:true,
          opts:[MenuOption(id:'km7',name:'Mısır'),MenuOption(id:'km8',name:'Rus Salatası'),MenuOption(id:'km9',name:'Zeytin'),MenuOption(id:'km10',name:'Turşu'),MenuOption(id:'km11',name:'Sucuk',price:20),MenuOption(id:'km12',name:'Mantar',price:20),MenuOption(id:'km13',name:'Meksika Fasulyesi',price:20),MenuOption(id:'km14',name:'Sosis',price:20),MenuOption(id:'km15',name:'Ekşi Krema',price:15),MenuOption(id:'km16',name:'Jalapeno',price:15)]),
        _mi('kmp3','Kumpir XL',350.00,'Jumbo boy, tereyağı, kaşar, 7 malzeme + ekstra sos','assets/food/kumpir.jpg',
          opts:[MenuOption(id:'km17',name:'Mısır'),MenuOption(id:'km18',name:'Rus Salatası'),MenuOption(id:'km19',name:'Zeytin'),MenuOption(id:'km20',name:'Mantar',price:20),MenuOption(id:'km21',name:'Sucuk',price:20)]),
        _mi('kmp4','Vejetaryen Kumpir',280.00,'Tereyağı, kaşar, mısır, mantar, biber, zeytin','assets/food/kumpir.jpg',veg:true),
        _mi('kmp5','Kumpir Menü',320.00,'Büyük kumpir + ayran + turşu','assets/food/kumpir.jpg',pop:true),
      ]),
      MenuCategory(id:'kmp2', name:'🥗 Ekstra Malzemeler', items:[
        _mi('kms1','Sucuk',15.90,'Dilimlenmiş Türk sucuğu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('kms2','Sosis',15.90,'İnce sosis dilimleri','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('kms3','Mantar',12.90,'Sote mantar','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
        _mi('kms4','Meksika Fasulyesi',12.90,'Baharatlı fasulye','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        _mi('kms5','Ekstra Kaşar',15.90,'Bol erimiş kaşar','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
      ]),
      _drinksEx('kmpd'),
    ],
    'cigkofte': [
      MenuCategory(id:'cgk1', name:'🌿 Çiğ Köfte', items:[
        _mi('cgk1','Dürüm Acılı',120.00,'Çiğ köfte, nar ekşisi, limon, lavaş','assets/menu/doner.png',veg:true,pop:true,spicy:true),
        _mi('cgk2','Dürüm Acısız',110.00,'Çiğ köfte, limon, lavaş','assets/menu/doner.png',veg:true),
        _mi('cgk3','Tabak Orta',250.00,'200gr çiğ köfte, nar ekşisi, maydanoz','assets/food/cig_kofte.jpg',veg:true,pop:true),
        _mi('cgk4','Tabak Büyük',380.00,'350gr çiğ köfte + 2 dürüm','assets/food/cig_kofte.jpg',veg:true),
        _mi('cgk5','İkili Dürüm',220.00,'2 adet dürüm, acı/acısız seçimli','assets/menu/doner.png',veg:true,pop:true),
        _mi('cgk6','Üçlü Menü',300.00,'3 dürüm + şalgam + turşu','assets/food/cig_kofte.jpg',veg:true),
      ]),
      MenuCategory(id:'cgk2', name:'🥤 İçecekler & Ekstra', items:[
        _mi('cgks1','Şalgam Suyu',19.90,'Acılı/acısız','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('cgks2','Ayran',19.90,'Soğuk ayran','assets/menu/icecekler.png',veg:true),
        _mi('cgks3','Turşu',12.90,'Karışık turşu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        _mi('cgks4','Ekstra Acı Sos',5.90,'Pul biber sosu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true,spicy:true),
        _mi('cgks5','Portakal Suyu',24.90,'Taze sıkılmış','assets/menu/portakal_suyu.png',veg:true),
      ]),
    ],
    'kokoreç': [
      MenuCategory(id:'kkr1', name:'🥙 Kokoreç', items:[
        _mi('kkr1','Kokoreç ½ Ekmek',210.00,'Bağırsak, kekik, kimyon, pul biber','assets/food/kokorec.jpg',pop:true,spicy:true),
        _mi('kkr2','Kokoreç Tam Ekmek',290.00,'Tam ekmek, bol baharat','assets/food/kokorec.jpg',pop:true),
        _mi('kkr3','Kokoreç Tabak',330.00,'200gr, pilav veya patates ile','assets/food/kokorec.jpg'),
        _mi('kkr4','Kokoreç Pide',240.00,'Pide üzerinde, extra peynir','assets/food/kokorec.jpg'),
        _mi('kkr5','Midye Dolma 10 Adet',210.00,'Taze midye, pirinç harcı, limon','assets/food/kokorec.jpg'),
        _mi('kkr6','Islak Burger',220.00,'Özel sos, domates soslu','assets/food/kokorec.jpg',pop:true),
      ]),
      _drinksEx('kkrd'),
    ],
    'tantuni': [
      MenuCategory(id:'tnt1', name:'🌮 Tantuni', items:[
        _mi('tnt1','Tantuni Dürüm',250.00,'Dana et, soğan, domates, lavaş','assets/menu/doner.png',pop:true,spicy:true),
        _mi('tnt2','Tantuni Ekmek',220.00,'Francala ekmek, özel sos','assets/food/tantuni.jpg'),
        _mi('tnt3','Tantuni Tabak',310.00,'200gr et, pilav, salata','assets/food/tantuni.jpg'),
        _mi('tnt4','İkili Dürüm Menü',340.00,'2 dürüm + şalgam + turşu','assets/menu/doner.png',pop:true),
        _mi('tnt5','Tavuk Tantuni',230.00,'Tavuk göğsü, az yağlı, lavaş','assets/food/tantuni.jpg'),
      ]),
      _drinksEx('tntd'),
    ],
    'lahmacun': [
      MenuCategory(id:'lhm1', name:'🫓 Lahmacun', items:[
        _mi('lhm1','Lahmacun 3 Adet',180.00,'İnce kıyma, domates, taze biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true,spicy:true),
        _mi('lhm2','Lahmacun Acısız 3',180.00,'Tatlı biber versiyonu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('lhm3','Lahmacun + Ayran',230.00,'3 adet lahmacun + soğuk ayran','assets/menu/icecekler.png',pop:true),
        _mi('lhm4','Dürüm Lahmacun',160.00,'Dürüm şeklinde, limon, maydanoz','assets/menu/doner.png'),
        _mi('lhm5','Lahmacun Aile (8 Adet)',390.00,'8 adet, maydanoz, limon, nar ekşisi','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'lhm2', name:'🥗 Yanlar', items:[
        _mi('lhms1','Turşu',10.90,'Ev turşusu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        _mi('lhms2','Ayran',19.90,'Soğuk','assets/menu/icecekler.png',veg:true),
        _mi('lhms3','Cacık',22.90,'Yoğurt, salatalık, nane','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('lhms4','Salata',24.90,'Mevsim salatası','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
      ]),
    ],
    'kofte': [
      MenuCategory(id:'kft1', name:'🥩 Köfte Çeşitleri', items:[
        _mi('kft1','Izgara Köfte Tabak',129.90,'3 adet el yapımı köfte, pilav, salata','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('kft2','Köfte Ekmek',79.90,'2 adet köfte, domates, biber, ekmek','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',pop:true),
        _mi('kft3','Köfte Menü',149.90,'3 köfte + pilav + salata + ayran','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('kft4','Piyaz + Köfte',139.90,'2 köfte + piyaz + turşu','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('kft5','Çift Köfte Ekmek',99.90,'4 adet köfte, özel sos','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
        _mi('kft6','Çiğ Köfte Yanında',24.90,'Piyaz sosu ile','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
      ]),
      MenuCategory(id:'kft2', name:'🥗 Yanlar & İçecekler', items:[
        _mi('kfts1','Pilav',24.90,'Sade pilav','assets/menu/pilav.png',veg:true),
        _mi('kfts2','Piyaz',22.90,'Soğan, maydanoz, sirke','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('kfts3','Ayran',19.90,'Soğuk','assets/menu/icecekler.png',veg:true),
        _mi('kfts4','Turşu',10.90,'','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
      ]),
    ],
    'steak': [
      MenuCategory(id:'stk1', name:'🥩 Izgara Et', items:[
        _mi('stk1','Ribeye 300gr',379.90,'USDA Choice, Wagyu, sote mantar','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
        _mi('stk2','Antrikot 250gr',299.90,'Angus, sarımsaklı tereyağı','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
        _mi('stk3','Bonfile 200gr',329.90,'Tenderloin, trüf sosu','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
        _mi('stk4','T-Bone 400gr',449.90,'Dev T-bone, 2 kişilik','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
        _mi('stk5','Kuzu Pirzola 4 Adet',259.90,'Fırın biberiyeli kuzu','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
        _mi('stk6','Burger Steak',229.90,'180gr patty, garnitür','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
      ]),
      MenuCategory(id:'stk2', name:'🥗 Garnitürler', items:[
        _mi('stks1','Sote Mantar',55.90,'Tereyağlı mantar','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
        _mi('stks2','Patates Rösti',55.90,'','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('stks3','Izgara Kuşkonmaz',60.90,'Zeytinyağlı','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
        _mi('stks4','Yeşil Salata',45.90,'Roka, parmesan, balsamik','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
      ]),
      _drinksEx('stkd'),
    ],
    // ── ZİNCİR RESTORAN MENÜLER ──────────────────────────────
    'mcdonalds': [
      MenuCategory(id:'mcd1', name:'🍔 Burgerler', items:[
        _mi('mcd1','Big Mac',219.90,'İki köfte, özel sos, marul, peynir, soğan, turşu','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
        _mi('mcd2','Double Big Mac',269.90,'Dört köfte, özel Big Mac sosu','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
        _mi('mcd3','Quarter Pounder with Cheese',239.90,'%100 dana et, erimiş peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('mcd4','McCrispy',229.90,'Çıtır tavuk burger, marul, mayo','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
        _mi('mcd5','Spicy McCrispy',239.90,'Acılı çıtır tavuk burger','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',spicy:true),
        _mi('mcd6','McChicken',189.90,'Tavuk göğsü, mayo, yeşil salata','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
        _mi('mcd7','Cheeseburger',109.90,'Dana et, erimiş peynir, turşu, ketçap','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('mcd8','Double Cheeseburger',149.90,'İki köfte, çift peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
      ]),
      MenuCategory(id:'mcd2', name:'🍗 Atıştırmalıklar', items:[
        _mi('mcds1','Chicken McNuggets 9',149.90,'9 adet çıtır nugget + sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',pop:true),
        _mi('mcds2','McWings 6',129.90,'6 adet kanat, BBQ veya ranch','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400'),
        _mi('mcds3','Patates Kızartması Küçük',69.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('mcds4','Patates Kızartması Büyük',89.90,'Büyük boy patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
      ]),
      MenuCategory(id:'mcd3', name:'🍦 Tatlılar & McCafé', items:[
        _mi('mcdt1','McFlurry',89.90,'Vanilya dondurma, oreo veya karamel','https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400',veg:true,pop:true),
        _mi('mcdc1','Latte',89.90,'Espresso + sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('mcdc2','Cappuccino',89.90,'Köpüklü espresso','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('mcdc3','Americano',79.90,'Uzun espresso','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      _drinksEx('mcdd'),
    ],
    'burgerking': [
      MenuCategory(id:'bk1', name:'🍔 Burgerler', items:[
        _mi('bk1','Whopper',249.90,'Izgara köfte, domates, marul, turşu, soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
        _mi('bk2','Double Whopper',309.90,'Çift köfte, klasik Whopper içeriği','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
        _mi('bk3','Whopper Jr.',169.90,'Küçük boy Whopper','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bk4','Big King',219.90,'Çift köfte, Big Mac tarzı','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bk5','Klasik Gurme Tavuk',219.90,'Çıtır tavuk fileto, marul, mayo','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
        _mi('bk6','Spicy Gurme Tavuk',229.90,'Acılı çıtır tavuk burger','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',spicy:true),
        _mi('bk7','Köfteburger',159.90,'Türk usulü ızgara köfte','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
      ]),
      MenuCategory(id:'bk2', name:'🍟 Çıtır Lezzetler', items:[
        _mi('bks1','Patates',69.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('bks2','Tırtıklı Patates',79.90,'Tırtıklı dilim patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('bks3','Soğan Halkası',79.90,'Çıtır soğan halkası','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('bks4','King Nuggets 9',129.90,'9 adet nugget + sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400'),
      ]),
      MenuCategory(id:'bk3', name:'🍦 Tatlılar', items:[
        _mi('bkt1','Sundae',69.90,'Vanilya dondurma + sos','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('bkt2','Milkshake',89.90,'Çikolata / Çilek / Vanilyalı','https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400',veg:true),
        _mi('bkt3','Sufle',89.90,'Çikolatalı sufle','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('bkd'),
    ],
    'kfc': [
      MenuCategory(id:'kfc1', name:'🍗 Burgerler & Wrap', items:[
        _mi('kfc1','Zinger Burger',219.90,'Acılı çıtır tavuk burger, coleslaw','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true,spicy:true),
        _mi('kfc2','Double Zinger Burger',279.90,'Çift Zinger burger','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',spicy:true),
        _mi('kfc3','Cruncher Burger',199.90,'Çıtır tavuk, marul, mayo','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
        _mi('kfc4','Twister Wrap',199.90,'Izgara tavuk, sebze, yoğurt sos, lavaş','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
      ]),
      MenuCategory(id:'kfc2', name:'🍗 Soslu Tavuklar', items:[
        _mi('kfcs1','Hot Wings 8',179.90,'8 adet baharatlı kanat + sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',pop:true,spicy:true),
        _mi('kfcs2','Hot Wings 4',99.90,'4 adet kanat','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',spicy:true),
        _mi('kfcs3','Strips 3',119.90,'3 adet uzun çıtır fileto','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400'),
        _mi('kfcs4','Kemiksiz Kutu',269.90,'Nugget + hot shots + strips + patates','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
      ]),
      MenuCategory(id:'kfc3', name:'🍟 Yanlar & Tatlılar', items:[
        _mi('kfcy1','Patates Küçük',69.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('kfcy2','Patates Büyük',89.90,'Büyük boy','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('kfcy3','Coleslaw',49.90,'Kremalı lahana salatası','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('kfcy4','Mozaik Kek',69.90,'KFC mozaik kek','assets/menu/kek.png',veg:true),
      ]),
      _drinksEx('kfcd'),
    ],
    'popeyes': [
      MenuCategory(id:'pop1', name:'🍗 Parça Tavuklar', items:[
        _mi('pop1','3 Parça Tavuk',199.90,'Göğüs, kaburga, but + sos seçimi','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',pop:true),
        _mi('pop2','4 Parça Tavuk',249.90,'4 parça tavuk','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
        _mi('pop3','Acılı Kanat 6',179.90,'6 adet acılı kanat + sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',spicy:true,pop:true),
        _mi('pop4','Tenders',149.90,'Çıtır tavuk fileto şeritleri','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400'),
      ]),
      MenuCategory(id:'pop2', name:'🍔 Burger & Sandviç', items:[
        _mi('popb1','Tavukburger',209.90,'Çıtır tavuk patty, coleslaw, turşu','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
        _mi('popb2','Popeyes XL Sandviç',239.90,'Büyük boy tavuk sandviç','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
        _mi('popb3','Pop Dürüm',199.90,'Tavuk, salata, sos, lavaş','assets/menu/doner.png'),
      ]),
      MenuCategory(id:'pop3', name:'🍟 Yancılar & Tatlılar', items:[
        _mi('pops1','Dilim Patates',79.90,'Normal dilim patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('pops2','Coleslaw',49.90,'Kremalı lahana','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('pops3','Biscuit',44.90,'Buttermilk biscuit ekmeği','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('pops4','Sufle',89.90,'Sıcak çikolatalı sufle','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('popd'),
    ],
    'dominos': [
      MenuCategory(id:'dom1', name:'🍕 Pizzalar', items:[
        _mi('dom1','Bol Malzemos',329.90,'Jambon, pepperoni, sucuk, sosis, mısır, mozza, zeytin','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true),
        _mi('dom2','Extravaganzza',349.90,'Jambon, pepperoni, sosis, mısır, mozza, zeytin, biber, soğan, mantar','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
        _mi('dom3','Margarita',299.90,'Mozarella peyniri, pizza sosu','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
        _mi('dom4','BBQ Tavuklu',349.90,'Pizza sosu, tavuk, köz biber, BBQ sos','https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400'),
        _mi('dom5','Bol Sucuksever',299.90,'Bol sucuk, mozarella','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
        _mi('dom6','3 Peynirli',369.90,'Mozarella, cheddar, olgun peynir, sarımsaklı sos','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
        _mi('dom7','Ocakbaşı',379.90,'Sucuk, köz biber, mantar, pastırma, kavurma','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
      ]),
      MenuCategory(id:'dom2', name:'🍗 Tavuklar & Yanlar', items:[
        _mi('doms1','Çıtır Tavuk Topları',89.90,'10 adet çıtır top','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',pop:true),
        _mi('doms2','Gurme Patates',69.90,'Çıtır gurme patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('doms3','Sarımsaklı Ekmek',79.90,'6 dilim sarımsaklı ekmek','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
      ]),
      MenuCategory(id:'dom3', name:'🍦 Tatlılar', items:[
        _mi('domt1','Çikolatalı Sufle',145.90,'Sıcak çikolata sufle','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('domt2','Cinnamon Roll',109.90,'Tarçınlı rulo, krema sosu','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('domt3','Algida Dondurma',79.90,'Vanilya veya çikolatalı','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('domd'),
    ],
    'starbucks': [
      MenuCategory(id:'sbx1', name:'☕ Espresso İçecekleri', items:[
        _mi('sbx1','Caffè Latte',200.00,'Espresso + sütlü köpük','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbx2','Cappuccino',190.00,'Espresso, buharla ısıtılmış süt, köpük','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbx3','Caramel Macchiato',220.00,'Vanilyalı, karamelli espresso','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbx4','White Chocolate Mocha',225.00,'Beyaz çikolata, espresso, sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('sbx5','Americano',175.00,'Uzun espresso','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('sbx6','Türk Kahvesi',170.00,'Geleneksel Türk kahvesi','assets/menu/kahve.png',veg:true),
      ]),
      MenuCategory(id:'sbx2', name:'🧊 Soğuk Kahveler', items:[
        _mi('sbxc1','Iced Caramel Macchiato',230.00,'Buzlu karamel macchiato','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbxc2','Iced Latte',215.00,'Buzlu latte','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('sbxc3','Cold Brew',220.00,'24 saat demleme, soğuk kahve','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbxc4','Iced Americano',185.00,'Buzlu americano','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      MenuCategory(id:'sbx3', name:'🥛 Frappuccino & Diğer', items:[
        _mi('sbxf1','Caramel Frappuccino',245.00,'Kahve, karamel sos, krem şanti','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true,pop:true),
        _mi('sbxf2','Java Chip Frappuccino',245.00,'Kahve, çikolata parçaları','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('sbxf3','Matcha Latte',215.00,'Japon matcha çayı, sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      MenuCategory(id:'sbx4', name:'🥐 Fırın & Atıştırmalık', items:[
        _mi('sbxb1','Tereyağlı Kruvasan',175.00,'Taze pişirilmiş butter croissant','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('sbxb2','Brownie',170.00,'Starbucks brownie','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('sbxb3','Cheesecake',220.00,'Limonlu / ahududulu cheesecake','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('sbxb4','Muffin',165.00,'Çikolatalı veya yaban mersinli','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('sbxb5','Sandviç',220.00,'Tavuklu / peynirli sandviç seçenekleri','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
    ],
    'simitSarayi': [
      MenuCategory(id:'ss1', name:'🥐 Simitler & Börekler', items:[
        _mi('ss1','Simit',29.90,'Taze susamlı simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('ss2','Çoko Simit',44.90,'Çikolata dolgulu simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('ss3','Su Böreği',89.90,'El açması su böreği','assets/menu/su.png',veg:true),
        _mi('ss4','Çıtır Kalem Börek',59.90,'Peynirli kalem börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('ss5','Kruvasan',69.90,'Tereyağlı / çikolatalı kruvasan','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('ss6','Poğaça',49.90,'Peynirli / zeytinli poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
      ]),
      MenuCategory(id:'ss2', name:'🥚 Kahvaltılar', items:[
        _mi('ssk1','Serpme Kahvaltı',359.90,'Peynir, zeytin, bal, kaymak, yumurta, sebze','assets/menu/kahvalti.png',pop:true,veg:true),
        _mi('ssk2','Menemen',99.90,'Domates, biber, yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
        _mi('ssk3','Sucuklu Yumurta',99.90,'Sucuk + sahanda yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
        _mi('ssk4','Simit Tabağı',89.90,'Simit + çeşitli peynir ve zeytin','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
      ]),
      MenuCategory(id:'ss3', name:'🥪 Sandviçler', items:[
        _mi('sss1','Simit Arası Kaşar',69.90,'Kaşar peynirli simit sandviç','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true,pop:true),
        _mi('sss2','Puf Sandviç',79.90,'Karışık puf ekmeği sandviç','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('sss3','Tavuklu Sandviç',89.90,'Izgara tavuk sandviç','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'ss5', name:'☕ İçecekler', items:[
        _mi('ssi1','Americano',79.90,'','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('ssi2','Latte',89.90,'','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('ssi3','Türk Kahvesi',69.90,'','assets/menu/kahve.png',veg:true),
        _mi('ssi4','Limonata',69.90,'Taze sıkma limonata','assets/menu/icecekler.png',veg:true),
        _mi('ssi5','Çay',29.90,'Bardak çay','assets/menu/cay.png',veg:true),
      ]),
    ],
    'simitciDunyasi': [
      MenuCategory(id:'sd1', name:'🥐 Simitler & Poğaçalar', items:[
        _mi('sd1','Susamlı Simit',29.90,'Taze susamlı simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('sd2','Peynirli Poğaça',49.90,'Peynirli taze poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('sd3','Zeytinli Açma',49.90,'Zeytinli açma','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('sd4','Rulo Börek Peynirli',69.90,'Peynirli rulo börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('sd5','Simit Arası Kaşar',59.90,'Kaşar peynirli simit sandviç','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
      ]),
      MenuCategory(id:'sd2', name:'🍔 Sıcak Sandviçler & Burger', items:[
        _mi('sds1','Simitçi Cheese Burger',149.90,'Özel köfte, cheddar, sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
        _mi('sds2','Kıtır Tavuklu Sandviç',129.90,'Çıtır tavuk, marul, sos','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
        _mi('sds3','Ekmek Arası Sucuk',89.90,'Dilim sucuk, domates, biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'sd4', name:'🍰 Tatlılar', items:[
        _mi('sdt1','Waffle',119.90,'Waffle + çikolata + meyve','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('sdt2','Tiramisu',99.90,'Klasik tiramisu','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('sdd'),
    ],
    'komagene': [
      MenuCategory(id:'kom1', name:'🌿 Çiğ Köfte', items:[
        _mi('kom1','Çiğ Köfte 300g',259.90,'300g çiğ köfte, lavaş, yeşillik, sos','assets/food/cig_kofte.jpg',veg:true,pop:true,spicy:true),
        _mi('kom2','Çiğ Köfte 500g Joker',369.90,'500g joker porsiyon + yeşillik','assets/food/cig_kofte.jpg',veg:true,pop:true),
        _mi('kom3','Çiğ Köfte 1kg',749.90,'Aile boyu 1kg çiğ köfte','assets/food/cig_kofte.jpg',veg:true),
      ]),
      MenuCategory(id:'kom2', name:'🌯 Dürümler', items:[
        _mi('komd1','Favori Çiğ Köfte Dürüm',109.90,'Dürüm, yeşillik, sos','assets/menu/doner.png',veg:true,pop:true),
        _mi('komd2','Mega Çiğ Köfte Dürüm',119.90,'Büyük boy dürüm','assets/menu/doner.png',veg:true),
        _mi('komd3','Doritos\'lu Dürüm',125.90,'Doritos ile ekstra çıtırlık','assets/food/cig_kofte.jpg',veg:true,pop:true),
        _mi('komd4','Double Dürüm',140.90,'Çift dürüm','assets/menu/doner.png',veg:true),
      ]),
      MenuCategory(id:'kom3', name:'🍚 Pilav', items:[
        _mi('komp1','Tavuklu Pilav 200g',139.90,'Nohutlu pilav + tavuk','assets/menu/pilav.png'),
        _mi('komp2','Tavuklu Pilav 400g',289.90,'Büyük boy pilav + tavuk','assets/menu/pilav.png',pop:true),
        _mi('komp3','Nohut Pilav 150g',109.90,'Sade nohutlu pilav','assets/menu/pilav.png',veg:true),
      ]),
      MenuCategory(id:'kom5', name:'🥤 İçecekler', items:[
        _mi('komi1','Komagene Ayran 270ml',45.90,'','assets/menu/icecekler.png',veg:true),
        _mi('komi2','Şalgam Acılı 300ml',34.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('komi3','Pepsi 330ml',59.90,'','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('komi4','Su 500ml',19.90,'','assets/menu/su.png',veg:true),
        _mi('komi5','Limonata',24.90,'Bardak limonata','assets/menu/icecekler.png',veg:true),
      ]),
    ],
    'baydoner': [
      MenuCategory(id:'bay1', name:'🌯 İskender & Döner', items:[
        _mi('bay1','İskender',329.90,'Dana döner, özel sos, yoğurt, tereyağı, pide','assets/food/doner.jpg',pop:true),
        _mi('bay2','1.5 İskender',419.90,'1.5 porsiyon büyük İskender','assets/food/doner.jpg'),
        _mi('bay3','Yoğurtlu Köz Patlıcanlı İskender',369.90,'İskender + közlenmiş patlıcan ezmesi','assets/food/doner.jpg',pop:true),
        _mi('bay4','Çökertme Döner',319.90,'Döner + patates + yoğurt sosu','assets/food/doner.jpg',pop:true),
      ]),
      MenuCategory(id:'bay2', name:'🥗 Yanlar & Tatlılar', items:[
        _mi('bays1','Mercimek Çorbası',89.90,'Ev yapımı mercimek çorbası','assets/menu/mercimek_corba.png',veg:true),
        _mi('bays2','Patates Kızartması',89.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('bays3','Salata',79.90,'Taze sebze salatası','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('bays4','Künefe',149.90,'Kaymak + kadayıf künefe','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('bays5','Sufle',99.90,'Çikolatalı sufle','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('bayd'),
    ],
    'tavukdunyasi': [
      MenuCategory(id:'tvd1', name:'🍗 Özel Tavuklar', items:[
        _mi('tvd1','Efsane Buffalo',179.90,'Acılı buffalo soslu izgara tavuk','assets/food/tavuk_dunyasi.jpg',pop:true,spicy:true),
        _mi('tvd2','Barbeküs',169.90,'BBQ soslu ızgara tavuk parçası','assets/food/tavuk_dunyasi.jpg',pop:true),
        _mi('tvd3','Peynirlim',169.90,'Üzerinde eritilmiş cheddar peyniri','assets/food/tavuk_dunyasi.jpg'),
        _mi('tvd4','Izgara Pirzola',189.90,'Yarım piliç pirzola, ızgara','assets/food/tavuk_dunyasi.jpg'),
      ]),
      MenuCategory(id:'tvd2', name:'🥗 Salatalar', items:[
        _mi('tvds1','Çıtır Tavuklum',149.90,'Çıtır tavuk, marul, sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',pop:true),
        _mi('tvds2','Sezarım Tavuklum',149.90,'Sezar salata + ızgara tavuk','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
      ]),
      MenuCategory(id:'tvd3', name:'🥔 Başlangıçlar & Tatlılar', items:[
        _mi('tvda1','Churros Patates',79.90,'Churros şeklinde baharatlı patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true,pop:true),
        _mi('tvdt1','Tiramisu',119.90,'Klasik tiramisu','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('tvdt2','Sufle',99.90,'Sıcak çikolatalı sufle','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('tvdd'),
    ],
    'kofteciyusuf': [
      MenuCategory(id:'kyf1', name:'🥩 Köfte Çeşitleri', items:[
        _mi('kyf1','Izgara Köfte (1 Porsiyon)',299.90,'El yapımı ızgara köfte, pilav, salata','assets/food/et.jpg',pop:true),
        _mi('kyf2','Köfte 300gr',429.90,'300gr ızgara köfte, pilav, piyaz','assets/food/et.jpg',pop:true),
        _mi('kyf3','Tek Köfte Burger',229.90,'Ekmek arası tek köfte burger','assets/food/et.jpg'),
        _mi('kyf4','Çift Köfte Burger',289.90,'Çift köfte burger','assets/food/et.jpg',pop:true),
        _mi('kyf5','Sucuk',299.90,'Izgara sucuk tabağı','assets/food/et.jpg'),
        _mi('kyf6','Dana Antrikot',429.90,'Izgara dana antrikot tabağı','assets/food/et.jpg'),
      ]),
      MenuCategory(id:'kyf2', name:'🥗 Yanlar', items:[
        _mi('kyfs1','Piyaz',79.90,'Fasulye piyazı, soğan, sirke','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
        _mi('kyfs2','Patates',79.90,'Porsiyon patates kızartması','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('kyfs3','Cacık',69.90,'Yoğurt, salatalık, nane','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('kyfs4','Ekmek Kadayıfı',89.90,'Şerbetli ekmek kadayıfı','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('kyfd'),
    ],
    'subway': [
      MenuCategory(id:'sub1', name:'🥖 Sub Sandviçler (15cm)', items:[
        _mi('sub1','Teriyaki Tavuk Sub 15',189.90,'Teriyaki soslu tavuk, salata seçimleri','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('sub2','Biftek & Peynir Sub 15',199.90,'Biftek, peynir, sebze','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('sub3','İtalyan B.M.T. Sub 15',189.90,'Salam, jambon, pepperoni','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('sub4','Tavuk Fileto Sub 15',179.90,'Izgara tavuk fileto, sebze','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('sub5','Sebze Keyfi Sub 15',149.90,'Taze sebze, peynir','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
      ]),
      MenuCategory(id:'sub2', name:'🥖 Sub Sandviçler (30cm)', items:[
        _mi('sub6','Teriyaki Tavuk Sub 30',249.90,'Büyük boy teriyaki tavuk','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('sub7','Biftek & Peynir Sub 30',269.90,'Büyük boy biftek sandviç','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'sub3', name:'🌯 Dürümler & Bowl', items:[
        _mi('subd1','Teriyaki Tavuk Dürüm',189.90,'Teriyaki tavuk lavaş dürüm','assets/menu/doner.png',pop:true),
        _mi('subd2','Biftek & Peynir Dürüm',199.90,'Biftek dürüm','assets/menu/doner.png'),
        _mi('subd3','Tavuk Fileto Bowl',179.90,'Izgara tavuk salata kasesi','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
      ]),
      _drinksEx('subxd'),
    ],
    // ── GENERIC MENUS ────────────────────────────────────────
    'burger': [
      MenuCategory(id:'bm1', name:'🍔 Burgerler', items:[
        _mi('bb1','Classic Smash',370.00,'180gr dana, cheddar, özel sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true,opts:[MenuOption(id:'bo1',name:'Ekstra Cheddar',price:25),MenuOption(id:'bo2',name:'Bacon',price:40),MenuOption(id:'bo3',name:'Soğan',isRemovable:true),MenuOption(id:'bo4',name:'Turşu',isRemovable:true)]),
        _mi('bb2','Double Smash',470.00,'Çift et, çift peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bb3','Crispy Chicken',360.00,'Çıtır tavuk burger','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
        _mi('bb4','Veggie Burger',350.00,'Sebze köftesi, avokado','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
      ]),
      MenuCategory(id:'bm2', name:'🍟 Yanlar', items:[
        _mi('bs1','Patates',95.00,'Çıtır patates','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bs2','Onion Rings',100.00,'Soğan halkaları','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bs3','Mozza Stick',110.00,'6 adet + marinara','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
      ]),
      _drinks('bd'),
    ],
    'pizza': [
      MenuCategory(id:'pm1', name:'🍕 Pizzalar', items:[
        _mi('pb1','Margarita',300.00,'Domates, mozzarella, fesleğen','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true,opts:[MenuOption(id:'po1',name:'Ekstra Peynir',price:30),MenuOption(id:'po2',name:'İnce Hamur'),MenuOption(id:'po3',name:'Kalın Hamur')]),
        _mi('pb2','Karışık',390.00,'Sucuk, mantar, biber, zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
        _mi('pb3','BBQ Tavuk',360.00,'BBQ sos, tavuk, soğan','https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400'),
        _mi('pb4','4 Peynirli',420.00,'Mozza, cheddar, parmesan, gouda','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
      ]),
      _drinks('pd'),
    ],
    'tavuk': [
      MenuCategory(id:'tm1', name:'🍗 Tavuk', items:[
        _mi('tb1','Bucket 8 Parça',440.00,'8 parça çıtır tavuk','assets/food/tavuk_dunyasi.jpg',pop:true),
        _mi('tb2','Tavuk Dürüm',260.00,'Izgara tavuk, sebze, lavaş','assets/menu/doner.png',opts:[MenuOption(id:'to1',name:'Acı Sos'),MenuOption(id:'to2',name:'Soğan',isRemovable:true)]),
        _mi('tb3','Çıtır Kanatlar 6',290.00,'6 adet kanat, dip sos','assets/food/tavuk_dunyasi.jpg',spicy:true),
        _mi('tb4','Tavuk Burger Menü',350.00,'Burger + patates + içecek','assets/food/tavuk_dunyasi.jpg'),
      ]),
      _drinks('td'),
    ],
    'doner': [
      MenuCategory(id:'dm1', name:'🌯 Döner', items:[
        _mi('db1','Et Dürüm',450.00,'Dana döner, lavaş, sebze','assets/menu/doner.png',pop:true,opts:[MenuOption(id:'do1',name:'Acı Sos'),MenuOption(id:'do2',name:'Ekstra Et',price:50),MenuOption(id:'do3',name:'Soğan',isRemovable:true)]),
        _mi('db2','Tavuk Dürüm',250.00,'Izgara tavuk, sebze','assets/menu/doner.png'),
        _mi('db3','Et Porsiyon',520.00,'Porsiyon et + pilav + salata','assets/food/doner.jpg'),
        _mi('db4','İskender',580.00,'Döner + domates sosu + yoğurt','assets/food/doner.jpg'),
      ]),
      _drinks('dd'),
    ],
    'pide': [
      MenuCategory(id:'pim1', name:'🫓 Pide & Lahmacun', items:[
        _mi('pib1','Kıymalı Pide',230.00,'Kıyma, domates, biber','assets/food/pide_lahmacun.jpg',pop:true,opts:[MenuOption(id:'pio1',name:'Yumurtalı',price:20),MenuOption(id:'pio2',name:'Kaşarlı',price:25)]),
        _mi('pib2','Kaşarlı Pide',210.00,'Bol kaşar peyniri','assets/food/pide_lahmacun.jpg'),
        _mi('pib3','Lahmacun 4 adet',200.00,'İnce kıymalı lahmacun','assets/food/pide_lahmacun.jpg'),
        _mi('pib4','Gözleme',200.00,'Peynirli veya ıspanaklı','assets/food/pide_lahmacun.jpg',veg:true),
      ]),
      _drinks('pidd'),
    ],
    'et': [
      MenuCategory(id:'em1', name:'🔥 Kebaplar', items:[
        _mi('eb1','Adana Kebap',399.90,'Acılı kıyma kebabı, pilav, söğüş','assets/food/et.jpg',pop:true,spicy:true),
        _mi('eb2','Urfa Kebap',399.90,'Acısız kıyma kebabı, pilav','assets/food/et.jpg'),
        _mi('eb3','Beyti Kebap',429.90,'Kıyma beyti, lavaş, yoğurt','assets/food/et.jpg',pop:true),
        _mi('eb4','Patlıcan Kebap',459.90,'Közlenmiş patlıcanlı kebap','assets/food/et.jpg'),
        _mi('eb5','Karışık Kebap',649.90,'Adana + urfa + köfte + pilav','assets/food/et.jpg',pop:true),
        _mi('eb6','Yoğurtlu Kebap',449.90,'Kebap + yoğurt sosu + pide','assets/food/et.jpg'),
      ]),
      MenuCategory(id:'em2', name:'🥩 Izgaralar', items:[
        _mi('ebı1','Izgara Köfte',360.00,'El yapımı ızgara köfte, pilav','assets/food/et.jpg',pop:true),
        _mi('ebı2','Kuzu Pirzola',699.90,'Izgara kuzu pirzola, fırın patates','assets/food/et.jpg'),
        _mi('ebı3','Dana Antrikot',649.90,'200gr dana antrikot, sebze','assets/food/et.jpg'),
        _mi('ebı4','Kuzu Şiş',549.90,'Kuzu şiş, pilav, salata','assets/food/et.jpg',pop:true),
        _mi('ebı5','Karışık Izgara',799.90,'Kuzu şiş + adana + köfte tabağı','assets/food/et.jpg',pop:true),
        _mi('ebı6','Kuzu İncik',549.90,'Fırında kuzu incik, pilav','assets/food/et.jpg'),
      ]),
      MenuCategory(id:'em3', name:'🥗 Yanlar & Çorbalar', items:[
        _mi('eby1','Mercimek Çorbası',89.90,'Kırmızı mercimek','assets/menu/mercimek_corba.png',veg:true),
        _mi('eby2','Çoban Salata',99.90,'Domates, salatalık, biber','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('eby3','Cacık',79.90,'Yoğurt, salatalık, nane','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('eby4','Patates Kızartması',99.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
      ]),
      _drinksEx('etd'),
    ],
    'deniz': [
      MenuCategory(id:'denim1', name:'🐟 Deniz Ürünleri', items:[
        _mi('denb1','Balık Izgara',380.00,'Günün balığı, sebze, pilav','assets/food/deniz_urunleri.jpg',pop:true),
        _mi('denb2','Karides Güveç',360.00,'Domates soslu karides','assets/food/deniz_urunleri.jpg'),
        _mi('denb3','Balık Ekmek',350.00,'Izgara balık, lavaş','assets/food/deniz_urunleri.jpg'),
        _mi('denb4','Meze Tabağı',360.00,'Karışık deniz mezeleri','assets/menu/meze.png'),
      ]),
      _drinks('dend'),
    ],
    'vegan': [
      MenuCategory(id:'vm1', name:'🥗 Ana Yemekler', items:[
        _mi('vb1','Buddha Bowl',280.00,'Kinoa, avokado, tahini, sebze','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
        _mi('vb2','Falafel Dürüm',240.00,'Falafel, humus, turşu, lavaş','assets/menu/doner.png',veg:true,pop:true),
        _mi('vb3','Vegan Burger',260.00,'Nohut köftesi, avokado, vegan sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('vb4','Acı Tofu Stir Fry',250.00,'Tofu, sebze, baharatlı soya sosu','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,spicy:true),
        _mi('vb5','Sebzeli Wrap',230.00,'Izgara sebze, humus, lavaş','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('vb6','Nohut Köri',245.00,'Hint köri, nohut, basmati pilav','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,spicy:true),
        _mi('vb7','Mercimek Çorbası',200.00,'Mercimek çorbası, ekmek','assets/menu/mercimek_corba.png',veg:true),
      ]),
      MenuCategory(id:'vm2', name:'🥗 Salatalar & Kaseler', items:[
        _mi('vbs1','Detoks Salata',210.00,'Kale, ıspanak, badem, limon sos','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
        _mi('vbs2','Protein Bowl',235.00,'Edamame, kinoa, avokado, sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('vbs3','Acı Salsa Kase',220.00,'Meksika usulü vegan kase','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,spicy:true),
      ]),
      _drinksEx('vd'),
    ],
    'kahvalti': [
      MenuCategory(id:'km1', name:'🥚 Kahvaltılar', items:[
        _mi('kb1','Serpme Kahvaltı 2 Kişi',449.90,'Peynir çeşitleri, bal, kaymak, yumurta, simit, zeytin, sebze','assets/menu/kahvalti.png',pop:true),
        _mi('kb2','Serpme Kahvaltı 1 Kişi',249.90,'Tek kişilik serpme kahvaltı tabağı','assets/menu/kahvalti.png'),
        _mi('kb3','Menemen',119.90,'Domates, biber, yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',pop:true,opts:[MenuOption(id:'ko1',name:'Sucuklu',price:25),MenuOption(id:'ko2',name:'Kaşarlı',price:20),MenuOption(id:'ko3',name:'Mantarlı',price:20)]),
        _mi('kb4','Sucuklu Yumurta',109.90,'Tava sucuk, sahanda yumurta, ekmek','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
        _mi('kb5','Çılbır',109.90,'Poşe yumurta, yoğurt, tereyağı','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
        _mi('kb6','Gözleme Peynirli',99.90,'El açması peynirli gözleme','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('kb7','Gözleme Kıymalı',109.90,'El açması kıymalı gözleme','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400'),
        _mi('kb8','Poğaça 6 adet',79.90,'Karışık taze poğaça','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('kb9','Köy Kahvaltısı',199.90,'Köy peyniri, bal, yumurta, zeytin','assets/menu/kahvalti.png',veg:true),
      ]),
      MenuCategory(id:'km2', name:'☕ Kahvaltı İçecekleri', items:[
        _mi('kbi1','Çay',25.90,'Demli bardak çay','assets/menu/cay.png',veg:true,pop:true),
        _mi('kbi2','Türk Kahvesi',49.90,'Geleneksel Türk kahvesi','assets/menu/kahve.png',veg:true),
        _mi('kbi3','Taze Portakal Suyu',79.90,'Sıkma portakal suyu','assets/menu/portakal_suyu.png',veg:true),
        _mi('kbi4','Ayran',35.90,'Soğuk ayran','assets/menu/icecekler.png',veg:true),
        _mi('kbi5','Latte',79.90,'Sütlü kahve','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
    ],
    'sokak': [
      MenuCategory(id:'skm1', name:'🌽 Sokak Lezzetleri', items:[
        _mi('skb1','Kumpir',250.00,'Büyük patates + 5 malzeme','assets/food/kumpir.jpg',pop:true,opts:[MenuOption(id:'sko1',name:'Mısır'),MenuOption(id:'sko2',name:'Zeytin'),MenuOption(id:'sko3',name:'Sosis',price:20),MenuOption(id:'sko4',name:'Rus Salatası'),MenuOption(id:'sko5',name:'Ekstra Peynir',price:25)]),
        _mi('skb2','Kokoreç',210.00,'Yarım ekmek kokoreç','assets/food/kokorec.jpg',spicy:true),
        _mi('skb3','Tantuni',220.00,'Et tantuni, lavaş, sebze','assets/food/tantuni.jpg'),
        _mi('skb4','Islak Burger',200.00,'İstanbul\'un ıslak burgeri','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
      ]),
      _drinks('skd'),
    ],
    'manti': [
      MenuCategory(id:'mam1', name:'🥟 Mantı & Makarna', items:[
        _mi('mab1','El Yapımı Mantı',270.00,'Mantı, yoğurt, nane tereyağı','https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400',pop:true,opts:[MenuOption(id:'mao1',name:'Ekstra Yoğurt',price:20),MenuOption(id:'mao2',name:'Acısız')]),
        _mi('mab2','Kremalı Makarna',245.00,'Krema, mantar, parmesan','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400',veg:true),
        _mi('mab3','Bolonez',250.00,'Kıymalı domates sosu','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400'),
        _mi('mab4','Lazanya',280.00,'Fırın lazanya, bolonez, beşamel','https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400'),
      ]),
      _drinks('mad'),
    ],
    'kahve': [
      MenuCategory(id:'kfm1', name:'☕ Kahveler', items:[
        _mi('kfb1','Latte',185.00,'Espresso + sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true,opts:[MenuOption(id:'kfo1',name:'Ekstra Shot',price:25),MenuOption(id:'kfo2',name:'Yulaf Sütü',price:35)]),
        _mi('kfb2','Türk Kahvesi',160.00,'Geleneksel Türk kahvesi','assets/menu/kahve.png',veg:true),
        _mi('kfb3','Soğuk Kahve',210.00,'Cold brew / frappuccino','assets/menu/kahve.png',veg:true),
        _mi('kfb4','Matcha Latte',225.00,'Premium matcha, sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      MenuCategory(id:'kfm2', name:'🥐 Atıştırmalık', items:[
        _mi('kfs1','Croissant',160.00,'Tereyağlı kruvasan','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('kfs2','Muffin',155.00,'Çikolatalı veya yaban mersinli','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
    ],
    'pastane': [
      MenuCategory(id:'pam1', name:'🥐 Börekler & Hamur İşleri', items:[
        _mi('pab1','Simit',25.90,'Taze susamlı simit','assets/food/pastane_firin.jpg',veg:true,pop:true),
        _mi('pab2','Peynirli Poğaça',49.90,'Taze pişmiş peynirli poğaça','assets/food/pastane_firin.jpg',veg:true,pop:true),
        _mi('pab3','Zeytinli Açma',45.90,'Zeytinli yumuşak açma','assets/food/pastane_firin.jpg',veg:true),
        _mi('pab4','Su Böreği (Dilim)',89.90,'El açması peynirli su böreği','assets/menu/su.png',veg:true,pop:true),
        _mi('pab5','Sigara Böreği 6 adet',79.90,'Çıtır peynirli sigara böreği','assets/food/pastane_firin.jpg',veg:true),
        _mi('pab6','Ispanaklı Börek',75.90,'El açması ıspanaklı börek','assets/food/pastane_firin.jpg',veg:true),
        _mi('pab7','Patatesli Börek',75.90,'El açması patatesli börek','assets/food/pastane_firin.jpg',veg:true),
        _mi('pab8','Kol Böreği',85.90,'Rulo kol böreği, peynirli','assets/food/pastane_firin.jpg',veg:true),
        _mi('pab9','Kruvasan',59.90,'Tereyağlı / çikolatalı kruvasan','assets/food/pastane_firin.jpg',veg:true),
        _mi('pab10','Etli Börek',95.90,'Kıymalı el açması börek','assets/food/pastane_firin.jpg'),
      ]),
      MenuCategory(id:'pam2', name:'🍰 Tatlılar', items:[
        _mi('pat1','Baklava 6 adet',129.90,'Antep fıstıklı baklava','assets/menu/baklava.png',veg:true,pop:true),
        _mi('pat2','Kadayıf',119.90,'Peynirli tel kadayıf','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat3','Sütlaç',79.90,'Fırın sütlaç','assets/menu/sutlu_tatlilar.png',veg:true),
        _mi('pat4','Sufle',99.90,'Çikolatalı sufle + dondurma','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat5','Tiramisu',109.90,'Klasik tiramisu','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat6','Cheesecake',119.90,'Limonlu / çilekli cheesecake','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('pat7','Brownie',79.90,'Çikolatalı brownie + dondurma','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat8','Profiterol',89.90,'Krema dolgulu profiterol','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      MenuCategory(id:'pam3', name:'☕ İçecekler', items:[
        _mi('pai1','Türk Kahvesi',49.90,'Geleneksel Türk kahvesi','assets/menu/kahve.png',veg:true),
        _mi('pai2','Çay',20.90,'Demli bardak çay','assets/menu/cay.png',veg:true),
        _mi('pai3','Latte',89.90,'Espresso + sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('pai4','Limonata',69.90,'Taze sıkma limonata','assets/menu/icecekler.png',veg:true),
        _mi('pai5','Su 500ml',15.90,'','assets/menu/su.png',veg:true),
      ]),
    ],
    'aperatif': [
      MenuCategory(id:'apm1', name:'🥗 Mezeler', items:[
        _mi('apb1','Karışık Meze Tabağı',179.90,'Humus, patlıcan, cacık, atom, ezme','assets/menu/meze.png',veg:true,pop:true),
        _mi('apb2','Humus',89.90,'Ev yapımı humus, pita ekmeği','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        _mi('apb3','Patlıcan Ezmesi',79.90,'Közlenmiş patlıcan ezmesi','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        _mi('apb4','Atom',79.90,'Baharatlı domates sosu','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        _mi('apb5','Cacık',69.90,'Salatalık yoğurt, sarımsak, nane','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('apb6','Ezme',69.90,'Acı biber, domates, maydanoz','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true,spicy:true),
        _mi('apb7','Arnavut Ciğeri',129.90,'Soğan, maydanoz, biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('apb8','Sucuk Izgara',119.90,'Izgara Türk sucuğu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('apb9','Pastırmalı Yumurta',109.90,'Pastırmalı sahanda yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
      ]),
      MenuCategory(id:'apm2', name:'🥗 Salatalar', items:[
        _mi('aps1','Mevsim Salatası',89.90,'Taze sebzeler, zeytinyağı, limon','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true,pop:true),
        _mi('aps2','Çoban Salata',79.90,'Domates, salatalık, biber, soğan','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('aps3','Roka Salatası',99.90,'Roka, parmesan, cherry domates','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('aps4','Sezar Salata',119.90,'Marul, crouton, parmesan, sezar sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
      ]),
      MenuCategory(id:'apm3', name:'🍷 İçecekler', items:[
        _mi('api1','Ayran',39.90,'Ev yapımı ayran','assets/menu/icecekler.png',veg:true),
        _mi('api2','Şalgam Suyu',45.90,'Acılı şalgam suyu','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('api3','Limonata',69.90,'Taze limonata','assets/menu/icecekler.png',veg:true),
        _mi('api4','Kola 330ml',49.90,'','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('api5','Su 500ml',15.90,'','assets/menu/su.png',veg:true),
      ]),
    ],
    'ev': [
      MenuCategory(id:'evm1', name:'🍲 Günlük Yemekler', items:[
        _mi('evb1','Günlük Tabak',260.00,'2 çeşit yemek + pilav + salata','assets/food/ev_yemekleri.jpg',pop:true),
        _mi('evb2','Karnıyarık',245.00,'Patlıcan, kıyma, fırın','assets/food/ev_yemekleri.jpg'),
        _mi('evb3','Etli Nohut',230.00,'Kuzu etli nohut, pilav','assets/food/ev_yemekleri.jpg'),
        _mi('evb4','Kuru Fasulye + Pilav',210.00,'Geleneksel kuru fasulye, pilav','assets/menu/pilav.png',veg:true,pop:true),
        _mi('evb5','İmam Bayıldı',225.00,'Zeytinyağlı patlıcan dolması','assets/food/ev_yemekleri.jpg',veg:true),
        _mi('evb6','Dolma (10 adet)',220.00,'Zeytinyağlı yaprak sarma','assets/food/ev_yemekleri.jpg',veg:true),
        _mi('evb7','Tarhana Çorbası',200.00,'Ev yapımı tarhana','assets/food/ev_yemekleri.jpg',veg:true),
        _mi('evb8','Mercimek Çorbası',200.00,'Kırmızı mercimek çorbası','assets/menu/mercimek_corba.png',veg:true),
      ]),
      _drinks('evd'),
    ],
    'dunya': [
      MenuCategory(id:'dun1', name:'🍣 Sushi', items:[
        _mi('dun1','Sushi Set 12',420.00,'12 parça karışık sushi','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',pop:true),
        _mi('dun2','Salmon Nigiri 4',280.00,'4 adet somon nigiri','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',pop:true),
        _mi('dun3','California Roll 8',310.00,'8 parça california roll','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400'),
        _mi('dun4','Spicy Tuna Roll 8',330.00,'Acılı ton balıklı roll','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',spicy:true),
        _mi('dun5','Vegan Avokado Roll 8',280.00,'Avokado, salatalık, nori','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',veg:true),
      ]),
      MenuCategory(id:'dun2', name:'🍜 Noodle & Wok', items:[
        _mi('dunw1','Ramen',340.00,'Tonkotsu çorba, erişte, yumurta','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',pop:true),
        _mi('dunw2','Pad Thai',320.00,'Pirinç eriştesi, karides, fıstık','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',pop:true),
        _mi('dunw3','Vegan Noodle',290.00,'Sebzeli erişte, soya sosu','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',veg:true),
        _mi('dunw4','Köri Wok',310.00,'Tavuklu hint körisi, pirinç','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',spicy:true),
      ]),
      MenuCategory(id:'dun3', name:'🍕 İtalyan', items:[
        _mi('duni1','Carbonara',340.00,'Spaghetti, guanciale, yumurta, parmesan','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400',pop:true),
        _mi('duni2','Boloneze',320.00,'Kıymalı domates sosu, tagliatelle','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400'),
        _mi('duni3','Margherita Pizza',370.00,'Domates, mozzarella, fesleğen','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
        _mi('duni4','Risotto Tartufo',420.00,'Trüf mantarlı risotto','https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=400',veg:true),
      ]),
      _drinksEx('dund'),
    ],
    'aspava': [
      MenuCategory(id:'asp1', name:'🥩 Döner', items:[
        _mi('asp_d1','Servis Et Döner',680,'Tabak servis et döner','assets/food/doner.jpg',pop:true),
        _mi('asp_d2','Dürüm Et Döner',680,'Lavaşta et döner dürüm','assets/menu/doner.png'),
        _mi('asp_d3','SSK Dürüm Döner',700,'Özel SSK dürüm','assets/menu/doner.png'),
        _mi('asp_d4','İskender Kebap',730,'Döner, yoğurt, tereyağı, domates sosu, pide','assets/food/doner.jpg',pop:true),
        _mi('asp_d5','Pilav Üstü Döner',720,'Pilav + döner','assets/menu/pilav.png'),
        _mi('asp_d6','Sarma Döner Beyti',730,'Lavaşta sarma beyti döner','assets/food/doner.jpg'),
      ]),
      MenuCategory(id:'asp2', name:'🔥 Kebaplar', items:[
        _mi('asp_k1','Adana Kebap',700,'Baharatlı acı kıyma kebap','assets/food/et.jpg',spicy:true,pop:true),
        _mi('asp_k2','Urfa Kebap',700,'Tatlı kıyma kebap','assets/food/et.jpg'),
        _mi('asp_k3','Beyti Kebap',730,'Kıyma beyti, lavaş','assets/food/et.jpg',pop:true),
        _mi('asp_k4','Yoğurtlu Adana',730,'Adana + yoğurt sos','assets/food/et.jpg',spicy:true),
        _mi('asp_k5','Patlıcan Kebap',760,'Közlenmiş patlıcanlı kebap','assets/food/et.jpg'),
        _mi('asp_k6','Domatesli Kebap',760,'Domates soslu kebap','assets/food/et.jpg'),
        _mi('asp_k7','Kuzu Pirzola',900,'Izgara kuzu pirzola','assets/food/et.jpg',pop:true),
        _mi('asp_k8','Izgara Köfte',700,'El yapımı ızgara köfte','assets/food/et.jpg'),
        _mi('asp_k9','Karışık Kebap',1950,'Karışık tabak: adana, urfa, tavuk, köfte','assets/food/et.jpg',pop:true),
      ]),
      MenuCategory(id:'asp3', name:'🧱 Kiremitte', items:[
        _mi('asp_ki1','Kiremitte Köfte',740,'Kiremit tencerede köfte','assets/food/et.jpg'),
        _mi('asp_ki2','Kiremitte Et Şiş',930,'Kiremit tencerede et şiş','assets/food/et.jpg',pop:true),
        _mi('asp_ki3','Kiremitte Tavuk Şiş',640,'Kiremit tencerede tavuk şiş','assets/food/tavuk_dunyasi.jpg'),
      ]),
      MenuCategory(id:'asp4', name:'🫓 Pideler', items:[
        _mi('asp_p1','Kuşbaşılı Kaşarlı Pide',710,'Kuşbaşı et + kaşar pide','assets/food/pide_lahmacun.jpg',pop:true),
        _mi('asp_p2','Kapalı Dönerli Pide',700,'Dönerli kapalı pide','assets/food/pide_lahmacun.jpg'),
        _mi('asp_p3','Kaşarlı Pide',620,'Sade kaşarlı pide','assets/food/pide_lahmacun.jpg',veg:true),
        _mi('asp_p4','Karışık Pide',700,'Karışık malzemeli pide','assets/food/pide_lahmacun.jpg',pop:true),
        _mi('asp_p5','Kıymalı Pide',610,'Kıymalı pide','assets/food/pide_lahmacun.jpg'),
        _mi('asp_p6','Kuşbaşılı Pide',690,'Kuşbaşı etli pide','assets/food/pide_lahmacun.jpg'),
        _mi('asp_p7','Kıymalı Kaşarlı Pide',630,'Kıyma + kaşar pide','assets/food/pide_lahmacun.jpg'),
        _mi('asp_p8','Mantarlı Kaşarlı Pide',630,'Mantar + kaşar pide','assets/food/pide_lahmacun.jpg',veg:true),
        _mi('asp_p9','Lahmacun',400,'İnce hamur kıymalı lahmacun','assets/food/pide_lahmacun.jpg'),
      ]),
      MenuCategory(id:'asp5', name:'🍢 Şişler', items:[
        _mi('asp_s1','Kuzu Şiş',900,'Izgara kuzu şiş','assets/food/et.jpg',pop:true),
        _mi('asp_s2','Tavuk Şiş',600,'Izgara tavuk şiş','assets/food/tavuk_dunyasi.jpg'),
        _mi('asp_s3','Tavuk Kanat',620,'Izgara tavuk kanat','assets/food/tavuk_dunyasi.jpg'),
        _mi('asp_s4','Ali Nazik Kuzu Şiş',930,'Kuzu şiş + ali nazik ezmesi','assets/food/et.jpg',pop:true),
        _mi('asp_s5','Ali Nazik Kebap',750,'Patlıcan ezmesi + kebap','assets/food/et.jpg'),
        _mi('asp_s6','Et Çöp Şiş',830,'İnce et çöp şiş','assets/food/et.jpg'),
        _mi('asp_s7','Ciğer Şiş',830,'Izgara ciğer şiş','assets/food/et.jpg'),
      ]),
      MenuCategory(id:'asp6', name:'🥗 Yan Ürünler', items:[
        _mi('asp_y1','İçli Köfte',130,'Geleneksel bulgur içli köfte','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('asp_y2','Çoban Salata',200,'Domates, salatalık, soğan, maydanoz','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
      ]),
      MenuCategory(id:'asp7', name:'🥤 İçecekler', items:[
        _mi('asp_i1','Kola',120,'330ml','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('asp_i2','Fanta',120,'330ml','assets/menu/icecekler.png'),
        _mi('asp_i3','Sprite',120,'330ml','assets/menu/icecekler.png'),
        _mi('asp_i4','Fuse Tea',120,'330ml','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('asp_i5','Meyve Suyu',120,'Çeşitli tatlar','assets/menu/portakal_suyu.png'),
        _mi('asp_i6','Şalgam Acılı',120,'Geleneksel şalgam','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
        _mi('asp_i7','Şalgam Acısız',120,'Acısız şalgam','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
        _mi('asp_i8','Ayran',100,'Soğuk ayran','assets/menu/icecekler.png'),
        _mi('asp_i9','Soda',80,'Soda 200ml','assets/menu/icecekler.png'),
        _mi('asp_i10','Su',40,'500ml su','assets/menu/su.png'),
      ]),
    ],
    'bulentborekci': [
      MenuCategory(id:'bb1', name:'🥐 Börekler', items:[
        _mi('bb_b1','Su Böreği',180,'El açması, peynirli veya kıymalı','assets/menu/su.png',pop:true),
        _mi('bb_b2','Sigara Böreği (6 adet)',120,'Peynirli çıtır sigara böreği','assets/food/pastane_firin.jpg',pop:true,veg:true),
        _mi('bb_b3','Kol Böreği',150,'Çıtır hamuruyla kol böreği','assets/food/pastane_firin.jpg',veg:true),
        _mi('bb_b4','Patatesli Börek',130,'İç dolgulu patatesli börek','assets/food/pastane_firin.jpg',veg:true),
        _mi('bb_b5','Ispanaklı Börek',130,'İspanak + peynir dolgulu börek','assets/food/pastane_firin.jpg',veg:true),
        _mi('bb_b6','Peynirli Börek',120,'Beyaz peynirli börek','assets/food/pastane_firin.jpg',veg:true),
        _mi('bb_b7','Etli Börek',160,'Kıymalı börek','assets/food/pastane_firin.jpg'),
      ]),
      MenuCategory(id:'bb2', name:'🫓 Poğaça & Simit', items:[
        _mi('bb_p1','Peynirli Poğaça',35,'Taze pişmiş peynirli poğaça','assets/food/pastane_firin.jpg',veg:true,pop:true),
        _mi('bb_p2','Zeytinli Poğaça',35,'Zeytin dolgulu poğaça','assets/food/pastane_firin.jpg',veg:true),
        _mi('bb_p3','Patatesli Poğaça',35,'Patates dolgulu poğaça','assets/food/pastane_firin.jpg',veg:true),
        _mi('bb_p4','Simit',25,'Taze susamlı simit','assets/food/pastane_firin.jpg',veg:true,pop:true),
        _mi('bb_p5','Açma',30,'Yumuşak açma','assets/food/pastane_firin.jpg',veg:true),
      ]),
      MenuCategory(id:'bb3', name:'🍳 Kahvaltı', items:[
        _mi('bb_kh1','Kahvaltı Tabağı',150,'Peynir, zeytin, domates, salatalık, yumurta','assets/menu/kahvalti.png',veg:true,pop:true),
        _mi('bb_kh2','Menemen',120,'Domates, biber, yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
        _mi('bb_kh3','Sahanda Yumurta',80,'Tereyağlı sahanda yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
        _mi('bb_kh4','Gözleme (Peynirli)',100,'El yapımı peynirli gözleme','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true,pop:true),
        _mi('bb_kh5','Gözleme (Ispanaklı)',100,'El yapımı ıspanaklı gözleme','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
      MenuCategory(id:'bb4', name:'🥤 İçecekler', items:[
        _mi('bb_i1','Çay',20,'Demli çay bardak','assets/menu/cay.png',veg:true,pop:true),
        _mi('bb_i2','Türk Kahvesi',40,'Geleneksel Türk kahvesi','assets/menu/kahve.png',veg:true),
        _mi('bb_i3','Ayran',30,'Soğuk ayran','assets/menu/icecekler.png',veg:true),
        _mi('bb_i4','Su',15,'500ml su','assets/menu/su.png',veg:true),
      ]),
    ],
    'tatli': [
      MenuCategory(id:'tat1', name:'🍮 Tatlılar', items:[
        _mi('tat_b1','Baklava (6 Dilim)',280.00,'Antep fıstıklı ev baklavası','assets/menu/baklava.png',veg:true,pop:true),
        _mi('tat_b2','Fıstıklı Baklava (4 Dilim)',240.00,'Özel fıstıklı baklava','assets/menu/baklava.png',veg:true),
        _mi('tat_k1','Kadayıf',220.00,'Şerbetli tel kadayıf, fıstıklı','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true),
        _mi('tat_ke1','Künefe',260.00,'Sıcak künefe, kaymak, antep fıstığı','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true,pop:true),
        _mi('tat_s1','Sütlaç',160.00,'Fırın sütlaç, tarçın','assets/menu/sutlu_tatlilar.png',veg:true,pop:true),
        _mi('tat_h1','Helva',150.00,'İrmik helvası, fıstıklı','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true),
        _mi('tat_a1','Aşure',160.00,'Geleneksel aşure, kuru meyve','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('tat_m1','Muhallebi',150.00,'Gül sulu muhallebi','assets/menu/sutlu_tatlilar.png',veg:true),
      ]),
      MenuCategory(id:'tat2', name:'🍦 Dondurma & Profiterol', items:[
        _mi('tat_d1','Dondurma (3 Top)',180.00,'Çikolata, çilek, vanilyalı','https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=400',veg:true,pop:true),
        _mi('tat_d2','Dondurma (5 Top)',250.00,'5 top dondurma, söz hakkın senin','https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=400',veg:true),
        _mi('tat_p1','Profiterol',210.00,'Çikolata soslu profiterol, vanilyalı dondurma','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true,pop:true),
        _mi('tat_sf1','Sufle',230.00,'Sıcak çikolatalı sufle, dondurma ile','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
      MenuCategory(id:'tat3', name:'🎂 Kek & Pasta', items:[
        _mi('tat_c1','Cheesecake',220.00,'New York usulü cheesecake, çilek sos','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('tat_c2','Tiramisu',210.00,'İtalyan tiramisu, espresso','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('tat_c3','Çikolatalı Kek',190.00,'Islak çikolatalı kek, ganaj','assets/menu/kek.png',veg:true),
        _mi('tat_c4','Limonlu Tart',200.00,'Taze limon kremalı tart','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinks('tatd'),
    ],
  };

  static MenuItem _mi(String id, String name, double price, String desc, String img,
      {bool pop=false, bool veg=false, bool spicy=false, List<MenuOption> opts=const[]}) =>
    MenuItem(id:id, name:name, description:desc, price:price, imageUrl:img,
        isPopular:pop, isVegetarian:veg, isSpicy:spicy, options:opts);

  static MenuCategory _drinks(String pfx) => MenuCategory(
    id:'${pfx}_d', name:'🥤 İçecekler', items:[
      MenuItem(id:'${pfx}d1', name:'Ayran', description:'Soğuk ayran 300ml', price:55.00, imageUrl: 'assets/menu/icecekler.png'),
      MenuItem(id:'${pfx}d2', name:'Cola', description:'330ml', price:65.00, imageUrl: 'assets/menu/icecekler.png'),
      MenuItem(id:'${pfx}d3', name:'Su', description:'500ml', price:50.00, imageUrl: 'assets/menu/su.png'),
      MenuItem(id:'${pfx}d4', name:'Meyve Suyu', description:'Taze sıkılmış portakal', price:80.00, imageUrl: 'assets/menu/portakal_suyu.png'),
    ],
  );

  static const Map<String, String> _cuisineMenuKey = {
    'Pizza':'pizza','Burger':'burger','Döner':'doner','Tavuk':'tavuk',
    'Pide & Lahmacun':'pide','Et':'et','Deniz Ürünleri':'deniz',
    'Vegan & Vejetaryen':'vegan','Kahvaltı':'kahvalti','Sokak Lezzetleri':'sokak',
    'Mantı & Makarna':'manti','Kahve & İçecek':'kahve',
    'Pastane & Fırın':'pastane','Aperatif':'aperatif','Ev Yemekleri':'ev',
    'Türk Mutfağı':'doner','Çiğ Köfte':'cigkofte','Tatlı':'tatli',
    'Dünya Mutfakları':'dunya',
  };

  static List<MenuCategory> getMenuForCuisine(String cuisine) {
    final key = _cuisineMenuKey[cuisine] ?? 'burger';
    return _menus[key] ?? _menus['burger']!;
  }

  /// Returns a cuisine-appropriate fallback image URL from Unsplash.
  static String fallbackImageForCuisine(String cuisine) {
    return _cuisineImgUrl[cuisine] ??
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600';
  }

  /// Restoran adına ve mutfağına göre kapak fotoğrafı seçer.
  /// Sokak Lezzetleri için ada göre farklı fotoğraf döndürür.
  static String fallbackImageForRestaurant(String cuisine, String name) {
    if (cuisine == 'Sokak Lezzetleri') {
      final n = name.toLowerCase();
      if (n.contains('kumpir')) return 'assets/food/kumpir.jpg';
      if (n.contains('tantuni')) return 'assets/food/tantuni.jpg';
      if (n.contains('kokoreç') || n.contains('kokorec')) return 'assets/food/kokorec.jpg';
      // varsayılan: en tanınan sokak lezzeti
      return 'assets/food/kumpir.jpg';
    }
    return fallbackImageForCuisine(cuisine);
  }

  /// Returns (lat, lng) for a Turkish city name, or İstanbul if not found.
  static ({double lat, double lng}) getCityCoordinates(String city) {
    for (final c in _cities) {
      if ((c['name'] as String).toLowerCase() == city.toLowerCase()) {
        return (lat: c['lat'] as double, lng: c['lng'] as double);
      }
    }
    return (lat: 41.01, lng: 28.97); // İstanbul fallback
  }

  // ─── ANA ÜRETEC ───────────────────────────────────────────────
  static List<Restaurant> generateAllRestaurants() {
    if (_cache != null) return _cache!;
    final List<Restaurant> list = [];
    int idCounter = 1;

    final cuisines = _cuisineMenuKey.keys.where((c) => c != 'Türk Mutfağı').toList();

    for (final city in _cities) {
      final cityName = city['name'] as String;
      final baseLat = city['lat'] as double;
      final baseLng = city['lng'] as double;
      final pop = city['pop'] as int;

      // Nüfusa göre restoran sayısı (min 500, max 5000 simüle şehir başına)
      // Küçük şehirlerde bile yeterli restoran (min 1000)
      final localCount = (pop / 1500).clamp(1000, 10000).toInt();

      // 1) Lokal restoranlar
      for (int i = 0; i < localCount; i++) {
        final rng = Random(idCounter * 7 + i * 13);
        final cuisine = cuisines[rng.nextInt(cuisines.length)];
        final names = _cuisineNames[cuisine] ?? ['Restoran'];
        final prefix = _prefixes[rng.nextInt(_prefixes.length)];
        final suffix = names[rng.nextInt(names.length)];
        final name = rng.nextBool() ? '$prefix $suffix' : '$suffix $cityName';
        final street = _streets[rng.nextInt(_streets.length)];
        final no = rng.nextInt(99) + 1;

        final dist = 0.3 + rng.nextDouble() * 6.5;
        final bearing = rng.nextDouble() * 2 * pi;
        // approximate offset: 1deg lat ≈ 111km
        final lat = baseLat + (dist / 111) * cos(bearing);
        final lng = baseLng + (dist / (111 * cos(baseLat * pi / 180))) * sin(bearing);

        final rating = 3.0 + rng.nextDouble() * 2.0;
        final reviews = 10 + rng.nextInt(5000);
        final timeMin = [5,15,25,35,45][rng.nextInt(5)];
        final feeOptions = [0.0, 0.0, 4.99, 7.99, 9.99];
        final fee = feeOptions[rng.nextInt(feeOptions.length)];
        final minOrder = [40,50,60,70,80,100,120][rng.nextInt(7)].toDouble();
        final isOpen = rng.nextDouble() > 0.12;
        final badges = <String>[];
        if (rating >= 4.5 && reviews > 500) badges.add('Çok Satılan');
        if (i < 3) badges.add('Yeni');
        if (fee == 0.0 && timeMin <= 15) badges.add('Hızlı Teslimat');

        list.add(Restaurant(
          id: 'r_$idCounter',
          name: name,
          imageUrl: fallbackImageForRestaurant(cuisine, name),
          cuisine: cuisine,
          rating: double.parse(rating.toStringAsFixed(1)),
          reviewCount: reviews,
          deliveryTimeMin: timeMin,
          deliveryTimeMax: timeMin + 10,
          deliveryFee: fee,
          minOrder: minOrder,
          isOpen: isOpen,
          tags: [cuisine, cityName],
          menu: getMenuForRestaurantByName('r_' + idCounter.toString(), cuisine, name),
          address: '$street No:$no, $cityName',
          distance: double.parse(dist.toStringAsFixed(1)),
          city: cityName,
          badges: badges,
          reviews: _generateReviews(rating, reviews ~/ 200, _rng),
        ));
        idCounter++;
      }

      // 2) Zincir restoranlar (her şehirde her zincirden 2-5 şube)
      for (final chain in _chains) {
        final branchCount = 2 + _rng.nextInt(4);
        for (int b = 0; b < branchCount; b++) {
          final rng2 = Random(idCounter * 11 + b * 17);
          final dist = 0.5 + rng2.nextDouble() * 5.5;
          final bearing = rng2.nextDouble() * 2 * pi;
          final lat = baseLat + (dist / 111) * cos(bearing);
          final lng = baseLng + (dist / (111 * cos(baseLat * pi / 180))) * sin(bearing);
          final rating = 3.8 + rng2.nextDouble() * 1.2;
          final reviews = 200 + rng2.nextInt(8000);
          final timeMin = [5,15,25,35][rng2.nextInt(4)];
          final imgIdx = (chain['img'] as int).clamp(0, _imgUrls.length - 1);

          // Şehre özgü şube isimleri
          final branchDistricts = ['Merkez','Kuzey','Güney','Doğu','Batı','Yeni','Eski'];
          final bName = b == 0 ? '${chain['name']} $cityName' : '${chain['name']} $cityName ${branchDistricts[b % branchDistricts.length]}';
          list.add(Restaurant(
            id: 'r_$idCounter',
            name: bName,
            imageUrl: _imgUrls[imgIdx],
            cuisine: chain['cuisine'],
            rating: double.parse(rating.toStringAsFixed(1)),
            reviewCount: reviews,
            deliveryTimeMin: timeMin,
            deliveryTimeMax: timeMin + 10,
            deliveryFee: chain['fee'],
            minOrder: chain['min'],
            isOpen: rng2.nextDouble() > 0.08,
            tags: [chain['cuisine'], cityName, 'Zincir'],
            menu: getMenuForRestaurant('r_$idCounter', chain['cuisine']),
            address: '${_streets[rng2.nextInt(_streets.length)]} No:${rng2.nextInt(50)+1}, $cityName',
            distance: double.parse(dist.toStringAsFixed(1)),
            city: cityName,
            badges: rating >= 4.5 ? ['Çok Satılan'] : [],
            reviews: _generateReviews(rating, reviews ~/ 200, rng2),
          ));
          idCounter++;
        }
      }
    }

    list.sort((a, b) => a.distance.compareTo(b.distance));
    _cache = list;
    print('Toplam restoran: ${list.length}');
    return list;
  }

  /// Belirli bir kategori için kullanıcı konumuna yakın simüle restoranlar üretir.
  /// Kategori filtresinde boş kalan bölümleri doldurmak için kullanılır.
  static List<Restaurant> generateForCategory(
      String cuisine, double lat, double lng, {int count = 5}) {
    final names = _cuisineNames[cuisine] ?? ['Restoran'];
    final result = <Restaurant>[];
    for (int i = 0; i < count; i++) {
      final rng = Random(cuisine.hashCode.abs() * 31 + i * 97 + lat.hashCode.abs());
      final prefix = _prefixes[rng.nextInt(_prefixes.length)];
      final suffix = names[rng.nextInt(names.length)];
      final name = '$prefix $suffix';
      final dist = 0.5 + rng.nextDouble() * 4.5;
      final bearing = rng.nextDouble() * 2 * pi;
      final rLat = lat + (dist / 111) * cos(bearing);
      final rLng = lng + (dist / (111 * cos(lat * pi / 180))) * sin(bearing);
      final rating = 3.5 + rng.nextDouble() * 1.5;
      final reviews = 30 + rng.nextInt(1500);
      final timeMin = [15, 25, 35][rng.nextInt(3)];
      final fee = [0.0, 4.99, 7.99][rng.nextInt(3)];
      final minOrder = [50.0, 60.0, 70.0, 80.0][rng.nextInt(4)];
      // Cihazdan bağımsız sabit ID — hashCode kullanmıyoruz, kararsız!
      final stableSlug = cuisine
          .toLowerCase()
          .replaceAll('&', 'and')
          .replaceAll(RegExp(r'[^a-z0-9]'), '_');
      result.add(Restaurant(
        id: 'sim_${stableSlug}_$i',
        name: name,
        imageUrl: fallbackImageForRestaurant(cuisine, name),
        cuisine: cuisine,
        rating: double.parse(rating.toStringAsFixed(1)),
        reviewCount: reviews,
        deliveryTimeMin: timeMin,
        deliveryTimeMax: timeMin + 10,
        deliveryFee: fee,
        minOrder: minOrder,
        isOpen: rng.nextDouble() > 0.1,
        tags: [cuisine],
        menu: getMenuForCuisine(cuisine),
        address: '${_streets[rng.nextInt(_streets.length)]} No:${rng.nextInt(99) + 1}',
        distance: double.parse(dist.toStringAsFixed(1)),
        latitude: rLat,
        longitude: rLng,
        badges: rating >= 4.5 ? ['Çok Satılan'] : [],
        reviews: _generateReviews(rating, reviews ~/ 200, rng),
      ));
    }
    return result;
  }
}
