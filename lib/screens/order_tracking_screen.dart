import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';

// StatefulWidget: Consumer içinde olduğu için timer güncellemeleri anında yansır
class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {

  @override
  Widget build(BuildContext context) {
    // Consumer ile her notifyListeners() çağrısında UI yenilenir
    return Consumer<OrderProvider>(
      builder: (ctx, prov, _) {
        final idx = prov.orders.indexWhere((o) => o.id == widget.orderId);
        if (idx < 0) {
          return Scaffold(
            appBar: AppBar(title: const Text('Sipariş Takibi')),
            body: const Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📋', style: TextStyle(fontSize: 64)),
                SizedBox(height: 12),
                Text('Sipariş bulunamadı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            )),
          );
        }

        final order = prov.orders[idx];

        return Scaffold(
          appBar: AppBar(
            title: Text('Sipariş #${order.id.split('-').last}'),
            actions: [
              if (order.status == OrderStatus.confirmed || order.status == OrderStatus.pending)
                TextButton(
                  onPressed: () => _confirmCancel(ctx, prov, order.id),
                  child: const Text('İptal Et', style: TextStyle(color: AppTheme.red)),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _StatusCard(order: order),
              const SizedBox(height: 16),
              _Timeline(order: order),
              const SizedBox(height: 16),
              if (order.courierName != null) ...[
                _CourierCard(order: order),
                const SizedBox(height: 16),
              ],
              _OrderDetails(order: order),
              const SizedBox(height: 16),
              _AddressCard(order: order),
              const SizedBox(height: 16),
              _PriceSummary(order: order),
              const SizedBox(height: 24),
            ]),
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext ctx, OrderProvider prov, String id) {
    final order = prov.orders.firstWhere((o) => o.id == id);
    final isBym = order.paymentMethod == 'BiYemek Bakiyesi';

    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Siparişi İptal Et'),
        content: Text(
          isBym
              ? 'Siparişinizi iptal etmek istiyor musunuz?\n\n'
                // Net paid = total - 10% cashback already received
                '₺${(order.total * 0.9).toStringAsFixed(2)} BYM bakiyenize iade edilecektir.'
              : 'Siparişinizi iptal etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hayır')),
          ElevatedButton(
            onPressed: () async {
              // Refund only net amount paid (total - 10% cashback already credited)
              if (isBym) {
                await ctx.read<AuthProvider>().addBalance(order.total * 0.9);
              }
              await prov.cancelOrder(id);
              if (c.mounted) Navigator.pop(c);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (isBym) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('₺${(order.total * 0.9).toStringAsFixed(2)} bakiyenize iade edildi.'),
                    backgroundColor: AppTheme.primaryGreen,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('İptal Et', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Status renkleri (global) ─────────────────────────────────────
Color statusColor(OrderStatus s) {
  switch (s) {
    case OrderStatus.pending:   return Colors.orange;
    case OrderStatus.confirmed: return Colors.blue;
    case OrderStatus.preparing: return AppTheme.orange;
    case OrderStatus.onTheWay:  return AppTheme.primaryGreen;
    case OrderStatus.delivered: return Colors.green.shade600;
    case OrderStatus.cancelled: return AppTheme.red;
  }
}

// ── Status Kartı ─────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final OrderModel order;
  const _StatusCard({required this.order});

  double get _progress {
    switch (order.status) {
      case OrderStatus.confirmed: return 0.25;
      case OrderStatus.preparing: return 0.50;
      case OrderStatus.onTheWay:  return 0.75;
      case OrderStatus.delivered: return 1.00;
      default: return 0.10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Text(order.status.emoji, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 10),
        Text(order.status.label,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(order.status.description,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 13)),
        if (order.estimatedDelivery != null && order.status.isActive) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.schedule, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text('Tahmini: ${DateFormat('HH:mm').format(order.estimatedDelivery!)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
        if (order.status.isActive) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Zaman Çizelgesi ──────────────────────────────────────────────
class _Timeline extends StatelessWidget {
  final OrderModel order;
  const _Timeline({required this.order});

  static const _steps = [
    (OrderStatus.confirmed, 'Sipariş Onaylandı', Icons.check_circle_outline),
    (OrderStatus.preparing, 'Hazırlanıyor',      Icons.restaurant),
    (OrderStatus.onTheWay,  'Yola Çıktı',        Icons.delivery_dining),
    (OrderStatus.delivered, 'Teslim Edildi',     Icons.home),
  ];

  @override
  Widget build(BuildContext context) {
    int curIdx = _steps.indexWhere((s) => s.$1 == order.status);
    if (order.status == OrderStatus.cancelled) curIdx = -1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.timeline, color: AppTheme.primaryGreen, size: 18),
          const SizedBox(width: 8),
          const Text('Sipariş Durumu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (order.status == OrderStatus.cancelled) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text('İptal Edildi', style: TextStyle(color: AppTheme.red, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        const SizedBox(height: 16),
        ..._steps.asMap().entries.map((e) {
          final i    = e.key;
          final step = e.value;
          final done    = curIdx >= 0 && i <= curIdx;
          final current = i == curIdx;
          final isLast  = i == _steps.length - 1;
          final inactiveCircle = Theme.of(context).colorScheme.surfaceContainerHighest;
          final inactiveIcon   = Theme.of(context).colorScheme.onSurface.withOpacity(0.35);
          final inactiveLine   = Theme.of(context).dividerColor;
          final doneText       = Theme.of(context).colorScheme.onSurface;
          final pendingText    = Theme.of(context).colorScheme.onSurface.withOpacity(0.35);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: done ? AppTheme.primaryGreen : inactiveCircle,
                  shape: BoxShape.circle,
                  boxShadow: done ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 8)] : [],
                ),
                child: Icon(step.$3, size: 18, color: done ? Colors.white : inactiveIcon),
              ),
              if (!isLast) AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 2, height: 36,
                color: (done && i < curIdx) ? AppTheme.primaryGreen : inactiveLine,
              ),
            ]),
            const SizedBox(width: 14),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(step.$2,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.bold : FontWeight.normal,
                    color: done ? doneText : pendingText,
                    fontSize: 14)),
                if (current)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Şu an bu aşamada',
                      style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.w500))),
                SizedBox(height: isLast ? 0 : 20),
              ]),
            )),
          ]);
        }),
      ]),
    );
  }
}

