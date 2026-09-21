// lib/settings_screen.dart — تنظیمات: تم، پس‌زمینه، رنگ دانه، انیمیشن، ابزارها
//
// موتور تم به سبک Namida: کاربر یک **تم آماده** برمی‌گزیند یا یک **رنگ دانه**
// دلخواه می‌دهد؛ کل پالت (سطح، متن، اکسنت) از همان ساخته می‌شود.
import 'package:flutter/material.dart';
import 'settings.dart' show ToolsTabBody;
import 'ai_models_screen.dart';
import 'vosk_models_screen.dart';
import 'glass.dart';
import 'l10n.dart';
import 'api_service.dart';
import 'theme.dart';
import 'vz_icons.dart';
import 'vz_tapfx.dart';
import 'vz_color_wheel.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState()=>_SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  @override void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final t = Vz.theme;
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
                Text('${t.name} • v${ApiService.appVersion}',
                  style: Ty.overline.copyWith(color: Vz.accent)),
              ])),
            const _ThemeOrb(),
          ]),
          const SizedBox(height: Sp.sm),

          // ── تم‌ها ──
          VzSectionHeader(title: L.theme),
          const VzThemeGallery(),

          // ── رنگ دانه ──
          VzSectionHeader(title: L.accentColor),
          const VzSeedPicker(),

          // ── پس‌زمینه ──
          VzSectionHeader(title: L.background),
          const VzBgPicker(),

          // ── حالت + انیمیشن ──
          VzSectionHeader(title: L.appearance),
          const VzModePicker(),
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
                    .findAncestorStateOfType<VzThemeState>()?.setAnimations(v),
              ),
            ),
          ),
          const SizedBox(height: Sp.sm),
          // ── انیمیشن لمس (کلیک) ──
          VzGlass(
            padding: EdgeInsets.zero,
            child: Column(children: [
              VzRow(
                icon: VzIcons.data('gesture'),
                title: L.touchFx,
                subtitle: L.touchFxDesc,
                accent: Vz.accent,
                trailing: Switch(
                  value: VzThemeScope.clickEnabledOf(context),
                  onChanged: (v) => context
                      .findAncestorStateOfType<VzThemeState>()?.setClickEnabled(v),
                ),
              ),
              if (VzThemeScope.clickEnabledOf(context)) ...[
                const Divider(height: 1, indent: 56),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.md, Sp.sm, Sp.md, Sp.md),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(L.touchFxStyle,
                      style: Ty.caption.copyWith(color: Vz.textSec)),
                    const SizedBox(height: Sp.sm),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final s in VzClickStyle.values)
                        _ClickStyleChip(
                          style: s,
                          selected: VzThemeScope.clickStyleOf(context) == s,
                          onTap: () => context
                              .findAncestorStateOfType<VzThemeState>()?.setClickStyle(s),
                        ),
                    ]),
                  ]),
                ),
              ],
            ]),
          ),

          const SizedBox(height: Sp.sm),
          // ── حباب لمسی (۲۰ مدل + رنگ/اندازه/سرعت) ──
          const _BubbleSettings(),

          // ── ابزارها ──
          VzSectionHeader(title: L.toolsSection),
          const VzGlass(
            padding: EdgeInsets.all(Sp.md),
            child: ToolsTabBody(),
          ),

          // ── مدل‌های AI ──
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

          // ── زبان ──
          VzSectionHeader(title: L.language),
          const VzGlass(
            padding: EdgeInsets.all(Sp.md),
            child: _LangPicker(),
          ),

          // ── درباره ──
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
                  gradient: Vz.accentGrad, borderRadius: Rad.r(Rad.xs)),
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
            VzRow(icon: VzIcons.data('update'), title: L.updateAvailable,
              accent: Vz.accent,
              onTap: ()async{
                final url = cfg['download_url'] ?? '';
                if(url.isNotEmpty) await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
              }),
          ],
          if (channel.isNotEmpty) ...[
            const Divider(height: 1),
            VzRow(icon: VzIcons.data('telegram'), title: L.telegramChannel,
              onTap: ()=>launchUrl(Uri.parse(channel),
                mode: LaunchMode.externalApplication)),
          ],
          if (admin.isNotEmpty) ...[
            const Divider(height: 1),
            VzRow(icon: VzIcons.data('bug'),
              title: cfg['report_text'] ?? L.reportBug,
              onTap: ()=>launchUrl(Uri.parse(admin),
                mode: LaunchMode.externalApplication)),
          ],
        ]),
      );
    });
}

