// lib/settings_screen.dart — تنظیمات اپ: تم، ابزارها، AI، زبان، درباره
//
// VOID rebuild: everything is grouped into hairline-ruled cards, no random
// per-row colors, no hardcoded English strings, and the theme picker now
// reads its state from VzThemeScope so the selection never goes stale.
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
          // ── هدر ──
          Text(L.settings, style: Ty.title),
          const SizedBox(height: 2),
          Text('Vezoo v${ApiService.appVersion} • VOID',
            style: Ty.overline.copyWith(color: Vz.textDim)),
          const SizedBox(height: Sp.sm),

          // ── Appearance ──
          VzSectionHeader(title: L.appearance),
          const VzThemePicker(),

          // ── Tools ──
          VzSectionHeader(title: L.toolsSection),
          const VzGlass(
            padding: EdgeInsets.all(Sp.md),
            child: ToolsTabBody(),
          ),

          // ── AI Models ──
          VzSectionHeader(title: L.aiModelsLabel),
          VzGlass(
            padding: EdgeInsets.zero,
            child: Column(children: [
              VzRow(
                icon: Icons.auto_awesome_rounded,
                title: L.aiModels,
                subtitle: 'Whisper • AI ${L.subtitle.toLowerCase()}',
                onTap: ()=>Navigator.push(context,
                  MaterialPageRoute(builder: (_)=>const AiModelsScreen())),
              ),
              const Divider(height: 1, indent: 56),
              VzRow(
                icon: Icons.record_voice_over_rounded,
                title: 'Vosk',
                subtitle: 'Offline • 18 ${L.language.toLowerCase()}',
                onTap: ()=>Navigator.push(context,
                  MaterialPageRoute(builder: (_)=>const VoskModelsScreen())),
              ),
            ]),
          ),

          // ── Language ──
          VzSectionHeader(title: L.language),
          const VzGlass(
            padding: EdgeInsets.all(Sp.md),
            child: _LangPicker(),
          ),

          // ── About ──
          VzSectionHeader(title: L.aboutSection),
          _aboutCard(),
        ],
      ),
    );
  }

  Widget _aboutCard() => FutureBuilder<Map<String,dynamic>?>(
    future: ApiService.getConfig(),
    builder: (ctx, snap){
      final cfg = snap.data ?? {};
      final channel = cfg['telegram_channel'] ?? '';
      final admin = cfg['telegram_admin'] ?? '';
      final remoteVer = cfg['app_version'] ?? '';
      final hasUpdate = remoteVer.isNotEmpty &&
          ApiService.isNewer(remoteVer, ApiService.appVersion);

      return VzGlass(
        padding: EdgeInsets.zero,
        child: Column(children: [
          // ── wordmark ──
          Padding(
            padding: const EdgeInsets.all(Sp.md),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: Vz.accentGrad,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.play_arrow_rounded,
                  color: Vz.isDark ? const Color(0xFF1A1203) : Colors.white,
                  size: 26),
              ),
              const SizedBox(width: Sp.md),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('VEZOO', style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 17,
                    letterSpacing: 2.5, color: Vz.text)),
                  const SizedBox(height: 2),
                  Text('v${ApiService.appVersion}',
                    style: Ty.caption.copyWith(fontSize: 11)),
                ])),
              if (snap.connectionState == ConnectionState.waiting)
                SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Vz.accent)),
            ]),
          ),
          if (hasUpdate) ...[
            const Divider(height: 1),
            VzRow(
              icon: Icons.system_update_rounded,
              title: L.updateAvailable,
              accent: Vz.accent,
              onTap: ()async{
                final url = cfg['download_url'] ?? '';
                if(url.isNotEmpty) await launchUrl(
                  Uri.parse(url), mode: LaunchMode.externalApplication);
              }),
          ],
          if (channel.isNotEmpty) ...[
            const Divider(height: 1),
            VzRow(
              icon: Icons.telegram_rounded,
              title: L.telegramChannel,
              onTap: ()=>launchUrl(
                Uri.parse(channel), mode: LaunchMode.externalApplication)),
          ],
          if (admin.isNotEmpty) ...[
            const Divider(height: 1),
            VzRow(
              icon: Icons.bug_report_rounded,
              title: cfg['report_text'] ?? L.reportBug,
              onTap: ()=>launchUrl(
                Uri.parse(admin), mode: LaunchMode.externalApplication)),
          ],
        ]),
      );
    });
}

/// ردیف استاندارد VOID — آیکون خطی + عنوان + زیرعنوان + chevron
class VzRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? accent;
  final VoidCallback? onTap;
  const VzRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = accent ?? Vz.textSec;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: c),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Ty.label.copyWith(fontSize: 13.5)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Ty.caption.copyWith(fontSize: 11)),
            ],
          ])),
        if (trailing != null)
          trailing!
        else if (onTap != null)
          Icon(Icons.chevron_right_rounded, size: 19, color: Vz.textDim),
      ]),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
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

/// انتخابگر تم VOID — سه حالت: سیستم / تیره / روشن
/// حالت انتخابی از VzThemeScope خونده می‌شود (نه از ancestor lookup) تا
/// وقتی تم عوض می‌شود همیشه درست رندر شود.
class VzThemePicker extends StatelessWidget {
  const VzThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = VzThemeScope.modeOf(context);
    final vzt = context.findAncestorStateOfType<VzThemeState>();

    return VzGlass(
      padding: const EdgeInsets.all(Sp.xs),
      child: Row(children: [
        Expanded(child: _item(context, vzt, mode, VzThemeMode.dark,
          Icons.dark_mode_rounded, L.themeDark)),
        const SizedBox(width: Sp.xs),
        Expanded(child: _item(context, vzt, mode, VzThemeMode.light,
          Icons.light_mode_rounded, L.themeLight)),
        const SizedBox(width: Sp.xs),
        Expanded(child: _item(context, vzt, mode, VzThemeMode.system,
          Icons.brightness_auto_rounded, L.themeSystem)),
      ]),
    );
  }

  Widget _item(BuildContext context, VzThemeState? vzt, VzThemeMode mode,
      VzThemeMode target, IconData icon, String label) {
    final selected = mode == target;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(Rad.sm),
        onTap: () => vzt?.setMode(target),
        child: AnimatedContainer(
          duration: Mo.fast,
          curve: Mo.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Vz.accent.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(Rad.sm),
            border: Border.all(
              color: selected ? Vz.accent : Vz.border,
              width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: selected ? Vz.accent : Vz.textDim),
            const SizedBox(height: 6),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w700,
                color: selected ? Vz.accent : Vz.textSec)),
          ]),
        ),
      ),
    );
  }
}
