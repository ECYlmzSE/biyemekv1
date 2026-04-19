import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/card_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/connectivity_provider.dart';
import '../services/iyzico_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'address_screen.dart';
import 'order_tracking_screen.dart';
import 'saved_cards_screen.dart';
import 'payment_3ds_screen.dart';
import '../widgets/app_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoCtrl = TextEditingController();
  bool _showPromo = false;
  final _noteCtrl = TextEditingController();
  String _selectedPayment = 'Nakit';

  static const List<Map<String, dynamic>> _paymentOptionDefs = [
    {'id': 'Nakit',            'label': 'Nakit',         'icon': '💵', 'desc': 'Kapıda nakit'},
    {'id': 'Kart (Kapıda)',    'label': 'Kart (Kapıda)', 'icon': '💳', 'desc': 'Kapıda kredi/banka kartı'},
    {'id': 'Kredi Kartı',      'label': 'Kredi Kartı',   'icon': '🏦', 'desc': 'Online ödeme'},
    {'id': 'BiYemek Bakiyesi', 'label': 'BYM Bakiye',    'icon': '💰', 'desc': null}, // desc injected dynamically
  ];

  @override
  void dispose() { _promoCtrl.dispose(); _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cart, auth, _) {
          if (cart.isEmpty) return _emptyCart(context);
          return Column(children: [
            Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
              // Restaurant name
              if (cart.currentRestaurant != null)
                Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                  const Icon(Icons.restaurant, color: AppTheme.primaryGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(cart.currentRestaurant!.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ])),

              // Items
              ...cart.items.map((ci) => _CartTile(ci: ci, cart: cart)),
              const SizedBox(height: 16),

              // Min order warning
              if (!cart.meetsMinOrder)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.orange.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppTheme.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Minimum sepet tutarı: ₺${cart.minOrder.toStringAsFixed(0)} (₺${(cart.minOrder - cart.subtotal).toStringAsFixed(0)} eksik)', style: const TextStyle(color: AppTheme.orange, fontSize: 13))),
                  ]),
                ),

              // Address
              _buildAddressSection(context, auth),
              const SizedBox(height: 16),

              // Order note
              _buildNoteSection(cart),
              const SizedBox(height: 16),

              // Payment
              _buildPaymentSection(cart),
              const SizedBox(height: 16),

              // Promo code
              _buildPromoSection(cart),
              const SizedBox(height: 16),

              // Price summary
              _buildPriceSummary(cart),
            ])),
            _buildCheckout(context, cart, auth),
          ]);
        },
      ),
    );
  }

  Widget _emptyCart(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('🛒', style: TextStyle(fontSize: 70)),
    const SizedBox(height: 16),
    const Text('Sepetiniz boş', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text('Lezzetli yemekler sizi bekliyor!', style: TextStyle(color: AppTheme.grey)),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Alışverişe Başla')),
  ]));

  Widget _buildAddressSection(BuildContext context, AuthProvider auth) {
    if (!auth.isLoggedIn) return _alertTile(AppTheme.red, Icons.warning_amber_rounded, 'Sipariş için giriş yapmalısınız', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())));
    final addr = auth.selectedAddress;
    if (addr == null) return _alertTile(AppTheme.orange, Icons.add_location_alt, 'Teslimat adresi ekleyin', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(addr.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(addr.displayAddress, style: TextStyle(color: AppTheme.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        // Sipariş sırasında adres değiştirme devre dışı
      ]),
    );
  }

  Widget _alertTile(Color color, IconData icon, String msg, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))), Icon(Icons.arrow_forward_ios, size: 14, color: color)]),
    ),
  );


  Widget _buildNoteSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.note_outlined, color: AppTheme.primaryGreen, size: 18),
          SizedBox(width: 8),
          Text('Sipariş Notu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          SizedBox(width: 6),
          Text('(İsteğe bağlı)', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _noteCtrl,
          maxLines: 2,
          maxLength: 200,
          onChanged: (v) => cart.setOrderNote(v),
          decoration: InputDecoration(
            hintText: 'Örn: Zil çalmasın, kapıya bırakın...',
            hintStyle: TextStyle(color: AppTheme.grey, fontSize: 13),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            counterStyle: const TextStyle(fontSize: 11),
          ),
        ),
      ]),
    );
  }

  Widget _buildPaymentSection(CartProvider cart) {
    final auth = context.read<AuthProvider>();
    final balance = auth.balance;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.payment_outlined, color: AppTheme.primaryGreen, size: 18),
          SizedBox(width: 8),
          Text('Ödeme Yöntemi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
        const SizedBox(height: 12),
        ..._paymentOptionDefs.map((opt) {
          final id  = opt['id'] as String;
          final sel = _selectedPayment == id;
          final isBym = id == 'BiYemek Bakiyesi';
          final desc = isBym ? '₺${balance.toStringAsFixed(2)} mevcut bakiye' : opt['desc'] as String;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPayment = id);
              cart.setPaymentMethod(id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primaryGreen.withOpacity(0.1) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? AppTheme.primaryGreen : Theme.of(context).dividerColor,
                  width: 1.5,
                ),
              ),
              child: Row(children: [
                Text(opt['icon'] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(opt['label'] as String, style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: sel ? AppTheme.primaryGreen : Theme.of(context).colorScheme.onSurface,
                  )),
                  Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.grey)),
                ])),
                if (sel) const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildPromoSection(CartProvider cart) {
    if (cart.promoCode != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3))),
        child: Row(children: [
          const Icon(Icons.local_offer, color: AppTheme.primaryGreen),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cart.promoCode!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            Text('%${cart.discount.toStringAsFixed(0)} indirim uygulandı', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
          ])),
          GestureDetector(onTap: cart.removePromoCode, child: const Icon(Icons.close, color: AppTheme.grey, size: 20)),
        ]),
      );
    }

    return Column(children: [
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showPromo = !_showPromo),
        child: Row(children: [
          const Icon(Icons.local_offer_outlined, color: AppTheme.primaryGreen, size: 18),
          const SizedBox(width: 8),
          const Text('Promosyon kodu ekle', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(_showPromo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.grey),
        ]),
      ),
      if (_showPromo) ...[
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(
            controller: _promoCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Kodu girin (örn. BIYEMEK30)', contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
          )),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final code = _promoCtrl.text.trim().toUpperCase();
              final auth = context.read<AuthProvider>();
              // Daha önce kullanıldı mı?
              if (auth.isPromoCodeUsed(code)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Bu promosyon kodu daha önce kullanılmış'),
                  backgroundColor: AppTheme.red,
                ));
                return;
              }
              final pastOrderCount = context.read<OrderProvider>().orders.length;
              final err = context.read<CartProvider>().applyPromoCode(code, pastOrderCount: pastOrderCount);
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppTheme.red));
              } else {
                auth.markPromoCodeUsed(code);
                _promoCtrl.clear();
                setState(() => _showPromo = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promosyon kodu uygulandı! 🎉'), backgroundColor: AppTheme.primaryGreen));
              }
            },
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            child: const Text('Uygula'),
          ),
        ]),
      ],
    ]);
  }

  Widget _buildPriceSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(children: [
        _pr('Ara toplam', '₺${cart.subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _pr('Teslimat ücreti', cart.deliveryFee == 0 ? 'Ücretsiz' : '₺${cart.deliveryFee.toStringAsFixed(2)}'),
        if (cart.discountAmount > 0) ...[
          const SizedBox(height: 8),
          _pr('İndirim (${cart.promoCode})', '-₺${cart.discountAmount.toStringAsFixed(2)}', color: AppTheme.primaryGreen),
        ],
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
        _pr('Toplam', '₺${cart.total.toStringAsFixed(2)}', bold: true),
      ]),
    );
  }

  Widget _pr(String l, String v, {bool bold = false, Color? color}) {
    final s = bold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : TextStyle(color: color ?? AppTheme.grey, fontSize: 14);
    final vs = bold ? TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color) : TextStyle(color: color ?? AppTheme.grey, fontSize: 14);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: s), Text(v, style: vs)]);
  }

  Widget _buildCheckout(BuildContext context, CartProvider cart, AuthProvider auth) => Padding(
    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
    child: SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: () => _handleCheckout(context, cart, auth),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
      child: Text('Siparişi Tamamla • ₺${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
    )),
  );

  void _handleCheckout(BuildContext context, CartProvider cart, AuthProvider _) {
    final auth = context.read<AuthProvider>(); // always fresh
    // Connectivity check
    final isConnected = context.read<ConnectivityProvider>().isConnected;
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('İnternet bağlantısı yok. Sipariş veremezsiniz.'),
        backgroundColor: AppTheme.red,
      ));
      return;
    }
    if (!auth.isLoggedIn) { _showLoginSheet(context); return; }
    if (auth.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Teslimat adresi ekleyin'), backgroundColor: AppTheme.red, action: SnackBarAction(label: 'Ekle', textColor: Colors.white, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())))));
      return;
    }
    if (!cart.meetsMinOrder) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Minimum sepet tutarı ₺${cart.minOrder.toStringAsFixed(0)}'), backgroundColor: AppTheme.orange));
      return;
    }
    // BYM balance check
    if (cart.paymentMethod == 'BiYemek Bakiyesi' && auth.balance < cart.total) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('BYM bakiyeniz yetersiz. Bakiye: ₺${auth.balance.toStringAsFixed(2)}, Gereken: ₺${cart.total.toStringAsFixed(2)}'),
        backgroundColor: AppTheme.red,
      ));
      return;
    }
    // Kredi kartı → ödeme sheet'i aç
    if (cart.paymentMethod == 'Kredi Kartı') {
      _showPaymentSheet(context, cart, auth);
      return;
    }
    _placeOrder(context, cart, auth);
  }

  void _showLoginSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🔐', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Giriş Yapmanız Gerekiyor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())); }, child: const Text('Giriş Yap / Kayıt Ol'))),
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
    ])),
  );

  void _showPaymentSheet(BuildContext context, CartProvider cart, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CardPaymentSheet(
        total: cart.total,
        onPay: (cardData) {
          Navigator.pop(context);
          _show3DSecure(context, cardData, cart, auth);
        },
      ),
    );
  }

  Future<void> _show3DSecure(
      BuildContext context, _CardPaymentData cardData, CartProvider cart, AuthProvider auth) async {
    final user = auth.currentUser;

    // Son 4 hane kartın son 4 hanesi
    final rawNum    = cardData.number.replaceAll(' ', '');
    final lastFour  = rawNum.length >= 4 ? rawNum.substring(rawNum.length - 4) : '****';
    final initPhone = user?.phone ?? '';

    // ── Firebase OTP ekranı (sahte 3D Secure) ───────────────────────────────
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Payment3DSScreen(
          initialPhone: initPhone,
          cardLastFour: lastFour,
        ),
      ),
    );

    if (!context.mounted) return;
    if (verified != true) return; // İptal veya hata

    // ── Yükleniyor ───────────────────────────────────────────────────────────
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 14),
            Text('Ödeme işleniyor…',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ]),
        ),
      ),
    );

    // ── İyzico direkt ödeme ───────────────────────────────────────────────────
    final displayName = user?.displayName?.trim() ?? '';
    final parts      = displayName.isNotEmpty ? displayName.split(' ') : [];
    final firstName  = (parts.isNotEmpty && parts.first.isNotEmpty) ? parts.first : 'Musteri';
    final lastName   = (parts.length > 1 && parts.last.isNotEmpty) ? parts.sublist(1).join(' ') : 'Kullanici';

    final result = await IyzicoService.createPayment(
      cardHolderName : cardData.holderName,
      cardNumber     : cardData.number,
      expireMonth    : cardData.expireMonth,
      expireYear     : cardData.expireYear,
      cvc            : cardData.cvc,
      price          : cart.total,
      buyerName      : firstName,
      buyerSurname   : lastName,
      buyerEmail     : (user?.email?.isNotEmpty == true) ? user!.email! : 'musteri@biyemek.com',
      buyerPhone     : '+905000000000',
      deliveryAddress: auth.selectedAddress?.displayAddress ?? 'Istanbul',
    );

    if (!context.mounted) return;
    Navigator.pop(context); // Yükleniyor kapat

    if (result.success) {
      _placeOrder(context, cart, auth);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ ${result.errorMessage ?? 'Ödeme başarısız'}'),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  Future<void> _placeOrder(BuildContext context, CartProvider cart, AuthProvider auth) async {
    final orderProvider = context.read<OrderProvider>();
    final restaurant = cart.currentRestaurant!;
    final address = auth.selectedAddress!;
    final items = List<CartItem>.from(cart.items);
    final isBym = cart.paymentMethod == 'BiYemek Bakiyesi';
    final total = cart.total;

    // Deduct BYM balance before placing order
    if (isBym) {
      final ok = await auth.deductBalance(total);
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(const SnackBar(
              content: Text('BYM bakiyeniz yetersiz.'),
              backgroundColor: AppTheme.red,
            ));
        }
        return;
      }
    }

    // Siparişi oluştur
    await orderProvider.placeOrder(
      restaurant: restaurant,
      items: items,
      deliveryAddress: address.displayAddress,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      note: cart.orderNote.isNotEmpty ? cart.orderNote : null,
      paymentMethod: cart.paymentMethod,
      discountPct: cart.discount,
      userEmail: auth.currentUser?.email ?? '',
      userName: auth.currentUser?.displayName ?? '',
    );

    if (!context.mounted) return;

    // 10% cashback for BYM balance payments
    if (isBym) {
      final cashback = total * 0.10;
      await auth.addBalance(cashback);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🎉 %10 cashback: ₺${cashback.toStringAsFixed(2)} BYM bakiyenize yüklendi!'),
          backgroundColor: AppTheme.primaryGreen,
          duration: const Duration(seconds: 4),
        ));
      }
    }

    if (!context.mounted) return;

    // Sipariş ID'yi al
    final orderId = orderProvider.orders.isNotEmpty ? orderProvider.orders.first.id : null;
    if (orderId == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
            content: Text('Sipariş oluşturulurken hata oluştu'),
            backgroundColor: Colors.red));
      return;
    }

    cart.clearCart();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
      (route) => route.isFirst,
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem ci;
  final CartProvider cart;
  const _CartTile({required this.ci, required this.cart});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: AppImage(url: ci.item.imageUrl, width: 65, height: 65, fit: BoxFit.cover, errorWidget: Container(width: 65, height: 65, color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.fastfood, color: AppTheme.grey)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ci.item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            if (ci.selectedOptions.isNotEmpty) Text(ci.selectedOptions.map((o) => o.name).join(', '), style: TextStyle(fontSize: 11, color: AppTheme.grey)),
            if (ci.removedIngredients.isNotEmpty) Text('Çıkar: ${ci.removedIngredients.map((o) => o.name).join(', ')}', style: const TextStyle(fontSize: 11, color: AppTheme.red)),
            if (ci.sideItems.isNotEmpty) Text('+ ${ci.sideItems.map((s) => s.name).join(', ')}', style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreen)),
            if (ci.note != null) Text('Not: ${ci.note}', style: TextStyle(fontSize: 11, color: AppTheme.grey, fontStyle: FontStyle.italic)),
          ])),
          Row(children: [
            _Btn(icon: Icons.remove, onTap: () => cart.removeItem(ci.item.id)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${ci.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            _Btn(icon: Icons.add, onTap: () => cart.addCartItem(ci)),
          ]),
        ]),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerRight, child: Text('₺${ci.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: Colors.white)));
}

