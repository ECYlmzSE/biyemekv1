import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotif = true;
  bool _smsNotif = false;
  bool _emailNotif = true;
  bool _orderUpdates = true;
  bool _promoNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(children: [
        _section('Bildirimler', [
          _toggle('Anlık Bildirimler', 'Uygulama bildirimleri', Icons.notifications_outlined, _pushNotif, (v) => setState(() => _pushNotif = v)),
          _toggle('SMS Bildirimleri', 'Telefona SMS gönder', Icons.sms_outlined, _smsNotif, (v) => setState(() => _smsNotif = v)),
          _toggle('E-posta Bildirimleri', 'Kampanya e-postaları', Icons.email_outlined, _emailNotif, (v) => setState(() => _emailNotif = v)),
          _toggle('Sipariş Güncellemeleri', 'Sipariş durumu bildirimleri', Icons.local_shipping_outlined, _orderUpdates, (v) => setState(() => _orderUpdates = v)),
          _toggle('Kampanya Bildirimleri', 'Fırsat ve indirim bildirimleri', Icons.local_offer_outlined, _promoNotif, (v) => setState(() => _promoNotif = v)),
        ]),
        _section('Uygulama', [
          _tile(Icons.language_outlined, 'Dil', 'Türkçe', () => _showInfo('Şu an yalnızca Türkçe desteklenmektedir.')),
          _tile(Icons.dark_mode_outlined, 'Tema', 'Açık', () => _showInfo('Karanlık mod yakında geliyor!')),
          _tile(Icons.cached_outlined, 'Önbelleği Temizle', '', () => _showSuccess('Önbellek temizlendi')),
        ]),
        _section('Gizlilik', [
          _tile(Icons.privacy_tip_outlined, 'Gizlilik Politikası', '', () => _showInfo('Gizlilik politikamız web sitemizde mevcuttur.')),
          _tile(Icons.description_outlined, 'Kullanım Koşulları', '', () => _showInfo('Kullanım koşullarımız web sitemizde mevcuttur.')),
          _tile(Icons.security_outlined, 'Veri Yönetimi', '', () => _showInfo('Verileriniz güvenli şekilde saklanmaktadır.')),
        ]),
        _section('Hesap', [
          _tile(Icons.delete_outline, 'Hesabı Sil', '', _confirmDelete, isDestructive: true),
        ]),
        const SizedBox(height: 24),
        Center(child: Text('Bi\'Yemek v1.0.0', style: TextStyle(color: AppTheme.grey, fontSize: 12))),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.grey))),
    Container(color: Colors.white, child: Column(children: children)),
  ]);

  Widget _toggle(String title, String subtitle, IconData icon, bool val, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(value: val, onChanged: onChanged, activeColor: AppTheme.primaryGreen),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.red : AppTheme.primaryGreen),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? AppTheme.red : null)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.grey),
      onTap: onTap,
    );
  }

  void _showInfo(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.primaryGreen, behavior: SnackBarBehavior.floating));

  void _confirmDelete() => showDialog(context: context, builder: (ctx) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: const Text('Hesabı Sil'),
    content: const Text('Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
      ElevatedButton(onPressed: () { context.read<AuthProvider>().signOut(); Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red), child: const Text('Hesabı Sil')),
    ],
  ));
}
