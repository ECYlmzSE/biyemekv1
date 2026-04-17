import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/restaurant.dart';
import '../providers/order_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  final OrderModel order;
  const ReviewScreen({super.key, required this.order});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 5;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Siparişi Değerlendir')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Restaurant card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.order.restaurantImage, width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: Colors.grey.shade200, child: const Icon(Icons.restaurant)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.order.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${widget.order.items.length} ürün • ₺${widget.order.total.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 28),

          // Star rating
          const Center(child: Text('Siparişinizi nasıl buldunuz?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    size: 44,
                    color: i < _rating ? const Color(0xFFFFC107) : Theme.of(context).dividerColor,
                  ),
                ),
              )),
            ),
          ),
          Center(child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_ratingLabel, style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 28),

          // Comment
          const Text('Yorumunuz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Deneyiminizi paylaşın...',
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          // Quick tags
          const SizedBox(height: 8),
          const Text('Hızlı etiketler:', style: TextStyle(fontSize: 13, color: AppTheme.grey)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final tag in ['🔥 Çok lezzetli', '⚡ Hızlı teslimat', '📦 Özenli paket', '🌡️ Sıcak geldi', '💰 Uygun fiyat', '👨‍🍳 Harika porsiyon'])
              GestureDetector(
                onTap: () {
                  final t = _commentCtrl.text;
                  _commentCtrl.text = t.isEmpty ? tag : '$t, $tag';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
                ),
              ),
          ]),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Değerlendirmeyi Gönder', style: TextStyle(fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  String get _ratingLabel {
    if (_rating >= 5) return '😍 Mükemmel!';
    if (_rating >= 4) return '😊 İyi';
    if (_rating >= 3) return '😐 Orta';
    if (_rating >= 2) return '😕 Kötü';
    return '😠 Çok kötü';
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final userName = auth.currentUser?.displayName?.isNotEmpty == true
        ? auth.currentUser!.displayName!
        : auth.currentUser?.email?.split('@').first ?? 'Kullanıcı';

    final review = Review(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      rating: _rating,
      comment: _commentCtrl.text.isNotEmpty ? _commentCtrl.text : _ratingLabel.replaceAll(RegExp(r'[😍😊😐😕😠] '), ''),
      createdAt: DateTime.now(),
      orderId: widget.order.id,
    );

    await context.read<OrderProvider>().addReview(widget.order.id, review);
    if (!mounted) return;

    // Sync review to restaurant so all users see it
    await context.read<RestaurantProvider>().addUserReview(widget.order.restaurantId, review);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Değerlendirmeniz için teşekkürler! 🌟'),
      backgroundColor: AppTheme.primaryGreen,
    ));
    Navigator.pop(context);
  }
}
