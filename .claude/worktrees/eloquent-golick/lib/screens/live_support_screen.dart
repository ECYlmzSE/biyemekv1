import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isTyping;
  const _Message({required this.text, required this.isUser, required this.time, this.isTyping = false});
}

class LiveSupportScreen extends StatefulWidget {
  const LiveSupportScreen({super.key});
  @override
  State<LiveSupportScreen> createState() => _LiveSupportScreenState();
}

class _LiveSupportScreenState extends State<LiveSupportScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Message> _msgs = [];
  bool _agentTyping = false;
  bool _connected = false;
  int _msgIndex = 0;

  static const _botName = 'Bi\'Yemek Destek';

  static const _greetingFlow = [
    'Merhaba! Bi\'Yemek Müşteri Hizmetleri\'ne hoş geldiniz 👋',
    'Ben Destek Asistanı\'yım. Size nasıl yardımcı olabilirim?',
    'Aşağıdaki konularda yardımcı olabilirim:\n\n📦 Sipariş durumu\n💰 İade ve iptal\n🚚 Teslimat sorunları\n🍽️ Restoran şikayetleri\n🔐 Hesap yönetimi',
  ];

  static const _autoReplies = {
    'sipariş': '📦 Sipariş takibini "Siparişlerim" ekranından yapabilirsiniz. Aktif bir siparişiniz varsa canlı takip mevcut. Başka yardımcı olabileceğim bir konu var mı?',
    'iade': '💰 İade talepleriniz için siparişin teslimattan sonra 24 saat içinde bildirilmesi gerekmektedir. Banka hesabınıza 3-5 iş günü içinde yansır.',
    'iptal': '❌ Sipariş onayından itibaren 2 dakika içinde iptal yapılabilir. Restoran hazırlamaya başladıktan sonra iptal mümkün olmayabilir.',
    'teslimat': '🚚 Teslimat süresi restoran ve konumunuza göre değişmektedir. Ortalama 20-45 dakikadır. Trafik durumunda uzayabilir.',
    'ödeme': '💳 Nakit, kredi kartı ve Bi\'Yemek bakiyesi ile ödeme kabul edilmektedir. Kartınızda sorun oluşursa farklı ödeme yöntemi seçebilirsiniz.',
    'promosyon': '🎁 Güncel kampanyaları ana ekrandaki duyurular bölümünden takip edebilirsiniz. Promosyon kodu "HOSGELDIN" ile ilk siparişte %20 indirim!',
    'şikayet': '⚠️ Şikayetinizi dikkate alıyoruz. Lütfen sipariş numaranızı ve yaşadığınız sorunu yazın, ekibimiz en kısa sürede dönüş yapacak.',
    'teşekkür': '🙏 Rica ederiz! İyi yemekler dileriz. Başka bir konuda yardımcı olmamı ister misiniz?',
    'merhaba': '😊 Merhaba! Nasıl yardımcı olabilirim?',
  };

  @override
  void initState() {
    super.initState();
    _startGreeting();
  }

  void _startGreeting() {
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _agentTyping = true);
      _sendBotMessage(0);
    });
  }

  void _sendBotMessage(int idx) {
    if (idx >= _greetingFlow.length) {
      if (mounted) setState(() { _connected = true; _agentTyping = false; });
      return;
    }
    Timer(Duration(milliseconds: 800 + idx * 300), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Message(text: _greetingFlow[idx], isUser: false, time: DateTime.now()));
        if (idx < _greetingFlow.length - 1) _agentTyping = true;
        else { _agentTyping = false; _connected = true; }
      });
      _scrollDown();
      _sendBotMessage(idx + 1);
    });
  }

  String _getBotReply(String msg) {
    final lower = msg.toLowerCase();
    for (final entry in _autoReplies.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    _msgIndex++;
    final fallbacks = [
      'Anlıyorum. Bu konuyu uzman ekibimize yönlendiriyorum. En kısa sürede sizinle iletişime geçeceğiz. 🔄',
      'Durumunuzu not aldım. Ekibimiz 24 saat içinde sizi arayacak. 📞',
      'Bu konuda size yardımcı olmak için ek bilgiye ihtiyacım var. Sipariş numaranızı paylaşabilir misiniz?',
      'Anlıyorum. Başka yardımcı olabileceğim bir konu var mı?',
    ];
    return fallbacks[_msgIndex % fallbacks.length];
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    setState(() {
      _msgs.add(_Message(text: text, isUser: true, time: DateTime.now()));
      _agentTyping = true;
    });
    _scrollDown();

    final reply = _getBotReply(text);
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Message(text: reply, isUser: false, time: DateTime.now()));
        _agentTyping = false;
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

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
              Text(_connected ? 'Çevrimiçi' : 'Bağlanıyor...',
                style: TextStyle(fontSize: 11, color: _connected ? Colors.greenAccent : Colors.orange)),
            ]),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Çağrı Merkezi: 0850 123 45 67'),
                backgroundColor: AppTheme.primaryGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // Quick replies
        if (_connected && _msgs.length >= 3)
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _quickBtn('📦 Sipariş durumu', 'Siparişim nerede?'),
              _quickBtn('💰 İade talebi', 'İade nasıl yapabilirim?'),
              _quickBtn('❌ İptal', 'Siparişi iptal etmek istiyorum'),
              _quickBtn('🚚 Teslimat', 'Teslimat çok geç'),
            ]),
          ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            itemCount: _msgs.length + (_agentTyping ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == _msgs.length) return _buildTypingBubble(theme, isDark);
              return _buildMsg(_msgs[i], theme, isDark);
            },
          ),
        ),

        // Input
        Container(
          padding: EdgeInsets.only(
            left: 12, right: 12, top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12),
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
                  color: AppTheme.primaryGreen, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _quickBtn(String emoji, String text) => GestureDetector(
    onTap: () {
      _ctrl.text = text;
      _send();
    },
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.primaryGreen.withOpacity(0.07),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
    ),
  );

  Widget _buildMsg(_Message msg, ThemeData theme, bool isDark) {
    final timeStr = '${msg.time.hour.toString().padLeft(2,'0')}:${msg.time.minute.toString().padLeft(2,'0')}';
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isUser
                      ? AppTheme.primaryGreen
                      : (isDark ? AppTheme.darkSurface : Colors.grey.shade100),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                    ),
                  ),
                  child: Text(msg.text, style: TextStyle(
                    fontSize: 14, height: 1.4,
                    color: msg.isUser ? Colors.white : null,
                  )),
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

  Widget _buildTypingBubble(ThemeData theme, bool isDark) => Padding(
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
            topLeft: Radius.circular(18), topRight: Radius.circular(18),
            bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
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
