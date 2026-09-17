// lib/settings_screen.dart — تنظیمات: پرسِت تم، بک‌گراند، انیمیشن، اکسنت، ابزارها
//
// VOID Theme Engine: کاربر یک «تم آماده» انتخاب می‌کند — هر تم پالت، گردی
// گوشه، بک‌گراند گرادیانی و اکسنت خودش را دارد. علاوه بر آن می‌تواند
// بک‌گراند را جدا عوض کند یا رنگ اکسنت را دستی تغییر دهد.
import 'package:flutter/material.dart';
import 'settings.dart' show ToolsTabBody;
import 'ai_models_screen.dart';
import 'vosk_models_screen.dart';
import 'glass.dart';
import 'l10n.dart';
import 'api_service.dart';
import 'theme.dart';
import 'vz_presets.dart';
import 'vz_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState()=>_SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context){
    final preset = Vz.preset;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md + 4, Sp.lg, 120),
        children: [
          // ── هدر ──
          Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(L.settings, style: Ty.title),
                const SizedBox(height: 2),
                Text('${preset.name} • v${ApiService.appVersion}',
                  style: Ty.overline.copyWith(color: Vz.accent)),
              ])),
            _AnimatedOrb(preset: preset),
          ]),
          const SizedBox(height: Sp.sm),

          // ── تم‌های آماده ──
          VzSectionHeader(title: L.theme),
          const VzPresetGallery(),

          // ── بک‌گراند ──
          VzSectionHeader(title: L.background),
          const VzBackgroundPicker(),

          // ── رنگ اکسنت ──
          VzSectionHeader(title: L.accentColor),
          const VzAccentPicker(),

          // ── حالت روشن/تیره + انیمیشن ──
          VzSectionHeader(title: L.appearance),
          const VzThemePicker(),
          const SizedBox(height: Sp.sm),
          VzGlass(
            padding: EdgeInsets.zero,
            child: VzRow(
              icon: VzIcons.data('animation'),
              title: L.animations,
              subtitle: L.animationsDesc,
              accent: Vz.accent,
              trailing: Switch(
                value: VzThemeScope.animationsOf(context),
                onChanged: (v) => context
                    .findAncestorStateOfType<VzThemeState>()
                    ?.setAnimations(v),
              ),
            ),
          ),

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
                icon: VzIcons.data('ai'),
                title: L.aiModels,
                subtitle: 'Whisper • AI ${L.subtitle.toLowerCase()}',
                accent: Vz.accent,
                onTap: ()=>Navigator.push(context,
                  MaterialPageRoute(builder: (_)=>const AiModelsScreen())),
              ),
              const Divider(height: 1, indent: 56),
              VzRow(
                icon: VzIcons.data('voice'),
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
          Padding(
            padding: const EdgeInsets.all(Sp.md),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: Vz.accentGrad,
                  borderRadius: Rad.r(Rad.xs),
                ),
                child: Icon(VzIcons.data('play'), color: Vz.onAccent, size: 26),
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
              icon: VzIcons.data('update'),
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
              icon: VzIcons.data('telegram'),
              title: L.telegramChannel,
              onTap: ()=>launchUrl(
                Uri.parse(channel), mode: LaunchMode.externalApplication)),
          ],
          if (admin.isNotEmpty) ...[
            const Divider(height: 1),
            VzRow(
              icon: VzIcons.data('bug'),
              title: cfg['report_text'] ?? L.reportBug,
              onTap: ()=>launchUrl(
                Uri.parse(admin), mode: LaunchMode.externalApplication)),
          ],
        ]),
      );
    });
}

/// کره‌ی متحرک هدر — رنگ و گردی‌اش از پرسِت می‌آید.
class _AnimatedOrb extends StatefulWidget {
  final VzPreset preset;
  const _AnimatedOrb({required this.preset});
  @override State<_AnimatedOrb> createState()=>_AnimatedOrbState();
}
class _AnimatedOrbState extends State<_AnimatedOrb> with SingleTickerProviderStateMixin{
  AnimationController? _c;
  @override void initState(){
    super.initState();
    if(Vz.animations){
      _c=AnimationController(vsync:this,duration:const Duration(seconds:6))..repeat(reverse:true);
    }
  }
  @override void didUpdateWidget(_AnimatedOrb old){
    super.didUpdateWidget(old);
    if(Vz.animations&&_c==null){
      _c=AnimationController(vsync:this,duration:const Duration(seconds:6))..repeat(reverse:true);
      setState((){});
    } else if(!Vz.animations&&_c!=null){
      _c!.dispose();_c=null;
    }
  }
  @override void dispose(){_c?.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final size = 44.0 * (0.9 + widget.preset.radiusScale*0.12);
    final child = Container(
      width:size,height:size,
      decoration:BoxDecoration(
        gradient:Vz.auroraGrad,
        borderRadius:Rad.r(Rad.xs),
        boxShadow:[Vz.glowSoft],
      ),
    );
    if(_c==null) return child;
    return AnimatedBuilder(animation:_c!,builder:(ctx,_){
      final t=Curves.easeInOut.transform(_c!.value);
      return Transform.rotate(
        angle:(t-0.5)*0.18,
        child:Transform.scale(scale:0.96+t*0.08,child:child));
    });
  }
}

