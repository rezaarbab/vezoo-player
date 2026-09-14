// lib/settings_screen.dart — تنظیمات اپ: تم، زبان، AI، ابزارها
import 'package:flutter/material.dart';
import 'store.dart';
import 'settings.dart' show ToolsTabBody;
import 'ai_models_screen.dart';
import 'vosk_models_screen.dart';
import 'glass.dart';
import 'l10n.dart';
import 'api_service.dart';
import 'theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState()=>_SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context){
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md + 4, Sp.lg, 120),
        children: [
          Text('Settings', style: Ty.title),
          const SizedBox(height: Sp.md),

          // ── Appearance (theme picker) ──
          VzSectionHeader(title: L.appearance),
          const VzThemePicker(),
          const SizedBox(height: Sp.xl),

          // ── Tools (yt-dlp, Gemini, VPN bypass, backup) ──
          const VzSectionHeader(title: 'Tools'),
          const ToolsTabBody(),
          const SizedBox(height: Sp.xl),

          // ── AI Models ──
          VzSectionHeader(title: L.aiModels),
          _settingCard(
            icon: Icons.auto_awesome_rounded,
            color: Vz.accent,
            title: L.aiModels,
            subtitle: 'Whisper • AI subtitles',
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const AiModelsScreen())),
          ),
          const SizedBox(height: Sp.sm),
          _settingCard(
            icon: Icons.record_voice_over_rounded,
            color: Vz.accentHi,
            title: 'Vosk — Models',
            subtitle: 'Offline • 18 languages • live subtitles',
            onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const VoskModelsScreen())),
          ),
          const SizedBox(height: Sp.xl),

          // ── Language ──
          VzSectionHeader(title: L.language),
          const _LangPicker(),
          const SizedBox(height: Sp.xl),

          // ── About ──
          VzSectionHeader(title: 'About'),
          _aboutCard(),
        ],
      ),
    );
  }

  Widget _settingCard({
    required IconData icon, required Color color,
    required String title, String? subtitle, VoidCallback? onTap,
  }) => VzGlass(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    onTap: onTap,
    child: Row(children: [
      VzIconBadge(icon: icon, color: color, size: 17, box: 38),
      const SizedBox(width: Sp.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Ty.label),
        if(subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: Ty.caption.copyWith(fontSize: 10)),
        ],
      ])),
      if(onTap != null)
        Icon(Icons.chevron_right_rounded, size: 18, color: Vz.textDim),
    ]),
  );

  Widget _aboutCard() => FutureBuilder<Map<String,dynamic>?>(
    future: ApiService.getConfig(),
    builder: (ctx, snap){
      final cfg = snap.data ?? {};
      final channel = cfg['telegram_channel'] ?? '';
      final admin = cfg['telegram_admin'] ?? '';
      final remoteVer = cfg['app_version'] ?? '';
      final hasUpdate = remoteVer.isNotEmpty && ApiService.isNewer(remoteVer, ApiService.appVersion);

      return VzGlass(
        padding: const EdgeInsets.all(Sp.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: Vz.accentGrad,
                borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24)),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('VEZOO', style:TextStyle(
                fontWeight: FontWeight.w800, fontSize: 17,
                letterSpacing: 2.5, color: Vz.text)),
              const SizedBox(height: 2),
              Text('v${ApiService.appVersion} — NOVA',
                style: Ty.overline.copyWith(fontSize: 10)),
            ])),
            if(snap.connectionState == ConnectionState.waiting)
              const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Vz.accent)),
          ]),
          const SizedBox(height: Sp.lg),
          if(hasUpdate)
            _aboutBtn(
              icon: Icons.system_update_rounded, color: Vz.amber,
              label: L.updateAvailable,
              onTap: ()async{
                final url = cfg['download_url'] ?? '';
                if(url.isNotEmpty) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }),
          if(hasUpdate) const SizedBox(height: Sp.sm),
          if(channel.isNotEmpty)
            _aboutBtn(
              icon: Icons.telegram_rounded, color: Vz.accentHi,
              label: L.telegramChannel,
              onTap: ()=>launchUrl(Uri.parse(channel), mode: LaunchMode.externalApplication)),
          if(channel.isNotEmpty) const SizedBox(height: Sp.sm),
          if(admin.isNotEmpty)
            _aboutBtn(
              icon: Icons.bug_report_rounded, color: Vz.magenta,
              label: cfg['report_text'] ?? L.reportBug,
              onTap: ()=>launchUrl(Uri.parse(admin), mode: LaunchMode.externalApplication)),
        ]),
      );
    });

  Widget _aboutBtn({required IconData icon, required Color color, required String label, VoidCallback? onTap}){
    return _settingCard(icon: icon, color: color, title: label, onTap: onTap);
  }
}

