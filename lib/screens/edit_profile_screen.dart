import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nameCtrl = TextEditingController(text: user.displayName ?? '');
    _phoneCtrl = TextEditingController(text: user.phone ?? '');
    _emailCtrl = TextEditingController(text: user.email ?? '');
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilgilerimi Düzenle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Avatar
            Center(child: Stack(children: [
              Container(
                width: 90, height: 90,
                decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                child: Center(child: Consumer<AuthProvider>(builder: (_, auth, __) => Text((auth.currentUser?.displayName?.isNotEmpty == true ? auth.currentUser!.displayName![0].toUpperCase() : 'U'), style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)))),
              ),
              Positioned(bottom: 0, right: 0, child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: const Icon(Icons.camera_alt, size: 16, color: AppTheme.grey),
              )),
            ])),
            const SizedBox(height: 28),
            _field('Ad Soyad', _nameCtrl, Icons.person_outline, validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null),
            const SizedBox(height: 16),
            _field('E-posta', _emailCtrl, Icons.email_outlined, enabled: false, hint: 'E-posta değiştirilemez'),
            const SizedBox(height: 16),
            _field('Telefon', _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Kaydet', style: TextStyle(fontSize: 16)),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool enabled = true, String? hint, String? Function(String?)? validator, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.grey)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        enabled: enabled,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          hintText: hint,
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade50,
        ),
      ),
    ]);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate save
    // In real app: context.read<AuthProvider>().updateProfile(...)
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bilgiler güncellendi ✓'), backgroundColor: AppTheme.primaryGreen));
      Navigator.pop(context);
    }
  }
}
