import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Settings screen with app sharing, about section, and theme info.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _appStoreLink =
      'https://apps.apple.com/app/financials';
  static const String _playStoreLink =
      'https://play.google.com/store/apps/details?id=com.brightlab.financials';

  static const String _shareMessage =
      '💰 Check out Financials — a smart personal finance tracker!\n\n'
      'Track income & expenses, analyze spending, and take control of your money.\n\n'
      '📱 iOS: $_appStoreLink\n'
      '🤖 Android: $_playStoreLink';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Info Card ──────────────────────────────────────────────
            _buildSectionLabel('About', textMuted),
            _buildCard(
              cardColor: cardColor,
              borderColor: cardBorder,
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.primaryLight,
                    label: 'App Name',
                    value: 'Financials',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildDivider(cardBorder),
                  _buildInfoRow(
                    icon: Icons.tag_rounded,
                    iconColor: AppColors.primaryLight,
                    label: 'Version',
                    value: '1.0.0',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildDivider(cardBorder),
                  _buildInfoRow(
                    icon: Icons.business_rounded,
                    iconColor: AppColors.primaryLight,
                    label: 'Developer',
                    value: 'BrightLab',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Share Section ──────────────────────────────────────────────
            _buildSectionLabel('Share', textMuted),
            _buildCard(
              cardColor: cardColor,
              borderColor: cardBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Text(
                      'Share Financials with friends & family',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Help others take control of their finances. Share the app via any platform below.',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Share platforms grid
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildShareChip(
                          context: context,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          icon: Icons.chat_rounded,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'Facebook',
                          color: const Color(0xFF1877F2),
                          icon: Icons.facebook_rounded,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'Twitter/X',
                          color: const Color(0xFF1DA1F2),
                          icon: Icons.alternate_email_rounded,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'Instagram',
                          color: const Color(0xFFE1306C),
                          icon: Icons.photo_camera_rounded,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'Telegram',
                          color: const Color(0xFF0088CC),
                          icon: Icons.send_rounded,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'Email',
                          color: AppColors.primaryLight,
                          icon: Icons.email_outlined,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'SMS',
                          color: const Color(0xFF34D399),
                          icon: Icons.sms_rounded,
                          onTap: () => _shareApp(context),
                        ),
                        _buildShareChip(
                          context: context,
                          label: 'More...',
                          color: AppColors.textSecondaryDark,
                          icon: Icons.share_rounded,
                          onTap: () => _shareApp(context),
                        ),
                      ],
                    ),
                  ),

                  // Main share button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _shareApp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          'Share Financials',
                          style: GoogleFonts.ibmPlexSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Storage Note ──────────────────────────────────────────────
            _buildSectionLabel('Data', textMuted),
            _buildCard(
              cardColor: cardColor,
              borderColor: cardBorder,
              child: _buildInfoRow(
                icon: Icons.save_outlined,
                iconColor: AppColors.income,
                label: 'Storage',
                value: 'Saved locally on your device',
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Text(
                'Made with ❤️ by BrightLab',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;
    Share.share(
      _shareMessage,
      subject: 'Financials App',
      sharePositionOrigin: origin,
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color cardColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, color: color, indent: 16, endIndent: 16);
  }

  Widget _buildShareChip({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark
        ? AppColors.surfaceDark
        : AppColors.bgLight;
    final chipBorder = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: chipBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