// ─────────────────────────────────────────────────────────────────────────────
// Kart ödeme verisi
// ─────────────────────────────────────────────────────────────────────────────
class _CardPaymentData {
  final String holderName, number, expireMonth, expireYear, cvc;
  const _CardPaymentData({
    required this.holderName,
    required this.number,
    required this.expireMonth,
    required this.expireYear,
    required this.cvc,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Kart numarası formatter (xxxx xxxx xxxx xxxx)
// ─────────────────────────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue _, TextEditingValue next) {
    final digits = next.text.replaceAll(' ', '');
    if (digits.length > 16) return _;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Son kullanma tarihi formatter (MM/YY)
// ─────────────────────────────────────────────────────────────────────────────
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) {
    final digits = next.text.replaceAll('/', '');
    if (digits.length > 4) return old;
    final text = digits.length <= 2 ? digits : '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kart tipi badge
// ─────────────────────────────────────────────────────────────────────────────
class _CardTypeBadge extends StatelessWidget {
  final CardType type;
  const _CardTypeBadge({required this.type});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      CardType.visa       => ('VISA', const Color(0xFF1A1F71)),
      CardType.mastercard => ('MC',   const Color(0xFFEB001B)),
      CardType.troy       => ('TROY', const Color(0xFF005F8E)),
      CardType.other      => ('CARD', Colors.grey),
    };
    return Container(
      width: 52, height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kart seçim / giriş sheet'i
// ─────────────────────────────────────────────────────────────────────────────
class _CardPaymentSheet extends StatefulWidget {
  final double total;
  final void Function(_CardPaymentData) onPay;
  const _CardPaymentSheet({required this.total, required this.onPay});
  @override
  State<_CardPaymentSheet> createState() => _CardPaymentSheetState();
}

class _CardPaymentSheetState extends State<_CardPaymentSheet> {
  SavedCard? _selected;
  bool _showNewCardForm = false;
  bool _showTest = false;

  // yeni kart form kontrolcüleri
  final _numCtrl    = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl    = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // initState'te cards henüz yok, build'de handle ediliyor
    _showNewCardForm = false;
  }

  @override
  void dispose() {
    _numCtrl.dispose(); _nameCtrl.dispose();
    _expiryCtrl.dispose(); _cvvCtrl.dispose();
    super.dispose();
  }

  CardType _detectType(String d) {
    if (d.startsWith('4')) return CardType.visa;
    if (d.length >= 2) {
      final p2 = int.tryParse(d.substring(0, 2)) ?? 0;
      if (p2 >= 51 && p2 <= 55) return CardType.mastercard;
    }
    if (d.length >= 4) {
      final p4 = int.tryParse(d.substring(0, 4)) ?? 0;
      if (p4 >= 2221 && p4 <= 2720) return CardType.mastercard;
    }
    if (d.startsWith('9792')) return CardType.troy;
    return CardType.other;
  }

  void _pay() {
    final cards = context.read<CardProvider>().cards;
    if (_showNewCardForm || cards.isEmpty) {
      if (!_formKey.currentState!.validate()) return;
      final exp   = _expiryCtrl.text.split('/');
      widget.onPay(_CardPaymentData(
        holderName  : _nameCtrl.text.trim().toUpperCase(),
        number      : _numCtrl.text.replaceAll(' ', ''),
        expireMonth : exp[0],
        expireYear  : '20${exp[1]}',
        cvc         : _cvvCtrl.text.trim(),
      ));
    } else {
      final c   = _selected!;
      final exp = c.expiry.split('/');
      // Eski kartlarda fullNumber boşsa test kartını kullan
      final num = c.fullNumber.isNotEmpty ? c.fullNumber : '5528790000000008';
      final cvv = c.cvv.isNotEmpty ? c.cvv : '123';
      widget.onPay(_CardPaymentData(
        holderName  : c.holderName,
        number      : num,
        expireMonth : exp[0],
        expireYear  : '20${exp[1]}',
        cvc         : cvv,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards  = context.watch<CardProvider>().cards;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kayıtlı kart yoksa her zaman yeni kart formu göster
    final showForm = _showNewCardForm || cards.isEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
        )),

        // Başlık
        Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), child:
          Row(children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.credit_card, color: Color(0xFF1565C0), size: 22)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ödeme Yöntemi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              Text('₺${widget.total.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600, fontSize: 14)),
            ]),
          ]),
        ),

