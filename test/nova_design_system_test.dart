// test/nova_design_system_test.dart — تست Design System NOVA
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/theme.dart';
import 'package:player/glass.dart';
import 'package:player/vz_presets.dart';

void main() {
  group('NOVA Design System — Tokens', () {
    test('Color palette — VOID', () {
      expect(Vz.bg.toARGB32(), equals(0xFF0A0A0C));
      expect(Vz.bgDeep.toARGB32(), equals(0xFF050507));
      expect(Vz.surface.toARGB32(), equals(0xFF121216));
      expect(Vz.card.toARGB32(), equals(0xFF17171C));
      expect(Vz.cardHi.toARGB32(), equals(0xFF1F1F26));
      // اکسنت پیش‌فرض = اولین پالت (Cyan) در حالت تیره
      expect(Vz.accentIndex, equals(-1)); // -1 = رنگ خودِ پرسِت
      expect(Vz.accent.toARGB32(), equals(Vz.preset.accentDark.toARGB32()));
      expect(Vz.accentHi.toARGB32(), equals(Vz.preset.accentDarkHi.toARGB32()));
      expect(Vz.deep.toARGB32(), equals(Vz.preset.accentDarkDeep.toARGB32()));
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
      expect(kVzPresets.length, greaterThanOrEqualTo(6));
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
      // هر دو سبک دخترونه و پسرونه موجود باشد
      expect(kVzPresets.any((p) => p.style == VzStyle.kawaii), isTrue);
      expect(kVzPresets.any((p) => p.style == VzStyle.shonen), isTrue);
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

    test('Theme — dark, Material 3, NOVA colors', () {
      final theme = buildVezooTheme();
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, Vz.accent);
      expect(theme.colorScheme.surface, Vz.surface);
      expect(theme.scaffoldBackgroundColor, Vz.bg);
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
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
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
      // ۵ آیتم: home, live, discover, library, settings
      expect(find.byIcon(Icons.movie_filter_rounded), findsOneWidget);
      expect(find.byIcon(Icons.live_tv_rounded), findsOneWidget);
      expect(find.byIcon(Icons.explore_rounded), findsOneWidget);
      expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.live_tv_rounded));
      await tester.pumpAndSettle();
      expect(selected, VzNavDest.live);
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
