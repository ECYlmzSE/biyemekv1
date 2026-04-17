import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Google ile giriş sonrası eksik profil bilgilerini (isim + telefon) tamamlama ekranı.
class ProfileCompletionScreen extends StatefulWidget {
  final String initialName;
  const ProfileCompletionScreen({super.key, this.initialName = ''});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.initialName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.red),
      );

  Future<void> _submit() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.replaceAll(' ', '').replaceAll('-', '');

    if (name.isEmpty)       { _showError('Ad Soyad giriniz'); return; }
    if (phone.length < 10)  { _showError('Geçerli bir telefon numarası giriniz'); return; }

    setState(() => _loading = true);

    final fullPhone = phone.startsWith('+') ? phone
        : phone.startsWith('0') ? '+90${phone.substring(1)}'
        : '+90$phone';

    await context.read<AuthProvider>().updateProfile(
      displayName: name,
      phone: fullPhone,
    );

    if (!mounted) return;

    final uid = context.read<AuthProvider>().currentUser?.uid ?? 'guest';
    await context.read<OrderProvider>().switchUser(uid);
    await context.read<CardProvider>().initialize(uid);

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Logo & Başlık ────────────────────────────────────────────
            Center(
              child: Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_add_rounded,
                      color: AppTheme.primaryGreen, size: 36),
                ),
                const SizedBox(height: 16),
                Text("Profilini Tamamla",
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  "Siparişlerinde sana ulaşabilmemiz için\nbilgilerini ekle.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                ),
              ]),
            ),

            const SizedBox(height: 36),

            // ── Ad Soyad ─────────────────────────────────────────────────
            Text('Ad Soyad *',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Adınız ve soyadınız',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Telefon ───────────────────────────────────────────────────
            Text('Telefon Numarası *',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: '5XX XXX XX XX',
                prefixText: '+90 ',
                prefixStyle: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.w600, color: Colors.black87),
                prefixIcon: const Icon(Icons.phone_outlined),
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                helperText: 'Ödeme doğrulaması için kullanılacak',
                helperStyle: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11),
              ),
            ),

            const SizedBox(height: 32),

            // ── Devam Et ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Devam Et',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),

            // ── Güvenlik notu ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  'Bilgileriniz güvenli şekilde saklanır',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
