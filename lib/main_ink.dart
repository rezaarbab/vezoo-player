// lib/main_ink.dart
// Preview entry for the INK interface:
//   flutter run -t lib/main_ink.dart
// The default entry point (lib/main.dart) stays on the existing UI.
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'ink/ink_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const InkApp());
}