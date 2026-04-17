import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'order_tracking_screen.dart';
import 'review_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Siparişlerim')),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔐', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Giriş Yapın', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Siparişlerinizi görmek için giriş yapın', style: TextStyle(color: AppTheme.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
            child: const Text('Giriş Yap / Kayıt Ol'),
          ),
        ])),
      );
    }

    // DefaultTabController must live OUTSIDE Consumer so its state (selected
    // tab index) is not reset every time OrderProvider calls notifyListeners().
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Siparişlerim')),
        body: Consumer<OrderProvider>(
          builder: (ctx, orders, _) => Column(children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                indicator: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(10)),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.grey,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Aktif'), Tab(text: 'Geçmiş')],
              ),
            ),
            Expanded(child: TabBarView(children: [
              _OrderList(orders: orders.activeOrders,
                  emptyText: 'Aktif sipariş yok', emptyEmoji: '🛵'),
              _OrderList(orders: orders.pastOrders,
                  emptyText: 'Geçmiş sipariş bulunamadı', emptyEmoji: '📋'),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;
  final String emptyText, emptyEmoji;
  const _OrderList({required this.orders, required this.emptyText, required this.emptyEmoji});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emptyEmoji, style: const TextStyle(fontSize: 52)),
      const SizedBox(height: 12),
      Text(emptyText, style: TextStyle(color: AppTheme.grey, fontSize: 15)),
    ]));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        // Status header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _statusColor(order.status).withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            Text(order.status.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(order.status.label, style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.bold, fontSize: 13)),
            const Spacer(),
            Text(DateFormat('dd MMM, HH:mm').format(order.createdAt), style: TextStyle(color: AppTheme.grey, fontSize: 12)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(order.restaurantImage, width: 48, height: 48, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.restaurant, color: AppTheme.grey))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${order.items.length} ürün • ₺${order.total.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
              ])),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.grey),
            ]),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                order.items.map((i) => '${i.name} ×${i.quantity}').take(3).join(', ') + (order.items.length > 3 ? '...' : ''),
                style: TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
            ],
            if (order.status.isActive && order.status != OrderStatus.cancelled) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressValue(order.status),
                  backgroundColor: Theme.of(context).dividerColor,
                  color: AppTheme.primaryGreen,
                  minHeight: 5,
                ),
              ),
            ],
            if (order.status == OrderStatus.delivered) ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restoran sayfasından tekrar sipariş verebilirsiniz'), backgroundColor: AppTheme.primaryGreen)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Text('Tekrar Sipariş Ver', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13))),
                  ),
                )),
                const SizedBox(width: 8),
                Consumer<OrderProvider>(
                  builder: (ctx2, op, _) {
                    final review = op.reviews[order.id];
                    if (review != null) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Row(children: List.generate(5, (j) => Icon(
                            j < review.rating ? Icons.star : Icons.star_border,
                            size: 13, color: const Color(0xFFFFC107)))),
                          const SizedBox(width: 6),
                          Text('Değerlendirildi',
                            style: const TextStyle(color: Color(0xFFFFA000),
                              fontWeight: FontWeight.w600, fontSize: 12)),
                        ]),
                      );
                    }
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ReviewScreen(order: order))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.4))),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_border, color: Color(0xFFFFA000), size: 15),
                          SizedBox(width: 4),
                          Text('Değerlendir',
                            style: TextStyle(color: Color(0xFFFFA000),
                              fontWeight: FontWeight.w600, fontSize: 12)),
                        ]),
                      ),
                    );
                  },
                ),
              ]),
              // Review comment
              Consumer<OrderProvider>(
                builder: (ctx3, op, _) {
                  final rev = op.reviews[order.id];
                  if (rev == null || rev.comment.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx3).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(ctx3).dividerColor)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.format_quote, size: 16, color: AppTheme.grey),
                      const SizedBox(width: 6),
                      Expanded(child: Text(rev.comment,
                        style: const TextStyle(fontSize: 13, height: 1.4, fontStyle: FontStyle.italic),
                        maxLines: 3, overflow: TextOverflow.ellipsis)),
                    ]),
                  );
                },
              ),
            ],
          ]),
        ),
      ]),
    ),
  );

  double _progressValue(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return 0.25;
      case OrderStatus.preparing: return 0.5;
      case OrderStatus.onTheWay: return 0.75;
      case OrderStatus.delivered: return 1.0;
      default: return 0.1;
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.confirmed: return Colors.blue;
      case OrderStatus.preparing: return AppTheme.orange;
      case OrderStatus.onTheWay: return AppTheme.primaryGreen;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.cancelled: return AppTheme.red;
    }
  }
}
