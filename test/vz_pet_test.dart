// test/vz_pet_test.dart — تست موتور پت و پارسر SVG
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/vz_kawaii.dart';
import 'package:player/vz_pet.dart';
import 'package:player/vz_svg_path.dart';

void main() {
  group('VzPet motion model', () {
    test('vector points the right way', () {
      expect(PetMotion.moveUp.vector.dy, lessThan(0));
      expect(PetMotion.moveDown.vector.dy, greaterThan(0));
      expect(PetMotion.moveLeft.vector.dx, lessThan(0));
      expect(PetMotion.moveRight.vector.dx, greaterThan(0));
      expect(PetMotion.stop.vector, Offset.zero);
    });

    test('isMoving only for move states', () {
      expect(PetMotion.moveUpLeft.isMoving, isTrue);
      expect(PetMotion.sleep.isMoving, isFalse);
      expect(PetMotion.wait.isMoving, isFalse);
      expect(PetMotion.awake.isMoving, isFalse);
    });

    test('motion from vector covers all eight directions', () {
      expect(petMotionFor(const Offset(0, -10)), PetMotion.moveUp);
      expect(petMotionFor(const Offset(0, 10)), PetMotion.moveDown);
      expect(petMotionFor(const Offset(-10, 0)), PetMotion.moveLeft);
      expect(petMotionFor(const Offset(10, 0)), PetMotion.moveRight);
      expect(petMotionFor(const Offset(-10, -10)), PetMotion.moveUpLeft);
      expect(petMotionFor(const Offset(10, -10)), PetMotion.moveUpRight);
      expect(petMotionFor(const Offset(-10, 10)), PetMotion.moveDownLeft);
      expect(petMotionFor(const Offset(10, 10)), PetMotion.moveDownRight);
    });

    test('tiny vector means stop', () {
      expect(petMotionFor(Offset.zero), PetMotion.stop);
    });
  });

  group('SVG path parser', () {
    test('parses move + line + close', () {
      final p = vzParseSvgPath('M0 0 L10 0 L10 10 Z');
      expect(p.getBounds().width, closeTo(10, 0.01));
      expect(p.getBounds().height, closeTo(10, 0.01));
    });

    test('parses relative and cubic commands', () {
      final p = vzParseSvgPath('M5 5 l10 0 c0 10 -10 10 -10 0 z');
      expect(p.getBounds().isEmpty, isFalse);
    });

    test('handles exponent numbers', () {
      final p = vzParseSvgPath('M0 0 L1e1 0 L1.5e1 5 Z');
      expect(p.getBounds().width, closeTo(15, 0.01));
    });

    test('react-kawaii face paths parse without error', () {
      // فقط نباید throw کند
      expect(
        () => vzParseSvgPath(
          'M11.3 9.7 C9.8 9.7 8.6 8.5 8.6 7.1 C8.6 6.2 7.9 5.5 7 5.5 '
          'C6.1 5.5 5.4 6.2 5.4 7.1 C5.4 8.5 4.2 9.7 2.7 9.7 C1.2 9.7 0 8.5 0 7.1 '
          'C0 3.3 3.1 0.3 7 0.3 C10.8 0.3 14 3.3 14 7.1 C14 8.5 12.8 9.7 11.3 9.7'),
        returnsNormally);
    });
  });

  group('VzKawaii', () {
    testWidgets('renders for every kind and mood', (tester) async {
      for (final kind in VzKawaiiKind.values) {
        for (final mood in VzKawaiiMood.values) {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(body: Center(
              child: VzKawaii(kind: kind, mood: mood, size: 48))),
          ));
          expect(tester.takeException(), isNull,
              reason: '$kind / $mood threw');
        }
      }
    });
  });

  group('VzPetLayer', () {
    testWidgets('runs without throwing and animates', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: VzPetLayer()),
      ));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}