// lib/settings_screen.dart — تنظیمات اپ: تم، زبان، AI، ابزارها
import 'package:flutter/material.dart';
import 'store.dart';
import 'settings.dart' show ToolsTabBody;
import 'ai_models_screen.dart';
import 'vosk_models_screen.dart';
import 'glass.dart';
import 'l10n.dart';
import 'api_service.dart';
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
        const Icon(Icons.chevron_right_rounded, size: 18, color: Vz.textDim),
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
              const Text('VEZOO', style: TextStyle(
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