        // ── Kayıtlı kartlar listesi ─────────────────────────────
        if (cards.isNotEmpty && !showForm) ...[
          Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('Kayıtlı Kartlar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                color: isDark ? AppTheme.darkSubtext : AppTheme.grey)),
          ),
          ...cards.map((card) {
            final sel = _selected?.id == card.id;
            return GestureDetector(
              onTap: () => setState(() => _selected = card),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF1565C0).withOpacity(0.07) : (isDark ? Colors.white10 : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? const Color(0xFF1565C0) : Colors.grey.shade300, width: sel ? 2 : 1),
                ),
                child: Row(children: [
                  _CardTypeBadge(type: card.type),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(card.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(card.maskedNumber, style: const TextStyle(color: AppTheme.grey, fontSize: 12, letterSpacing: 1)),
                  ])),
                  sel
                    ? const Icon(Icons.check_circle, color: Color(0xFF1565C0), size: 22)
                    : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 22),
                ]),
              ),
            );
          }),
          Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: TextButton.icon(
              icon: const Icon(Icons.add_card, size: 16),
              label: const Text('Yeni kart ile öde'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
              onPressed: () => setState(() { _showNewCardForm = true; _selected = null; }),
            ),
          ),
        ],

        // ── Yeni kart formu ─────────────────────────────────────
        if (showForm) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (cards.isNotEmpty) TextButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Kayıtlı kartlarıma dön'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.grey, padding: EdgeInsets.zero),
              onPressed: () => setState(() { _showNewCardForm = false; _selected = cards.first; }),
            ),
            TextFormField(
              controller: _numCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CardNumberFormatter()],
              decoration: InputDecoration(
                labelText: 'Kart Numarası',
                hintText: '0000 0000 0000 0000',
                prefixIcon: const Icon(Icons.credit_card),
                suffixIcon: _numCtrl.text.isNotEmpty
                    ? _CardTypeBadge(type: _detectType(_numCtrl.text.replaceAll(' ', '')))
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 64, minHeight: 40),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final n = (v ?? '').replaceAll(' ', '');
                if (n.length != 16) return 'Kart numarası 16 haneli olmalıdır';
                // Luhn algoritması
                int sum = 0;
                for (int i = 0; i < n.length; i++) {
                  int d = int.tryParse(n[n.length - 1 - i]) ?? 0;
                  if (i.isOdd) { d *= 2; if (d > 9) d -= 9; }
                  sum += d;
                }
                if (sum % 10 != 0) return 'Geçersiz kart numarası';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Kart Üzerindeki İsim', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'İsim zorunlu' : null,
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _expiryCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ExpiryFormatter()],
                decoration: const InputDecoration(labelText: 'Son Kullanma', hintText: 'AA/YY', prefixIcon: Icon(Icons.calendar_today_outlined)),
                validator: (v) {
                  final p = (v ?? '').split('/');
                  if (p.length != 2 || p[0].length != 2 || p[1].length != 2) return 'AA/YY';
                  final m = int.tryParse(p[0]) ?? 0;
                  final y = int.tryParse(p[1]) ?? 0;
                  if (m < 1 || m > 12) return 'Geçersiz ay';
                  final now = DateTime.now();
                  final expiry = DateTime(2000 + y, m + 1);
                  if (expiry.isBefore(DateTime(now.year, now.month))) return 'Kartın süresi dolmuş';
                  return null;
                },
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _cvvCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                obscureText: true,
                decoration: const InputDecoration(labelText: 'CVV', hintText: '•••', prefixIcon: Icon(Icons.lock_outline)),
                validator: (v) => (v?.length ?? 0) < 3 ? 'En az 3 hane' : null,
              )),
            ]),
            const SizedBox(height: 12),
            // Test kartı
            GestureDetector(
              onTap: () => setState(() => _showTest = !_showTest),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(children: [
                  const Icon(Icons.science_outlined, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Sandbox test kartı', style: TextStyle(fontSize: 13, color: Colors.amber, fontWeight: FontWeight.w600))),
                  Icon(_showTest ? Icons.expand_less : Icons.expand_more, color: Colors.amber, size: 18),
                ]),
              ),
            ),
            if (_showTest) Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Kart No: 5528 7900 0000 0008', style: TextStyle(fontSize: 13, fontFamily: 'monospace')),
                Text('CVV: 123    SKT: 12/2030',      style: TextStyle(fontSize: 13, fontFamily: 'monospace')),
                Text('İsim: TEST USER',                style: TextStyle(fontSize: 13, fontFamily: 'monospace')),
              ]),
            ),
          ])),
        ),

        // ── Ödeme butonu ────────────────────────────────────────
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), child:
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: (showForm || _selected != null) ? _pay : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline, size: 18),
              const SizedBox(width: 8),
              Text('Güvenli Öde • ₺${widget.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ]),
          )),
        ),
      ])),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// İyzico ödeme işleme sheet'i — telefon adımı yok, direkt sandbox
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentProcessingSheet extends StatefulWidget {
  final _CardPaymentData cardData;
  final double total;
  final String buyerName, buyerSurname, buyerEmail, buyerPhone, deliveryAddress;
  final VoidCallback onSuccess;
  const _PaymentProcessingSheet({
    required this.cardData,
    required this.total,
    required this.buyerName,
    required this.buyerSurname,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.deliveryAddress,
    required this.onSuccess,
  });
  @override
  State<_PaymentProcessingSheet> createState() => _PaymentProcessingSheetState();
}

