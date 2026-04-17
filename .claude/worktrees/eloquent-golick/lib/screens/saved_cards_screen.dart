import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../theme/app_theme.dart';

class SavedCardsScreen extends StatelessWidget {
  const SavedCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<CardProvider>().cards;

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Kartlarım')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () => showAddCardSheet(context),
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text('Kart Ekle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: cards.isEmpty
          ? _emptyState(context)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Text('Kayıtlı Kartlar',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkSubtext
                            : AppTheme.grey)),
                const SizedBox(height: 12),
                ...cards.map((c) => _CardTile(
                    card: c,
                    onDelete: () => _confirmDelete(context, c),
                    onRename: () => _showRenameSheet(context, c))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.lock_outline, size: 18, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                        'Kart bilgileriniz şifreli olarak saklanır ve güvende tutulur.',
                        style: TextStyle(fontSize: 12, color: Colors.blue))),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _emptyState(BuildContext ctx) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.credit_card_off_outlined,
            size: 52, color: Colors.purple)),
      const SizedBox(height: 20),
      const Text('Kayıtlı kart bulunamadı',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Hızlı ödeme için kartınızı kaydedin',
          style: TextStyle(color: AppTheme.grey, fontSize: 14)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: () => showAddCardSheet(ctx),
        icon: const Icon(Icons.add_card),
        label: const Text('Kart Ekle'),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
      ),
    ]),
  );

  void _confirmDelete(BuildContext ctx, SavedCard card) {
    showDialog(
      context: ctx,
      builder: (d) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kartı Sil'),
        content: Text('${card.maskedNumber} kartını silmek istiyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(d);
              ctx.read<CardProvider>().deleteCard(card.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showRenameSheet(BuildContext ctx, SavedCard card) {
    final ctrl = TextEditingController(text: card.label);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(sheet).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Karta İsim Ver',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
                labelText: 'Kart Adı (ör. İş Kartım, Maaş Kartım)',
                prefixIcon: Icon(Icons.label_outline)),
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              ctx.read<CardProvider>().renameCard(card.id, ctrl.text.trim());
              Navigator.pop(sheet);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CARD TILE
// ─────────────────────────────────────────────────────────────
class _CardTile extends StatelessWidget {
  final SavedCard card;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  const _CardTile({required this.card, required this.onDelete, required this.onRename});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors(card.type),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _gradientColors(card.type).first.withOpacity(0.35),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              if (card.label.isNotEmpty)
                Text(card.displayName,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ])),
            GestureDetector(
              onTap: onRename,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Text(card.maskedNumber,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('KART SAHİBİ',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10)),
              const SizedBox(height: 2),
              Text(card.holderName.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(width: 32),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('SON KULLANMA',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 10)),
              const SizedBox(height: 2),
              Text(card.expiry,
                  style: const TextStyle(color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ]),
          ]),
        ]),
      ),
    );
  }

  List<Color> _gradientColors(CardType type) {
    switch (type) {
      case CardType.visa:       return [const Color(0xFF1A237E), const Color(0xFF283593)];
      case CardType.mastercard: return [const Color(0xFFBF360C), const Color(0xFFD84315)];
      case CardType.troy:       return [const Color(0xFF1B5E20), const Color(0xFF2E7D32)];
      case CardType.other:      return [const Color(0xFF37474F), const Color(0xFF455A64)];
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  ADD CARD BOTTOM SHEET  (reusable from cart & cards screen)
// ─────────────────────────────────────────────────────────────

/// Shows the add card sheet. Returns the saved card if user saved it, null otherwise.
/// [forceShowSave] = true when called from cart (always show save option).
Future<SavedCard?> showAddCardSheet(BuildContext context,
    {bool forceShowSave = false}) {
  return showModalBottomSheet<SavedCard?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AddCardSheet(forceShowSave: forceShowSave),
  );
}

class _AddCardSheet extends StatefulWidget {
  final bool forceShowSave;
  const _AddCardSheet({this.forceShowSave = false});
  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _numberCtrl = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl    = TextEditingController();
  final _labelCtrl  = TextEditingController();
  final _formKey    = GlobalKey<FormState>();
  bool _loading     = false;
  bool _saveCard    = false;
  CardType _detectedType = CardType.other;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFromCart = widget.forceShowSave;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(isFromCart ? 'Kart Bilgilerini Girin' : 'Kart Ekle',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Card number
          TextFormField(
            controller: _numberCtrl,
            keyboardType: TextInputType.number,
            maxLength: 19,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Kart Numarası',
              prefixIcon: const Icon(Icons.credit_card),
              counterText: '',
              suffixIcon: _detectedType != CardType.other
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _detectedType == CardType.visa ? 'VISA'
                          : _detectedType == CardType.mastercard ? 'MC'
                          : 'TROY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _detectedType == CardType.visa ? const Color(0xFF1A237E)
                            : _detectedType == CardType.mastercard ? const Color(0xFFBF360C)
                            : const Color(0xFF1B5E20),
                        ),
                      ),
                    )
                  : null,
            ),
            validator: (v) {
              final digits = v?.replaceAll(' ', '') ?? '';
              if (digits.length < 16) return 'Kart numarası 16 haneli olmalıdır';
              if (!_luhnCheck(digits)) return 'Geçersiz kart numarası';
              return null;
            },
            onChanged: (v) {
              final digits = v.replaceAll(' ', '');
              setState(() => _detectedType = _detectType(digits));
            },
          ),
          const SizedBox(height: 14),

          // Card holder name
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Kart Üzerindeki Ad Soyad',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v?.trim().isEmpty ?? true) ? 'Ad soyad giriniz' : null,
          ),
          const SizedBox(height: 14),

          Row(children: [
            // Expiry
            Expanded(
              child: TextFormField(
                controller: _expiryCtrl,
                keyboardType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'AA/YY',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  counterText: '',
                ),
                validator: _validateExpiry,
              ),
            ),
            const SizedBox(width: 14),
            // CVV
            Expanded(
              child: TextFormField(
                controller: _cvvCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock_outline),
                  counterText: '',
                ),
                validator: (v) {
                  final len = v?.length ?? 0;
                  if (len < 3) return 'CVV en az 3 haneli olmalıdır';
                  return null;
                },
              ),
            ),
          ]),

          // Save card option
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _saveCard,
            onChanged: (v) => setState(() => _saveCard = v ?? false),
            title: const Text('Bu kartı kaydet', style: TextStyle(fontSize: 14)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryGreen,
            dense: true,
          ),

          // Label field shown when saving
          if (_saveCard) ...[
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Kart Adı (ör. İş Kartım)',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _pay,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _loading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isFromCart ? 'Bu Kartla Öde' : 'Kartı Kaydet',
                      style: const TextStyle(fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  String? _validateExpiry(String? v) {
    if (v == null || v.length < 5) return 'Geçersiz tarih';
    final parts = v.split('/');
    if (parts.length != 2) return 'AA/YY formatında girin';
    final month = int.tryParse(parts[0]);
    final year  = int.tryParse(parts[1]);
    if (month == null || year == null) return 'Geçersiz tarih';
    if (month < 1 || month > 12) return 'Geçersiz ay';
    final now = DateTime.now();
    final fullYear = 2000 + year;
    // Card valid through the last day of the expiry month
    final expiry = DateTime(fullYear, month + 1);
    if (expiry.isBefore(DateTime(now.year, now.month))) return 'Kartın süresi dolmuş';
    return null;
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final number = _numberCtrl.text.replaceAll(' ', '');
    final last4  = number.substring(number.length - 4);
    final type   = _detectType(number);

    final card = SavedCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      last4: last4,
      holderName: _nameCtrl.text.trim(),
      expiry: _expiryCtrl.text,
      type: type,
      label: _labelCtrl.text.trim(),
    );

    if (_saveCard && context.mounted) {
      await context.read<CardProvider>().addCard(card);
    }

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, card);
  }

  bool _luhnCheck(String number) {
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  CardType _detectType(String number) {
    if (number.isEmpty) return CardType.other;
    // Visa: 4 ile başlar
    if (number.startsWith('4')) return CardType.visa;
    // Mastercard: 51-55 veya 2221-2720
    if (number.length >= 2) {
      final p2 = int.tryParse(number.substring(0, 2)) ?? 0;
      if (p2 >= 51 && p2 <= 55) return CardType.mastercard;
    }
    if (number.length >= 4) {
      final p4 = int.tryParse(number.substring(0, 4)) ?? 0;
      if (p4 >= 2221 && p4 <= 2720) return CardType.mastercard;
    }
    // Troy: 9792 ile başlar
    if (number.startsWith('9792')) return CardType.troy;
    return CardType.other;
  }
}

// ─────────────────────────────────────────────────────────────
//  INPUT FORMATTERS
// ─────────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
