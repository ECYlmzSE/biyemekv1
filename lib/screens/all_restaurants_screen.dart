import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import 'restaurant_detail_screen.dart';

class AllRestaurantsScreen extends StatelessWidget {
  final String title;
  final List<Restaurant> restaurants;
  const AllRestaurantsScreen({super.key, required this.title, required this.restaurants});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: restaurants.length,
      itemBuilder: (ctx, i) => _Card(r: restaurants[i]),
    ),
  );
}

class _Card extends StatelessWidget {
  final Restaurant r;
  const _Card({required this.r});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          child: AppImage(url: r.imageUrl, width: 90, height: 80, fit: BoxFit.cover,
              errorWidget: Container(width: 90, height: 80, color: Theme.of(context).scaffoldBackgroundColor))),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
            Text(r.cuisine, style: const TextStyle(color: AppTheme.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star, size: 13, color: Color(0xFFFFC107)),
              Text(' ${r.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text(' • ${r.deliveryTimeMin}-${r.deliveryTimeMax} dk', style: const TextStyle(fontSize: 12, color: AppTheme.grey)),
            ]),
          ]),
        )),
        const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.grey)),
      ]),
    ),
  );
}
