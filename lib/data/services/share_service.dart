import 'dart:ui';
import 'package:share_plus/share_plus.dart';

/// Data layer service wrapping the native platform share sheet (`share_plus`).
class ShareService {
  const ShareService();

  Future<void> shareText({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