// ── Kurye Kartı ──────────────────────────────────────────────────
class _CourierCard extends StatelessWidget {
  final OrderModel order;
  const _CourierCard({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
        child: const Text('🛵', style: TextStyle(fontSize: 24))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Kuryeniz', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
        Text(order.courierName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text('Siparişinizi teslim edecek', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
      ])),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.delivery_dining, color: AppTheme.primaryGreen, size: 22)),
    ]),
  );
}

// ── Sipariş Detayı ───────────────────────────────────────────────
class _OrderDetails extends StatelessWidget {
  final OrderModel order;
  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.receipt_long_outlined, color: AppTheme.primaryGreen, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(order.restaurantName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
      ]),
      const Divider(height: 20),
      if (order.items.isEmpty)
        const Text('Ürün bilgisi yüklenemedi', style: TextStyle(color: AppTheme.grey, fontSize: 13))
      else
        ...order.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            if (item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppImage(url: item.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
                  errorWidget: Container(width: 40, height: 40,
                    color: Theme.of(context).scaffoldBackgroundColor, child: const Icon(Icons.fastfood, size: 18, color: AppTheme.grey))),
              ),
            if (item.imageUrl.isNotEmpty) const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(6)),
              child: Text('×${item.quantity}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              if (item.options.isNotEmpty)
                Text(item.options, style: const TextStyle(fontSize: 11, color: AppTheme.grey)),
            ])),
            Text('₺${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
        )),
    ]),
  );
}

// ── Adres Kartı ──────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final OrderModel order;
  const _AddressCard({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Teslimat Adresi', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(order.deliveryAddress, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ])),
    ]),
  );
}

// ── Fiyat Özeti ──────────────────────────────────────────────────
class _PriceSummary extends StatelessWidget {
  final OrderModel order;
  const _PriceSummary({required this.order});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
    ),
    child: Column(children: [
      _row('Ara Toplam', '₺${order.subtotal.toStringAsFixed(2)}'),
      const SizedBox(height: 8),
      _row('Teslimat Ücreti', order.deliveryFee == 0 ? 'Ücretsiz 🎉' : '₺${order.deliveryFee.toStringAsFixed(2)}'),
      const Divider(height: 20),
      _row('Toplam', '₺${order.total.toStringAsFixed(2)}', bold: true),
    ]),
  );

  Widget _row(String l, String v, {bool bold = false}) {
    final s = bold
      ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
      : const TextStyle(color: AppTheme.grey, fontSize: 14);
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(l, style: s), Text(v, style: s)]);
  }
}