/// گالری تم‌های آماده — هر کارت یک پیش‌نمایش زنده از پالت پرسِت است.
class VzPresetGallery extends StatelessWidget {
  const VzPresetGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final currentId = VzThemeScope.presetIdOf(context);
    final vzt = context.findAncestorStateOfType<VzThemeState>();
    final dark = Vz.isDark;

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: kVzPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: Sp.md),
        itemBuilder: (ctx, i) {
          final p = kVzPresets[i];
          return _PresetCard(
            preset: p,
            dark: dark,
            selected: p.id == currentId,
            onTap: () => vzt?.setPreset(p),
          );
        },
      ),
    );
  }
}

class _PresetCard extends StatefulWidget {
  final VzPreset preset;
  final bool dark, selected;
  final VoidCallback onTap;
  const _PresetCard({required this.preset, required this.dark,
    required this.selected, required this.onTap});
  @override State<_PresetCard> createState()=>_PresetCardState();
}
class _PresetCardState extends State<_PresetCard>{
  bool _down=false;
  @override Widget build(BuildContext context){
    final p = widget.preset;
    final dark = widget.dark;
    final bgGrad = dark ? p.bgGradientsDark : p.bgGradientsLight;
    final card = dark ? p.cardDark : p.cardLight;
    final border = dark ? p.borderDark : p.borderLight;
    final text = dark ? const Color(0xFFF5F5F7) : const Color(0xFF101014);
    final textDim = dark ? const Color(0xFFA1A1AA) : const Color(0xFF8E8E99);
    final accent = dark ? p.accentDark : p.accentLight;
    final accent2 = p.accent2;

    return GestureDetector(
      onTapDown: (_)=>setState(()=>_down=true),
      onTapUp: (_)=>setState(()=>_down=false),
      onTapCancel: ()=>setState(()=>_down=false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down?0.96:1.0,
        duration: Mo.press, curve: Mo.easeOut,
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          width: 138,
          padding: const EdgeInsets.all(Sp.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: bgGrad,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(Rad.s(Rad.md)),
            border: Border.all(
              color: widget.selected ? accent : border,
              width: widget.selected ? 2 : 1),
            boxShadow: widget.selected
              ? [BoxShadow(color: accent.withValues(alpha: 0.28),
                  blurRadius: 18, offset: const Offset(0, 6))]
              : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── پیش‌نمایش صفحه ──
            Expanded(child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: card.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(Rad.s(p.radiusScale*6)),
                border: Border.all(color: border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // نوار بالا
                Row(children: [
                  Container(width: 16, height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [accent, accent2]),
                      borderRadius: BorderRadius.circular(Rad.s(p.radiusScale*3))),
                  ),
                  const Spacer(),
                  Container(width: 20, height: 4,
                    decoration: BoxDecoration(color: border,
                      borderRadius: BorderRadius.circular(2))),
                ]),
                const SizedBox(height: 6),
                Container(width: 44, height: 5,
                  decoration: BoxDecoration(color: text.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 4),
                Container(width: 30, height: 4,
                  decoration: BoxDecoration(color: textDim.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2))),
                const Spacer(),
                // دو کارت کوچک با گردی پرسِت
                Row(children: [
                  for (var k = 0; k < 2; k++) ...[
                    if (k > 0) const SizedBox(width: 4),
                    Expanded(child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: k == 0
                          ? accent.withValues(alpha: 0.20)
                          : border.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(Rad.s(p.radiusScale*4)),
                        border: Border.all(
                          color: k == 0 ? accent.withValues(alpha: 0.6) : Colors.transparent),
                      ),
                    )),
                  ],
                ]),
                const SizedBox(height: 5),
                Container(height: 4,
                  decoration: BoxDecoration(
                    color: border.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2))),
              ]),
            )),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text(p.name, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800,
                  color: text))),
              Icon(
                switch (p.style) {
                  VzStyle.kawaii => Icons.favorite_rounded,
                  VzStyle.shonen => Icons.bolt_rounded,
                  VzStyle.mono   => Icons.circle_outlined,
                },
                size: 11, color: accent),
            ]),
            Text(p.tagline, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 8.5, color: textDim, height: 1.2)),
          ]),
        ),
      ),
    );
  }
}

/// انتخاب حالت بک‌گراند — گرادیان / تخت / خاموش
class VzBackgroundPicker extends StatelessWidget {
  const VzBackgroundPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = VzThemeScope.bgModeOf(context);
    final vzt = context.findAncestorStateOfType<VzThemeState>();
    final colors = Vz.bgGradientColors;