/// کره‌ی هدر — رنگ و گردی‌اش از تم فعال.
class _ThemeOrb extends StatefulWidget {
  const _ThemeOrb();
  @override State<_ThemeOrb> createState()=>_ThemeOrbState();
}

class _ThemeOrbState extends State<_ThemeOrb> with SingleTickerProviderStateMixin{
  AnimationController? _c;
  @override void initState(){
    super.initState();
    if(Vz.animations){
      _c=AnimationController(vsync:this,duration:const Duration(seconds:6))
        ..repeat(reverse:true);
    }
  }
  @override void didChangeDependencies(){
    super.didChangeDependencies();
    if(Vz.animations && _c==null){
      _c=AnimationController(vsync:this,duration:const Duration(seconds:6))
        ..repeat(reverse:true);
    } else if(!Vz.animations && _c!=null){
      _c!.dispose(); _c=null;
    }
  }
  @override void dispose(){_c?.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final size = 44.0 * (0.9 + Vz.radiusScale*0.10);
    final child = Container(
      width:size,height:size,
      decoration:BoxDecoration(
        gradient:Vz.auroraGrad,
        borderRadius:Rad.r(Rad.xs),
        boxShadow:[Vz.glowSoft],
      ),
    );
    final c=_c;
    if(c==null) return child;
    return AnimatedBuilder(animation:c,builder:(ctx,_){
      final t=Curves.easeInOut.transform(c.value);
      return Transform.rotate(angle:(t-0.5)*0.18,
        child:Transform.scale(scale:0.96+t*0.08,child:child));
    });
  }
}

/// گالری تم‌های آماده — پیش‌نمایش زنده از پالت هر تم.
class VzThemeGallery extends StatelessWidget {
  const VzThemeGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final currentId = VzThemeScope.themeIdOf(context);
    final vzt = context.findAncestorStateOfType<VzThemeState>();
    final dark = Vz.isDark;

    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: kVzThemes.length,
        separatorBuilder: (_, __) => const SizedBox(width: Sp.md),
itemBuilder: (ctx, i) {

          final t = kVzThemes[i];
          return _ThemeCard(
            def: t, dark: dark,
            selected: t.id == currentId,
            onTap: () => vzt?.setTheme(t),
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatefulWidget {
  final VzThemeDef def;
  final bool dark, selected;
  final VoidCallback onTap;
  const _ThemeCard({required this.def, required this.dark,
    required this.selected, required this.onTap});
  @override State<_ThemeCard> createState()=>_ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard>{
  bool _down=false;
  @override Widget build(BuildContext context){
    final d = widget.def;
    // پالت واقعی همین تم را می‌سازیم تا پیش‌نمایش دقیق باشد
    final p = vzBuildPalette(d.seed, dark: widget.dark);
    final grad = vzBackground(p, d.bg);
    final radius = Rad.s(d.radiusScale * 6);

    return GestureDetector(
      onTapDown: (_)=>setState(()=>_down=true),
      onTapUp: (_)=>setState(()=>_down=false),
      onTapCancel: ()=>setState(()=>_down=false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down?0.96:1.0, duration: Mo.press, curve: Mo.easeOut,
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          width: 142,
          padding: const EdgeInsets.all(Sp.sm),
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: BorderRadius.circular(Rad.s(Rad.md)),
            border: Border.all(
              color: widget.selected ? p.accent : p.border,
              width: widget.selected ? 2 : 1),
            boxShadow: widget.selected
              ? [BoxShadow(color: p.accent.withValues(alpha: 0.30),
                  blurRadius: 18, offset: const Offset(0, 6))]
              : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── پیش‌نمایش صفحه ──
            Expanded(child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: p.card.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: p.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 16, height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [p.accent, p.accentHi]),
                      borderRadius: BorderRadius.circular(Rad.s(d.radiusScale*3)))),
                  const Spacer(),
                  Container(width: 20, height: 4,
                    decoration: BoxDecoration(color: p.border,
                      borderRadius: BorderRadius.circular(2))),
                ]),
                const SizedBox(height: 6),
                Container(width: 46, height: 5,
                  decoration: BoxDecoration(color: p.text.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 4),
                Container(width: 30, height: 4,
                  decoration: BoxDecoration(color: p.textDim.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2))),
                const Spacer(),
                Row(children: [
                  for (var k = 0; k < 2; k++) ...[
                    if (k > 0) const SizedBox(width: 4),
                    Expanded(child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: k == 0 ? p.accentSoft : p.border.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(Rad.s(d.radiusScale*4)),
                        border: Border.all(
                          color: k == 0 ? p.accent.withValues(alpha: 0.6) : Colors.transparent),
                      ),
                    )),
                  ],
                ]),
                const SizedBox(height: 5),
                Container(height: 4, decoration: BoxDecoration(
                  color: p.border.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2))),
              ]),
            )),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: Text(d.name, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800,
                  color: p.text))),
              Icon(VzIcons.data('sparkle'), size: 11, color: p.accent),
            ]),
            Text(d.tagline, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 8.5, color: p.textDim, height: 1.2)),
          ]),
        ),
      ),
    );
  }
}

