// test/nova_design_system_test.dart — تست Design System NOVA
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/theme.dart';
import 'package:player/glass.dart';
import 'package:player/vz_presets.dart';
import 'package:player/vz_icons.dart';

void main() {
  // تست‌های ویجت با انیمیشن‌های بی‌نهایت (نفس‌کشیدن داک) هرگز settle نمی‌شوند،
  // مگر انیمیشن‌ها خاموش باشند — که دقیقاً همان حالتی است که کاربر هم
  // می‌تواند از تنظیمات انتخاب کند. قبل از هر تست خاموش، بعد آزاد می‌کنیم.
  setUp(() => Vz.previewAnimations(false));
  tearDown(() => Vz.previewAnimations(true));

  group('NOVA Design System — Tokens', () {
    test('Color palette — VOID', () {
      // رنگ‌های پایه از پرسِت فعال خوانده می‌شوند (نه هاردکد).
      final p = Vz.preset;
      expect(Vz.bg.toARGB32(), equals(p.bgDark.toARGB32()));
      expect(Vz.bgDeep.toARGB32(), equals(p.bgDeepDark.toARGB32()));
      expect(Vz.surface.toARGB32(), equals(p.surfaceDark.toARGB32()));
      expect(Vz.card.toARGB32(), equals(p.cardDark.toARGB32()));
      expect(Vz.cardHi.toARGB32(), equals(p.cardHiDark.toARGB32()));
      expect(Vz.border.toARGB32(), equals(p.borderDark.toARGB32()));
      // پالت تیره نیست اگه با کارت یکسان باشه
      expect(Vz.bg, isNot(equals(Vz.card)));
      // اکسنت پیش‌فرض = رنگ خودِ پرسِت
      expect(Vz.accentIndex, equals(-1));
      expect(Vz.accent.toARGB32(), equals(p.accentDark.toARGB32()));
      expect(Vz.accentHi.toARGB32(), equals(p.accentDarkHi.toARGB32()));
      expect(Vz.deep.toARGB32(), equals(p.accentDarkDeep.toARGB32()));
      // رنگ‌های semantic بین پرسِت‌ها ثابت‌اند
      expect(Vz.magenta.toARGB32(), equals(0xFFFB7185));
      expect(Vz.green.toARGB32(), equals(0xFF4ADE80));
      expect(Vz.amber.toARGB32(), equals(0xFFFBBF24));
      expect(Vz.red.toARGB32(), equals(0xFFF87171));
      expect(Vz.text.toARGB32(), equals(0xFFF5F5F7));
    });

    test('Typography scale — sizes & weights', () {
      expect(Ty.display.fontSize, 28);
      expect(Ty.display.fontWeight, FontWeight.w800);
      expect(Ty.title.fontSize, 20);
      expect(Ty.title.fontWeight, FontWeight.w700);
      expect(Ty.heading.fontSize, 16);
      expect(Ty.body.fontSize, 14);
      expect(Ty.label.fontSize, 12);
      expect(Ty.caption.fontSize, 11);
      expect(Ty.overline.fontSize, 10);
      expect(Ty.mono.fontFeatures, isNotNull);
    });

    test('Spacing — ۴pt scale', () {
      expect(Sp.xs, 4.0); expect(Sp.sm, 8.0);
      expect(Sp.md, 12.0); expect(Sp.lg, 16.0);
      expect(Sp.xl, 20.0); expect(Sp.xxl, 24.0);
      expect(Sp.xxxl, 32.0); expect(Sp.giant, 56.0);
    });

    test('Shape radius system', () {
      expect(Rad.xs, 10.0); expect(Rad.sm, 14.0);
      expect(Rad.md, 18.0); expect(Rad.lg, 24.0);
      expect(Rad.xl, 28.0); expect(Rad.full, 999.0);
    });

    test('Accent gradient — follows selected accent, 3 stops', () {
      expect(Vz.auroraGrad.colors.length, 3);
      expect(Vz.auroraGrad.colors.first, Vz.accentHi);
      expect(Vz.auroraGrad.colors.last, Vz.deep);
    });

    test('Presets are complete — palette, gradient, radius', () {
      expect(kVzPresets.length, greaterThanOrEqualTo(8));
      for (final p in kVzPresets) {
        expect(p.id, isNotEmpty);
        expect(p.name, isNotEmpty);
        expect(p.bgGradientsDark.length, greaterThanOrEqualTo(2));
        expect(p.bgGradientsLight.length, greaterThanOrEqualTo(2));
        // هر پرسِت باید هر سه لایه‌ی رنگ را داشته باشد و از هم متفاوت باشند
        expect(p.bgDark, isNot(equals(p.cardDark)));
        expect(p.bgLight, isNot(equals(p.cardLight)));
        expect(p.radiusScale, greaterThan(0));
      }
      // هر سه سبک موجود باشد — از جمله سبک انیمه (Bilibili/Gainax)
      expect(kVzPresets.any((p) => p.style == VzStyle.kawaii), isTrue);
      expect(kVzPresets.any((p) => p.style == VzStyle.shonen), isTrue);
      expect(kVzPresets.any((p) => p.style == VzStyle.anime), isTrue);
      // Bilibili اولین پرسِت گالری است (سمت چپ)
      expect(kVzPresets.first.id, equals('bilibili'));
    });

    test('Light preset surfaces are actually light', () {
      for (final p in kVzPresets) {
        // bg روشن باید روشنایی بالا داشته باشد (باگ قبلی: تم روشن خاکستری بود)
        expect(p.bgLight.computeLuminance(), greaterThan(0.75),
            reason: 'بک‌گراند روشن پرسِت ');
        expect(p.cardLight.computeLuminance(), greaterThan(0.85),
            reason: 'کارت روشن پرسِت ');
        // و متن تیره و خوانا باشد
        expect(p.borderLight.computeLuminance(), greaterThan(0.5));
      }
    });
    test('Accent palette is complete and readable', () {
      expect(kVzAccents.length, greaterThanOrEqualTo(8));
      for (final a in kVzAccents) {
        expect(a.name, isNotEmpty);
      }
      // متنِ روی اکسنت یا تیره است یا سفید — نه چیزی بین‌راه
      final on = Vz.onAccent;
      expect(on == Colors.white || on == const Color(0xFF0C0C0F), isTrue);
    });
    test('Scrim tokens + scrimGrad — media thumbnail overlay', () {
      // رگرسیون: scrim* باید در پالت runtime موجود باشد (قبلاً undefined بود)
      expect(Vz.scrimTop.toARGB32(), equals(0x000A0A0C));
      expect(Vz.scrimMid.toARGB32(), equals(0x800A0A0C));
      expect(Vz.scrimBot.toARGB32(), equals(0xE60A0A0C));
      expect(Vz.scrimGrad.colors, hasLength(3));
      expect(Vz.scrimGrad.colors.first, equals(Vz.scrimBot));
      expect(Vz.scrimGrad.colors.last, equals(Vz.scrimTop));
      expect(Vz.scrimGrad.stops, equals(const [0.0, 0.45, 1.0]));
    });

    test('Theme — dark, Material 3, preset colors', () {
      final theme = buildVezooTheme();
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, Vz.accent);
      expect(theme.colorScheme.surface, Vz.surface);
      // در حالت flat، scaffold رنگ پایه می‌گیرد؛ وگرنه شفاف است تا
      // بک‌گراند گرادیانی از پشت دیده شود.
      if (Vz.bgStyle == VzBgStyle.flat) {
        expect(theme.scaffoldBackgroundColor, Vz.bg);
      } else {
        expect(theme.scaffoldBackgroundColor, Colors.transparent);
      }
      expect(theme.bottomSheetTheme.backgroundColor, Vz.surface);
    });
  });

  group('NOVA Components — widget tests', () {
    testWidgets('VzEmpty renders icon, title, hint and CTA', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: const Scaffold(body: VzEmpty(
          icon: Icons.movie_rounded,
          title: 'No files found',
          hint: 'Open a folder to browse',
          ctaLabel: 'Browse',
        )),
      ));
      expect(find.text('No files found'), findsOneWidget);
      expect(find.text('Open a folder to browse'), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
      await tester.tap(find.text('Browse'));
      await tester.pump();
      expect(tapped, isFalse); // بدون onCta هیچ اتفاقی نمی‌افتد
    });

    testWidgets('VzChip selected state uses accent color', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: const Scaffold(body: Center(child: VzChip(
          label: 'History', icon: Icons.history_rounded, selected: true,
        ))),
      ));
      expect(find.text('History'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('VzIconBadge — const-safe + default color = accent', (tester) async {
      // رگرسیون: default قبلی `Vz.accent` در const constructor خطای compile می‌داد
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: const Scaffold(body: Center(child: VzIconBadge(icon: Icons.star_rounded))),
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.star_rounded));
      expect(icon.color, equals(Vz.accent));
    });

    testWidgets('VzMediaCard renders title, duration badge', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: Scaffold(body: Center(child: VzMediaCard(
          image: const SizedBox.expand(),
          title: 'Big Buck Bunny',
          subtitle: 'Movies/Folder',
          duration: '12:34',
          onTap: () {},
        ))),
      ));
      expect(find.text('Big Buck Bunny'), findsOneWidget);
      expect(find.text('12:34'), findsOneWidget);
      expect(find.byIcon(VzIcons.data('play')), findsOneWidget);
    });

    testWidgets('VzNavDock renders 5 destinations and fires onSelect', (tester) async {
      VzNavDest? selected;
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: Scaffold(
          bottomNavigationBar: VzNavDock(
            current: VzNavDest.home,
            onSelect: (d) => selected = d,
          ),
        ),
      ));
      // آیکون‌ها از لایه‌ی VzIcons می‌آیند (پک پیش‌فرض = Solar)، پس به‌جای
      // IconData هاردکد، با Semantics هر مقصد را پیدا می‌کنیم.
      for (final d in VzNavDest.values) {
        expect(find.bySemanticsLabel(d.label), findsOneWidget,
            reason: 'مقصد ${d.name} در داک نیست');
      }
      // ۵ مقصد
      expect(find.byType(VzIcon), findsNWidgets(5));

      await tester.tap(find.bySemanticsLabel(VzNavDest.live.label));
      await tester.pumpAndSettle();
      expect(selected, VzNavDest.live);
    });

    testWidgets('VzNavDock uses the swappable icon layer', (tester) async {
      // پک پیش‌فرض باید Solar باشد، نه Material
      expect(VzIcons.pack, isA<SolarIconPack>());
      // هر نامی که در پک نباشد به متریال برمی‌گردد (بدون کرش)
      expect(VzIcons.data('__does_not_exist__'), equals(Icons.circle_outlined));
      // نام‌های ناوبری واقعاً resolve می‌شوند
      for (final n in ['home', 'live', 'discover', 'library', 'settings']) {
        expect(VzIcons.data(n), isNot(equals(Icons.circle_outlined)),
            reason: 'آیکون $n resolve نشد');
      }
    });

    testWidgets('VzSearchField renders hint text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: const Scaffold(body: Center(child: Padding(
          padding: EdgeInsets.all(16),
          child: VzSearchField(hint: 'Search videos...'),
        ))),
      ));
      expect(find.text('Search videos...'), findsOneWidget);
    });

    testWidgets('VzSectionHeader renders title and action', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: const Scaffold(body: VzSectionHeader(
          title: 'Tools', actionLabel: 'Manage',
        )),
      ));
      expect(find.text('TOOLS'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
    });

    testWidgets('VzBadge renders label', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: Center(child: VzBadge(text: 'SUB', color: Color(0xFF34D399)))),
      ));
      expect(find.text('SUB'), findsOneWidget);
    });

    testWidgets('showVzDialog shows title, message and actions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: Builder(builder: (ctx) => Scaffold(
          body: Center(child: FilledButton(
            onPressed: () => showVzDialog(
              context: ctx,
              title: 'Delete file?',
              message: 'This cannot be undone.',
              icon: Icons.delete_outline_rounded,
              cancelLabel: 'Cancel',
              confirmLabel: 'Delete',
              destructive: true,
            ),
            child: const Text('Open'),
          )),
        )),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete file?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete file?'), findsNothing);
    });

    testWidgets('showVzInputDialog returns entered text', (tester) async {
      String? result;
      await tester.pumpWidget(MaterialApp(
        theme: buildVezooTheme(),
        home: Builder(builder: (ctx) => Scaffold(
          body: Center(child: FilledButton(
            onPressed: () async {
              result = await showVzInputDialog(
                context: ctx,
                title: 'New playlist',
                hint: 'Playlist name...',
                icon: Icons.add_rounded,
              );
            },
            child: const Text('Open'),
          )),
        )),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Mix');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, 'My Mix');
    });
  });
}