    return VzGlass(
      padding: const EdgeInsets.all(Sp.sm),
      child: Column(children: [
        // پیش‌نمایش تمام‌عرض گرادیان
        Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: Rad.r(Rad.sm),
            border: Border.all(color: Vz.border),
          ),
          child: Center(child: Icon(VzIcons.data('background'),
            color: Vz.accent, size: 22)),
        ),
        const SizedBox(height: Sp.sm),
        Row(children: [
          for (final (m, label) in [
            (VzBgMode.gradient, 'Gradient'),
            (VzBgMode.solid, 'Flat'),
            (VzBgMode.off, 'Off'),
          ]) ...[
            Expanded(child: _btn(context, vzt, mode, m, label)),
            if (m != VzBgMode.off) const SizedBox(width: Sp.sm),
          ],
        ]),
      ]),
    );
  }

  Widget _btn(BuildContext context, VzThemeState? vzt, VzBgMode mode,
      VzBgMode target, String label) {
    final selected = mode == target;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: Rad.r(Rad.xs),
        onTap: () => vzt?.setBgMode(target),
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Vz.accent.withValues(alpha: 0.14) : Vz.cardHi,
            borderRadius: Rad.r(Rad.xs),
            border: Border.all(color: selected ? Vz.accent : Vz.border),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w700,
            color: selected ? Vz.accent : Vz.textSec)),
        ),
      ),
    );
  }
}

/// انتخابگر رنگ اکسنت — «خودِ پرسِت» + پالت‌های آماده.
class VzAccentPicker extends StatefulWidget {
  const VzAccentPicker({super.key});
  @override State<VzAccentPicker> createState() => _VzAccentPickerState();
}

class _VzAccentPickerState extends State<VzAccentPicker> {
  @override
  Widget build(BuildContext context) {
    final current = VzThemeScope.accentIndexOf(context);
    final vzt = context.findAncestorStateOfType<VzThemeState>();
    final dark = Vz.isDark;

    return VzGlass(
      padding: const EdgeInsets.symmetric(vertical: Sp.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md),
          child: Row(children: [
            Icon(VzIcons.data('palette'), size: 18, color: Vz.accent),
            const SizedBox(width: Sp.sm),
            Expanded(child: Text(
              current < 0 ? L.accentColor : kVzAccents[current].name,
              style: Ty.label.copyWith(fontSize: 13))),
            _dot(Vz.bg), const SizedBox(width: 3),
            _dot(Vz.card), const SizedBox(width: 3),
            _dot(Vz.accent), const SizedBox(width: 3),
            _dot(Vz.accentHi),
          ]),
        ),
        const SizedBox(height: Sp.md),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Sp.md),
            itemCount: kVzAccents.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: Sp.sm),
            itemBuilder: (ctx, i) {
              // i == 0 → رنگ خودِ پرسِت
              if (i == 0) {
                final selected = current < 0;
                return _swatch(
                  c: Vz.preset.accentDark,
                  hi: dark ? Vz.preset.accentDarkHi : Vz.preset.accentLightHi,
                  selected: selected,
                  label: 'Preset',
                  onTap: () => vzt?.setAccent(-1),
                );
              }
              final a = kVzAccents[i - 1];
              final c = dark ? a.dark : a.light;
              final hi = dark ? a.darkHi : a.lightHi;
              final selected = (i - 1) == current;
              return _swatch(
                c: c, hi: hi, selected: selected, label: a.name,
                onTap: () => vzt?.setAccent(i - 1),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _swatch({
    required Color c, required Color hi, required bool selected,
    required String label, required VoidCallback onTap,
  }) => Semantics(
    selected: selected, button: true, label: label,
    container: true, excludeSemantics: true, onTap: onTap,
    child: Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(Rad.full),
        onTap: onTap,
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [hi, c],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Vz.text : Vz.border,
              width: selected ? 2.5 : 1),
          ),
          child: selected
            ? Icon(VzIcons.data('check'), size: 21,
                color: c.computeLuminance() > 0.55
                  ? const Color(0xFF0C0C0F) : Colors.white)
            : null,
        ),
      ),
    ),
  );

  Widget _dot(Color c) => Container(
    width: 14, height: 14,
    decoration: BoxDecoration(
      color: c, shape: BoxShape.circle,
      border: Border.all(color: Vz.border, width: 1)),
  );
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

/// انتخاب حالت روشن/تیره/سیستم
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
          VzIcons.data('dark'), L.themeDark)),
        const SizedBox(width: Sp.xs),
        Expanded(child: _item(context, vzt, mode, VzThemeMode.light,
          VzIcons.data('light'), L.themeLight)),
        const SizedBox(width: Sp.xs),
        Expanded(child: _item(context, vzt, mode, VzThemeMode.system,
          VzIcons.data('auto'), L.themeSystem)),
      ]),
    );
  }

  Widget _item(BuildContext context, VzThemeState? vzt, VzThemeMode mode,
      VzThemeMode target, IconData icon, String label) {
    final selected = mode == target;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: Rad.r(Rad.xs),
        onTap: () => vzt?.setMode(target),
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Vz.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: Rad.r(Rad.xs),
            border: Border.all(color: selected ? Vz.accent : Vz.border),
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

/// ردیف استاندارد VOID — آیکون + عنوان + زیرعنوان + کنترل
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
          Icon(VzIcons.data('chevron-right'), size: 19, color: Vz.textDim),
      ]),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
