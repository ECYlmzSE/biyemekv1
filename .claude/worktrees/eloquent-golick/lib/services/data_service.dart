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
    'Pizza':'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
    'Burger':'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    'Döner':'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=500',
    'Tavuk':'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=500',
    'Pide & Lahmacun':'https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=500',
    'Et':'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500',
    'Deniz Ürünleri':'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=500',
    'Vegan & Vejetaryen':'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
    'Kahvaltı':'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500',
    'Sokak Lezzetleri':'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=500',
    'Mantı & Makarna':'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=500',
    'Kahve & İçecek':'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500',
    'Pastane & Fırın':'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
    'Aperatif':'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=500',
    'Ev Yemekleri':'https://images.unsplash.com/photo-1547592180-85f173990554?w=500',
    'Çiğ Köfte':'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500',
    'Dünya Mutfakları':'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=500',
    'Tatlı':'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500',
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
          _mi('bba1','Classic Smash',169.90,'180gr dana, cheddar, özel sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true,opts:[MenuOption(id:'bo1',name:'Ekstra Cheddar',price:15),MenuOption(id:'bo2',name:'Bacon',price:25),MenuOption(id:'bo3',name:'Soğan',isRemovable:true)]),
          _mi('bba2','Double Smash',219.90,'Çift et, çift peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bba3','Crispy Chicken',159.90,'Çıtır tavuk, coleslaw, turşu','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
          _mi('bba4','Veggie Deluxe',149.90,'Sebze köftesi, avokado, feta','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bba5','Mushroom Swiss',179.90,'Dana, mantar, swiss peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bba6','Bacon BBQ',189.90,'Dana, bacon, BBQ sos, soğan halkası','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bba7','Spicy Jalapeno',174.90,'Dana, jalapeño, acı sos, pepper jack','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',spicy:true),
          _mi('bba8','Truffle Smash',229.90,'Dana, trüf sosu, karamelize soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        ]),
        MenuCategory(id:'bma2', name:'🍟 Yanlar', items:[
          _mi('bsa1','Patates Küçük',39.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsa2','Patates Büyük',54.90,'Büyük boy','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsa3','Onion Rings 8',59.90,'8 adet + sos','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsa4','Mozza Sticks 6',69.90,'6 adet + marinara','https://images.unsplash.com/photo-1548340748-6af3e4b89898?w=400',veg:true),
          _mi('bsa5','Acı Kanatlar 6',79.90,'Baharatlı kanat + dip','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',spicy:true),
          _mi('bsa6','Sweet Potato Fries',59.90,'Tatlı patates + chipotle mayo','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        ]),
        MenuCategory(id:'bma3', name:'🧁 Tatlılar', items:[
          _mi('btd1','Çikolatalı Shake',79.90,'Milkshake, 400ml','https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400',veg:true),
          _mi('btd2','Cheesecake',89.90,'NY style cheesecake','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
          _mi('btd3','Brownie',69.90,'Sıcak brownie + vanilya dondurma','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        ]),
        _drinksEx('bda'),
      ],
      // Varyant B - Korean & Gourmet
      [
        MenuCategory(id:'bmb1', name:'🌶️ Signature Burgerler', items:[
          _mi('bbb1','Korean BBQ',199.90,'Bulgogi sos, kimchi mayo, çıtır soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',spicy:true,pop:true),
          _mi('bbb2','Truffle Deluxe',224.90,'Siyah trüf sosu, gruyère, arugula','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbb3','Nashville Hot',184.90,'Nashville acı tavuk, pickle, brioche','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',spicy:true),
          _mi('bbb4','Smoked Brisket',239.90,'Tütsülenmiş brisket, coleslaw, pickles','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbb5','Plant-Based Smash',154.90,'Bitki bazlı et, vegan sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bbb6','Breakfast Smash',164.90,'Dana, yumurta, cheddar, sosis','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbb7','Blue Cheese Burger',199.90,'Angus, gorgonzola, ceviz, roka','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbb8','Lamb Burger',229.90,'Kuzu kıyma, harissa, tzatziki','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        ]),
        MenuCategory(id:'bmb2', name:'🍟 Smash Yanlar', items:[
          _mi('bsb1','Skin-on Fries',49.90,'Kabuklu patates, tuz, karabiber','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsb2','Smash Nuggets 8',79.90,'8 adet et top + dip sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bsb3','Halloumi Fries',74.90,'Kızarmış hellim + nane sosu','https://images.unsplash.com/photo-1548340748-6af3e4b89898?w=400',veg:true),
          _mi('bsb4','Truffle Mac & Cheese',94.90,'Kremalı makarna, trüf, parmesan','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',veg:true),
          _mi('bsb5','Wedge Salata',79.90,'Iceberg, blue cheese, cherry domates','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        ]),
        _drinksEx('bdb'),
      ],
      // Varyant C - Wagyu & Premium
      [
        MenuCategory(id:'bmc1', name:'👑 Premium Burgerler', items:[
          _mi('bbc1','Wagyu Burger',279.90,'A5 wagyu, trüf mayo, altın soğan','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbc2','Angus Classic',219.90,'Black Angus, karamelize soğan, brie','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbc3','Surf & Turf',299.90,'Dana + karides, garlic butter','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbc4','Portobello Gourmet',179.90,'Portobello mantar, feta, pesto','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bbc5','Foie Gras',319.90,'Angus, foie gras, sautéed elma','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
          _mi('bbc6','Smash Royale',249.90,'Triple smash, özel tatlı sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('bbc7','Vegan Royale',169.90,'Jackfruit, smoky mayo, crispy onion','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('bbc8','Signature Stack',289.90,'Çift wagyu, triple peynir, bacon','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        ]),
        MenuCategory(id:'bmc2', name:'🥂 Premium Yanlar', items:[
          _mi('bsc1','Gourmet Fries',64.90,'Parmesan, trüf yağı, maydanoz','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('bsc2','Bone Marrow',129.90,'Fırın kemik iliği, kızarmış ekmek','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('bsc3','Tuna Tartar',149.90,'Taze ton balığı, avokado, çıtır ekmek','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('bsc4','Lobster Bisque',119.90,'Istakoz çorbası, krema, kruvasan','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        ]),
        _drinksEx('bdc'),
      ],
    ],
    'pizza': [
      [
        MenuCategory(id:'pma1', name:'🍕 Klasik Pizzalar', items:[
          _mi('pba1','Margarita',139.90,'Domates, mozzarella, fesleğen','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true,veg:true,opts:[MenuOption(id:'po1',name:'Ekstra Peynir',price:20),MenuOption(id:'po2',name:'İnce Hamur'),MenuOption(id:'po3',name:'Kalın Hamur')]),
          _mi('pba2','Karışık',179.90,'Sucuk, mantar, biber, zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
          _mi('pba3','BBQ Tavuk',169.90,'BBQ sos, tavuk, soğan, taze biber','https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400'),
          _mi('pba4','4 Peynirli',189.90,'Mozza, cheddar, parmesan, gouda','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pba5','Pepperoni',169.90,'Bol pepperoni, mozzarella','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
          _mi('pba6','Vegetariana',159.90,'Renkli biber, mantar, zeytin, mısır','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pba7','Prosciutto',199.90,'Prosciutto, roka, parmesan','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('pba8','Diavola',174.90,'Acılı salam, mozzarella','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
        ]),
        MenuCategory(id:'pma2', name:'🥗 Başlangıçlar', items:[
          _mi('psa1','Garlic Bread',49.90,'Sarımsaklı ekmek','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('psa2','Sezar Salata',79.90,'Romain, crouton, parmesan','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
          _mi('psa3','Mozzarella Sticks 6',69.90,'Kızarmış mozza + marinara','https://images.unsplash.com/photo-1548340748-6af3e4b89898?w=400',veg:true),
          _mi('psa4','Bruschetta 3',74.90,'Domates, fesleğen, sarımsak','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
        ]),
        _drinksEx('pda'),
      ],
      [
        MenuCategory(id:'pmb1', name:'🍕 Napoliten Pizzalar', items:[
          _mi('pbb1','Margherita DOC',149.90,'San Marzano domates, bufala mozza','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true,veg:true),
          _mi('pbb2','Marinara',129.90,'Domates, sarımsak, origano','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pbb3','Napoli',164.90,'Ançuez, kapari, siyah zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
          _mi('pbb4','Quattro Stagioni',189.90,'Mantar, jambon, enginar, zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
          _mi('pbb5','Bianca Funghi',169.90,'Beyaz sos, karışık mantar, trüf','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true,pop:true),
          _mi('pbb6','Salame Piccante',179.90,'Acı salam, nduja','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
          _mi('pbb7','Prosciutto Rucola',194.90,'San Daniele, roka, grana padano','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('pbb8','Puttanesca',174.90,'Domates, ançuez, siyah zeytin, kapari','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',spicy:true),
        ]),
        MenuCategory(id:'pmb2', name:'🥙 Calzone & Focaccia', items:[
          _mi('psb1','Calzone Klasik',159.90,'Kapalı pizza, ricotta, salam, ıspanak','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('psb2','Focaccia Rosmarino',69.90,'Biberiye, deniz tuzu','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('psb3','Stromboli',149.90,'Sarılı pizza, salam, biber, peynir','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
        ]),
        _drinksEx('pdb'),
      ],
      [
        MenuCategory(id:'pmc1', name:'🍕 Türk Fusion Pizzalar', items:[
          _mi('pbc1','Sucuklu Kaşar',164.90,'Türk sucuğu, kaşar, domates','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true),
          _mi('pbc2','Lahmacun Pizza',149.90,'İnce kıymalı lahmacun pizza','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',spicy:true),
          _mi('pbc3','Döner Pizza',179.90,'Döner et, domates sos, soğan, biber','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',pop:true),
          _mi('pbc4','Pastırmalı',189.90,'Türk pastırması, yumurta, kaşar','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
          _mi('pbc5','Ispanaklı Beyaz',164.90,'Beyaz sos, ıspanak, feta','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pbc6','Karadeniz Fındıklı',174.90,'Fındık ezmesi, feta, bal, arugula','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('pbc7','Acılı Bonfile',199.90,'Bonfile dilimi, acı biber sosu, roka','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',spicy:true),
          _mi('pbc8','Kuzulu Özel',209.90,'Kuzu döner, sumak soğanı, nar ekşisi','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true),
        ]),
        MenuCategory(id:'pmc2', name:'🥗 Mezeler', items:[
          _mi('psc1','Domates Çorbası',49.90,'Taze domates, krema, fesleğen','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
          _mi('psc2','Humus & Pita',59.90,'Ev yapımı humus, taze pita','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        ]),
        _drinksEx('pdc'),
      ],
    ],
    'doner': [
      [
        MenuCategory(id:'doa1', name:'🌯 Dürüm & Döner', items:[
          _mi('doa1','Et Dürüm',89.90,'Dana döner, lavaş, sebze, sos','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
          _mi('doa2','Tavuk Dürüm',79.90,'Tavuk döner, lavaş, yoğurt sos','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
          _mi('doa3','Karışık Dürüm',94.90,'Et+tavuk, közlenmiş sebze','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
          _mi('doa4','İskender Dürüm',99.90,'İskender sos, tereyağı, yoğurt','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
          _mi('doa5','Et Porsiyon',129.90,'200gr döner + pilav + salata','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
          _mi('doa6','Tavuk Porsiyon',109.90,'200gr tavuk döner + pilav','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
          _mi('doa7','Yarım Ekmek Döner',69.90,'Yarım ekmek, et döner','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
          _mi('doa8','Döner Tabak',149.90,'Et döner, bulgur, közlenmiş domates','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        ]),
        MenuCategory(id:'doa2', name:'🥗 Mezeler & Çorbalar', items:[
          _mi('dos1','Mercimek Çorbası',44.90,'Ev yapımı, sıcak','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
          _mi('dos2','Cacık',34.90,'Yoğurt, salatalık, nane','https://images.unsplash.com/photo-1460306855393-a4056d5f740b?w=400',veg:true),
          _mi('dos3','Közlenmiş Patlıcan',49.90,'Sarımsaklı yoğurt, nar ekşisi','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        ]),
        _drinksEx('doda'),
      ],
      [
        MenuCategory(id:'dob1', name:'🥙 Kebap Çeşitleri', items:[
          _mi('dob1','Adana Kebap',149.90,'Acılı kıyma, közlenmiş biber, lavaş','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',spicy:true,pop:true),
          _mi('dob2','Urfa Kebap',144.90,'Tatlı kıyma, soğan, domates','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
          _mi('dob3','Tavuk Şiş',129.90,'Marine edilmiş tavuk şiş','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
          _mi('dob4','Kuzu Şiş',169.90,'Közlenmiş kuzu parça','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
          _mi('dob5','Karışık Izgara',219.90,'Adana+urfa+şiş tabağı','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
          _mi('dob6','Patlıcanlı Kebap',154.90,'Döner + közlenmiş patlıcan','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        ]),
        MenuCategory(id:'dob2', name:'🍚 Pilav & Ekstra', items:[
          _mi('dob7','Bulgur Pilavı',39.90,'Nohutlu bulgur pilavı','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
          _mi('dob8','Pirinç Pilav',34.90,'Tereyağlı pirinç','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
          _mi('dob9','Lavaş Ekmek',14.90,'Taze lavaş','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
        ]),
        _drinksEx('dodb'),
      ],
      [
        MenuCategory(id:'doc1', name:'🌮 Wrap & Sandviç', items:[
          _mi('doc1','Tavuk Wrap',84.90,'Izgara tavuk, mısır, salata, sezar','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
          _mi('doc2','Et Wrap',94.90,'Döner et, domates, turşu, sos','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
          _mi('doc3','Falafel Wrap',74.90,'Vegan falafel, humus, sebze','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
          _mi('doc4','Kokoreç Sandviç',69.90,'Klasik kokoreç, ekmek','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',spicy:true),
          _mi('doc5','Midye Tava Sandviç',64.90,'Taze midye tava, limon','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
          _mi('doc6','Balık Ekmek',79.90,'Izgara balık, soğan, biber','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400'),
        ]),
        _drinksEx('dodc'),
      ],
    ],
    'tavuk': [
      [
        MenuCategory(id:'tva1', name:'🍗 Çıtır Tavuk', items:[
          _mi('tva1','Crispy Tavuk Menu',129.90,'3 parça çıtır + patates + içecek','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('tva2','Tavuk Burger',109.90,'Çıtır tavuk, coleslaw, turşu','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
          _mi('tva3','Spicy Tavuk',119.90,'Acılı baharat, sriracha mayo','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',spicy:true),
          _mi('tva4','Kanat 6 Parça',89.90,'BBQ veya buffalo sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',pop:true),
          _mi('tva5','Nugget 9',79.90,'9 adet nugget + sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400'),
          _mi('tva6','Tender 5',94.90,'5 adet fileto tender','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400'),
          _mi('tva7','Jumbo Kanat 12',149.90,'12 adet jumbo kanat','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',pop:true),
        ]),
        MenuCategory(id:'tva2', name:'🍟 Yanlar', items:[
          _mi('tvs1','Patates Küçük',39.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('tvs2','Patates Büyük',54.90,'Büyük boy','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('tvs3','Coleslaw',39.90,'Lahana salatası','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        ]),
        _drinksEx('tvda'),
      ],
      [
        MenuCategory(id:'tvb1', name:'🔥 Izgara Tavuk', items:[
          _mi('tvb1','Fırın Tavuk Yarım',129.90,'Yarım közlenmiş piliç + pilav','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',pop:true),
          _mi('tvb2','Tavuk Şiş',119.90,'4 şiş, lavaş, acı sos','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
          _mi('tvb3','Tavuk Döner Tabak',109.90,'Döner, pilav, salata','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
          _mi('tvb4','Tavuk Sote',124.90,'Mantar, biber, krema sosu','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',pop:true),
          _mi('tvb5','Soslu Tavuk Parça',99.90,'3 parça, sos seçimi','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
        ]),
        _drinksEx('tvdb'),
      ],
    ],
    'pide': [
      [
        MenuCategory(id:'pia1', name:'🫓 Pide Çeşitleri', items:[
          _mi('pia1','Kıymalı Pide',79.90,'İnce kıyma, domates, biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('pia2','Kaşarlı Pide',74.90,'Bol kaşar peyniri','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
          _mi('pia3','Kuşbaşılı Pide',94.90,'Dana kuşbaşı, biber, domates','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('pia4','Karışık Pide',89.90,'Kıyma + kaşar + sucuk','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('pia5','Sucuklu Yumurtalı',84.90,'Sucuk, yumurta, kaşar','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('pia6','Ispanaklı Peynirli',79.90,'Ispanak, beyaz peynir, yumurta','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        ]),
        MenuCategory(id:'pia2', name:'🌮 Lahmacun', items:[
          _mi('pil1','Lahmacun 3 Adet',69.90,'İnce kıymalı klasik','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true,spicy:true),
          _mi('pil2','Acısız Lahmacun 3',69.90,'Tatlı biber, az baharatlı','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('pil3','Simit Sarayı Lahmacun',74.90,'Extra kıyma + nar ekşisi','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',spicy:true),
        ]),
        _drinksEx('pida'),
      ],
      [
        MenuCategory(id:'pib1', name:'🫓 Karadeniz Pidesi', items:[
          _mi('pib1','Karadeniz Kaşar Pide',84.90,'Sürme tereyağı, taze kaşar','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true,veg:true),
          _mi('pib2','Hamsi Pidesi',94.90,'Taze hamsi, mısır, karabiber','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400'),
          _mi('pib3','Tereyağlı Yumurtalı',79.90,'Sürme tereyağı, köy yumurtası','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
          _mi('pib4','Kıymalı Karadeniz',89.90,'Kıyma, soğan, Karadeniz baharatı','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        ]),
        _drinksEx('pidb'),
      ],
    ],
    'et': [
      [
        MenuCategory(id:'eta1', name:'🥩 Izgara Et Lezzetleri', items:[
          _mi('eta1','Antrikot 250gr',299.90,'Wagyu/Angus, garnitür + salata','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
          _mi('eta2','Ribeye 300gr',349.90,'Mermer yağlı ribeye, sote mantar','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
          _mi('eta3','Dana Köfte 3',139.90,'El yapımı köfte, közlenmiş sebze','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
          _mi('eta4','Kuzu Pirzola 4',249.90,'Fırın kuzu, biberiye, sarımsak','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
          _mi('eta5','Bonfile 200gr',279.90,'Tenderloin, trüf sosu','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
          _mi('eta6','Kuzu Tandır',219.90,'Fırın kuzu tandır + pilav','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
        ]),
        MenuCategory(id:'eta2', name:'🥗 Garnitürler', items:[
          _mi('ets1','Sote Mantar',49.90,'Tereyağlı sote mantar','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
          _mi('ets2','Patates Rösti',54.90,'Fırın patates rösti','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
          _mi('ets3','Izgara Sebze',59.90,'Kabak, biber, patlıcan ızgara','https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',veg:true),
        ]),
        _drinksEx('etda'),
      ],
    ],
    'deniz': [
      [
        MenuCategory(id:'dena1', name:'🐟 Balık Çeşitleri', items:[
          _mi('dena1','Izgara Levrek',229.90,'Taze levrek, limon, roka','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',pop:true),
          _mi('dena2','Izgara Çipura',219.90,'Akdeniz çipura, zeytinyağı','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400'),
          _mi('dena3','Somon Izgara',249.90,'Norveç somon, dereotu sos','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',pop:true),
          _mi('dena4','Tava Hamsi',149.90,'Karadeniz hamsisi, mısır unu','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400'),
          _mi('dena5','Kalamar Tava',179.90,'Çıtır kalamar, tartar sos','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400'),
          _mi('dena6','Midye Tava 10',99.90,'10 adet midye tava, limon','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('dena7','Ahtapot Izgara',199.90,'Közlenmiş ahtapot, zeytinyağı','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',pop:true),
        ]),
        MenuCategory(id:'dena2', name:'🦐 Deniz Ürünleri', items:[
          _mi('dens1','Karides Sote',189.90,'Tereyağı, sarımsak, limon','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('dens2','Paella',249.90,'İspanyol pirinç, deniz ürünleri','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('dens3','Balık Çorbası',79.90,'Günlük taze balık çorbası','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        ]),
        _drinksEx('denrda'),
      ],
    ],
    'vegan': [
      [
        MenuCategory(id:'vga1', name:'🌱 Ana Yemekler', items:[
          _mi('vga1','Buddha Bowl',129.90,'Quinoa, avokado, edamame, nar','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
          _mi('vga2','Falafel Tabak',119.90,'6 adet falafel, humus, tabbule','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
          _mi('vga3','Jackfruit Burger',129.90,'Vegan et alternatifi, smash bun','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true,pop:true),
          _mi('vga4','Vegan Pizza',149.90,'Cashew mozzarella, sebze bol','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
          _mi('vga5','Sebzeli Wrap',99.90,'Izgara sebze, humus, roka','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
          _mi('vga6','Mercimek Köftesi',89.90,'Kırmızı mercimek, bulgur','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true),
        ]),
        MenuCategory(id:'vga2', name:'🥣 Salatalar & Kaseler', items:[
          _mi('vgs1','Yeşil Salata',74.90,'Miks yeşillik, nar, ceviz, balsamik','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
          _mi('vgs2','Ton Balığı Salatası',99.90,'Limon sos, kapari, zeytin','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400'),
          _mi('vgs3','Acai Bowl',109.90,'Açai, granola, taze meyve, chia','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
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
          _mi('kab2','Full Kahvaltı',129.90,'Bacon, yumurta, sosis, fasulye, toast','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
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
          _mi('ska1','Kumpir Büyük',99.90,'Patates, 5 malzeme, sos','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
          _mi('ska2','Kokoreç ½ Ekmek',79.90,'Bağırsak, baharatlar, ekmek','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',spicy:true,pop:true),
          _mi('ska3','Midye Dolma 10',69.90,'10 adet, limon, acı sos','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
          _mi('ska4','Simit Sandviç',44.90,'Kaşar + domates + zeytin','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('ska5','Balık Ekmek',89.90,'Boğaz balığı, soğan, maydanoz','https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400'),
          _mi('ska6','Islak Burger',59.90,'Domates soslu ıslak burger','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
          _mi('ska7','Mısır (Büyük)',39.90,'Fırın mısır, tereyağı','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
          _mi('ska8','Tost Karışık',54.90,'Kaşar + sucuk + domates','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
        ]),
        _drinksEx('skda'),
      ],
      [
        MenuCategory(id:'skb1', name:'🥙 Simit & Açık Büfe', items:[
          _mi('skb1','Pide Tost',49.90,'Pide ekmeğinde karışık tost','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
          _mi('skb2','Gözleme Peynirli',54.90,'El açması, taze peynir','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true,pop:true),
          _mi('skb3','Gözleme Kıymalı',59.90,'El açması, kıyma, biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',spicy:true),
          _mi('skb4','Börek Peynirli',54.90,'Yufka, beyaz peynir, bol ot','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true,pop:true),
          _mi('skb5','Çiğ Köfte Dürüm',49.90,'Acılı/acısız, nar ekşisi','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
        ]),
        _drinksEx('skdb'),
      ],
    ],
    'manti': [
      [
        MenuCategory(id:'mna1', name:'🥟 Mantı Çeşitleri', items:[
          _mi('mna1','Kayseri Mantısı',119.90,'El yapımı, yoğurt, kırmızı tereyağı','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',pop:true),
          _mi('mna2','Sulu Mantı',114.90,'Et suyu, yoğurt, pul biber','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',pop:true),
          _mi('mna3','Kızartma Mantı',124.90,'Kızartılmış, üzerine yoğurt','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400'),
          _mi('mna4','Vegan Mantı',109.90,'Sebze iç harçlı, cashew yoğurt','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400',veg:true),
        ]),
        MenuCategory(id:'mna2', name:'🍝 Makarna', items:[
          _mi('mns1','Spaghetti Bolognese',119.90,'Dana kıyma, domates sos, parmesan','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400'),
          _mi('mns2','Carbonara',129.90,'Guanciale, yumurta sarısı, pecorino','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',pop:true),
          _mi('mns3','Penne Arrabbiata',109.90,'Acı domates sos, sarımsak','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',veg:true,spicy:true),
          _mi('mns4','Fettuccine Alfredo',119.90,'Kremalı, parmesan, karabiber','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',veg:true),
          _mi('mns5','Türk Makarna',94.90,'Kıymalı, domates sos, kaşar','https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',pop:true),
        ]),
        _drinksEx('mnda'),
      ],
    ],
    'kahve': [
      [
        MenuCategory(id:'kfa1', name:'☕ Sıcak İçecekler', items:[
          _mi('kfa1','Espresso',34.90,'Double shot, koyu kavrum','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa2','Flat White',54.90,'Ristretto bazlı, ince süt köpüğü','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true,pop:true),
          _mi('kfa3','Latte',54.90,'Espresso + bol süt','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa4','Cappuccino',54.90,'Espresso + sütlü köpük','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa5','Matcha Latte',64.90,'Japon matcha, oat milk','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true,pop:true),
          _mi('kfa6','Türk Kahvesi',39.90,'Geleneksel, lokum ile','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
          _mi('kfa7','Sıcak Çikolata',54.90,'Yoğun kakao, kremalı','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        ]),
        MenuCategory(id:'kfa2', name:'🧊 Soğuk İçecekler', items:[
          _mi('kfs1','Cold Brew',59.90,'12 saat demleme, soğuk servis','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
          _mi('kfs2','Iced Latte',59.90,'Espresso, buz, soğuk süt','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
          _mi('kfs3','Frappuccino',69.90,'Blended, çikolata/karamel','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
          _mi('kfs4','Smoothie Mango',64.90,'Mango, portakal, zencefil','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        ]),
        MenuCategory(id:'kfa3', name:'🥐 Atıştırmalık', items:[
          _mi('kfp1','Kruvasan',54.90,'Tereyağlı, içi boş veya dolgulu','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',veg:true),
          _mi('kfp2','Avokado Toast',79.90,'Ekşi maya, avokado, za''atar','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true,pop:true),
          _mi('kfp3','Tiramisu',74.90,'Mascarpone, espresso, kakao','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
          _mi('kfp4','Cheesecake',79.90,'NY style, çilek sosu','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
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
      MenuItem(id:'${pfx}d1',name:'Ayran',description:'Soğuk ayran 300ml',price:24.90,imageUrl:'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
      MenuItem(id:'${pfx}d2',name:'Cola 330ml',description:'Gazlı içecek',price:29.90,imageUrl:'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400'),
      MenuItem(id:'${pfx}d3',name:'Sprite 330ml',description:'Limonlu gazlı',price:29.90,imageUrl:'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400'),
      MenuItem(id:'${pfx}d4',name:'Su 500ml',description:'Kaynak suyu',price:12.90,imageUrl:'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
      MenuItem(id:'${pfx}d5',name:'Taze Portakal Suyu',description:'100% taze sıkılmış',price:39.90,imageUrl:'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400'),
      MenuItem(id:'${pfx}d6',name:'Limonata',description:'Taze limon, nane, soda',price:34.90,imageUrl:'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400'),
      MenuItem(id:'${pfx}d7',name:'Ice Tea',description:'Şeftali veya limon',price:32.90,imageUrl:'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
    ],
  );

  // ─── MENÜLER ─────────────────────────────────────────────────
  static final Map<String, List<MenuCategory>> _menus = {
    // ── ÖZEL MENÜLER ───────────────────────────────────────────
    'kumpir': [
      MenuCategory(id:'kmp1', name:'🥔 Kumpir', items:[
        _mi('kmp1','Kumpir Küçük',79.90,'Fırın patates, tereyağı, kaşar, 3 malzeme seçimi','https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400',pop:true,
          opts:[MenuOption(id:'km1',name:'Mısır'),MenuOption(id:'km2',name:'Rus Salatası'),MenuOption(id:'km3',name:'Zeytin'),MenuOption(id:'km4',name:'Turşu'),MenuOption(id:'km5',name:'Sucuk',price:10),MenuOption(id:'km6',name:'Sosis',price:10)]),
        _mi('kmp2','Kumpir Büyük',109.90,'Fırın patates, tereyağı, kaşar, 5 malzeme seçimi','https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400',pop:true,
          opts:[MenuOption(id:'km7',name:'Mısır'),MenuOption(id:'km8',name:'Rus Salatası'),MenuOption(id:'km9',name:'Zeytin'),MenuOption(id:'km10',name:'Turşu'),MenuOption(id:'km11',name:'Sucuk',price:10),MenuOption(id:'km12',name:'Mantar',price:12),MenuOption(id:'km13',name:'Meksika Fasulyesi',price:12),MenuOption(id:'km14',name:'Sosis',price:10),MenuOption(id:'km15',name:'Ekşi Krema',price:10),MenuOption(id:'km16',name:'Jalapeno',price:8)]),
        _mi('kmp3','Kumpir XL',134.90,'Jumbo boy, tereyağı, kaşar, 7 malzeme + ekstra sos','https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400',
          opts:[MenuOption(id:'km17',name:'Mısır'),MenuOption(id:'km18',name:'Rus Salatası'),MenuOption(id:'km19',name:'Zeytin'),MenuOption(id:'km20',name:'Mantar',price:12),MenuOption(id:'km21',name:'Sucuk',price:10)]),
        _mi('kmp4','Vejetaryen Kumpir',99.90,'Tereyağı, kaşar, mısır, mantar, biber, zeytin','https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400',veg:true),
        _mi('kmp5','Kumpir Menü',134.90,'Büyük kumpir + ayran + turşu','https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400',pop:true),
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
        _mi('cgk1','Dürüm Acılı',49.90,'Çiğ köfte, nar ekşisi, limon, lavaş','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true,spicy:true),
        _mi('cgk2','Dürüm Acısız',49.90,'Çiğ köfte, limon, lavaş','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
        _mi('cgk3','Tabak Orta',59.90,'200gr çiğ köfte, nar ekşisi, maydanoz','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true),
        _mi('cgk4','Tabak Büyük',79.90,'350gr çiğ köfte + 2 dürüm','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
        _mi('cgk5','İkili Dürüm',89.90,'2 adet dürüm, acı/acısız seçimli','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true),
        _mi('cgk6','Üçlü Menü',114.90,'3 dürüm + şalgam + turşu','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
      ]),
      MenuCategory(id:'cgk2', name:'🥤 İçecekler & Ekstra', items:[
        _mi('cgks1','Şalgam Suyu',19.90,'Acılı/acısız','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('cgks2','Ayran',19.90,'Soğuk ayran','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('cgks3','Turşu',12.90,'Karışık turşu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        _mi('cgks4','Ekstra Acı Sos',5.90,'Pul biber sosu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true,spicy:true),
        _mi('cgks5','Portakal Suyu',24.90,'Taze sıkılmış','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
      ]),
    ],
    'kokoreç': [
      MenuCategory(id:'kkr1', name:'🥙 Kokoreç', items:[
        _mi('kkr1','Kokoreç ½ Ekmek',79.90,'Bağırsak, kekik, kimyon, pul biber','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',pop:true,spicy:true),
        _mi('kkr2','Kokoreç Tam Ekmek',139.90,'Tam ekmek, bol baharat','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',pop:true),
        _mi('kkr3','Kokoreç Tabak',149.90,'200gr, pilav veya patates ile','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
        _mi('kkr4','Kokoreç Pide',89.90,'Pide üzerinde, extra peynir','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
        _mi('kkr5','Midye Dolma 10 Adet',69.90,'Taze midye, pirinç harcı, limon','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('kkr6','Islak Burger',64.90,'Özel sos, domates soslu','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
      ]),
      _drinksEx('kkrd'),
    ],
    'tantuni': [
      MenuCategory(id:'tnt1', name:'🌮 Tantuni', items:[
        _mi('tnt1','Tantuni Dürüm',74.90,'Dana et, soğan, domates, lavaş','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true,spicy:true),
        _mi('tnt2','Tantuni Ekmek',64.90,'Francala ekmek, özel sos','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
        _mi('tnt3','Tantuni Tabak',89.90,'200gr et, pilav, salata','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
        _mi('tnt4','İkili Dürüm Menü',129.90,'2 dürüm + şalgam + turşu','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
        _mi('tnt5','Tavuk Tantuni',69.90,'Tavuk göğsü, az yağlı, lavaş','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
      ]),
      _drinksEx('tntd'),
    ],
    'lahmacun': [
      MenuCategory(id:'lhm1', name:'🫓 Lahmacun', items:[
        _mi('lhm1','Lahmacun 3 Adet',69.90,'İnce kıyma, domates, taze biber','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true,spicy:true),
        _mi('lhm2','Lahmacun Acısız 3',69.90,'Tatlı biber versiyonu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('lhm3','Lahmacun + Ayran',84.90,'3 adet lahmacun + soğuk ayran','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('lhm4','Dürüm Lahmacun',59.90,'Dürüm şeklinde, limon, maydanoz','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
        _mi('lhm5','Lahmacun Aile (8 Adet)',169.90,'8 adet, maydanoz, limon, nar ekşisi','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'lhm2', name:'🥗 Yanlar', items:[
        _mi('lhms1','Turşu',10.90,'Ev turşusu','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        _mi('lhms2','Ayran',19.90,'Soğuk','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
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
        _mi('kfts1','Pilav',24.90,'Sade pilav','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
        _mi('kfts2','Piyaz',22.90,'Soğan, maydanoz, sirke','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('kfts3','Ayran',19.90,'Soğuk','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
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
        _mi('kfcy4','Mozaik Kek',69.90,'KFC mozaik kek','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
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
        _mi('popb3','Pop Dürüm',199.90,'Tavuk, salata, sos, lavaş','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
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
        _mi('sbx1','Caffè Latte',119.90,'Espresso + sütlü köpük','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbx2','Cappuccino',109.90,'Espresso, buharla ısıtılmış süt, köpük','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbx3','Caramel Macchiato',129.90,'Vanilyalı, karamelli espresso','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbx4','White Chocolate Mocha',129.90,'Beyaz çikolata, espresso, sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('sbx5','Americano',99.90,'Uzun espresso','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('sbx6','Türk Kahvesi',89.90,'Geleneksel Türk kahvesi','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
      ]),
      MenuCategory(id:'sbx2', name:'🧊 Soğuk Kahveler', items:[
        _mi('sbxc1','Iced Caramel Macchiato',139.90,'Buzlu karamel macchiato','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbxc2','Iced Latte',129.90,'Buzlu latte','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('sbxc3','Cold Brew',129.90,'24 saat demleme, soğuk kahve','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('sbxc4','Iced Americano',109.90,'Buzlu americano','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      MenuCategory(id:'sbx3', name:'🥛 Frappuccino & Diğer', items:[
        _mi('sbxf1','Caramel Frappuccino',149.90,'Kahve, karamel sos, krem şanti','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true,pop:true),
        _mi('sbxf2','Java Chip Frappuccino',149.90,'Kahve, çikolata parçaları','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('sbxf3','Matcha Latte',129.90,'Japon matcha çayı, sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      MenuCategory(id:'sbx4', name:'🥐 Fırın & Atıştırmalık', items:[
        _mi('sbxb1','Tereyağlı Kruvasan',89.90,'Taze pişirilmiş butter croissant','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('sbxb2','Brownie',89.90,'Starbucks brownie','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('sbxb3','Cheesecake',119.90,'Limonlu / ahududulu cheesecake','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('sbxb4','Muffin',79.90,'Çikolatalı veya yaban mersinli','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('sbxb5','Sandviç',119.90,'Tavuklu / peynirli sandviç seçenekleri','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
    ],
    'simitSarayi': [
      MenuCategory(id:'ss1', name:'🥐 Simitler & Börekler', items:[
        _mi('ss1','Simit',29.90,'Taze susamlı simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('ss2','Çoko Simit',44.90,'Çikolata dolgulu simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('ss3','Su Böreği',89.90,'El açması su böreği','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('ss4','Çıtır Kalem Börek',59.90,'Peynirli kalem börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('ss5','Kruvasan',69.90,'Tereyağlı / çikolatalı kruvasan','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('ss6','Poğaça',49.90,'Peynirli / zeytinli poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
      ]),
      MenuCategory(id:'ss2', name:'🥚 Kahvaltılar', items:[
        _mi('ssk1','Serpme Kahvaltı',359.90,'Peynir, zeytin, bal, kaymak, yumurta, sebze','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',pop:true,veg:true),
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
        _mi('ssi3','Türk Kahvesi',69.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('ssi4','Limonata',69.90,'Taze sıkma limonata','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('ssi5','Çay',29.90,'Bardak çay','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
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
        _mi('kom1','Çiğ Köfte 300g',259.90,'300g çiğ köfte, lavaş, yeşillik, sos','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true,spicy:true),
        _mi('kom2','Çiğ Köfte 500g Joker',369.90,'500g joker porsiyon + yeşillik','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true),
        _mi('kom3','Çiğ Köfte 1kg',749.90,'Aile boyu 1kg çiğ köfte','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
      ]),
      MenuCategory(id:'kom2', name:'🌯 Dürümler', items:[
        _mi('komd1','Favori Çiğ Köfte Dürüm',109.90,'Dürüm, yeşillik, sos','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true),
        _mi('komd2','Mega Çiğ Köfte Dürüm',119.90,'Büyük boy dürüm','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
        _mi('komd3','Doritos\'lu Dürüm',125.90,'Doritos ile ekstra çıtırlık','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true,pop:true),
        _mi('komd4','Double Dürüm',140.90,'Çift dürüm','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',veg:true),
      ]),
      MenuCategory(id:'kom3', name:'🍚 Pilav', items:[
        _mi('komp1','Tavuklu Pilav 200g',139.90,'Nohutlu pilav + tavuk','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('komp2','Tavuklu Pilav 400g',289.90,'Büyük boy pilav + tavuk','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('komp3','Nohut Pilav 150g',109.90,'Sade nohutlu pilav','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',veg:true),
      ]),
      MenuCategory(id:'kom5', name:'🥤 İçecekler', items:[
        _mi('komi1','Komagene Ayran 270ml',45.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('komi2','Şalgam Acılı 300ml',34.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('komi3','Pepsi 330ml',59.90,'','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('komi4','Su 500ml',19.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('komi5','Limonata',24.90,'Bardak limonata','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
      ]),
    ],
    'baydoner': [
      MenuCategory(id:'bay1', name:'🌯 İskender & Döner', items:[
        _mi('bay1','İskender',329.90,'Dana döner, özel sos, yoğurt, tereyağı, pide','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true),
        _mi('bay2','1.5 İskender',419.90,'1.5 porsiyon büyük İskender','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
        _mi('bay3','Yoğurtlu Köz Patlıcanlı İskender',369.90,'İskender + közlenmiş patlıcan ezmesi','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true),
        _mi('bay4','Çökertme Döner',319.90,'Döner + patates + yoğurt sosu','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
      ]),
      MenuCategory(id:'bay2', name:'🥗 Yanlar & Tatlılar', items:[
        _mi('bays1','Mercimek Çorbası',89.90,'Ev yapımı mercimek çorbası','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
        _mi('bays2','Patates Kızartması',89.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
        _mi('bays3','Salata',79.90,'Taze sebze salatası','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('bays4','Künefe',149.90,'Kaymak + kadayıf künefe','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('bays5','Sufle',99.90,'Çikolatalı sufle','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      _drinksEx('bayd'),
    ],
    'tavukdunyasi': [
      MenuCategory(id:'tvd1', name:'🍗 Özel Tavuklar', items:[
        _mi('tvd1','Efsane Buffalo',179.90,'Acılı buffalo soslu izgara tavuk','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',pop:true,spicy:true),
        _mi('tvd2','Barbeküs',169.90,'BBQ soslu ızgara tavuk parçası','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',pop:true),
        _mi('tvd3','Peynirlim',169.90,'Üzerinde eritilmiş cheddar peyniri','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
        _mi('tvd4','Izgara Pirzola',189.90,'Yarım piliç pirzola, ızgara','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
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
        _mi('kyf1','Izgara Köfte (1 Porsiyon)',299.90,'El yapımı ızgara köfte, pilav, salata','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('kyf2','Köfte 300gr',429.90,'300gr ızgara köfte, pilav, piyaz','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('kyf3','Tek Köfte Burger',229.90,'Ekmek arası tek köfte burger','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400'),
        _mi('kyf4','Çift Köfte Burger',289.90,'Çift köfte burger','https://images.unsplash.com/photo-1619221882266-1bc8e7b87e68?w=400',pop:true),
        _mi('kyf5','Sucuk',299.90,'Izgara sucuk tabağı','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('kyf6','Dana Antrikot',429.90,'Izgara dana antrikot tabağı','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
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
        _mi('subd1','Teriyaki Tavuk Dürüm',189.90,'Teriyaki tavuk lavaş dürüm','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400',pop:true),
        _mi('subd2','Biftek & Peynir Dürüm',199.90,'Biftek dürüm','https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400'),
        _mi('subd3','Tavuk Fileto Bowl',179.90,'Izgara tavuk salata kasesi','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400'),
      ]),
      _drinksEx('subxd'),
    ],
    // ── GENERIC MENUS ────────────────────────────────────────
    'burger': [
      MenuCategory(id:'bm1', name:'🍔 Burgerler', items:[
        _mi('bb1','Classic Smash',169.90,'180gr dana, cheddar, özel sos','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true,opts:[MenuOption(id:'bo1',name:'Ekstra Cheddar',price:15),MenuOption(id:'bo2',name:'Bacon',price:25),MenuOption(id:'bo3',name:'Soğan',isRemovable:true),MenuOption(id:'bo4',name:'Turşu',isRemovable:true)]),
        _mi('bb2','Double Smash',219.90,'Çift et, çift peynir','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bb3','Crispy Chicken',159.90,'Çıtır tavuk burger','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
        _mi('bb4','Veggie Burger',149.90,'Sebze köftesi, avokado','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
      ]),
      MenuCategory(id:'bm2', name:'🍟 Yanlar', items:[
        _mi('bs1','Patates',49.90,'Çıtır patates','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bs2','Onion Rings',54.90,'Soğan halkaları','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
        _mi('bs3','Mozza Stick',59.90,'6 adet + marinara','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'),
      ]),
      _drinks('bd'),
    ],
    'pizza': [
      MenuCategory(id:'pm1', name:'🍕 Pizzalar', items:[
        _mi('pb1','Margarita',139.90,'Domates, mozzarella, fesleğen','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',pop:true,opts:[MenuOption(id:'po1',name:'Ekstra Peynir',price:20),MenuOption(id:'po2',name:'İnce Hamur'),MenuOption(id:'po3',name:'Kalın Hamur')]),
        _mi('pb2','Karışık',179.90,'Sucuk, mantar, biber, zeytin','https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'),
        _mi('pb3','BBQ Tavuk',169.90,'BBQ sos, tavuk, soğan','https://images.unsplash.com/photo-1571997478779-2adcbbe9ab2f?w=400'),
        _mi('pb4','4 Peynirli',189.90,'Mozza, cheddar, parmesan, gouda','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400'),
      ]),
      _drinks('pd'),
    ],
    'tavuk': [
      MenuCategory(id:'tm1', name:'🍗 Tavuk', items:[
        _mi('tb1','Bucket 8 Parça',399.90,'8 parça çıtır tavuk','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400',pop:true),
        _mi('tb2','Tavuk Dürüm',119.90,'Izgara tavuk, sebze, lavaş','https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400',opts:[MenuOption(id:'to1',name:'Acı Sos'),MenuOption(id:'to2',name:'Soğan',isRemovable:true)]),
        _mi('tb3','Çıtır Kanatlar 6',159.90,'6 adet kanat, dip sos','https://images.unsplash.com/photo-1587899897387-091ebd01a6b2?w=400',spicy:true),
        _mi('tb4','Tavuk Burger Menü',189.90,'Burger + patates + içecek','https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=400'),
      ]),
      _drinks('td'),
    ],
    'doner': [
      MenuCategory(id:'dm1', name:'🌯 Döner', items:[
        _mi('db1','Et Dürüm',109.90,'Dana döner, lavaş, sebze','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true,opts:[MenuOption(id:'do1',name:'Acı Sos'),MenuOption(id:'do2',name:'Ekstra Et',price:30),MenuOption(id:'do3',name:'Soğan',isRemovable:true)]),
        _mi('db2','Tavuk Dürüm',89.90,'Izgara tavuk, sebze','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
        _mi('db3','Et Porsiyon',139.90,'Porsiyon et + pilav + salata','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
        _mi('db4','İskender',229.90,'Döner + domates sosu + yoğurt','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
      ]),
      _drinks('dd'),
    ],
    'pide': [
      MenuCategory(id:'pim1', name:'🫓 Pide & Lahmacun', items:[
        _mi('pib1','Kıymalı Pide',119.90,'Kıyma, domates, biber','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400',pop:true,opts:[MenuOption(id:'pio1',name:'Yumurtalı',price:10),MenuOption(id:'pio2',name:'Kaşarlı',price:15)]),
        _mi('pib2','Kaşarlı Pide',109.90,'Bol kaşar peyniri','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400'),
        _mi('pib3','Lahmacun 4 adet',89.90,'İnce kıymalı lahmacun','https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400'),
        _mi('pib4','Gözleme',79.90,'Peynirli veya ıspanaklı','https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',veg:true),
      ]),
      _drinks('pidd'),
    ],
    'et': [
      MenuCategory(id:'em1', name:'🔥 Kebaplar', items:[
        _mi('eb1','Adana Kebap',399.90,'Acılı kıyma kebabı, pilav, söğüş','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true,spicy:true),
        _mi('eb2','Urfa Kebap',399.90,'Acısız kıyma kebabı, pilav','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('eb3','Beyti Kebap',429.90,'Kıyma beyti, lavaş, yoğurt','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('eb4','Patlıcan Kebap',459.90,'Közlenmiş patlıcanlı kebap','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('eb5','Karışık Kebap',649.90,'Adana + urfa + köfte + pilav','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true),
        _mi('eb6','Yoğurtlu Kebap',449.90,'Kebap + yoğurt sosu + pide','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
      ]),
      MenuCategory(id:'em2', name:'🥩 Izgaralar', items:[
        _mi('ebı1','Izgara Köfte',349.90,'El yapımı ızgara köfte, pilav','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true),
        _mi('ebı2','Kuzu Pirzola',699.90,'Izgara kuzu pirzola, fırın patates','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
        _mi('ebı3','Dana Antrikot',649.90,'200gr dana antrikot, sebze','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400'),
        _mi('ebı4','Kuzu Şiş',549.90,'Kuzu şiş, pilav, salata','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('ebı5','Karışık Izgara',799.90,'Kuzu şiş + adana + köfte tabağı','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true),
        _mi('ebı6','Kuzu İncik',549.90,'Fırında kuzu incik, pilav','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'em3', name:'🥗 Yanlar & Çorbalar', items:[
        _mi('eby1','Mercimek Çorbası',89.90,'Kırmızı mercimek','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
        _mi('eby2','Çoban Salata',99.90,'Domates, salatalık, biber','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('eby3','Cacık',79.90,'Yoğurt, salatalık, nane','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
        _mi('eby4','Patates Kızartması',99.90,'Çıtır patates','https://images.unsplash.com/photo-1576107232684-1279f8b84e04?w=400',veg:true),
      ]),
      _drinksEx('etd'),
    ],
    'deniz': [
      MenuCategory(id:'denim1', name:'🐟 Deniz Ürünleri', items:[
        _mi('denb1','Balık Izgara',249.90,'Günün balığı, sebze, pilav','https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400',pop:true),
        _mi('denb2','Karides Güveç',229.90,'Domates soslu karides','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400'),
        _mi('denb3','Balık Ekmek',99.90,'Izgara balık, lavaş','https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400'),
        _mi('denb4','Meze Tabağı',189.90,'Karışık deniz mezeleri','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400'),
      ]),
      _drinks('dend'),
    ],
    'vegan': [
      MenuCategory(id:'vm1', name:'🥗 Ana Yemekler', items:[
        _mi('vb1','Buddha Bowl',169.90,'Kinoa, avokado, tahini, sebze','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
        _mi('vb2','Falafel Dürüm',129.90,'Falafel, humus, turşu, lavaş','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true,pop:true),
        _mi('vb3','Vegan Burger',159.90,'Nohut köftesi, avokado, vegan sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('vb4','Acı Tofu Stir Fry',149.90,'Tofu, sebze, baharatlı soya sosu','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,spicy:true),
        _mi('vb5','Sebzeli Wrap',129.90,'Izgara sebze, humus, lavaş','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('vb6','Nohut Köri',139.90,'Hint köri, nohut, basmati pilav','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,spicy:true),
        _mi('vb7','Lentil Soup',89.90,'Mercimek çorbası, ekmek','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
      ]),
      MenuCategory(id:'vm2', name:'🥗 Salatalar & Kaseler', items:[
        _mi('vbs1','Detoks Salata',119.90,'Kale, ıspanak, badem, limon sos','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,pop:true),
        _mi('vbs2','Protein Bowl',139.90,'Edamame, kinoa, avokado, sos','https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',veg:true),
        _mi('vbs3','Acı Salsa Kase',129.90,'Meksika usulü vegan kase','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true,spicy:true),
      ]),
      _drinksEx('vd'),
    ],
    'kahvalti': [
      MenuCategory(id:'km1', name:'🥚 Kahvaltılar', items:[
        _mi('kb1','Serpme Kahvaltı 2 Kişi',449.90,'Peynir çeşitleri, bal, kaymak, yumurta, simit, zeytin, sebze','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',pop:true),
        _mi('kb2','Serpme Kahvaltı 1 Kişi',249.90,'Tek kişilik serpme kahvaltı tabağı','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
        _mi('kb3','Menemen',119.90,'Domates, biber, yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',pop:true,opts:[MenuOption(id:'ko1',name:'Sucuklu',price:25),MenuOption(id:'ko2',name:'Kaşarlı',price:20),MenuOption(id:'ko3',name:'Mantarlı',price:20)]),
        _mi('kb4','Sucuklu Yumurta',109.90,'Tava sucuk, sahanda yumurta, ekmek','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
        _mi('kb5','Çılbır',109.90,'Poşe yumurta, yoğurt, tereyağı','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400'),
        _mi('kb6','Gözleme Peynirli',99.90,'El açması peynirli gözleme','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('kb7','Gözleme Kıymalı',109.90,'El açması kıymalı gözleme','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400'),
        _mi('kb8','Poğaça 6 adet',79.90,'Karışık taze poğaça','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('kb9','Köy Kahvaltısı',199.90,'Köy peyniri, bal, yumurta, zeytin','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
      ]),
      MenuCategory(id:'km2', name:'☕ Kahvaltı İçecekleri', items:[
        _mi('kbi1','Çay',25.90,'Demli bardak çay','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('kbi2','Türk Kahvesi',49.90,'Geleneksel Türk kahvesi','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('kbi3','Taze Portakal Suyu',79.90,'Sıkma portakal suyu','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('kbi4','Ayran',35.90,'Soğuk ayran','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('kbi5','Latte',79.90,'Sütlü kahve','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
    ],
    'sokak': [
      MenuCategory(id:'skm1', name:'🌽 Sokak Lezzetleri', items:[
        _mi('skb1','Kumpir',129.90,'Büyük patates + 5 malzeme','https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400',pop:true,opts:[MenuOption(id:'sko1',name:'Mısır'),MenuOption(id:'sko2',name:'Zeytin'),MenuOption(id:'sko3',name:'Sosis',price:10),MenuOption(id:'sko4',name:'Rus Salatası'),MenuOption(id:'sko5',name:'Ekstra Peynir',price:15)]),
        _mi('skb2','Kokoreç',89.90,'Yarım ekmek kokoreç','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',spicy:true),
        _mi('skb3','Tantuni',99.90,'Et tantuni, lavaş, sebze','https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400'),
        _mi('skb4','Islak Burger',69.90,'İstanbul\'un ıslak burgeri','https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',pop:true),
      ]),
      _drinks('skd'),
    ],
    'manti': [
      MenuCategory(id:'mam1', name:'🥟 Mantı & Makarna', items:[
        _mi('mab1','El Yapımı Mantı',149.90,'Mantı, yoğurt, nane tereyağı','https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400',pop:true,opts:[MenuOption(id:'mao1',name:'Ekstra Yoğurt',price:10),MenuOption(id:'mao2',name:'Acısız')]),
        _mi('mab2','Kremalı Makarna',129.90,'Krema, mantar, parmesan','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400',veg:true),
        _mi('mab3','Bolonez',139.90,'Kıymalı domates sosu','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400'),
        _mi('mab4','Lazanya',159.90,'Fırın lazanya, bolonez, beşamel','https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400'),
      ]),
      _drinks('mad'),
    ],
    'kahve': [
      MenuCategory(id:'kfm1', name:'☕ Kahveler', items:[
        _mi('kfb1','Latte',89.90,'Espresso + sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true,opts:[MenuOption(id:'kfo1',name:'Ekstra Shot',price:15),MenuOption(id:'kfo2',name:'Yulaf Sütü',price:20)]),
        _mi('kfb2','Türk Kahvesi',49.90,'Geleneksel Türk kahvesi','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('kfb3','Soğuk Kahve',99.90,'Cold brew / frappuccino','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('kfb4','Matcha Latte',109.90,'Premium matcha, sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
      ]),
      MenuCategory(id:'kfm2', name:'🥐 Atıştırmalık', items:[
        _mi('kfs1','Croissant',59.90,'Tereyağlı kruvasan','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('kfs2','Muffin',49.90,'Çikolatalı veya yaban mersinli','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
    ],
    'pastane': [
      MenuCategory(id:'pam1', name:'🥐 Börekler & Hamur İşleri', items:[
        _mi('pab1','Simit',25.90,'Taze susamlı simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('pab2','Peynirli Poğaça',49.90,'Taze pişmiş peynirli poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true,pop:true),
        _mi('pab3','Zeytinli Açma',45.90,'Zeytinli yumuşak açma','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('pab4','Su Böreği (Dilim)',89.90,'El açması peynirli su böreği','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true,pop:true),
        _mi('pab5','Sigara Böreği 6 adet',79.90,'Çıtır peynirli sigara böreği','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('pab6','Ispanaklı Börek',75.90,'El açması ıspanaklı börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('pab7','Patatesli Börek',75.90,'El açması patatesli börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('pab8','Kol Böreği',85.90,'Rulo kol böreği, peynirli','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('pab9','Kruvasan',59.90,'Tereyağlı / çikolatalı kruvasan','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true),
        _mi('pab10','Etli Börek',95.90,'Kıymalı el açması börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400'),
      ]),
      MenuCategory(id:'pam2', name:'🍰 Tatlılar', items:[
        _mi('pat1','Baklava 6 adet',129.90,'Antep fıstıklı baklava','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true,pop:true),
        _mi('pat2','Kadayıf',119.90,'Peynirli tel kadayıf','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat3','Sütlaç',79.90,'Fırın sütlaç','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat4','Sufle',99.90,'Çikolatalı sufle + dondurma','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat5','Tiramisu',109.90,'Klasik tiramisu','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat6','Cheesecake',119.90,'Limonlu / çilekli cheesecake','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('pat7','Brownie',79.90,'Çikolatalı brownie + dondurma','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
        _mi('pat8','Profiterol',89.90,'Krema dolgulu profiterol','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
      ]),
      MenuCategory(id:'pam3', name:'☕ İçecekler', items:[
        _mi('pai1','Türk Kahvesi',49.90,'Geleneksel Türk kahvesi','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('pai2','Çay',20.90,'Demli bardak çay','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('pai3','Latte',89.90,'Espresso + sütlü','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true),
        _mi('pai4','Limonata',69.90,'Taze sıkma limonata','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('pai5','Su 500ml',15.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
      ]),
    ],
    'aperatif': [
      MenuCategory(id:'apm1', name:'🥗 Mezeler', items:[
        _mi('apb1','Karışık Meze Tabağı',179.90,'Humus, patlıcan, cacık, atom, ezme','https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400',veg:true,pop:true),
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
        _mi('api1','Ayran',39.90,'Ev yapımı ayran','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('api2','Şalgam Suyu',45.90,'Acılı şalgam suyu','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('api3','Limonata',69.90,'Taze limonata','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400',veg:true),
        _mi('api4','Kola 330ml',49.90,'','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('api5','Su 500ml',15.90,'','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
      ]),
    ],
    'ev': [
      MenuCategory(id:'evm1', name:'🍲 Günlük Yemekler', items:[
        _mi('evb1','Günlük Tabak',149.90,'2 çeşit yemek + pilav + salata','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('evb2','Karnıyarık',139.90,'Patlıcan, kıyma, fırın','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('evb3','Etli Nohut',119.90,'Kuzu etli nohut, pilav','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('evb4','Kuru Fasulye + Pilav',99.90,'Geleneksel kuru fasulye, pilav','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('evb5','İmam Bayıldı',119.90,'Zeytinyağlı patlıcan dolması','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
        _mi('evb6','Dolma (10 adet)',109.90,'Zeytinyağlı yaprak sarma','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
        _mi('evb7','Tarhana Çorbası',69.90,'Ev yapımı tarhana','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
        _mi('evb8','Mercimek Çorbası',59.90,'Kırmızı mercimek çorbası','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',veg:true),
      ]),
      _drinks('evd'),
    ],
    'dunya': [
      MenuCategory(id:'dun1', name:'🍣 Sushi', items:[
        _mi('dun1','Sushi Set 12',249.90,'12 parça karışık sushi','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',pop:true),
        _mi('dun2','Salmon Nigiri 4',149.90,'4 adet somon nigiri','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',pop:true),
        _mi('dun3','California Roll 8',169.90,'8 parça california roll','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400'),
        _mi('dun4','Spicy Tuna Roll 8',179.90,'Acılı ton balıklı roll','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',spicy:true),
        _mi('dun5','Vegan Avokado Roll 8',149.90,'Avokado, salatalık, nori','https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',veg:true),
      ]),
      MenuCategory(id:'dun2', name:'🍜 Noodle & Wok', items:[
        _mi('dunw1','Ramen',199.90,'Tonkotsu çorba, erişte, yumurta','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',pop:true),
        _mi('dunw2','Pad Thai',189.90,'Pirinç eriştesi, karides, fıstık','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',pop:true),
        _mi('dunw3','Vegan Noodle',169.90,'Sebzeli erişte, soya sosu','https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',veg:true),
        _mi('dunw4','Köri Wok',189.90,'Tavuklu hint körisi, pirinç','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',spicy:true),
      ]),
      MenuCategory(id:'dun3', name:'🍕 İtalyan', items:[
        _mi('duni1','Carbonara',199.90,'Spaghetti, guanciale, yumurta, parmesan','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400',pop:true),
        _mi('duni2','Boloneze',189.90,'Kıymalı domates sosu, tagliatelle','https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=400'),
        _mi('duni3','Margherita Pizza',229.90,'Domates, mozzarella, fesleğen','https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',veg:true),
        _mi('duni4','Risotto Tartufo',249.90,'Trüf mantarlı risotto','https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=400',veg:true),
      ]),
      _drinksEx('dund'),
    ],
    'aspava': [
      MenuCategory(id:'asp1', name:'🥩 Döner', items:[
        _mi('asp_d1','Servis Et Döner',680,'Tabak servis et döner','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400',pop:true),
        _mi('asp_d2','Dürüm Et Döner',680,'Lavaşta et döner dürüm','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
        _mi('asp_d3','SSK Dürüm Döner',700,'Özel SSK dürüm','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
        _mi('asp_d4','İskender Kebap',730,'Döner, yoğurt, tereyağı, domates sosu, pide','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('asp_d5','Pilav Üstü Döner',720,'Pilav + döner','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
        _mi('asp_d6','Sarma Döner Beyti',730,'Lavaşta sarma beyti döner','https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=400'),
      ]),
      MenuCategory(id:'asp2', name:'🔥 Kebaplar', items:[
        _mi('asp_k1','Adana Kebap',700,'Baharatlı acı kıyma kebap','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',spicy:true,pop:true),
        _mi('asp_k2','Urfa Kebap',700,'Tatlı kıyma kebap','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('asp_k3','Beyti Kebap',730,'Kıyma beyti, lavaş','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',pop:true),
        _mi('asp_k4','Yoğurtlu Adana',730,'Adana + yoğurt sos','https://images.unsplash.com/photo-1547592180-85f173990554?w=400',spicy:true),
        _mi('asp_k5','Patlıcan Kebap',760,'Közlenmiş patlıcanlı kebap','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('asp_k6','Domatesli Kebap',760,'Domates soslu kebap','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('asp_k7','Kuzu Pirzola',900,'Izgara kuzu pirzola','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
        _mi('asp_k8','Izgara Köfte',700,'El yapımı ızgara köfte','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('asp_k9','Karışık Kebap',1950,'Karışık tabak: adana, urfa, tavuk, köfte','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
      ]),
      MenuCategory(id:'asp3', name:'🧱 Kiremitte', items:[
        _mi('asp_ki1','Kiremitte Köfte',740,'Kiremit tencerede köfte','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('asp_ki2','Kiremitte Et Şiş',930,'Kiremit tencerede et şiş','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',pop:true),
        _mi('asp_ki3','Kiremitte Tavuk Şiş',640,'Kiremit tencerede tavuk şiş','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
      ]),
      MenuCategory(id:'asp4', name:'🫓 Pideler', items:[
        _mi('asp_p1','Kuşbaşılı Kaşarlı Pide',710,'Kuşbaşı et + kaşar pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400',pop:true),
        _mi('asp_p2','Kapalı Dönerli Pide',700,'Dönerli kapalı pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400'),
        _mi('asp_p3','Kaşarlı Pide',620,'Sade kaşarlı pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400',veg:true),
        _mi('asp_p4','Karışık Pide',700,'Karışık malzemeli pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400',pop:true),
        _mi('asp_p5','Kıymalı Pide',610,'Kıymalı pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400'),
        _mi('asp_p6','Kuşbaşılı Pide',690,'Kuşbaşı etli pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400'),
        _mi('asp_p7','Kıymalı Kaşarlı Pide',630,'Kıyma + kaşar pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400'),
        _mi('asp_p8','Mantarlı Kaşarlı Pide',630,'Mantar + kaşar pide','https://images.unsplash.com/photo-1630409351241-e90e7f6b6571?w=400',veg:true),
        _mi('asp_p9','Lahmacun',400,'İnce hamur kıymalı lahmacun','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'asp5', name:'🍢 Şişler', items:[
        _mi('asp_s1','Kuzu Şiş',900,'Izgara kuzu şiş','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
        _mi('asp_s2','Tavuk Şiş',600,'Izgara tavuk şiş','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
        _mi('asp_s3','Tavuk Kanat',620,'Izgara tavuk kanat','https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'),
        _mi('asp_s4','Ali Nazik Kuzu Şiş',930,'Kuzu şiş + ali nazik ezmesi','https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',pop:true),
        _mi('asp_s5','Ali Nazik Kebap',750,'Patlıcan ezmesi + kebap','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('asp_s6','Et Çöp Şiş',830,'İnce et çöp şiş','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
        _mi('asp_s7','Ciğer Şiş',830,'Izgara ciğer şiş','https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400'),
      ]),
      MenuCategory(id:'asp6', name:'🥗 Yan Ürünler', items:[
        _mi('asp_y1','İçli Köfte',130,'Geleneksel bulgur içli köfte','https://images.unsplash.com/photo-1547592180-85f173990554?w=400'),
        _mi('asp_y2','Çoban Salata',200,'Domates, salatalık, soğan, maydanoz','https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',veg:true),
      ]),
      MenuCategory(id:'asp7', name:'🥤 İçecekler', items:[
        _mi('asp_i1','Kola',120,'330ml','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('asp_i2','Fanta',120,'330ml','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('asp_i3','Sprite',120,'330ml','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('asp_i4','Fuse Tea',120,'330ml','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
        _mi('asp_i5','Meyve Suyu',120,'Çeşitli tatlar','https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400'),
        _mi('asp_i6','Şalgam Acılı',120,'Geleneksel şalgam','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
        _mi('asp_i7','Şalgam Acısız',120,'Acısız şalgam','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
        _mi('asp_i8','Ayran',100,'Soğuk ayran','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
        _mi('asp_i9','Soda',80,'Soda 200ml','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
        _mi('asp_i10','Su',40,'500ml su','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
      ]),
    ],
    'bulentborekci': [
      MenuCategory(id:'bb1', name:'🥐 Börekler', items:[
        _mi('bb_b1','Su Böreği',180,'El açması, peynirli veya kıymalı','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',pop:true),
        _mi('bb_b2','Sigara Böreği (6 adet)',120,'Peynirli çıtır sigara böreği','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',pop:true,veg:true),
        _mi('bb_b3','Kol Böreği',150,'Çıtır hamuruyla kol böreği','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('bb_b4','Patatesli Börek',130,'İç dolgulu patatesli börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('bb_b5','Ispanaklı Börek',130,'İspanak + peynir dolgulu börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('bb_b6','Peynirli Börek',120,'Beyaz peynirli börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('bb_b7','Etli Börek',160,'Kıymalı börek','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400'),
      ]),
      MenuCategory(id:'bb2', name:'🫓 Poğaça & Simit', items:[
        _mi('bb_p1','Peynirli Poğaça',35,'Taze pişmiş peynirli poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true,pop:true),
        _mi('bb_p2','Zeytinli Poğaça',35,'Zeytin dolgulu poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('bb_p3','Patatesli Poğaça',35,'Patates dolgulu poğaça','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
        _mi('bb_p4','Simit',25,'Taze susamlı simit','https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',veg:true,pop:true),
        _mi('bb_p5','Açma',30,'Yumuşak açma','https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',veg:true),
      ]),
      MenuCategory(id:'bb3', name:'🍳 Kahvaltı', items:[
        _mi('bb_kh1','Kahvaltı Tabağı',150,'Peynir, zeytin, domates, salatalık, yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true,pop:true),
        _mi('bb_kh2','Menemen',120,'Domates, biber, yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
        _mi('bb_kh3','Sahanda Yumurta',80,'Tereyağlı sahanda yumurta','https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400',veg:true),
        _mi('bb_kh4','Gözleme (Peynirli)',100,'El yapımı peynirli gözleme','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true,pop:true),
        _mi('bb_kh5','Gözleme (Ispanaklı)',100,'El yapımı ıspanaklı gözleme','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
      MenuCategory(id:'bb4', name:'🥤 İçecekler', items:[
        _mi('bb_i1','Çay',20,'Demli çay bardak','https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',veg:true,pop:true),
        _mi('bb_i2','Türk Kahvesi',40,'Geleneksel Türk kahvesi','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('bb_i3','Ayran',30,'Soğuk ayran','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
        _mi('bb_i4','Su',15,'500ml su','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',veg:true),
      ]),
    ],
    'tatli': [
      MenuCategory(id:'tat1', name:'🍮 Tatlılar', items:[
        _mi('tat_b1','Baklava (6 Dilim)',189.90,'Antep fıstıklı ev baklavası','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true,pop:true),
        _mi('tat_b2','Fıstıklı Baklava (4 Dilim)',159.90,'Özel fıstıklı baklava','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true),
        _mi('tat_k1','Kadayıf',149.90,'Şerbetli tel kadayıf, fıstıklı','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true),
        _mi('tat_ke1','Künefe',169.90,'Sıcak künefe, kaymak, antep fıstığı','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true,pop:true),
        _mi('tat_s1','Sütlaç',89.90,'Fırın sütlaç, tarçın','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true,pop:true),
        _mi('tat_h1','Helva',79.90,'İrmik helvası, fıstıklı','https://images.unsplash.com/photo-1519676867240-f03562e64548?w=400',veg:true),
        _mi('tat_a1','Aşure',89.90,'Geleneksel aşure, kuru meyve','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('tat_m1','Muhallebi',79.90,'Gül sulu muhallebi','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
      MenuCategory(id:'tat2', name:'🍦 Dondurma & Profiterol', items:[
        _mi('tat_d1','Dondurma (3 Top)',99.90,'Çikolata, çilek, vanilyalı','https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=400',veg:true,pop:true),
        _mi('tat_d2','Dondurma (5 Top)',149.90,'5 top dondurma, söz hakkın senin','https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=400',veg:true),
        _mi('tat_p1','Profiterol',129.90,'Çikolata soslu profiterol, vanilyalı dondurma','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true,pop:true),
        _mi('tat_sf1','Sufle',149.90,'Sıcak çikolatalı sufle, dondurma ile','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
      ]),
      MenuCategory(id:'tat3', name:'🎂 Kek & Pasta', items:[
        _mi('tat_c1','Cheesecake',139.90,'New York usulü cheesecake, çilek sos','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true,pop:true),
        _mi('tat_c2','Tiramisu',129.90,'İtalyan tiramisu, espresso','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('tat_c3','Çikolatalı Kek',109.90,'Islak çikolatalı kek, ganaj','https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',veg:true),
        _mi('tat_c4','Limonlu Tart',119.90,'Taze limon kremalı tart','https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',veg:true),
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
      MenuItem(id:'${pfx}d1', name:'Ayran', description:'Soğuk ayran 300ml', price:24.90, imageUrl:'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
      MenuItem(id:'${pfx}d2', name:'Cola', description:'330ml', price:29.90, imageUrl:'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400'),
      MenuItem(id:'${pfx}d3', name:'Su', description:'500ml', price:12.90, imageUrl:'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400'),
      MenuItem(id:'${pfx}d4', name:'Meyve Suyu', description:'Taze sıkılmış portakal', price:34.90, imageUrl:'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400'),
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

  /// Returns a name-aware fallback image. For Sokak Lezzetleri picks the
  /// correct street-food image based on the restaurant name; for Tavuk only
  /// Tavuk Dünyası gets the brand asset. All other cases delegate to
  /// [fallbackImageForCuisine].
  static String fallbackImageForRestaurant(String cuisine, String name) {
    final n = name.toLowerCase();
    if (cuisine == 'Sokak Lezzetleri') {
      if (n.contains('kumpir')) return 'assets/food/kumpir.jpg';
      if (n.contains('tantuni')) return 'assets/food/tantuni.jpg';
      if (n.contains('kokoreç') || n.contains('kokorec')) return 'assets/food/kokorec.jpg';
      return fallbackImageForCuisine(cuisine);
    }
    if (cuisine == 'Tavuk' &&
        (n.contains('tavuk dünyası') || n.contains('tavuk dunyasi'))) {
      return 'assets/food/tavuk_dunyasi.jpg';
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
      result.add(Restaurant(
        id: 'sim_${cuisine.hashCode.abs()}_$i',
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
