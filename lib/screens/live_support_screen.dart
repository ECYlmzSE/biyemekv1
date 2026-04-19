import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';

// ── Mesaj modeli ─────────────────────────────────────────────────────────────
class _Message {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<String>? choices; // restoran seçim butonları için
  const _Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.choices,
  });
}

// ── Akış durumu ───────────────────────────────────────────────────────────────
enum _Topic { none, orderStatus, cancelStatus, complaint }
enum _ComplaintStep { selectOrder, enterText }

// ─────────────────────────────────────────────────────────────────────────────
class LiveSupportScreen extends StatefulWidget {
  const LiveSupportScreen({super.key});
  @override
  State<LiveSupportScreen> createState() => _LiveSupportScreenState();
}

class _LiveSupportScreenState extends State<LiveSupportScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _msgs = [];

  bool _agentTyping = false;
  bool _connected   = false;

  _Topic         _topic          = _Topic.none;
  _ComplaintStep _complaintStep  = _ComplaintStep.selectOrder;
  String?        _complaintRest; // seçilen restoran adı

  static const _botName = 'Bi\'Yemek Destek';

  static const _greetingFlow = [
    'Merhaba! Bi\'Yemek Müşteri Hizmetleri\'ne hoş geldiniz 👋',
    'Ben Destek Asistanı\'yım. Size nasıl yardımcı olabilirim?',
    'Aşağıdaki konularda yardımcı olabilirim:\n\n📦 Sipariş Durumu\n🔴 İptal Talebi\n🍽️ Restoran Şikayetleri',
  ];

  // ── Provider kısayolları ─────────────────────────────────────────────────
  List<OrderModel> get _activeOrders =>
      context.read<OrderProvider>().activeOrders;

  List<OrderModel> get _cancelledOrders =>
      context.read<OrderProvider>().orders
          .where((o) => o.status == OrderStatus.cancelled)
          .toList();

  List<OrderModel> get _recentOrders {
    final all = context.read<OrderProvider>().orders;
    return all.take(3).toList();
  }

  // ── Init ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _agentTyping = true);
      _sendBotSequence(_greetingFlow, onDone: () {
        if (mounted) setState(() { _connected = true; _agentTyping = false; });
      });
    });
  }

  // ── Bot mesaj gönderme ───────────────────────────────────────────────────
  void _sendBotSequence(List<String> msgs, {int idx = 0, VoidCallback? onDone}) {
    if (idx >= msgs.length) { onDone?.call(); return; }
    Timer(Duration(milliseconds: 800 + idx * 300), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Message(text: msgs[idx], isUser: false, time: DateTime.now()));
        _agentTyping = idx < msgs.length - 1;
      });
      _scrollDown();
      _sendBotSequence(msgs, idx: idx + 1, onDone: onDone);
    });
  }

  void _botReply(String text, {List<String>? choices}) {
    setState(() => _agentTyping = true);
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Message(text: text, isUser: false, time: DateTime.now(), choices: choices));
        _agentTyping = false;
      });
      _scrollDown();
    });
  }

  // ── Kullanıcı mesajı işleme ──────────────────────────────────────────────
  void _handleUserMessage(String text) {
    switch (_topic) {
      case _Topic.complaint:
        if (_complaintStep == _ComplaintStep.enterText) {
          _botReply(
            'Şikayet talebiniz alınmıştır, en kısa sürede çözümlenecektir. 🙏\n\nBaşka yardımcı olabileceğim konu var mı?',
          );
          _topic = _Topic.none;
        } else {
          // selectOrder aşamasında yazı gelirse yönlendir
          _routeTopic(text);
        }
        break;
      default:
        _routeTopic(text);
        break;
    }
  }

  void _routeTopic(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('sipariş') || lower.contains('durum')) {
      _handleOrderStatus();
    } else if (lower.contains('iptal') || lower.contains('iade')) {
      _handleCancelStatus();
    } else if (lower.contains('şikayet') || lower.contains('restoran')) {
      _handleComplaint();
    } else {
      _topic = _Topic.none;
      _botReply(
        'Durumunuz not alınmıştır, ekiplerimiz kısa bir süre içinde geri dönüş sağlayacaktır.',
      );
    }
  }

  void _handleOrderStatus() {
    _topic = _Topic.orderStatus;
    final active = _activeOrders;
    if (active.isEmpty) {
      _botReply(
        'Şu anda aktif siparişiniz bulunmamaktadır.\n\nBaşka yardımcı olabileceğim konu var mı?',
      );
    } else {
      final o = active.first;
      _botReply(
        '${o.status.emoji} Siparişinizin durumu: ${o.status.label}\n'
        '🍽️ Restoran: ${o.restaurantName}\n\n'
        'Başka yardımcı olabileceğim konu var mı?',
      );
    }
  }

  void _handleCancelStatus() {
    _topic = _Topic.cancelStatus;
    final cancelled = _cancelledOrders;
    if (cancelled.isEmpty) {
      _botReply(
        'İptal talebiniz bulunmamaktadır.\n\nBaşka yardımcı olabileceğim konu var mı?',
      );
    } else {
      _botReply(
        'İptal talebiniz onaylanmıştır. Para iadeniz bankanıza bağlı olarak hesabınıza 1-5 iş günü içerisinde yansır. 💳\n\nBaşka yardımcı olabileceğim konu var mı?',
      );
    }
  }

  void _handleComplaint() {
    _topic = _Topic.complaint;
    _complaintStep = _ComplaintStep.selectOrder;
    final recent = _recentOrders;
    if (recent.isEmpty) {
      _botReply(
        'Şikayet oluşturabilmek için geçmiş siparişiniz bulunması gerekmektedir.\n\nBaşka yardımcı olabileceğim konu var mı?',
      );
      _topic = _Topic.none;
      return;
    }
    _botReply(
      'Yardımcı olabilmek için hangi siparişinizle alakalı şikayette bulunacaksınız?',
      choices: recent.map((o) => o.restaurantName).toList(),
    );
  }

  void _selectOrderForComplaint(String restaurantName) {
    if (_complaintStep != _ComplaintStep.selectOrder) return;
    _complaintRest  = restaurantName;
    _complaintStep  = _ComplaintStep.enterText;
    setState(() {
      _msgs.add(_Message(text: restaurantName, isUser: true, time: DateTime.now()));
    });
    _scrollDown();
    _botReply('$restaurantName ile alakalı şikayetiniz nedir?');
  }

  // ── Kullanıcı gönder ─────────────────────────────────────────────────────
  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_Message(text: text, isUser: true, time: DateTime.now()));
      _agentTyping = true;
    });
    _scrollDown();
    _handleUserMessage(text);
  }

  void _scrollDown() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(_botName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Row(children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: _connected ? Colors.greenAccent : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _connected ? 'Çevrimiçi' : 'Bağlanıyor...',
                style: TextStyle(
                  fontSize: 11,
                  color: _connected ? Colors.greenAccent : Colors.orange,
                ),
              ),
            ]),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Çağrı Merkezi: 0850 123 45 67'),
                backgroundColor: AppTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // ── Hızlı seçim butonları ──────────────────────────────────────
        if (_connected && _msgs.length >= 3)
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _quickBtn('📦 Sipariş Durumu',      'Sipariş durumumu öğrenmek istiyorum'),
              _quickBtn('🔴 İptal Talebi',         'İptal talebimi sormak istiyorum'),
              _quickBtn('🍽️ Restoran Şikayetleri', 'Restoran şikayeti iletmek istiyorum'),
            ]),
          ),

        // ── Mesaj listesi ───────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _msgs.length + (_agentTyping ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _msgs.length) return _buildTypingBubble(isDark);
              return _buildMsg(_msgs[i], isDark);
            },
          ),
        ),

        // ── Metin girişi ────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.only(
            left: 12, right: 12, top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _send(),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3, minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Mesaj yaz...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Hızlı buton ─────────────────────────────────────────────────────────
  Widget _quickBtn(String label, String sendText) => GestureDetector(
    onTap: () { _ctrl.text = sendText; _send(); },
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.primaryGreen.withOpacity(0.07),
      ),
      child: Text(label,
        style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
    ),
  );

  // ── Mesaj balonu ─────────────────────────────────────────────────────────
  Widget _buildMsg(_Message msg, bool isDark) {
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';
    final showChoices = msg.choices != null &&
        _topic == _Topic.complaint &&
        _complaintStep == _ComplaintStep.selectOrder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Metin balonu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppTheme.primaryGreen
                        : (isDark ? AppTheme.darkSurface : Colors.grey.shade100),
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  Radius.circular(msg.isUser ? 18 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                    ),
                  ),
                  child: Text(msg.text, style: TextStyle(
                    fontSize: 14, height: 1.4,
                    color: msg.isUser ? Colors.white : null,
                  )),
                ),
                // Restoran seçim butonları
                if (showChoices)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: msg.choices!.map((name) => GestureDetector(
                        onTap: () => _selectOrderForComplaint(name),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.primaryGreen.withOpacity(0.07),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.restaurant, size: 14, color: AppTheme.primaryGreen),
                            const SizedBox(width: 6),
                            Text(name, style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            )),
                          ]),
                        ),
                      )).toList(),
                    ),
                  ),
                const SizedBox(height: 3),
                Text(timeStr, style: const TextStyle(fontSize: 10, color: AppTheme.grey)),
              ],
            ),
          ),
          if (msg.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // ── Yazıyor animasyonu ───────────────────────────────────────────────────
  Widget _buildTypingBubble(bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
        child: const Icon(Icons.support_agent, color: Colors.white, size: 16),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft:     Radius.circular(18),
            topRight:    Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft:  Radius.circular(4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4),
          _dot(1), const SizedBox(width: 4),
          _dot(2),
        ]),
      ),
    ]),
  );

  Widget _dot(int i) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 600 + i * 200),
    builder: (_, v, __) => Container(
      width: 7, height: 7,
      decoration: BoxDecoration(
        color: AppTheme.grey.withOpacity(0.4 + 0.6 * v),
        shape: BoxShape.circle,
      ),
    ),
  );
}
