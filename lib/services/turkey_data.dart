// Türkiye il/ilçe/mahalle veritabanı (örneklem - gerçek veri)
class TurkeyData {
  // İl → İlçeler
  static const Map<String, List<String>> districts = {
    'İstanbul': ['Adalar','Arnavutköy','Ataşehir','Avcılar','Bağcılar','Bahçelievler','Bakırköy','Başakşehir','Bayrampaşa','Beşiktaş','Beykoz','Beylikdüzü','Beyoğlu','Büyükçekmece','Çatalca','Çekmeköy','Esenler','Esenyurt','Eyüpsultan','Fatih','Gaziosmanpaşa','Güngören','Kadıköy','Kağıthane','Kartal','Küçükçekmece','Maltepe','Pendik','Sancaktepe','Sarıyer','Silivri','Sultanbeyli','Sultangazi','Şile','Şişli','Tuzla','Ümraniye','Üsküdar','Zeytinburnu'],
    'Ankara': ['Akyurt','Altındağ','Ayaş','Balâ','Beypazarı','Çamlıdere','Çankaya','Çubuk','Elmadağ','Etimesgut','Evren','Gölbaşı','Güdül','Haymana','Kalecik','Kahramankazan','Keçiören','Kızılcahamam','Mamak','Nallıhan','Polatlı','Pursaklar','Sincan','Şereflikoçhisar','Yenimahalle'],
    'İzmir': ['Aliağa','Balçova','Bayındır','Bayraklı','Bergama','Beydağ','Bornova','Buca','Çeşme','Çiğli','Dikili','Foça','Gaziemir','Güzelbahçe','Karabağlar','Karaburun','Karşıyaka','Kemalpaşa','Kınık','Kiraz','Konak','Menderes','Menemen','Narlıdere','Ödemiş','Seferihisar','Selçuk','Tire','Torbalı','Urla'],
    'Bursa': ['Büyükorhan','Gemlik','Gürsu','Harmancık','İnegöl','İznik','Karacabey','Keles','Kestel','Mudanya','Mustafakemalpaşa','Nilüfer','Orhaneli','Orhangazi','Osmangazi','Yenişehir','Yıldırım'],
    'Antalya': ['Akseki','Aksu','Alanya','Demre','Döşemealtı','Elmalı','Finike','Gazipaşa','Gündoğmuş','İbradı','Kaş','Kemer','Kepez','Konyaaltı','Korkuteli','Kumluca','Manavgat','Muratpaşa','Serik'],
    'Adana': ['Aladağ','Ceyhan','Çukurova','Feke','İmamoğlu','Karaisalı','Karataş','Kozan','Pozantı','Saimbeyli','Sarıçam','Seyhan','Tufanbeyli','Yumurtalık','Yüreğir'],
    'Gaziantep': ['Araban','İslahiye','Karkamış','Nizip','Nurdağı','Oğuzeli','Şahinbey','Şehitkamil','Yavuzeli'],
    'Konya': ['Ahırlı','Akören','Akşehir','Altınekin','Beyşehir','Bozkır','Cihanbeyli','Çeltik','Çumra','Derbent','Derebucak','Doğanhisar','Emirgazi','Ereğli','Güneysınır','Hadim','Halkapınar','Hüyük','Ilgın','Kadınhanı','Karapınar','Karatay','Kulu','Meram','Sarayönü','Selçuklu','Seydişehir','Taşkent','Tuzlukçu','Yalıhüyük','Yunak'],
    'Mersin': ['Akdeniz','Anamur','Aydıncık','Bozyazı','Çamlıyayla','Erdemli','Gülnar','Mezitli','Mut','Silifke','Tarsus','Toroslar','Yenişehir'],
    'Kayseri': ['Akkışla','Bünyan','Develi','Felahiye','Hacılar','İncesu','Kocasinan','Melikgazi','Özvatan','Pınarbaşı','Sarıoğlan','Sarız','Talas','Tomarza','Yahyalı','Yeşilhisar'],
    'Eskişehir': ['Alpu','Beylikova','Çifteler','Günyüzü','Han','İnönü','Mahmudiye','Mihalgazi','Mihallıçcık','Odunpazarı','Sarıcakaya','Seyitgazi','Sivrihisar','Tepebaşı'],
    'Samsun': ['Alaçam','Asarcık','Atakum','Ayvacık','Bafra','Canik','Çarşamba','Havza','İlkadım','Kavak','Ladik','Ondokuzmayıs','Salıpazarı','Tekkeköy','Terme','Vezirköprü','Yakakent'],
    'Trabzon': ['Akçaabat','Araklı','Arsin','Beşikdüzü','Çarşıbaşı','Çaykara','Dernekpazarı','Düzköy','Hayrat','Köprübaşı','Maçka','Of','Ortahisar','Sürmene','Şalpazarı','Tonya','Vakfıkebir','Yomra'],
    'Diyarbakır': ['Bağlar','Bismil','Çermik','Çınar','Çüngüş','Dicle','Eğil','Ergani','Hani','Hazro','Kayapınar','Kocaköy','Kulp','Lice','Silvan','Sur','Yenişehir'],
    'Kocaeli': ['Başiskele','Çayırova','Darıca','Derince','Dilovası','Gebze','Gölcük','İzmit','Kandıra','Karamürsel','Kartepe','Körfez'],
    'Şanlıurfa': ['Akçakale','Birecik','Bozova','Ceylanpınar','Eyyübiye','Halfeti','Haliliye','Harran','Hilvan','Karaköprü','Siverek','Suruç','Viranşehir'],
    'Hatay': ['Altınözü','Antakya','Arsuz','Belen','Defne','Dörtyol','Erzin','Hassa','İskenderun','Kırıkhan','Kumlu','Payas','Reyhanlı','Samandağ','Serinyol','Yayladağı'],
    'Manisa': ['Ahmetli','Akhisar','Alaşehir','Demirci','Gölmarmara','Gördes','Kırkağaç','Köprübaşı','Kula','Salihli','Sarıgöl','Saruhanlı','Selendi','Soma','Şehzadeler','Turgutlu','Yunusemre'],
    'Muğla': ['Bodrum','Dalaman','Datça','Fethiye','Kavaklıdere','Köyceğiz','Marmaris','Mentеşe','Milas','Ortaca','Seydikemer','Ula','Yatağan'],
    'Balıkesir': ['Altıeylül','Ayvalık','Balya','Bandırma','Bigadiç','Burhaniye','Dursunbey','Edremit','Erdek','Gömeç','Gönen','Havran','İvrindi','Karesi','Kepsut','Manyas','Marmara','Pamukçu','Savaştepe','Sındırgı','Susurluk'],
    'Tekirdağ': ['Çerkezköy','Çorlu','Ergene','Hayrabolu','Kapaklı','Malkara','Marmaraereğlisi','Muratlı','Saray','Süleymanpaşa','Şarköy'],
  };

