import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/connectivity_provider.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'address_screen.dart';
import 'order_tracking_screen.dart';

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
        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())), child: const Text('Değiştir', style: TextStyle(color: AppTheme.primaryGreen))),
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
              final err = context.read<CartProvider>().applyPromoCode(_promoCtrl.text);
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppTheme.red));
              } else {
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sipariş oluşturulurken hata oluştu'), backgroundColor: Colors.red));
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
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(ci.item.imageUrl, width: 65, height: 65, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 65, height: 65, color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.fastfood, color: AppTheme.grey)))),
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
