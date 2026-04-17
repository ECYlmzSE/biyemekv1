import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});
  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final _ctrl = TextEditingController();
  bool _showInput = false;

  final List<Map<String, dynamic>> _campaigns = [
    {'emoji':'🍕','code':'BIYEMEK30','title':'Bi\'Yemek\'e Hoş Geldin!','desc':'Tüm siparişlerde %30 indirim','discount':'%30','color':const Color(0xFF06C167),'exp':'28 Şubat 2026'},
    {'emoji':'🎉','code':'HOSGELDIN','title':'İlk Sipariş İndirimi','desc':'İlk siparişinizde %20 indirim','discount':'%20','color':const Color(0xFF7C3AED),'exp':'31 Mart 2026'},
    {'emoji':'🍔','code':'YEMEK15','title':'Burger Günleri','desc':'Burger kategorisinde %15 indirim','discount':'%15','color':const Color(0xFFFF6B35),'exp':'15 Mart 2026'},
    {'emoji':'🌟','code':'INDIRIM25','title':'Hafta Sonu Fırsatı','desc':'Hafta sonu siparişlerinde %25 indirim','discount':'%25','color':const Color(0xFFE91E8C),'exp':'Her hafta sonu'},
    {'emoji':'🍰','code':'TATLI10','title':'Tatlı Keyfi','desc':'Pastane & Tatlı kategorisinde %10 indirim','discount':'%10','color':const Color(0xFF6F4E37),'exp':'30 Nisan 2026'},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kampanyalar & Promosyonlar')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Add promo code
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _showInput = !_showInput),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.local_offer, color: AppTheme.primaryGreen)),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Promosyon Kodu Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Kodunuzu girerek indirim kazanın', style: TextStyle(fontSize: 12, color: AppTheme.grey)),
              ])),
              Icon(_showInput ? Icons.keyboard_arrow_up : Icons.add, color: AppTheme.primaryGreen),
            ]),
          ),
        ),
        if (_showInput) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(
              controller: _ctrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'Promosyon kodunu girin...'),
            )),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final err = context.read<CartProvider>().applyPromoCode(_ctrl.text);
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppTheme.red));
                } else {
                  _ctrl.clear();
                  setState(() => _showInput = false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Promosyon kodu uygulandı! 🎉'), backgroundColor: AppTheme.primaryGreen));
                }
              },
              child: const Text('Uygula'),
            ),
          ]),
        ],
        const SizedBox(height: 20),
        const Text('Aktif Kampanyalar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ..._campaigns.map((c) => _CampaignCard(campaign: c)),
      ]),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final color = campaign['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 10)],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            Text(campaign['emoji']!, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(campaign['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(campaign['desc']!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(campaign['discount']!, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(campaign['code']!, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
            ),
            const SizedBox(width: 10),
            Text('Son: ${campaign['exp']}', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                final err = context.read<CartProvider>().applyPromoCode(campaign['code']!);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(err ?? 'Kod uygulandı! 🎉'),
                  backgroundColor: err != null ? AppTheme.red : AppTheme.primaryGreen,
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: const Text('Uygula', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
