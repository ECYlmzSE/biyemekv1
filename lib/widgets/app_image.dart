import 'package:flutter/material.dart';

/// Yerel asset veya network URL'sine göre doğru Image widget'ını seçer.
/// URL 'assets/' ile başlıyorsa Image.asset, aksi hâlde Image.network kullanır.
class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  Widget _buildError(BuildContext ctx, Object e, StackTrace? _) =>
      errorWidget ??
      Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        child: const Icon(Icons.restaurant, color: Colors.grey),
      );

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: _buildError,
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: _buildError,
    );
  }
}
