// lib/signals.dart — سیگنال‌های بین صفحه‌ای (بدون circular import)
import 'package:flutter/material.dart';

/// سیگنال بازکردن پوشه در Home از صفحات دیگر (مثل Library)
/// شِل به این سیگنال گوش می‌دهد: به Home سوئیچ می‌کند و Home مسیر را باز می‌کند
class VzOpenFolderSignal {
  String? value;
  final List<VoidCallback> _listeners = [];
  void notifyListeners(){ for(final l in List.of(_listeners)) l(); }
  void addListener(VoidCallback l){ _listeners.add(l); }
  void removeListener(VoidCallback l){ _listeners.remove(l); }
}

final VzOpenFolderSignal vzOpenFolderSignal = VzOpenFolderSignal();