/// انتخاب رنگ دانه — چند رنگ آماده + چرخ رنگ کامل.
class VzSeedPicker extends StatelessWidget {
  const VzSeedPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vzt = context.findAncestorStateOfType<VzThemeState>();
    final custom = VzThemeScope.customSeedOf(context);
    final dynamic_ = VzThemeScope.dynamicSeedOf(context);

    return VzGlass(
      padding: const EdgeInsets.symmetric(vertical: Sp.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md),
          child: Row(children: [
            Icon(VzIcons.data('palette'), size: 18, color: Vz.accent),
            const SizedBox(width: Sp.sm),
            Expanded(child: Text(
              custom != null
                ? 'Custom'
                : (dynamic_ != null ? 'From artwork' : 'Theme color'),
              style: Ty.label.copyWith(fontSize: 13))),
            if (custom != null)
              GestureDetector(
                onTap: ()=>vzt?.clearCustomSeed(),
                child: Icon(VzIcons.data('refresh'), size: 16, color: Vz.textDim)),
            const SizedBox(width: Sp.sm),
            _dot(Vz.bg), const SizedBox(width: 3),
            _dot(Vz.card), const SizedBox(width: 3),
            _dot(Vz.accent), const SizedBox(width: 3),
            _dot(Vz.accentHi),
          ]),
        ),
        const SizedBox(height: Sp.md),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Sp.md),
            itemCount: kVzSeeds.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: Sp.sm),
itemBuilder: (ctx, i) {

              // آخرین آیتم: چرخ رنگ دلخواه
              if (i == kVzSeeds.length) {
                return _CustomSeedSwatch(
                  color: custom,
                  selected: custom != null,
                  onTap: () async {
                    final picked = await showVzColorPicker(
                      context, initial: custom ?? Vz.accent);
                    if (picked != null) await vzt?.setCustomSeed(picked);
                  },
                );
              }
              final s = kVzSeeds[i];
              final selected = custom != null && custom.toARGB32() == s.toARGB32();
              return GestureDetector(
                onTap: ()=>vzt?.setCustomSeed(s),
                child: AnimatedContainer(
                  duration: Mo.fast, curve: Mo.easeOut,
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: s, shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Vz.text : Vz.border,
                      width: selected ? 2.5 : 1)),
                  child: selected
                    ? Icon(VzIcons.data('check'),
                        size: 20, color: vzOnColor(s))
                    : null,
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _dot(Color c) => Container(
    width: 14, height: 14,
    decoration: BoxDecoration(
      color: c, shape: BoxShape.circle,
      border: Border.all(color: Vz.border, width: 1)));
}

/// سواچ چرخ رنگ برای رنگ دلخواه.
class _CustomSeedSwatch extends StatelessWidget {
  final Color? color;
  final bool selected;
  final VoidCallback onTap;
  const _CustomSeedSwatch({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected, button: true, label: 'Custom color',
    container: true, excludeSemantics: true, onTap: onTap,
    child: Tooltip(
      message: 'Custom color',
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color,
            gradient: color == null
              ? const SweepGradient(colors: [
                  Color(0xFFFF0000), Color(0xFFFFFF00), Color(0xFF00FF00),
                  Color(0xFF00FFFF), Color(0xFF0000FF), Color(0xFFFF00FF),
                  Color(0xFFFF0000)])
              : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Vz.text : Vz.border,
              width: selected ? 2.5 : 1)),
          child: Center(child: Icon(
            selected ? VzIcons.data('check') : VzIcons.data('palette'),
            size: 20,
            color: selected ? vzOnColor(color ?? Vz.accent) : Colors.white)),
        ),
      ),
    ),
  );
}