  // İlçe → Mahalleler (örnek)
  static const Map<String, List<String>> neighborhoods = {
    // İstanbul
    'Kadıköy': ['Acıbadem','Bostancı','Caferağa','Erenköy','Feneryolu','Fikirtepe','Göztepe','Hasanpaşa','Koşuyolu','Moda','Osmanağa','Rasimpaşa','Suadiye','Zühtüpaşa'],
    'Beşiktaş': ['Abbasağa','Akatlar','Arnavutköy','Bebek','Etiler','Gayrettepe','Kuruçeşme','Levent','Nişantaşı','Ortaköy','Sinanpaşa','Türkali','Ulus','Yıldız'],
    'Şişli': ['Bozkurt','Cumhuriyet','Esentepe','Feriköy','Fulya','Gülbahar','Halaskargazi','Harbiye','İhlamur','Kuştepe','Mecidiyeköy','Meşrutiyet','Osmanbey','Pangaltı','Teşvikiye'],
    'Ataşehir': ['Barbaros','Başak','Batı','Cumhuriyet','Esatpaşa','Ferhatpaşa','İçerenköy','İnkilap','Kayışdağı','Küçükbakkalköy','Mevlana','Mustafa Kemal','Yenisahra'],
    'Çankaya': ['Aşağıöveçler','Bahçelievler','Birlik','Bülbül','Çukurambar','Emek','Gaziosmanpaşa','Kavaklıdere','Kızılay','Kurtuluş','Maltepe','Mebusevleri','Öveçler','Tunalı Hilmi','Yıldız'],
    'Keçiören': ['Aktepe','Bağlum','Dutluk','Eğlence','Etlik','Kalaba','Kanuni','Karşıyaka','Koyunabdal','Kuşcağız','Ovacık','Pınarbaşı','Subayevleri','Telli','Yenidoğan'],
    'Bornova': ['Atatürk','Doğanlar','Erzene','Güzelyalı','Kavacık','Kazımdirik','Mevlana','Mithatpaşa','Naldöken','Pınarbaşı','Türkan','Yamanlar'],
    'Konak': ['Alsancak','Basmane','Çankaya','Eşrefpaşa','Güzelyurt','Hatay','Kahramanlar','Kemeralti','Kuruçay','Liman','Mithatpaşa','Umurbey'],
    'Osmangazi': ['Bahçelievler','Demirci','Dobruca','Emir','Ertuğrulgazi','Fatih','Hamitler','Heykel','Işıklar','Kükürtlü','Maksem','Santral'],
    'Nilüfer': ['Balat','Beşevler','Bademli','Demirci','Egemenlik','Fethiye','Görükle','İhsaniye','Karaman','Kayapa','Korupark'],
    // Antalya
    'Muratpaşa': ['Bahçelievler','Balbey','Çağlayan','Etiler','Fener','Güzeloba','Kızıltoprak','Kışla','Konyaaltı','Lara','Memurevleri','Sinan'],
    'Kepez': ['Altınova','Atatürk','Duraliler','Fabrikalar','Göksu','Güzeloba','Haşimişcan','Işıklar','Kayaönü','Kuzey','Özgürlük','Yenigöl'],
    'Konyaaltı': ['Arapsuyu','Çakırlar','Doyran','Hurma','Sarısu','Siteler','Uncalı'],
    // Genel
    'Şahinbey': ['Bağlarbaşı','Dabakhane','Düztepe','Gazikelaynak','İncilipınar','Karataş','Mithatpaşa','Mücahitler','Narlı','Özgürlük','Yaprak'],
    'Şehitkamil': ['Altınşehir','Bağlarbaşı','Beştepe','Çırçır','Dülükbaba','Güneykent','Harmantepe','İbrahimli','Küsget','Muammer Aksoy'],
    'Seyhan': ['Barış','Çınarlı','Denizli','Emek','Güzelyalı','Kanalaltı','Kurtuluş','Reşatbey','Uçak','Vatan','Yeşiloba'],
    'Yüreğir': ['Adnan Menderes','Cumhuriyet','Döşeme','Fatih','Hürriyet','Kurtuluş','Mithatpaşa','Yeşilbağlar'],
    'Meram': ['Beşyüzevler','Çukurören','Dutluk','Göçü','Gödene','Karaaslan','Kırklar','Ladik','Musalla','Nişantaşı','Selçuklu'],
    'Selçuklu': ['Boruktolu','Feritköy','Horozluhan','Kayacık','Nalçacı','Saraçoğlu','Sille','Yazır'],
    'İzmit': ['Akmeşe','Arızlı','Aslanbey','Bayraktepe','Durhasan','Gündoğdu','İlyasbey','Kullar','Ömerağa','Serdar','Tepecik','Yahyakaptan'],
    'Gebze': ['Balçık','Çayırova','Güzeller','İhsaniye','Işıklar','Pelitli','Hacı Halil','Köseköy','Pelitköy'],
    'Haliliye': ['Bahçelievler','Bediüzzaman','Camikebir','Eyyübiye','Karaköprü','Osmanbey','Yenice'],
    'Antakya': ['Armutlu','Atatürk','Aziziye','Cumhuriyet','Defne','Güzelburç','Harbiye','Narlıca','Narlıköy','Yenişehir'],
  };

  // Fallback neighborhoods for any district
  static List<String> getNeighborhoods(String district) {
    if (neighborhoods.containsKey(district)) return neighborhoods[district]!;
    // Generate generic neighborhoods
    return [
      '$district Merkez Mah.', 'Atatürk Mah.', 'Cumhuriyet Mah.',
      'Fatih Mah.', 'Yıldız Mah.', 'Yeni Mah.', 'Bahçelievler Mah.',
      'Kızılay Mah.', 'İnönü Mah.', 'Barış Mah.', 'Emek Mah.',
      'Güneş Mah.', 'Çamlıca Mah.', 'Bağlar Mah.', 'Çarşı Mah.',
    ];
  }

  static List<String> getDistricts(String city) {
    // Normalize city name (remove "İli" etc.)
    final normalized = city.replaceAll(' İli', '').replaceAll(' Merkezi', '').trim();
    return districts[normalized] ?? ['Merkez'];
  }

  // Try to find city from partial name
  static String? matchCity(String partial) {
    final lower = partial.toLowerCase();
    for (final city in districts.keys) {
      if (city.toLowerCase().contains(lower) || lower.contains(city.toLowerCase())) {
        return city;
      }
    }
    return null;
  }
}
