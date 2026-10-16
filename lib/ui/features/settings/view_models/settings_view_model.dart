import 'dart:ui';
import '../../../../data/services/share_service.dart';

/// ViewModel for the Settings feature.
/// Encapsulates app metadata and delegates social sharing to [ShareService].
class SettingsViewModel {
  final ShareService shareService;

  const SettingsViewModel({
    this.shareService = const ShareService(),
  });

  static const String appName = 'Financials';
  static const String appVersion = '1.0.0';
  static const String developerName = 'BrightLab';
  static const String storageDescription = 'Saved locally on your device';

  static const String _appStoreLink = 'https://apps.apple.com/app/financials';
  static const String _playStoreLink =
      'https://play.google.com/store/apps/details?id=com.brightlab.financials';

  static const String shareMessage =
      '💰 Check out Financials — a smart personal finance tracker!\n\n'
      'Track income & expenses, analyze spending, and take control of your money.\n\n'
      '📱 iOS: $_appStoreLink\n'
      '🤖 Android: $_playStoreLink';

  Future<void> shareApp({Rect? sharePositionOrigin}) async {
    await shareService.shareText(
      text: shareMessage,
      subject: 'Financials App',
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

