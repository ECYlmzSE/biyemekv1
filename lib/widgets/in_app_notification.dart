import 'dart:async';
import 'package:flutter/material.dart';

// ── Notification data ──────────────────────────────────────────────────────────
class _NotifData {
  final String title, body, emoji;
  const _NotifData({required this.title, required this.body, this.emoji = '🍽️'});
}

// ── Singleton service — call from anywhere (e.g. OrderProvider) ───────────────
class InAppNotificationService {
  static final StreamController<_NotifData> _ctrl =
      StreamController<_NotifData>.broadcast();

  static Stream<_NotifData> get stream => _ctrl.stream;

  static void show(String title, String body, {String emoji = '🍽️'}) {
    if (!_ctrl.isClosed) {
      _ctrl.add(_NotifData(title: title, body: body, emoji: emoji));
    }
  }
}

// ── Wrapper widget — place at the root of the widget tree ────────────────────
class InAppNotificationWrapper extends StatefulWidget {
  final Widget child;
  const InAppNotificationWrapper({super.key, required this.child});

  @override
  State<InAppNotificationWrapper> createState() =>
      _InAppNotificationWrapperState();
}

class _InAppNotificationWrapperState extends State<InAppNotificationWrapper>
    with SingleTickerProviderStateMixin {
  StreamSubscription<_NotifData>? _sub;
  _NotifData? _current;
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slide;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(
            begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _sub = InAppNotificationService.stream.listen(_onNotif);
  }

  void _onNotif(_NotifData data) {
    _hideTimer?.cancel();
    setState(() => _current = data);
    _animCtrl.forward(from: 0);
    _hideTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  void _dismiss() {
    _animCtrl.reverse().then((_) {
      if (mounted) setState(() => _current = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animCtrl.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(children: [
      widget.child,
      if (_current != null)
        Positioned(
          top: top + 8,
          left: 16,
          right: 16,
          child: SlideTransition(
            position: _slide,
            child: GestureDetector(
              onTap: _dismiss,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1C1C1E),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Text(_current!.emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_current!.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(_current!.body,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ]),
                    ),
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(Icons.close,
                          color: Colors.white54, size: 16),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}