/// انتخاب سبک پس‌زمینه.
class VzBgPicker extends StatelessWidget {
  const VzBgPicker({super.key});

  static const _styles = [
    (VzBgStyle.flat,  'Flat',  Icons.crop_square_rounded),
    (VzBgStyle.soft,  'Soft',  Icons.gradient_rounded),
    (VzBgStyle.glow,  'Glow',  Icons.blur_on_rounded),
    (VzBgStyle.vivid, 'Vivid', Icons.local_fire_department_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final style = VzThemeScope.bgStyleOf(context);
    final vzt = context.findAncestorStateOfType<VzThemeState>();

    return VzGlass(
      padding: const EdgeInsets.all(Sp.sm),
      child: Column(children: [
        // پیش‌نمایش بزرگ
        AnimatedContainer(
          duration: Mo.normal,
          height: 66,
          decoration: BoxDecoration(
            gradient: Vz.bgGradient,
            borderRadius: Rad.r(Rad.sm),
            border: Border.all(color: Vz.border)),
          child: Center(child: VzBreathing(
            amount: 0.05,
            child: Icon(VzIcons.data('background'), color: Vz.accent, size: 24))),
        ),
        const SizedBox(height: Sp.md),
        Row(children: [
          for (var i = 0; i < _styles.length; i++) ...[
            if (i > 0) const SizedBox(width: Sp.sm),
            Expanded(child: _btn(vzt, style, _styles[i].$1, _styles[i].$2, _styles[i].$3)),
          ],
        ]),
      ]),
    );
  }

  Widget _btn(VzThemeState? vzt, VzBgStyle current, VzBgStyle target,
      String label, IconData icon) {
    final selected = current == target;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: Rad.r(Rad.xs),
        onTap: () => vzt?.setBgStyle(target),
        child: AnimatedContainer(
          duration: Mo.fast, curve: Mo.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Vz.accentSoft : Vz.cardHi,
            borderRadius: Rad.r(Rad.xs),
            border: Border.all(color: selected ? Vz.accent : Vz.border)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 17, color: selected ? Vz.accent : Vz.textDim),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700,
              color: selected ? Vz.accent : Vz.textSec)),
          ]),
        ),
      ),
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

/// انتخاب حالت روشن/تیره/سیستم.
class VzModePicker extends StatelessWidget {
  const VzModePicker({super.key});

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
            color: selected ? Vz.accentSoft : Colors.transparent,
            borderRadius: Rad.r(Rad.xs),
            border: Border.all(color: selected ? Vz.accent : Vz.border)),
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

/// ردیف استاندارد — آیکون + عنوان + زیرعنوان + کنترل.
class VzRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? accent;
  final VoidCallback? onTap;
  const VzRow({
    super.key, required this.icon, required this.title,
    this.subtitle, this.trailing, this.accent, this.onTap,
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
    return VzTappable(onTap: onTap, radius: Rad.r(Rad.md), child: row);
  }
}

class _ClickStyleChip extends StatelessWidget {
  final VzClickStyle style;
  final bool selected;
  final VoidCallback onTap;
  const _ClickStyleChip({
    required this.style, required this.selected, required this.onTap,
  });

