import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/card_provider.dart';
import '../theme/app_theme.dart';
import 'email_verification_screen.dart';
import 'home_screen.dart';
import 'profile_completion_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Google Sign-In (shared between login & register tabs) ────
  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final error = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppTheme.red));
      return;
    }
    if (!context.read<AuthProvider>().isLoggedIn) return;

    // Telefon numarası yoksa profil tamamlama ekranına yönlendir
    final user = context.read<AuthProvider>().currentUser;
    if (user?.phone == null || user!.phone!.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ProfileCompletionScreen(
            initialName: user?.displayName ?? '',
          ),
        ),
        (_) => false,
      );
      return;
    }

    await _postLoginSetup();
  }

  Future<void> _postLoginSetup() async {
    if (!mounted) return;
    final uid = context.read<AuthProvider>().currentUser?.uid ?? 'guest';
    await context.read<OrderProvider>().switchUser(uid);
    await context.read<CardProvider>().initialize(uid);
    // Kullanıcı geçişinde sepeti temizle (başka kullanıcının sepeti görünmesin)
    if (mounted) context.read<CartProvider>().clearCart();
    if (!mounted) return;
    // Tüm önceki ekranları (welcome + auth) temizleyerek ana ekrana git
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppTheme.red));
  }

  Future<void> _submitLogin() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (email.isEmpty) { _showError('E-posta adresi giriniz'); return; }
    if (pass.isEmpty)  { _showError('Şifre giriniz'); return; }
    if (pass.length < 6) { _showError('Şifre en az 6 karakter olmalıdır'); return; }

    setState(() => _loading = true);
    final error = await context.read<AuthProvider>().login(email, pass);
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) { _showError(error); return; }

    // E-posta doğrulanmamışsa doğrulama ekranına yönlendir
    final auth = context.read<AuthProvider>();
    if (!auth.isEmailVerified) {
      await auth.sendVerificationEmail();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        ),
        (_) => false,
      );
      return;
    }

    await _postLoginSetup();
  }

  Future<void> _submitRegister() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty)  { _showError('Ad Soyad giriniz'); return; }
    if (phone.length < 10) { _showError('Telefon numarası giriniz (10 hane)'); return; }
    if (email.isEmpty) { _showError('E-posta adresi giriniz'); return; }
    if (pass.isEmpty)  { _showError('Şifre giriniz'); return; }
    if (pass.length < 6) { _showError('Şifre en az 6 karakter olmalıdır'); return; }

    setState(() => _loading = true);
    final error = await context.read<AuthProvider>().register(
        email, pass, name: name,
        phone: '+90$phone');
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) { _showError(error); return; }

    // Başarılı kayıt → email doğrulama ekranına git
    if (!mounted) return;
    final uid = context.read<AuthProvider>().currentUser?.uid ?? 'guest';
    await context.read<OrderProvider>().switchUser(uid);
    await context.read<CardProvider>().initialize(uid);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(email: _emailCtrl.text.trim()),
      ),
      (_) => false,
    );
  }

  // ── Google button widget ─────────────────────────────────────
  Widget _googleButton(String label) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: _loading ? null : _googleSignIn,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(2)),
          child: const Center(
              child: Text('G',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 13))),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    ),
  );

  Widget _orDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(children: [
      const Expanded(child: Divider()),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('veya',
              style: TextStyle(color: AppTheme.grey, fontSize: 13))),
      const Expanded(child: Divider()),
    ]),
  );

  // ── Login tab ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        controller: _tab,
        indicatorColor: AppTheme.primaryGreen,
        labelColor: AppTheme.primaryGreen,
        unselectedLabelColor: AppTheme.grey,
        tabs: const [Tab(text: 'Giriş Yap'), Tab(text: 'Kayıt Ol')],
      ),
    ),
    body: TabBarView(
      controller: _tab,
      children: [_loginTab(), _registerTab()],
    ),
  );

  Widget _loginTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      const SizedBox(height: 32),
      const Text('🍽️', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 16),
      const Text("Bi'Yemek'e Hoş Geldin",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 32),

      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
            labelText: 'E-posta *',
            prefixIcon: Icon(Icons.email_outlined)),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _passCtrl,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Şifre *',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _submitLogin,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Giriş Yap', style: TextStyle(fontSize: 15)),
        ),
      ),

      _orDivider(),
      _googleButton('Google ile Giriş Yap'),
    ]),
  );

  // ── Register tab ─────────────────────────────────────────────
  Widget _registerTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(children: [
      const SizedBox(height: 24),

      TextField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
            labelText: 'Ad Soyad *',
            prefixIcon: Icon(Icons.person_outline)),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.number,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Telefon Numarası *',
          prefixIcon: Icon(Icons.phone_outlined),
          prefixText: '+90 ',
          counterText: '',
          hintText: '5XX XXX XX XX',
        ),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
            labelText: 'E-posta *',
            prefixIcon: Icon(Icons.email_outlined)),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _passCtrl,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Şifre (en az 6 karakter) *',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _submitRegister,
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16)),
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Kayıt Ol', style: TextStyle(fontSize: 15)),
        ),
      ),
    ]),
  );
}