class _LangPicker extends StatefulWidget {
  const _LangPicker();
  @override State<_LangPicker> createState()=>_LangPickerState();
}
class _LangPickerState extends State<_LangPicker>{
  @override Widget build(BuildContext context){
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: kSupportedLangs.map((lang)=>
        VzChip(
          label: kLangNames[lang]!,
          selected: L.current == lang,
          onTap: ()async{ await L.set(lang); if(mounted) setState((){}); },
        )).toList(),
    );
  }
}

/// انتخابگر تم NOVA Duo — سه حالت: سیستمی / تیره / روشن
/// هر آیتم: پیش‌نمایش کوچک از پالت + عنوان. انتخاب = تغییر زنده کل اپ.
class VzThemePicker extends StatelessWidget {
  const VzThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    // VzTheme رو از بالا پیدا می‌کنیم
    final vzTheme = context.findAncestorStateOfType<VzThemeState>();
    final mode = vzTheme?.mode ?? VzThemeMode.system;

    return Row(children: [
      Expanded(child: _themeCard(
        context: context,
        mode: mode,
        target: VzThemeMode.dark,
        icon: Icons.dark_mode_rounded,
        label: L.themeDark,
        preview: _PalettePreview.dark(),
      )),
      const SizedBox(width: Sp.sm),
      Expanded(child: _themeCard(
        context: context,
        mode: mode,
        target: VzThemeMode.light,
        icon: Icons.light_mode_rounded,
        label: L.themeLight,
        preview: _PalettePreview.light(),
      )),
      const SizedBox(width: Sp.sm),
      Expanded(child: _themeCard(
        context: context,
        mode: mode,
        target: VzThemeMode.system,
        icon: Icons.brightness_auto_rounded,
        label: L.themeSystem,
        preview: _PalettePreview.auto(),
      )),
    ]);
  }

  Widget _themeCard({
    required BuildContext context,
    required VzThemeMode mode,
    required VzThemeMode target,
    required IconData icon,
    required String label,
    required Widget preview,
  }) {
    final selected = mode == target;
    final vzTheme = context.findAncestorStateOfType<VzThemeState>();
    return VzGlass(
      padding: const EdgeInsets.all(Sp.sm),
      onTap: () => vzTheme?.setMode(target),
      borderColor: selected ? Vz.accent.withOpacity(0.65) : null,
      boxShadow: selected ? [Vz.glowSoft] : null,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        preview,
        const SizedBox(height: Sp.sm),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 13,
            color: selected ? Vz.accent : Vz.textDim),
          const SizedBox(width: 4),
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: selected ? Vz.accent : Vz.textSec))),
        ]),
      ]),
    );
  }
}

/// پیش‌نمایش پالت — سه نوار رنگی که حس تم رو نشون میده
class _PalettePreview extends StatelessWidget {
  final bool dark;
  final bool auto;
  const _PalettePreview._({required this.dark, this.auto = false});
  const _PalettePreview.dark() : this._(dark: true);
  const _PalettePreview.light() : this._(dark: false);
  const _PalettePreview.auto() : this._(dark: true, auto: true);

  @override
  Widget build(BuildContext context) {
    final isAuto = auto;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0B0B10) : const Color(0xFFF7F5FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark ? const Color(0xFF2A2A38) : const Color(0xFFE4E1EE),
          width: 0.8),
      ),
      child: Stack(children: [
        // mini aurora blob
        Positioned(
          right: -14, top: -14,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFF8B5CF6).withOpacity(0.4),
                const Color(0xFF8B5CF6).withOpacity(0),
              ]),
            ),
          ),
        ),
        // mini cards
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 34, height: 5,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF2A2A38) : const Color(0xFFE4E1EE),
              borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 14, height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFA78BFA), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 3),
            Container(
              width: 8, height: 4,
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A1A23) : Colors.white,
                borderRadius: BorderRadius.circular(2)),
            ),
          ]),
        ])),
        if (isAuto)
          Positioned(
            left: 4, bottom: 4,
            child: Icon(Icons.brightness_auto_rounded,
              size: 10, color: dark ? const Color(0xFF5C5F73) : const Color(0xFF9A97AB)),
          ),
      ]),
    );
  }
}