  IconData get _icon => switch (style) {
    VzClickStyle.ripple => Icons.waves_rounded,
    VzClickStyle.spring => Icons.compress_rounded,
    VzClickStyle.lift   => Icons.arrow_upward_rounded,
    VzClickStyle.glow   => Icons.blur_on_rounded,
    VzClickStyle.none   => Icons.block_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return VzTappable(
      onTap: onTap,
      radius: Rad.r(Rad.sm),
      child: AnimatedContainer(
        duration: Mo.fast, curve: Mo.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Vz.accentSoft : Vz.cardHi,
          borderRadius: Rad.r(Rad.sm),
          border: Border.all(
            color: selected ? Vz.accent : Vz.border,
            width: selected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_icon, size: 15, color: selected ? Vz.accent : Vz.textSec),
          const SizedBox(width: 6),
          Text(style.label, style: Ty.caption.copyWith(
            color: selected ? Vz.accent : Vz.text,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
//  _BubbleSettings — تنظیمات کامل حباب لمسی (۲۰ مدل + رنگ + اندازه + سرعت)
// ─────────────────────────────────────────────────────────────────────────────
class _BubbleSettings extends StatelessWidget {
  const _BubbleSettings();

  static const _swatch = <Color?>[
    null, // اکسنت تم
    Color(0xFFFFFFFF), Color(0xFF000000),
    Color(0xFFFF5A5F), Color(0xFFFF9F43), Color(0xFFFFD93D),
    Color(0xFF6BCB77), Color(0xFF00D2D3), Color(0xFF4D96FF),
    Color(0xFF9B59B6), Color(0xFFFF6BCB),
  ];

  @override
  Widget build(BuildContext context) {
    final vzt = context.findAncestorStateOfType<VzThemeState>();
    final on = VzThemeScope.bubbleOnOf(context);

    return VzGlass(
      padding: EdgeInsets.zero,
      child: Column(children: [
        VzRow(
          icon: VzIcons.data('background'),
          title: L.bubble,
          subtitle: L.bubbleDesc,
          accent: Vz.accent,
          trailing: Switch(
            value: on,
            onChanged: (v) => vzt?.setBubbleOn(v),
          ),
        ),
        if (on) ...[
          const Divider(height: 1, indent: 56),

          // ── انتخاب طرح (۱۰۰ طرح در شیت کشویی) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.md),
            child: VzTappable(
              radius: Rad.r(Rad.sm),
              onTap: () async {
                final picked = await showVzTapFxPicker(context,
                  current: VzThemeScope.tapFxOf(context));
                if (picked != null) await vzt?.setTapFx(picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 12),
                decoration: BoxDecoration(
                  color: Vz.cardHi,
                  borderRadius: Rad.r(Rad.sm),
                  border: Border.all(color: Vz.border)),
                child: Row(children: [
                  Icon(VzIcons.data('gesture'), size: 18, color: Vz.accent),
                  const SizedBox(width: Sp.sm),
                  Expanded(child: Text('انتخاب طرح ( طرح)',
                    style: Ty.label)),
                  Text(VzTapFx.all[VzThemeScope.tapFxOf(context).clamp(0, 99)].name,
                    style: Ty.caption.copyWith(color: Vz.textSec)),
                  const SizedBox(width: 6),
                  Icon(VzIcons.data('chevron-right'), size: 16, color: Vz.textDim),
                ]),
              ),
            ),
          ),
          // ── رنگ ──
          const SizedBox(height: Sp.sm),
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.md, 0, Sp.md, 4),
            child: Align(alignment: AlignmentDirectional.centerStart,
              child: Text(L.bubbleColor,
                style: Ty.caption.copyWith(color: Vz.textSec))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.md),
            child: Row(children: [
              for (final c in _swatch) ...[
                _Swatch(
                  color: c ?? Vz.accent,
                  selected: (VzThemeScope.bubbleColorOf(context) ?? Vz.accent) ==
                      (c ?? Vz.accent),
                  auto: c == null,
                  onTap: () => vzt?.setBubbleColor(c),
                ),
                const SizedBox(width: 7),
              ],
            ]),
          ),

          // ── اندازه ──
          const SizedBox(height: Sp.sm),
          _Slider(
            label: L.bubbleSize,
            value: VzThemeScope.bubbleSizeOf(context),
            min: 0.5, max: 2.0,
            onChange: (v) => vzt?.setBubbleSize(v),
          ),

          // ── سرعت ──
          _Slider(
            label: L.bubbleSpeed,
            value: VzThemeScope.bubbleSpeedOf(context),
            min: 0.5, max: 2.0,
            onChange: (v) => vzt?.setBubbleSpeed(v),
          ),
          const SizedBox(height: Sp.sm),
        ],
      ]),
    );
  }
}


class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final bool auto;
  final VoidCallback onTap;
  const _Swatch({
    required this.color, required this.selected,
    required this.onTap, this.auto = false,
  });

  @override
  Widget build(BuildContext context) {
    return VzTappable(
      onTap: onTap,
      radius: Rad.r(Rad.full),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Vz.text : Vz.border,
            width: selected ? 2.5 : 1),
        ),
        child: auto
          ? Icon(Icons.auto_awesome_rounded, size: 14,
              color: Vz.onAccent)
          : (selected
              ? Icon(Icons.check_rounded, size: 15, color: Colors.white)
              : null),
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChange;
  const _Slider({
    required this.label, required this.value,
    required this.min, required this.max, required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md),
      child: Row(children: [
        SizedBox(width: 74, child: Text(label,
          style: Ty.caption.copyWith(color: Vz.textSec))),
        Expanded(child: Slider(
          value: value.clamp(min, max), min: min, max: max,
          activeColor: Vz.accent,
          onChanged: onChange,
        )),
        SizedBox(width: 34, child: Text(value.toStringAsFixed(1),
          textAlign: TextAlign.end,
          style: Ty.caption.copyWith(color: Vz.text))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  انتخابگر طرح لمس — شیت کشویی با ۱۰۰ طرح و پیشنمایش زنده
// ─────────────────────────────────────────────────────────────────────────────

/// شیت کشویی: شبکه‌ی ۱۰۰ طرح با پیشنمایش انیمیتشده. طرح انتخابی را
/// برمی‌گرداند (ایندکس) یا null اگر کاربر فقط بست.
Future<int?> showVzTapFxPicker(BuildContext context, {required int current}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Vz.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => _TapFxPickerSheet(current: current),
  );
}

class _TapFxPickerSheet extends StatefulWidget {
  final int current;
  const _TapFxPickerSheet({required this.current});
  @override State<_TapFxPickerSheet> createState() => _TapFxPickerSheetState();
}

class _TapFxPickerSheetState extends State<_TapFxPickerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  late int _sel = 0;
  String? _family = VzTapFx.all[widget.current.clamp(0, 99)].family;

  @override void initState() { super.initState(); _sel = widget.current; }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(children: [
        const SizedBox(height: 12),
        const Center(child: VzSheetHandle()),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md),
          child: Row(children: [
            Text('انتخاب طرح لمس', style: Ty.heading),
            const Spacer(),
            IconButton(
              icon: Icon(VzIcons.data('close'), size: 20, color: Vz.textSec),
              onPressed: () => Navigator.pop(context)),
          ]),
        ),
        // فیلتر خانواده
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Sp.md),
            children: [
              _famChip(null, 'همه'),
              for (final f in VzTapFx.families) _famChip(f, VzTapFx.familyLabels[f] ?? f),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: AnimatedBuilder(
            animation: _c,
        builder: (ctx, _) {
          final items = <int>[
            for (var i = 0; i < VzTapFx.all.length; i++)
              if (_family == null || VzTapFx.all[i].family == _family) i,
          ];
          return GridView.builder(
              padding: const EdgeInsets.all(Sp.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemCount: items.length,
              itemBuilder: (ctx, idx) {
                final i = items[idx];
                final fx = VzTapFx.all[i];
                return _FxTile(
                  fx: fx, selected: i == _sel, t: _c.value,
                  onTap: () { setState(() => _sel = i); Navigator.pop(context, i); },
                );
              },
            ),
          );
        },
      ),
        ),
      ]),
    );
  }

