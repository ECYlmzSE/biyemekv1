import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../providers/card_provider.dart';
import 'saved_cards_screen.dart';
import 'auth_screen.dart';
import 'orders_screen.dart';
import 'address_screen.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final theme  = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    final orderCount    = orders.pastOrders.length;
// User info
    final user = auth.currentUser;
    final hasName  = user?.displayName?.isNotEmpty == true;
    final hasEmail = user?.email?.isNotEmpty == true;
    final hasPhone = user?.phone?.isNotEmpty == true;
    final displayName = hasName
        ? user!.displayName!
        : hasEmail
            ? user!.email!.split('@').first
            : hasPhone
                ? user!.phone!
                : 'Kullanıcı';
    final avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'K';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          // ── Header ──────────────────────────────────────────
          Row(children: [
            CircleAvatar(
              radius: 38,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
              child: Text(auth.isLoggedIn ? avatarLetter : '👤',
                style: TextStyle(fontSize: auth.isLoggedIn ? 28 : 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(auth.isLoggedIn ? displayName : 'Misafir Kullanıcı',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              if (auth.isLoggedIn && user?.email?.isNotEmpty == true)
                Text(user!.email!, style: const TextStyle(fontSize: 12, color: AppTheme.grey), overflow: TextOverflow.ellipsis),
              if (auth.isLoggedIn && user?.phone?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    const Icon(Icons.phone, size: 12, color: AppTheme.grey),
                    const SizedBox(width: 4),
                    Text('+90 ${_formatPhone(user!.phone!)}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                  ]),
                ),
              if (!auth.isLoggedIn)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                  child: const Text('Giriş yap / Kayıt ol',
                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w500, fontSize: 13)),
                ),
            ])),
            if (auth.isLoggedIn)
              IconButton(
                onPressed: () => _showEditProfile(context, auth),
                icon: const Icon(Icons.edit_outlined, color: AppTheme.grey, size: 20),
              ),
          ]),
          const SizedBox(height: 20),

          // ── Stats ────────────────────────────────────────────
          Row(children: [
            Expanded(child: _StatCard(value: '$orderCount', label: 'Sipariş', icon: '📦')),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '${orders.reviews.length}', label: 'Değerlendirme', icon: '⭐')),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(value: '${auth.favorites.length}', label: 'Favori', icon: '❤️')),
          ]),
          const SizedBox(height: 20),

          // ── BYM Bakiye Kartı ─────────────────────────────────
          if (auth.isLoggedIn)
            _BalanceCard(balance: auth.balance, onTopUp: () => _showTopUpSheet(context, auth)),
          if (auth.isLoggedIn) const SizedBox(height: 14),

          // ── Hesabım ──────────────────────────────────────────
          _Section(title: 'HESABIM', children: [
            _Tile(icon: Icons.shopping_bag_outlined, color: Colors.blue, label: 'Siparişlerim',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
            _Tile(icon: Icons.favorite_outline, color: AppTheme.red, label: 'Favorilerim',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
            _Tile(icon: Icons.location_on_outlined, color: AppTheme.primaryGreen, label: 'Adreslerim',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()))),
            _Tile(icon: Icons.card_giftcard_outlined, color: AppTheme.orange, label: 'Promosyon Kodları',
              onTap: () => _showPromoSheet(context)),
            _Tile(icon: Icons.credit_card_outlined, color: Colors.purple, label: 'Kayıtlı Kartlarım',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedCardsScreen()))),
            if (auth.isLoggedIn)
              _Tile(icon: Icons.logout, color: AppTheme.red, label: 'Çıkış Yap',
                onTap: () => _confirmSignOut(context, auth)),
          ]),
          const SizedBox(height: 14),

          // ── Yardım ───────────────────────────────────────────
          _Section(title: 'YARDIM', children: [
            _Tile(icon: Icons.help_outline, color: Colors.teal, label: 'Yardım Merkezi',
              onTap: () => _showInfo(context, 'Yardım Merkezi', 'Sorularınız için:\n📧 destek@biyemek.com\n📞 0850 123 45 67\n\nÇalışma saatleri: 08:00 - 24:00')),
            _Tile(icon: Icons.chat_bubble_outline, color: Colors.indigo, label: 'Bize Ulaşın',
              onTap: () => _showInfo(context, 'Bize Ulaşın', '📧 iletisim@biyemek.com\n📞 0850 123 45 67\n\nSosyal medya:\nInstagram: @biyemek\nTwitter: @biyemek')),
            _Tile(icon: Icons.info_outline, color: AppTheme.grey, label: 'Hakkımızda',
              onTap: () => _showInfo(context, "Bi'Yemek Hakkında", "Bi'Yemek, Türkiye genelinde binlerce restoranı kapınıza getiren yemek sipariş platformudur.\n\nVersiyon: 1.0.0\n© 2025 Bi'Yemek. Tüm hakları saklıdır.")),
          ]),
          const SizedBox(height: 14),

          // ── Uygulama ─────────────────────────────────────────
          _Section(title: 'UYGULAMA', children: [
            _Tile(icon: Icons.notifications_outlined, color: Colors.orange, label: 'Bildirimler',
              onTap: () => _showInfo(context, 'Bildirimler', 'Sipariş bildirimleri aktif.\nTelefon ayarlarından değiştirebilirsiniz.')),
            _Tile(
              icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? Colors.amber : Colors.blueGrey,
              label: isDark ? 'Açık Mod' : 'Karanlık Mod',
              onTap: () => context.read<ThemeProvider>().toggle(),
              trailing: Switch(
                value: isDark,
                activeColor: AppTheme.primaryGreen,
                onChanged: (_) => context.read<ThemeProvider>().toggle(),
              ),
            ),
            if (auth.isLoggedIn)
              _Tile(icon: Icons.delete_forever_outlined, color: Colors.red.shade800, label: 'Hesabı Kalıcı Olarak Sil',
                onTap: () => _confirmDeleteAccount(context, auth)),
          ]),
          const SizedBox(height: 24),

          Center(child: Text(
            "Bi'Yemek v1.0.0 • © 2025 Tüm hakları saklıdır",
            style: const TextStyle(color: AppTheme.grey, fontSize: 11),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Formats a 10-digit phone string as "545 555 4444"
  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    return raw; // fallback: show as-is
  }

  void _showEditProfile(BuildContext context, AuthProvider auth) {
    final nameCtrl  = TextEditingController(text: auth.currentUser?.displayName ?? '');
    final phoneCtrl = TextEditingController(text: auth.currentUser?.phone ?? '');
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Profili Düzenle', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Ad Soyad', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words),
          const SizedBox(height: 14),
          TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: '+90 ',
                counterText: '',
                hintText: '5XX XXX XX XX',
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              auth.updateProfile(displayName: nameCtrl.text.trim(), phone: phoneCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ),
    );
  }

  void _showPromoSheet(BuildContext context) {
    const codes = [
      {'code': 'BIYEMEK30', 'desc': 'Tüm siparişlerde %30 indirim', 'expiry': '31.12.2025'},
      {'code': 'HOSGELDIN', 'desc': 'İlk siparişte %20 indirim', 'expiry': '31.12.2025'},
      {'code': 'YEMEK15', 'desc': 'Kahve & İçeceklerde %15 indirim', 'expiry': '31.12.2025'},
      {'code': 'INDIRIM25', 'desc': 'Sokak lezzetlerinde %25 indirim', 'expiry': '31.12.2025'},
    ];
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.3, maxChildSize: 0.8, expand: false,
        builder: (_, sc) => Column(children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Promosyon Kodlarım', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          Expanded(child: ListView(controller: sc, children: codes.map((c) => ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.local_offer, color: AppTheme.orange)),
            title: Text(c['code']!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            subtitle: Text('${c['desc']}\nSon kullanma: ${c['expiry']}'),
            isThreeLine: true,
          )).toList())),
        ]),
      ),
    );
  }

  void _showTopUpSheet(BuildContext context, AuthProvider auth) {
    final amountCtrl  = TextEditingController();
    final cardNoCtrl  = TextEditingController();
    final expiryCtrl  = TextEditingController();
    final cvvCtrl     = TextEditingController();
    final holderCtrl  = TextEditingController();
    final cards       = context.read<CardProvider>().cards;
    String? selectedCardId = cards.isNotEmpty ? cards.first.id : null;
    bool useNewCard = cards.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setBS) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx2).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('BYM Bakiye Yükle', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Mevcut bakiye: ₺${auth.balance.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
            const SizedBox(height: 20),

            // Quick amount buttons
            Row(children: [50.0, 100.0, 200.0, 500.0].map((v) =>
              Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  onPressed: () => amountCtrl.text = v.toStringAsFixed(0),
                  child: Text('₺${v.toStringAsFixed(0)}'),
                ),
              )),
            ).toList()),
            const SizedBox(height: 12),

            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Yüklenecek Tutar (₺)',
                prefixIcon: Icon(Icons.currency_lira),
              ),
            ),
            const SizedBox(height: 16),

            // ── Saved card selection ─────────────────────────
            if (cards.isNotEmpty) ...[
              const Text('Ödeme Kartı', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              ...cards.map((c) => RadioListTile<String>(
                value: c.id,
                groupValue: useNewCard ? null : selectedCardId,
                onChanged: (v) => setBS(() { selectedCardId = v; useNewCard = false; }),
                title: Text('•••• ${c.last4}'),
                subtitle: Text('${c.holderName} • ${c.expiry}'),
                activeColor: AppTheme.primaryGreen,
                contentPadding: EdgeInsets.zero,
              )),
              RadioListTile<String>(
                value: '__new__',
                groupValue: useNewCard ? '__new__' : null,
                onChanged: (_) => setBS(() => useNewCard = true),
                title: const Text('Yeni kart ile öde'),
                activeColor: AppTheme.primaryGreen,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            // ── New card form (shown when no saved cards OR "Yeni kart" selected) ──
            if (useNewCard) ...[
              const SizedBox(height: 8),
              TextField(
                controller: cardNoCtrl,
                keyboardType: TextInputType.number,
                maxLength: 19,
                decoration: const InputDecoration(
                  labelText: 'Kart Numarası',
                  prefixIcon: Icon(Icons.credit_card),
                  counterText: '',
                ),
                onChanged: (v) {
                  // Format as XXXX XXXX XXXX XXXX
                  final digits = v.replaceAll(' ', '');
                  final buf = StringBuffer();
                  for (var i = 0; i < digits.length && i < 16; i++) {
                    if (i > 0 && i % 4 == 0) buf.write(' ');
                    buf.write(digits[i]);
                  }
                  final formatted = buf.toString();
                  if (formatted != v) {
                    cardNoCtrl.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(
                  controller: expiryCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    labelText: 'Son Kullanma (AA/YY)',
                    counterText: '',
                  ),
                  onChanged: (v) {
                    final digits = v.replaceAll('/', '');
                    if (digits.length >= 2) {
                      final formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
                      if (formatted != v) {
                        expiryCtrl.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: cvvCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    counterText: '',
                  ),
                )),
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: holderCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Kart Üzerindeki İsim',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(
                    content: Text('Geçerli bir tutar giriniz'),
                    backgroundColor: AppTheme.red,
                  ));
                  return;
                }
                // Validate new card fields
                if (useNewCard) {
                  final digits = cardNoCtrl.text.replaceAll(' ', '');
                  if (digits.length < 16) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(
                      content: Text('Geçerli bir kart numarası giriniz'),
                      backgroundColor: AppTheme.red,
                    ));
                    return;
                  }
                  if (!expiryCtrl.text.contains('/') || expiryCtrl.text.length < 5) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(
                      content: Text('Son kullanma tarihini AA/YY formatında giriniz'),
                      backgroundColor: AppTheme.red,
                    ));
                    return;
                  }
                  if (cvvCtrl.text.length < 3) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(
                      content: Text('CVV 3 haneli olmalıdır'),
                      backgroundColor: AppTheme.red,
                    ));
                    return;
                  }
                  if (holderCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(
                      content: Text('Kart üzerindeki ismi giriniz'),
                      backgroundColor: AppTheme.red,
                    ));
                    return;
                  }
                }
                await auth.addBalance(amount);
                if (ctx2.mounted) {
                  Navigator.pop(ctx2);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('₺${amount.toStringAsFixed(2)} bakiyenize yüklendi! 🎉'),
                    backgroundColor: AppTheme.primaryGreen,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Bakiye Yükle', style: TextStyle(fontSize: 15)),
            )),
          ]),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınız ve tüm verileriniz (siparişler, adresler, bakiye) kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.deleteAccount();
              // Bellek içi sipariş/değerlendirme verisini hemen temizle
              if (context.mounted) {
                await context.read<OrderProvider>().switchUser('guest');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Kalıcı Olarak Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(content, style: const TextStyle(height: 1.6)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))),
        ]),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Çıkış Yap'),
      content: const Text('Hesabınızdan çıkış yapmak istiyor musunuz?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); auth.signOut(); }, child: const Text('Çıkış Yap')),
      ],
    ));
  }
}

// ── Balance Card ─────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onTopUp;
  const _BalanceCard({required this.balance, required this.onTopUp});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF06C167), Color(0xFF059652)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5))],
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('BYM Bakiye', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text('₺${balance.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('%10 cashback ile öde', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ])),
      ElevatedButton.icon(
        onPressed: onTopUp,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Yükle'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    ]),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.grey, letterSpacing: 1))),
    Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    ),
  ]);
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  const _Tile({required this.icon, required this.color, required this.label, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          trailing ?? const Icon(Icons.chevron_right, color: AppTheme.grey, size: 20),
        ]),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label, icon;
  const _StatCard({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.grey)),
      ]),
    ),
  );
}
