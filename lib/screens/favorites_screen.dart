import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import 'restaurant_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final rp   = context.watch<RestaurantProvider>();
    final favs = rp.allRestaurants.where((r) => auth.isFavorite(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: favs.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🤍', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('Henüz favori yok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Restoran sayfasında ❤️ tuşuna basın', style: TextStyle(color: AppTheme.grey)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favs.length,
            itemBuilder: (ctx, i) {
              final r = favs[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r))),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                      child: AppImage(url: r.imageUrl, width: 90, height: 80, fit: BoxFit.cover,
                          errorWidget: Container(width: 90, height: 80, color: Theme.of(context).scaffoldBackgroundColor)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                        Text(r.cuisine, style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
                          Text(' ${r.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(' • ${r.deliveryTimeLabel}', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
                        ]),
                      ]),
                    )),
                    IconButton(
                      onPressed: () => auth.toggleFavorite(r.id),
                      icon: const Icon(Icons.favorite, color: AppTheme.red, size: 22),
                    ),
                  ]),
                ),
              );
            },
          ),
    );
  }
}