  Widget _famChip(String? fam, String label) {
    final sel = _family == fam;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: VzTappable(
        onTap: () => setState(() => _family = fam),
        radius: Rad.r(Rad.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? Vz.accentSoft : Vz.cardHi,
            borderRadius: Rad.r(Rad.full),
            border: Border.all(color: sel ? Vz.accent : Vz.border)),
          child: Text(label, style: Ty.caption.copyWith(
            color: sel ? Vz.accent : Vz.textSec)),
        ),
      ),
    );
  }
}

class _FxTile extends StatelessWidget {
  final VzTapFx fx;
  final bool selected;
  final double t;
  final VoidCallback onTap;
  const _FxTile({
    required this.fx, required this.selected, required this.t, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Vz.card,
          borderRadius: Rad.r(Rad.sm),
          border: Border.all(
            color: selected ? Vz.accent : Vz.border,
            width: selected ? 2 : 1)),
        child: Column(children: [
          Expanded(
            child: CustomPaint(
              painter: VzTapFxPainter(
                origin: const Offset(40, 30), t: (t * 1.4) % 1.0,
                fx: fx, color: Vz.accent, scale: 0.42),
              child: const SizedBox.expand(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(fx.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: Ty.caption.copyWith(
                fontSize: 9,
                color: selected ? Vz.accent : Vz.textSec)),
          ),
        ]),
      ),
    );
  }
}
