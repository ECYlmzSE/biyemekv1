import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<RestaurantProvider>();
    final cityCount = p.cityRestaurants.length;
    final filtCount = p.filteredRestaurants.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtreler'),
        actions: [
          TextButton(
            onPressed: () { p.resetFilters(); Navigator.pop(context); },
            child: const Text('Sıfırla', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sıralama
          _SectionTitle(title: 'Sıralama'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: SortOption.values.map((s) {
              final sel = p.sortOption == s;
              return FilterChip(
                label: Text(s.label),
                selected: sel,
                onSelected: (_) => p.setSortOption(s),
                selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(color: sel ? AppTheme.primaryGreen : Theme.of(context).colorScheme.onSurface, fontSize: 13),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Kategori
          _SectionTitle(title: 'Kategori'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: p.categories.map((cat) {
              final sel = p.selectedCategory == cat;
              return FilterChip(
                label: Text(cat),
                selected: sel,
                onSelected: (_) => p.setCategory(cat),
                selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(color: sel ? AppTheme.primaryGreen : Theme.of(context).colorScheme.onSurface, fontSize: 13),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Teslimat Ücreti
          _SectionTitle(title: 'Maks. Teslimat Ücreti: ₺${p.maxDeliveryFee >= 999 ? "Hepsi" : p.maxDeliveryFee.toStringAsFixed(0)}'),
          Slider(
            value: p.maxDeliveryFee >= 999 ? 100 : p.maxDeliveryFee,
            min: 0, max: 100,
            divisions: 10,
            activeColor: AppTheme.primaryGreen,
            label: p.maxDeliveryFee >= 999 ? 'Hepsi' : '₺${p.maxDeliveryFee.toStringAsFixed(0)}',
            onChanged: (v) => p.setMaxDeliveryFee(v >= 100 ? 999 : v),
          ),
          const SizedBox(height: 12),

          // Min Puan
          _SectionTitle(title: 'Min. Puan: ${p.minRating == 0 ? "Hepsi" : p.minRating.toStringAsFixed(1)}'),
          Slider(
            value: p.minRating,
            min: 0, max: 5,
            divisions: 10,
            activeColor: AppTheme.primaryGreen,
            label: p.minRating == 0 ? 'Hepsi' : '${p.minRating.toStringAsFixed(1)} ⭐',
            onChanged: (v) => p.setMinRating(v),
          ),
          const SizedBox(height: 12),

          // Teslimat Süresi
          _SectionTitle(title: 'Teslimat Süresi'),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: p.deliveryTimeOptions.map((opt) {
              final sel = p.deliveryTimeFilter == opt;
              return FilterChip(
                label: Text(opt),
                selected: sel,
                onSelected: (_) => p.setDeliveryTimeFilter(sel ? null : opt),
                selectedColor: AppTheme.primaryGreen.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryGreen,
                labelStyle: TextStyle(color: sel ? AppTheme.primaryGreen : Theme.of(context).colorScheme.onSurface, fontSize: 13),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Seçenekler
          _SectionTitle(title: 'Seçenekler'),
          SwitchListTile(
            title: const Text('Sadece Açık Olanlar', style: TextStyle(fontSize: 14)),
            value: p.onlyOpen,
            activeColor: AppTheme.primaryGreen,
            onChanged: p.setOnlyOpen,
          ),
          SwitchListTile(
            title: const Text('Ücretsiz Teslimat', style: TextStyle(fontSize: 14)),
            value: p.freeDelivery,
            activeColor: AppTheme.primaryGreen,
            onChanged: p.setFreeDelivery,
          ),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))],
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text(
            '$filtCount restoran göster (${p.selectedCity} bölgesi)',
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  );
}
