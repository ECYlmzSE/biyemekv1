import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'item_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});
  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ScrollController _sc = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _sc.addListener(() {
      final show = _sc.offset > 200;
      if (show != _showTitle) setState(() => _showTitle = show);
    });
  }

  @override
  void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // Always read the live version from the provider so reviews/ratings
    // added after navigation are immediately visible.
    final rp = context.watch<RestaurantProvider>();
    final r = rp.allRestaurants.firstWhere(
      (res) => res.id == widget.restaurant.id,
      orElse: () => widget.restaurant,
    );
    return Scaffold(
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cart, auth, _) => Stack(children: [
          CustomScrollView(controller: _sc, slivers: [
            _buildAppBar(context, r, auth),
            SliverToBoxAdapter(child: _buildInfo(context, r)),
            ...r.menu.map((cat) => _buildMenuCategory(context, cat, r, cart)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
          if (!cart.isEmpty)
            Positioned(bottom: MediaQuery.of(context).padding.bottom + 16, left: 16, right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.4), blurRadius: 16, offset: const Offset(0,4))]),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Sepeti Görüntüle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                    Text('₺${cart.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ]),
                ),
              )),
        ]),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Restaurant r, AuthProvider auth) {
    final isFav = auth.isFavorite(r.id);
    return SliverAppBar(
      expandedHeight: 240, pinned: true, backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
          child: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black)),
      ),
      actions: [
        GestureDetector(
          onTap: () => auth.toggleFavorite(r.id),
          child: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
            child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? AppTheme.red : AppTheme.grey, size: 20)),
        ),
      ],
      title: AnimatedOpacity(
        opacity: _showTitle ? 1 : 0, duration: const Duration(milliseconds: 200),
        child: Text(r.name, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(r.imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Theme.of(context).scaffoldBackgroundColor,
            child: const Icon(Icons.restaurant, size: 80, color: AppTheme.grey))),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, Restaurant r) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(r.cuisine, style: const TextStyle(color: AppTheme.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Row(children: [
          // Rating - tıklanınca yorumlar
          GestureDetector(
            onTap: () => _showReviewsSheet(context, r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFC107).withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star, size: 15, color: Color(0xFFFFC107)),
                const SizedBox(width: 4),
                Text('${r.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 4),
                Text('(${r.reviewCount})', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 14, color: AppTheme.grey),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          _chip(Icons.schedule, r.deliveryTimeLabel),
          const SizedBox(width: 8),
          _chip(Icons.delivery_dining, r.deliveryFee == 0 ? 'Ücretsiz' : '₺${r.deliveryFee.toStringAsFixed(0)}'),
        ]),
        if (r.badges.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: r.badges.map((b) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(b, style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.w600)),
          )).toList()),
        ],
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.info_outline, size: 13, color: AppTheme.grey),
          const SizedBox(width: 4),
          Text('Min. sipariş: ₺${r.minOrder.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
      ]),
    );
  }

  Widget _chip(IconData icon, String text) => Builder(builder: (context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppTheme.grey),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
    ]),
  ));

  void _showReviewsSheet(BuildContext context, Restaurant r) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, sc) => Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), child:
            Row(children: [
              const Icon(Icons.star, color: Color(0xFFFFC107), size: 20),
              const SizedBox(width: 6),
              Text('${r.rating}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('(${r.reviewCount} değerlendirme)', style: const TextStyle(color: AppTheme.grey)),
            ]),
          ),
          const Divider(),
          Expanded(child: r.reviews.isEmpty
            ? const Center(child: Text('Henüz yorum yok', style: TextStyle(color: AppTheme.grey)))
            : ListView.separated(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: r.reviews.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx2, i) {
                  final rev = r.reviews[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 16,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                          child: Text(rev.userName[0].toUpperCase(),
                            style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(DateFormat('dd MMM yyyy').format(rev.createdAt),
                            style: const TextStyle(color: AppTheme.grey, fontSize: 11)),
                        ])),
                        Row(children: List.generate(5, (j) => Icon(
                          j < rev.rating ? Icons.star : Icons.star_border,
                          size: 14, color: j < rev.rating ? const Color(0xFFFFC107) : Theme.of(context).dividerColor))),
                      ]),
                      if (rev.comment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(rev.comment, style: const TextStyle(fontSize: 13, height: 1.4)),
                      ],
                    ]),
                  );
                },
              )),
        ]),
      ),
    );
  }

  Widget _buildMenuCategory(BuildContext context, MenuCategory cat, Restaurant r, CartProvider cart) {
    return SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Text(cat.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      ...cat.items.map((item) => _MenuItemCard(item: item, restaurant: r, cart: cart)),
    ]));
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final CartProvider cart;
  const _MenuItemCard({required this.item, required this.restaurant, required this.cart});

  @override
  Widget build(BuildContext context) {
    final qty = cart.getItemQuantity(item.id);
    return GestureDetector(
      onTap: () => ItemDetailSheet.show(context, item, restaurant),
      child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Row(children: [
        Expanded(child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (item.isPopular) Container(margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Popüler', style: TextStyle(fontSize: 10, color: AppTheme.orange, fontWeight: FontWeight.w600))),
              if (item.isVegetarian) const Text('🌱 ', style: TextStyle(fontSize: 12)),
              if (item.isSpicy) const Text('🌶️ ', style: TextStyle(fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.description, style: const TextStyle(color: AppTheme.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Text('₺${item.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
        )),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
            child: Image.network(item.imageUrl, width: 100, height: 85, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 100, height: 85, color: Theme.of(context).scaffoldBackgroundColor,
                child: const Icon(Icons.fastfood, color: AppTheme.grey, size: 32))),
          ),
          const SizedBox(height: 6),
          qty == 0
            ? Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: GestureDetector(
                  onTap: () => cart.addItem(item, restaurant),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _CounterBtn(icon: Icons.remove, onTap: () => cart.removeItem(item.id)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                  _CounterBtn(icon: Icons.add, onTap: () => cart.addItem(item, restaurant)),
                ]),
              ),
        ]),
      ]),
    ));
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 28, height: 28,
      decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: Colors.white)),
  );
}
