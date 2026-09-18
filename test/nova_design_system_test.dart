// test/nova_design_system_test.dart - Vezoo theme engine + components
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/theme.dart';
import 'package:player/glass.dart';
import 'package:player/vz_icons.dart';

void main() {
  // تست‌های ویجت با انیمیشن‌های بی‌نهایت هرگز settle نمی‌شوند، مگر انیمیشن
  // خاموش باشد — که کاربر هم می‌تواند از تنظیمات انتخاب کند.
  setUp(() => Vz.previewAnimations(false));
  tearDown(() => Vz.previewAnimations(true));

  group('Vezoo theme engine (Namida-like)', () {
    test('Palette is derived from one seed and stays harmonic', () {
      const seed = Color(0xFF00AEEC);
      final dark = vzBuildPalette(seed, dark: true);
      final light = vzBuildPalette(seed, dark: false);

      expect(dark.seed, seed);
      expect(light.seed, seed);

      // سطح‌ها پله‌پله از هم جدا هستند (M3-like layering)
      expect(dark.bg, isNot(dark.surface));
      expect(dark.surface, isNot(dark.card));
      expect(dark.card, isNot(dark.cardHi));
      expect(dark.border, isNot(dark.borderHi));

      // حالت روشن واقعاً روشن است
      expect(light.bg.computeLuminance(), greaterThan(0.85));
      expect(light.card.computeLuminance(), greaterThan(0.90));
      expect(light.border.computeLuminance(), greaterThan(0.60));

      // اکسنت روی پس‌زمینه‌ی خودش خوانا است
      expect(vzContrast(dark.accent, dark.bg), greaterThan(3.0));
      expect(vzContrast(light.accent, light.bg), greaterThan(3.0));
    });

    test('Every seed produces a readable onAccent', () {
      for (final s in kVzSeeds) {
        for (final dark in [true, false]) {
          final p = vzBuildPalette(s, dark: dark);
          expect(vzContrast(p.onAccent, p.accent), greaterThan(3.0),
              reason: 'seed ${s.toARGB32().toRadixString(16)} dark=$dark');
        }
      }
    });

    test('Built-in themes are complete and unique', () {
      expect(kVzThemes.length, greaterThanOrEqualTo(6));
      final ids = kVzThemes.map((t) => t.id).toSet();
      expect(ids.length, equals(kVzThemes.length));
      for (final t in kVzThemes) {
        expect(t.name, isNotEmpty);
        expect(t.tagline, isNotEmpty);
        expect(t.radiusScale, greaterThan(0));
        final p = vzBuildPalette(t.seed, dark: true);
        expect(p.accent, isNot(p.bg));
      }
      expect(kVzThemes.first.id, equals('moe'));
    });

    test('Background styles all build a gradient', () {
      final p = vzBuildPalette(kVzSeeds.first, dark: true);
      for (final s in VzBgStyle.values) {
        final g = vzBackground(p, s);
        expect(g.colors.length, greaterThanOrEqualTo(2));
      }
      final flat = vzBackground(p, VzBgStyle.flat);
      expect(flat.colors.first, equals(flat.colors.last));
    });

    test('vzOnColor picks the readable foreground', () {
      expect(vzOnColor(Colors.white), equals(const Color(0xFF0C0C0F)));
      expect(vzOnColor(Colors.black), equals(Colors.white));
    });

    test('Typography scale', () {
      expect(Ty.display.fontSize, 28);
      expect(Ty.title.fontSize, 20);
      expect(Ty.heading.fontSize, 16);
      expect(Ty.body.fontSize, 14);
      expect(Ty.label.fontSize, 12);
      expect(Ty.caption.fontSize, 11);
      expect(Ty.overline.fontSize, 10);
      expect(Ty.mono.fontFeatures, isNotNull);
    });

    test('Spacing and radius scales', () {
      expect(Sp.xs, 4.0); expect(Sp.sm, 8.0); expect(Sp.md, 12.0);
      expect(Sp.lg, 16.0); expect(Sp.xl, 20.0); expect(Sp.xxl, 24.0);
      expect(Rad.xs, 10.0); expect(Rad.sm, 14.0);
      expect(Rad.md, 18.0); expect(Rad.lg, 24.0); expect(Rad.full, 999.0);
      expect(Rad.s(10), greaterThan(0));
    });

    test('Scrim tokens + scrimGrad', () {
      expect(Vz.scrimTop.toARGB32(), equals(0x00000000));
      expect(Vz.scrimMid.toARGB32(), equals(0x80000000));
      expect(Vz.scrimBot.toARGB32(), equals(0xE6000000));
      expect(Vz.scrimGrad.colors, hasLength(3));
      expect(Vz.scrimGrad.stops, equals(const [0.0, 0.45, 1.0]));
    });

    test('Theme data is Material 3 and uses the active palette', () {
      final theme = buildVezooTheme();
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, Vz.accent);
      expect(theme.colorScheme.surface, Vz.surface);
      expect(theme.bottomSheetTheme.backgroundColor, Vz.surface);
    });
  });

  group('Vezoo components', () {
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
      // پک پیش‌فرض BiliIconPack است (گلیف‌های موئه + fallback به Solar).
      expect(VzIcons.pack, isA<BiliIconPack>());

      // هر نامی که در هیچ پکی نباشد به متریال برمی‌گردد (بدون کرش)
      expect(VzIcons.data('__does_not_exist__'), equals(Icons.circle_outlined));

      // نام‌های عملیاتی ناوبری از Solar می‌آیند و باید resolve شوند
      for (final n in ['home', 'live', 'discover', 'library', 'settings']) {
        expect(VzIcons.data(n), isNot(equals(Icons.circle_outlined)),
            reason: 'آیکون $n resolve نشد');
      }
    });

    testWidgets('moe icon pack serves its named glyphs and falls back', (tester) async {
      const pack = BiliIconPack();

      // پنج گلیف شناسایی‌شده باید از فونت VanFont بیایند
      for (final entry in BiliIconPack.known.entries) {
        expect(BiliIconPack.has(entry.key), isTrue);
        final icon = pack.fallback(entry.key);
        expect(icon.fontFamily, equals('VanFont'),
            reason: '${entry.key} باید از VanFont باشد');
        expect(icon.codePoint, equals(entry.value));
      }

      // نام ناشناخته باید به پک Solar برگردد، نه فونت موئه
      final fallback = pack.fallback('settings');
      expect(fallback.fontFamily, isNot(equals('VanFont')));

      // همه‌ی کدپوینت‌ها معتبر و یکتا هستند
      expect(BiliIconPack.allCodePoints.length, equals(62));
      expect(BiliIconPack.allCodePoints.toSet().length, equals(62));
      for (final cp in BiliIconPack.allCodePoints) {
        expect(BiliIconPack.has('van${cp.toRadixString(16).toUpperCase()}'), isTrue);
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