enum _PayStep { processing, success, failed }

class _PaymentProcessingSheetState extends State<_PaymentProcessingSheet> {
  _PayStep _step = _PayStep.processing;
  String? _failMsg;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    final result = await IyzicoService.createPayment(
      cardHolderName : widget.cardData.holderName,
      cardNumber     : widget.cardData.number,
      expireMonth    : widget.cardData.expireMonth,
      expireYear     : widget.cardData.expireYear,
      cvc            : widget.cardData.cvc,
      price          : widget.total,
      buyerName      : widget.buyerName,
      buyerSurname   : widget.buyerSurname,
      buyerEmail     : widget.buyerEmail,
      buyerPhone     : widget.buyerPhone,
      deliveryAddress: widget.deliveryAddress,
    );
    if (!mounted) return;
    if (result.success) {
      setState(() => _step = _PayStep.success);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      widget.onSuccess();
    } else {
      setState(() { _step = _PayStep.failed; _failMsg = result.errorMessage; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
        )),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: const Text('3D', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w900, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('3D Güvenli Ödeme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('İyzico Sandbox', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            const Icon(Icons.lock, color: Colors.white70, size: 20),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: switch (_step) {
            _PayStep.processing => _buildProcessing(),
            _PayStep.success    => _buildSuccess(),
            _PayStep.failed     => _buildFailed(),
          },
        ),
      ]),
    );
  }

  Widget _buildProcessing() => Column(mainAxisSize: MainAxisSize.min, children: const [
    SizedBox(width: 56, height: 56, child: CircularProgressIndicator(
      strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Color(0xFF1565C0)))),
    SizedBox(height: 20),
    Text('Ödeme işleniyor...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
    SizedBox(height: 6),
    Text('Lütfen bekleyin, sayfayı kapatmayın.', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
  ]);

  Widget _buildSuccess() => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 72, height: 72,
      decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
      child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48)),
    const SizedBox(height: 16),
    const Text('Ödeme Onaylandı!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
    const SizedBox(height: 6),
    const Text('Siparişiniz oluşturuluyor...', style: TextStyle(color: AppTheme.grey, fontSize: 13)),
  ]);

  Widget _buildFailed() => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 72, height: 72,
      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
      child: const Icon(Icons.cancel_rounded, color: Colors.red, size: 48)),
    const SizedBox(height: 16),
    const Text('Ödeme Başarısız', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
    const SizedBox(height: 8),
    Text(_failMsg ?? 'Bir hata oluştu.',
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
    const SizedBox(height: 24),
    SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: () { setState(() { _step = _PayStep.processing; }); _processPayment(); },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Tekrar Dene'),
    )),
    const SizedBox(height: 10),
    TextButton(onPressed: () => Navigator.pop(context),
      child: const Text('İptal', style: TextStyle(color: AppTheme.grey))),
  ]);
}
