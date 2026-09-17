// test/ink_design_system_test.dart
// Tests for the INK design language: tokens, components and the guarantee that
// INK sources never import the legacy UI layer.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ink/ink_components.dart';

Widget _host(Widget child, {TextDirection? direction, double textScale = 1}) {
  return MaterialApp(
    theme: inkThemeData(dark: Ink.isDark),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(
        textDirection: direction ?? TextDirection.ltr,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  tearDown(() => Ink.setDark(false));

  group('INK tokens', () {
    test('light paper palette is the default', () {
      expect(Ink.isDark, isFalse);
      expect(Ink.canvas, const Color(0xFFF6F1E7));
      expect(Ink.sheet, const Color(0xFFFFFDF8));
      expect(Ink.accent, const Color(0xFFC2410C));
      expect(Ink.ink, const Color(0xFF16130F));
    });

    test('dark switch swaps the palette', () {
      Ink.setDark(true);
      expect(Ink.isDark, isTrue);
      expect(Ink.canvas, const Color(0xFF111110));
      expect(Ink.accent, const Color(0xFFF97316));
    });

    test('shadows are hard offsets — never blurred', () {
      for (final shadow in Ink.hardShadow) {
        expect(shadow.blurRadius, 0);
        expect(shadow.spreadRadius, 0);
        expect(shadow.offset, const Offset(3, 3));
      }
      expect(Ink.noShadow, isEmpty);
    });

    test('type scale keeps the uppercase micro label tracked', () {
      expect(InkType.micro.letterSpacing, greaterThan(1));
      expect(InkType.display.fontWeight, FontWeight.w800);
      expect(InkSp.x4, 16);
      expect(InkRad.sharp, 2);
    });

    test('INK sources never import the legacy UI layer', () {
      final dir = Directory('lib/ink');
      expect(dir.existsSync(), isTrue,
          reason: 'expected to run from the package root');
      final offenders = <String>[];
      for (final file in dir.listSync().whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        final source = file.readAsStringSync();
        if (source.contains('theme.dart') ||
            source.contains('glass.dart') ||
            RegExp(r'\bVz[A-Z]\w*|\bVz\b').hasMatch(source)) {
          offenders.add(file.path);
        }
      }
      expect(offenders, isEmpty,
          reason: 'INK must stay independent from the previous UI');
    });
  });
}