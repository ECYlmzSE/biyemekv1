import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

// ─── Data classes ─────────────────────────────────────────────────────────────
class _Ingredient { final String name; const _Ingredient(this.name); }
class _Side { final String name; final double price; const _Side(this.name, this.price); }
class _MenuData {
  final List<_Ingredient> removable;
  final List<_Side> sides;
  const _MenuData({this.removable = const [], this.sides = const []});
}

// ─── Resolve menu data based on ITEM description ─────────────────────────────
_MenuData _resolve(MenuItem item, Restaurant restaurant) {
  final iName = item.name.toLowerCase();
  final iDesc = item.description.toLowerCase();
  final rName = restaurant.name.toLowerCase();
  final cuis  = restaurant.cuisine.toLowerCase();

  // Helper: does item contain any of these words?
  bool has(List<String> words) =>
      words.any((w) => iName.contains(w) || iDesc.contains(w));

  // ── KUMPIR ────────────────────────────────────────────────────
  if (has(['kumpir'])) {
    // Figure out which ingredients are actually in this kumpir
    final base = <_Ingredient>[
      if (iDesc.contains('tereyağ') || iDesc.contains('butter')) const _Ingredient('Tereyağı'),
      if (iDesc.contains('kaşar') || iDesc.contains('peynir')) const _Ingredient('Kaşar'),
    ];
    // These are standard kumpir toppings that can always be removed
    final standard = [
      const _Ingredient('Mısır'), const _Ingredient('Zeytin'),
      const _Ingredient('Rus Salatası'), const _Ingredient('Turşu'),
      const _Ingredient('Maydanoz'),
    ];
    return _MenuData(
      removable: [...base, ...standard],
      sides: const [
        _Side('Sucuk', 15), _Side('Sosis', 12), _Side('Mantar', 12),
        _Side('Meksika Fasulyesi', 12), _Side('Ekstra Kaşar', 12),
        _Side('Ekşi Krema', 10), _Side('Jalapeno', 8), _Side('Sıcak Sos', 8),
        _Side('Ayran', 20), _Side('Cola 330ml', 25), _Side('Su', 12),
      ],
    );
  }

  // ── ÇİĞ KÖFTE ─────────────────────────────────────────────────
  if (has(['çiğ köfte', 'cigköfte']) || (rName.contains('çiğ') && has(['dürüm', 'tabak', 'porsiyon']))) {
    return const _MenuData(
      removable: [
        _Ingredient('Nar Ekşisi'), _Ingredient('Maydanoz'),
        _Ingredient('Limon'), _Ingredient('Yeşil Soğan'),
        _Ingredient('Roka'), _Ingredient('Sos'),
      ],
      sides: [
        _Side('Ayran', 20), _Side('Şalgam Acılı', 15),
        _Side('Şalgam Acısız', 15), _Side('Portakal Suyu', 25),
        _Side('Ekstra Dürüm', 42), _Side('Acı Sos (+)', 5),
        _Side('Turşu', 10),
      ],
    );
  }

  // ── KOKOREÇ ───────────────────────────────────────────────────
  if (has(['kokoreç'])) {
    return const _MenuData(
      removable: [
        _Ingredient('Kekik'), _Ingredient('Kimyon'),
        _Ingredient('Kırmızı Biber'), _Ingredient('Soğan'),
        _Ingredient('Domates'),
      ],
      sides: [
        _Side('Turşu', 10), _Side('Taze Soğan', 8),
        _Side('Ayran', 20), _Side('Kola', 25),
        _Side('Ekstra Ekmek', 10),
      ],
    );
  }

  // ── MIDYE DOLMA ───────────────────────────────────────────────
  if (has(['midye'])) {
    return const _MenuData(
      removable: [_Ingredient('Limon'), _Ingredient('Acı Sos')],
      sides: [
        _Side('Ekstra Midye (5)', 35), _Side('Ayran', 20),
        _Side('Kola', 25), _Side('Limonata', 28),
      ],
    );
  }

  // ── ISLAK BURGER ──────────────────────────────────────────────
  if (has(['ıslak', 'islak'])) {
    return const _MenuData(
      removable: [_Ingredient('Domates Sosu'), _Ingredient('Soğan')],
      sides: [
        _Side('Ekstra Islak Burger', 55), _Side('Turşu', 10),
        _Side('Ayran', 20), _Side('Kola', 25),
      ],
    );
  }

  // ── TANTUNI ───────────────────────────────────────────────────
  if (has(['tantuni'])) {
    return const _MenuData(
      removable: [
        _Ingredient('Soğan'), _Ingredient('Domates'),
        _Ingredient('Maydanoz'), _Ingredient('Yeşil Biber'),
        _Ingredient('Limon'), _Ingredient('Acı Biber'),
      ],
      sides: [
        _Side('Şalgam', 15), _Side('Ayran', 20),
        _Side('Turşu', 10), _Side('Ekstra Lavaş', 8),
        _Side('Kola', 25),
      ],
    );
  }

  // ── BURGER ────────────────────────────────────────────────────
  if (has(['burger', 'smash', 'cheeseburger', 'whopper', 'big mac']) || cuis.contains('burger')) {
    // Extract actual ingredients from description to offer as removable
    final removable = <_Ingredient>[];
    if (iDesc.contains('soğan') || iName.contains('soğan')) removable.add(const _Ingredient('Soğan'));
    if (iDesc.contains('turşu') || iDesc.contains('pickle')) removable.add(const _Ingredient('Turşu'));
    if (iDesc.contains('domates') || iDesc.contains('tomato')) removable.add(const _Ingredient('Domates'));
    if (iDesc.contains('marul') || iDesc.contains('lettuce')) removable.add(const _Ingredient('Marul'));
    if (iDesc.contains('ketçap') || iDesc.contains('ketchup')) removable.add(const _Ingredient('Ketçap'));
    if (iDesc.contains('mayonez') || iDesc.contains('mayo')) removable.add(const _Ingredient('Mayonez'));
    if (iDesc.contains('hardal') || iDesc.contains('mustard')) removable.add(const _Ingredient('Hardal'));
    if (iDesc.contains('kaşar') || iDesc.contains('cheese') || iDesc.contains('cheddar')) removable.add(const _Ingredient('Kaşar'));
    if (iDesc.contains('jalapeno') || iDesc.contains('jalapeño')) removable.add(const _Ingredient('Jalapeño'));
    if (iDesc.contains('sos') && removable.isEmpty) removable.add(const _Ingredient('Sos'));
    // Default removable set if description has no info
    if (removable.isEmpty) {
      removable.addAll([
        const _Ingredient('Soğan'), const _Ingredient('Turşu'),
        const _Ingredient('Domates'), const _Ingredient('Marul'),
        const _Ingredient('Ketçap'), const _Ingredient('Mayonez'),
      ]);
    }
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Patates Kızartması (K)', 35), _Side('Patates Kızartması (B)', 45),
        _Side('Onion Ring', 40), _Side('Coleslaw', 28),
        _Side('Nugget 6 Adet', 55), _Side('BBQ Sos', 10),
        _Side('Kola 330ml', 29), _Side('Ayran', 20),
        _Side('Limonata', 30), _Side('Su', 12),
      ],
    );
  }

  // ── PIZZA ─────────────────────────────────────────────────────
  if (has(['pizza']) || cuis.contains('pizza')) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('soğan') || iName.contains('soğan')) removable.add(const _Ingredient('Soğan'));
    if (iDesc.contains('biber') || iDesc.contains('pepper')) removable.add(const _Ingredient('Biber'));
    if (iDesc.contains('mantar') || iDesc.contains('mushroom')) removable.add(const _Ingredient('Mantar'));
    if (iDesc.contains('zeytin') || iDesc.contains('olive')) removable.add(const _Ingredient('Zeytin'));
    if (iDesc.contains('sucuk') || iDesc.contains('sausage')) removable.add(const _Ingredient('Sucuk'));
    if (iDesc.contains('pepperoni')) removable.add(const _Ingredient('Pepperoni'));
    if (iDesc.contains('sarımsak') || iDesc.contains('garlic')) removable.add(const _Ingredient('Sarımsak'));
    if (iDesc.contains('jalapeno') || iDesc.contains('jalapeño')) removable.add(const _Ingredient('Jalapeño'));
    if (removable.isEmpty) {
      removable.addAll([const _Ingredient('Soğan'), const _Ingredient('Biber'), const _Ingredient('Mantar')]);
    }
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Garlic Dip', 15), _Side('Ranch Sos', 12),
        _Side('BBQ Sos', 12), _Side('Sarımsaklı Ekmek', 28),
        _Side('Mozzarella Çubukları', 55), _Side('Caesar Salata', 48),
        _Side('Kola 330ml', 29), _Side('Ayran', 20), _Side('Su', 12),
      ],
    );
  }

  // ── DÖNER ─────────────────────────────────────────────────────
  if (has(['döner', 'iskender', 'dürüm döner']) || cuis.contains('döner')) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('soğan')) removable.add(const _Ingredient('Soğan'));
    if (iDesc.contains('domates')) removable.add(const _Ingredient('Domates'));
    if (iDesc.contains('maydanoz')) removable.add(const _Ingredient('Maydanoz'));
    if (iDesc.contains('turşu')) removable.add(const _Ingredient('Turşu'));
    if (iDesc.contains('acı') || iDesc.contains('biber')) removable.add(const _Ingredient('Acı Biber'));
    if (iDesc.contains('sarımsak')) removable.add(const _Ingredient('Sarımsak Sosu'));
    if (iDesc.contains('piyaz') || iDesc.contains('soğan')) removable.add(const _Ingredient('Piyaz'));
    if (removable.isEmpty) {
      removable.addAll([
        const _Ingredient('Soğan'), const _Ingredient('Domates'),
        const _Ingredient('Turşu'), const _Ingredient('Acı Sos'),
      ]);
    }
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Pilav', 25), _Side('Cacık', 22),
        _Side('Ezme', 20), _Side('Çorba', 30),
        _Side('Salata', 25), _Side('Turşu', 10),
        _Side('Ayran', 20), _Side('Şalgam', 15), _Side('Kola', 29),
      ],
    );
  }

  // ── KEBAP (şiş, adana, urfa…) ─────────────────────────────────
  if (has(['kebap', 'adana', 'urfa', 'şiş', 'sis kebap', 'tavuk şiş', 'kuzu'])) {
    return const _MenuData(
      removable: [
        _Ingredient('Soğan'), _Ingredient('Domates'), _Ingredient('Biber'),
        _Ingredient('Maydanoz'), _Ingredient('Sumak'),
      ],
      sides: [
        _Side('Pilav', 25), _Side('Lavaş', 8), _Side('Pide', 15),
        _Side('Cacık', 22), _Side('Ezme', 20),
        _Side('Ayran', 20), _Side('Kola', 29),
      ],
    );
  }

  // ── PİDE ──────────────────────────────────────────────────────
  if (has(['pide', 'lahmacun'])) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('kaşar') || iDesc.contains('peynir')) removable.add(const _Ingredient('Kaşar'));
    if (iDesc.contains('kıyma') || iDesc.contains('et')) removable.add(const _Ingredient('Kıyma'));
    if (iDesc.contains('sucuk')) removable.add(const _Ingredient('Sucuk'));
    if (iDesc.contains('yumurta')) removable.add(const _Ingredient('Yumurta'));
    if (iDesc.contains('soğan') || iDesc.contains('biber')) {
      removable.add(const _Ingredient('Soğan'));
      removable.add(const _Ingredient('Biber'));
    }
    if (iDesc.contains('domates')) removable.add(const _Ingredient('Domates'));
    if (iDesc.contains('maydanoz') || iName.contains('lahmacun')) removable.add(const _Ingredient('Maydanoz'));
    if (iName.contains('lahmacun')) removable.add(const _Ingredient('Nar Ekşisi'));
    if (removable.isEmpty) removable.addAll([const _Ingredient('Soğan'), const _Ingredient('Biber')]);
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Ayran', 20), _Side('Cacık', 22),
        _Side('Salata', 25), _Side('Turşu', 10),
        _Side('Çorba', 30),
      ],
    );
  }

  // ── TAVUK ─────────────────────────────────────────────────────
  if (has(['tavuk', 'kanat', 'nugget', 'tender', 'crispy', 'piliç', 'broast']) || cuis.contains('tavuk')) {
    final isWing = has(['kanat', 'wing', 'bucket']);
    return _MenuData(
      removable: [
        if (!isWing) const _Ingredient('Marul'),
        if (!isWing) const _Ingredient('Domates'),
        if (!isWing) const _Ingredient('Turşu'),
        const _Ingredient('Sos'),
        const _Ingredient('Sarımsak Sosu'),
      ],
      sides: const [
        _Side('Patates Kızartması', 40), _Side('Coleslaw', 28),
        _Side('Mısır', 22), _Side('BBQ Sos', 10),
        _Side('Ranch Dip', 12), _Side('Acı Sos', 8),
        _Side('Kola 330ml', 29), _Side('Ayran', 20),
      ],
    );
  }

  // ── ET / IZGARA ───────────────────────────────────────────────
  if (has(['antrikot', 'ribeye', 'bonfile', 't-bone', 'pirzola', 'kuşbaşı', 'ızgara et']) ||
      (has(['köfte']) && (cuis.contains('et') || rName.contains('köfteci')))) {
    return const _MenuData(
      removable: [
        _Ingredient('Sos'), _Ingredient('Soğan'),
        _Ingredient('Sarımsak'), _Ingredient('Biberiye'),
      ],
      sides: [
        _Side('Sote Mantar', 52), _Side('Patates Rösti', 52),
        _Side('Izgara Sebze', 58), _Side('Yeşil Salata', 45),
        _Side('Pilav', 25), _Side('Ekmek Sepeti', 20),
        _Side('Maden Suyu', 20),
      ],
    );
  }

  // ── KÖFTE (burger/ekmek arası) ────────────────────────────────
  if (has(['köfte'])) {
    return const _MenuData(
      removable: [
        _Ingredient('Soğan'), _Ingredient('Domates'),
        _Ingredient('Biber'), _Ingredient('Turşu'), _Ingredient('Sos'),
      ],
      sides: [
        _Side('Pilav', 25), _Side('Piyaz', 22),
        _Side('Cacık', 22), _Side('Salata', 25),
        _Side('Turşu', 10), _Side('Ayran', 20), _Side('Kola', 29),
      ],
    );
  }

  // ── BALIQ / DENİZ ─────────────────────────────────────────────
  if (has(['levrek', 'çipura', 'somon', 'karides', 'balık', 'midye', 'ahtapot', 'kalamar']) ||
      cuis.contains('deniz')) {
    return const _MenuData(
      removable: [
        _Ingredient('Limon'), _Ingredient('Roka'),
        _Ingredient('Soğan'), _Ingredient('Sos'),
      ],
      sides: [
        _Side('Pilav', 25), _Side('Patates Tava', 38),
        _Side('Yeşil Salata', 45), _Side('Ezme', 20),
        _Side('Meze Tabağı', 65), _Side('Maden Suyu', 20),
        _Side('Ayran', 20),
      ],
    );
  }

  // ── VEGAN / SALATA ────────────────────────────────────────────
  if (has(['falafel', 'buddha', 'humus', 'hummus', 'wrap vegan', 'salata', 'bowl']) ||
      cuis.contains('vegan')) {
    return const _MenuData(
      removable: [
        _Ingredient('Avokado'), _Ingredient('Soğan'),
        _Ingredient('Domates'), _Ingredient('Limon'),
        _Ingredient('Sos'), _Ingredient('Nar'),
      ],
      sides: [
        _Side('Taze Limonata', 30), _Side('Smoothie', 55),
        _Side('Ekstra Humus', 22), _Side('Pita Ekmek', 12),
        _Side('Turşu', 10), _Side('Boza', 20),
      ],
    );
  }

  // ── MANTI ─────────────────────────────────────────────────────
  if (has(['mantı', 'manti'])) {
    return const _MenuData(
      removable: [
        _Ingredient('Yoğurt'), _Ingredient('Tereyağı'),
        _Ingredient('Pul Biber'), _Ingredient('Sarımsak'),
        _Ingredient('Nane'),
      ],
      sides: [
        _Side('Çorba', 30), _Side('Cacık', 22),
        _Side('Ekstra Yoğurt', 12), _Side('Salata', 25),
        _Side('Ayran', 20), _Side('Limonata', 30),
      ],
    );
  }

  // ── MAKARNA ───────────────────────────────────────────────────
  if (has(['makarna', 'spaghetti', 'carbonara', 'penne', 'fettuccine', 'pasta'])) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('soğan')) removable.add(const _Ingredient('Soğan'));
    if (iDesc.contains('sarımsak') || iDesc.contains('garlic')) removable.add(const _Ingredient('Sarımsak'));
    if (iDesc.contains('parmesan')) removable.add(const _Ingredient('Parmesan'));
    if (iDesc.contains('karabiber')) removable.add(const _Ingredient('Karabiber'));
    if (iDesc.contains('maydanoz') || iDesc.contains('parsley')) removable.add(const _Ingredient('Maydanoz'));
    if (iDesc.contains('guanciale') || iDesc.contains('bacon')) removable.add(const _Ingredient('Guanciale'));
    if (removable.isEmpty) {
      removable.addAll([const _Ingredient('Soğan'), const _Ingredient('Parmesan'), const _Ingredient('Karabiber')]);
    }
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Ekstra Parmesan', 15), _Side('Garlic Bread', 28),
        _Side('Caesar Salata', 45), _Side('Çorba', 30),
        _Side('Tiramisu', 72), _Side('Limonata', 30),
      ],
    );
  }

  // ── KAHVALTI ──────────────────────────────────────────────────
  if (has(['serpme', 'kahvaltı', 'menemen', 'omlet', 'sahanda', 'sucuklu yumurta']) ||
      cuis.contains('kahvaltı')) {
    return const _MenuData(
      removable: [
        _Ingredient('Soğan'), _Ingredient('Biber'),
        _Ingredient('Domates'), _Ingredient('Zeytin'),
        _Ingredient('Reçel'), _Ingredient('Bal'),
      ],
      sides: [
        _Side('Çay Demliği', 25), _Side('Türk Kahvesi', 38),
        _Side('Portakal Suyu', 30), _Side('Ekstra Ekmek', 10),
        _Side('Sucuk Ekle', 32), _Side('Taze Meyve Tabağı', 28),
      ],
    );
  }

  // ── GÖZLEME ───────────────────────────────────────────────────
  if (has(['gözleme'])) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('peynir')) removable.add(const _Ingredient('Peynir'));
    if (iDesc.contains('ot') || iDesc.contains('nane') || iDesc.contains('maydanoz')) removable.add(const _Ingredient('Ot'));
    if (iDesc.contains('kıyma') || iDesc.contains('et')) removable.add(const _Ingredient('Kıyma'));
    if (iDesc.contains('soğan')) removable.add(const _Ingredient('Soğan'));
    if (iDesc.contains('patates')) removable.add(const _Ingredient('Patates'));
    if (removable.isEmpty) removable.add(const _Ingredient('İç Harcı'));
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Ayran', 20), _Side('Çay', 15),
        _Side('Cacık', 22), _Side('Turşu', 10),
        _Side('Bal & Kaymak', 25),
      ],
    );
  }

  // ── BÖREK ─────────────────────────────────────────────────────
  if (has(['börek', 'su böreği', 'sigara böreği', 'kol böreği'])) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('peynir')) removable.add(const _Ingredient('Peynir'));
    if (iDesc.contains('ot') || iDesc.contains('maydanoz')) removable.add(const _Ingredient('Ot'));
    if (iDesc.contains('kıyma')) removable.add(const _Ingredient('Kıyma'));
    if (iDesc.contains('ıspanak') || iDesc.contains('ispanak')) removable.add(const _Ingredient('Ispanak'));
    if (removable.isEmpty) removable.add(const _Ingredient('İç Harcı'));
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Çay', 15), _Side('Ayran', 20),
        _Side('Turşu', 10), _Side('Kaymak & Bal', 22),
      ],
    );
  }

  // ── TOST / SANDVIÇ ────────────────────────────────────────────
  if (has(['tost', 'sandviç', 'sandwich', 'club'])) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('kaşar') || iDesc.contains('peynir')) removable.add(const _Ingredient('Kaşar'));
    if (iDesc.contains('sucuk')) removable.add(const _Ingredient('Sucuk'));
    if (iDesc.contains('domates')) removable.add(const _Ingredient('Domates'));
    if (iDesc.contains('turşu')) removable.add(const _Ingredient('Turşu'));
    if (iDesc.contains('marul') || iDesc.contains('yeşillik')) removable.add(const _Ingredient('Marul'));
    if (iDesc.contains('mayonez')) removable.add(const _Ingredient('Mayonez'));
    if (removable.isEmpty) {
      removable.addAll([
        const _Ingredient('Kaşar'), const _Ingredient('Domates'), const _Ingredient('Turşu'),
      ]);
    }
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Çay', 15), _Side('Ayran', 20),
        _Side('Patates Cipsi', 18), _Side('Meyve Suyu', 25),
        _Side('Ketçap', 5), _Side('Mayonez', 5),
      ],
    );
  }

  // ── SİMİT ─────────────────────────────────────────────────────
  if (has(['simit'])) {
    return const _MenuData(
      removable: [_Ingredient('Kaşar'), _Ingredient('Zeytin')],
      sides: [
        _Side('Çay', 15), _Side('Türk Kahvesi', 35),
        _Side('Ayran', 20), _Side('Peynir Ekle', 18),
        _Side('Reçel Ekle', 12),
      ],
    );
  }

  // ── BALIQ EKMEK ───────────────────────────────────────────────
  if (has(['balık ekmek'])) {
    return const _MenuData(
      removable: [
        _Ingredient('Soğan'), _Ingredient('Biber'),
        _Ingredient('Maydanoz'), _Ingredient('Limon'),
      ],
      sides: [
        _Side('Turşu', 10), _Side('Ayran', 20),
        _Side('Kola', 29), _Side('Patates', 35),
      ],
    );
  }

  // ── PASTANE (kek, pasta, tatlı…) ──────────────────────────────
  if (has(['pasta', 'kek', 'tiramisu', 'cheesecake', 'profiterol', 'baklava',
           'künefe', 'sütlaç', 'kazandibi', 'waffle', 'krep']) ||
      cuis.contains('pastane')) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('çikolata') || iDesc.contains('chocolate')) removable.add(const _Ingredient('Çikolata Sos'));
    if (iDesc.contains('krema') || iDesc.contains('cream')) removable.add(const _Ingredient('Krema'));
    if (iDesc.contains('fındık') || iDesc.contains('fıstık')) removable.add(const _Ingredient('Fındık'));
    if (iDesc.contains('meyve') || iDesc.contains('çilek')) removable.add(const _Ingredient('Meyve/Çilek'));
    if (removable.isEmpty) removable.add(const _Ingredient('Sos'));
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Türk Kahvesi', 38), _Side('Çay', 20),
        _Side('Sütlü Kahve', 48), _Side('Portakal Suyu', 30),
        _Side('Dondurma Topping', 15),
      ],
    );
  }

  // ── KAHVE ─────────────────────────────────────────────────────
  if (has(['latte', 'cappuccino', 'espresso', 'americano', 'flat white',
           'cold brew', 'filtre', 'matcha', 'türk kahvesi', 'nescafe']) ||
      cuis.contains('kahve')) {
    final isHot = !has(['iced', 'cold', 'frappuccino', 'soğuk']);
    return _MenuData(
      removable: const [_Ingredient('Şeker'), _Ingredient('Süt')],
      sides: [
        const _Side('Oat Milk (+)', 12), const _Side('Almond Milk (+)', 12),
        if (isHot) const _Side('Extra Shot', 15),
        const _Side('Şurup (+)', 10),
        const _Side('Kruvasan', 55), const _Side('Cheesecake Dilim', 68),
        const _Side('Tiramisu', 72), const _Side('Granola Kase', 62),
      ],
    );
  }

  // ── İÇECEK ────────────────────────────────────────────────────
  if (has(['ayran', 'şalgam', 'limonata', 'smoothie', 'meyve suyu', 'cola',
           'boza', 'kefir', 'soda'])) {
    return const _MenuData(
      removable: [_Ingredient('Şeker'), _Ingredient('Buz')],
      sides: [
        _Side('Ekstra Büyük Boy', 8), _Side('Atıştırmalık', 15),
      ],
    );
  }

  // ── EV YEMEKLERİ ─────────────────────────────────────────────
  if (has(['pilav', 'çorba', 'dolma', 'sarma', 'etli', 'zeytinyağlı', 'musakka', 'güveç']) ||
      cuis.contains('ev yemek')) {
    final removable = <_Ingredient>[];
    if (iDesc.contains('soğan')) removable.add(const _Ingredient('Soğan'));
    if (iDesc.contains('sarımsak')) removable.add(const _Ingredient('Sarımsak'));
    if (iDesc.contains('biber')) removable.add(const _Ingredient('Biber'));
    if (iDesc.contains('domates')) removable.add(const _Ingredient('Domates'));
    if (removable.isEmpty) removable.add(const _Ingredient('Sos'));
    return _MenuData(
      removable: removable,
      sides: const [
        _Side('Cacık', 22), _Side('Turşu', 10),
        _Side('Ayran', 20), _Side('Salata', 25),
        _Side('Ekstra Pilav', 22), _Side('Ekmek', 10),
      ],
    );
  }

  // ── GENERIC FALLBACK ─────────────────────────────────────────
  return const _MenuData(
    removable: [],
    sides: [
      _Side('Ayran', 20), _Side('Kola 330ml', 29),
      _Side('Limonata', 30), _Side('Su', 12),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
//  ITEM DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────────────────────
class ItemDetailSheet extends StatefulWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final ScrollController? scrollController;
  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.restaurant,
    this.scrollController,
  });

  static Future<void> show(BuildContext context, MenuItem item, Restaurant restaurant) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        useSafeArea: true,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.35, 0.6, 0.95],
          expand: false,
          builder: (ctx, scrollController) => ItemDetailSheet(
            item: item,
            restaurant: restaurant,
            scrollController: scrollController,
          ),
        ),
      );

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  int _qty = 1;
  final _noteCtrl = TextEditingController();
  final Set<String> _removed  = {};
  final Set<String> _sides    = {};
  final Set<String> _optIds   = {};
  late final _MenuData _data;

  @override
  void initState() {
    super.initState();
    _data = _resolve(widget.item, widget.restaurant);
  }

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  double get _extraCost {
    double t = 0;
    for (final s in _data.sides) if (_sides.contains(s.name)) t += s.price;
    for (final o in widget.item.options) if (_optIds.contains(o.id)) t += o.price;
    return t;
  }
  double get _unitPrice  => widget.item.price + _extraCost;
  double get _total      => _unitPrice * _qty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item  = widget.item;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle — sürüklemek için dokunma alanı
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        Flexible(child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Header row
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (item.isPopular) Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🔥 Popüler',
                      style: TextStyle(fontSize: 10, color: AppTheme.orange, fontWeight: FontWeight.w600)),
                ),
                Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(item.description,
                      style: const TextStyle(color: AppTheme.grey, fontSize: 13, height: 1.4)),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  Text('₺${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  if (item.isVegetarian) const Text('🌱 ', style: TextStyle(fontSize: 14)),
                  if (item.isSpicy) const Text('🌶️', style: TextStyle(fontSize: 14)),
                ]),
              ])),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AppImage(url: item.imageUrl, width: 88, height: 88, fit: BoxFit.cover,
                    errorWidget: Container(
                        width: 88, height: 88,
                        color: theme.scaffoldBackgroundColor,
                        child: const Icon(Icons.fastfood, color: AppTheme.grey))),
              ),
            ]),

            const SizedBox(height: 16),
            Divider(height: 1, color: theme.dividerColor),

            // ── Malzeme Çıkar ──────────────────────────────────
            if (_data.removable.isNotEmpty) ...[
              const SizedBox(height: 14),
              _sectionHead('🥬 Malzeme Çıkar', 'İstemediğini işaretle'),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _data.removable.map((ing) {
                final removed = _removed.contains(ing.name);
                return GestureDetector(
                  onTap: () => setState(() =>
                      removed ? _removed.remove(ing.name) : _removed.add(ing.name)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: removed ? AppTheme.red.withOpacity(0.1) : theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: removed ? AppTheme.red : theme.dividerColor,
                          width: removed ? 1.5 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (removed) ...[
                        const Icon(Icons.close, size: 12, color: AppTheme.red),
                        const SizedBox(width: 4),
                      ],
                      Text(ing.name, style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500,
                          color: removed ? AppTheme.red : null,
                          decoration: removed ? TextDecoration.lineThrough : null)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 14),
              Divider(height: 1, color: theme.dividerColor),
            ],

            // ── MenuItem options (e.g. size choice, extras from data_service) ──
            if (widget.item.options.where((o) => !o.isRemovable).isNotEmpty) ...[
              const SizedBox(height: 14),
              _sectionHead('✨ Ekstra Seçenekler', 'Özelleştir'),
              const SizedBox(height: 8),
              ...widget.item.options.where((o) => !o.isRemovable).map((opt) => _checkRow(
                    opt.name,
                    opt.price > 0 ? '+₺${opt.price.toStringAsFixed(0)}' : 'Ücretsiz',
                    _optIds.contains(opt.id),
                    () => setState(() => _optIds.contains(opt.id)
                        ? _optIds.remove(opt.id)
                        : _optIds.add(opt.id)),
                    theme,
                  )),
              const SizedBox(height: 14),
              Divider(height: 1, color: theme.dividerColor),
            ],

            // ── Yanında Gelsin ─────────────────────────────────
            if (_data.sides.isNotEmpty) ...[
              const SizedBox(height: 14),
              _sectionHead('🍟 Yanında Gelsin', 'Eklemek istediğini seç'),
              const SizedBox(height: 8),
              ..._data.sides.map((s) => _checkRow(
                    s.name,
                    s.price > 0 ? '+₺${s.price.toStringAsFixed(0)}' : 'Ücretsiz',
                    _sides.contains(s.name),
                    () => setState(() => _sides.contains(s.name)
                        ? _sides.remove(s.name)
                        : _sides.add(s.name)),
                    theme,
                  )),
              const SizedBox(height: 14),
              Divider(height: 1, color: theme.dividerColor),
            ],

            // ── Not ────────────────────────────────────────────
            const SizedBox(height: 14),
            _sectionHead('📝 Ürün Notu', 'Aşçıya özel istek'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              maxLength: 150,
              decoration: const InputDecoration(
                hintText: 'Örn: Az pişsin, ekstra sos, vb.',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        )),

        // ── Bottom bar ─────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(children: [
            // Qty control
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: Icon(_qty == 1 ? Icons.delete_outline : Icons.remove,
                      color: _qty == 1 ? AppTheme.red : AppTheme.primaryGreen, size: 18),
                  onPressed: () { if (_qty > 1) setState(() => _qty--); },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('$_qty',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: AppTheme.primaryGreen, size: 18),
                  onPressed: () => setState(() => _qty++),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Sepete Ekle',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 8),
                Text('₺${_total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ]),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionHead(String title, String sub) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(width: 8),
      Text(sub, style: const TextStyle(color: AppTheme.grey, fontSize: 11)),
    ],
  );

  Widget _checkRow(String label, String price, bool sel, VoidCallback onTap, ThemeData theme) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primaryGreen.withOpacity(0.07) : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? AppTheme.primaryGreen : theme.dividerColor,
                width: sel ? 1.5 : 1),
          ),
          child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: sel ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: sel ? AppTheme.primaryGreen : AppTheme.grey),
              ),
              child: sel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            Text(price, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: sel ? AppTheme.primaryGreen : AppTheme.grey)),
          ]),
        ),
      );

  void _addToCart() {
    final removedList = _data.removable
        .where((i) => _removed.contains(i.name))
        .map((i) => MenuOption(id: 'rm_${i.name}', name: i.name, isRemovable: true))
        .toList();
    final sideList = _data.sides
        .where((s) => _sides.contains(s.name))
        .map((s) => MenuOption(id: 'sd_${s.name}', name: s.name, price: s.price))
        .toList();
    final optList = widget.item.options
        .where((o) => _optIds.contains(o.id) && !o.isRemovable)
        .toList();

    context.read<CartProvider>().addCustomItem(CartItem(
      item: widget.item,
      restaurant: widget.restaurant,
      quantity: _qty,
      note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      removedIngredients: removedList,
      sideItems: sideList,
      selectedOptions: optList,
    ));

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text('${widget.item.name} sepete eklendi')),
      ]),
      backgroundColor: AppTheme.primaryGreen,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}
