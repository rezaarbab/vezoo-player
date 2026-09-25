// lib/gallery_service.dart — اسکن ویدیوهای گوشی از MediaStore
//
// یک channel یک‌طرفه به side اندرویدِ اپ (MainActivity / plugin vezoo_jni.c):
// تمام ویدیوهای register شده در MediaStore با thumbnail + duration در یک‌بار.
// در روش «هر ویدیو یکی‌یکی بگردي» (MX/VLC style) هم داده آماده است.

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'store.dart';

class GalVideo {
  final String path;
  final String name;
  final String folder;      // مسیر کاملِ فولدر
  final String folderLabel; // نام کوتاه فولدر
  final int durationMs;
  final int sizeBytes;
  final int modifiedAt;     // epoch ms

  const GalVideo({
    required this.path, required this.name,
    required this.folder, required this.folderLabel,
    required this.durationMs, required this.sizeBytes,
    required this.modifiedAt,
  });

  String get durText => formatDur(durationMs);
}

class GalFolder {
  final String folder;
  final List<GalVideo> videos;
  const GalFolder({required this.folder, required this.videos});
  int get count => videos.length;
  String get folderLabel => folder.split('/').where((s)=>s.isNotEmpty).last;
}

class GalService {
  static const _ch = MethodChannel('com.vezoo.player/media');

  static Future<bool> ensurePermission() async {
    var ok = await Permission.videos.isGranted ||
             await Permission.storage.isGranted;
    if (!ok) {
      final r = await Permission.videos.request();
      ok = r.isGranted;
    }
    if (!ok) {
      final r2 = await Permission.storage.request();
      ok = r2.isGranted;
    }
    if (!ok) {
      // آخرین گزینه: ManageAllFiles (پرمیژن قدیمی)
      final r3 = await Permission.manageExternalStorage.request();
      ok = r3.isGranted;
    }
    return ok;
  }

  /// اسکن MediaStore — در یک بار از channel می‌آید…
  static Future<List<GalVideo>> scanVideos() async {
    try {
      final raw = await _ch.invokeMethod('scanVideos');
      if (raw is! List) return const [];
      final list = raw.map((m) {
        final p = (m['path'] ?? '') as String;
        final durMs = (m['duration'] ?? 0) as int;
        return GalVideo(
          path: p,
          name: (m['displayName'] ?? _basename(p)).toString(),
          folder: (m['folder'] ?? '').toString(),
          folderLabel: ((m['folder'] ?? '').toString()).split('/')
              .where((s) => s.isNotEmpty).last,
          durationMs: durMs,
          sizeBytes: (m['size'] ?? 0) as int,
          modifiedAt: (m['modified'] ?? 0) as int,
        );
      }).toList();
      // جدیدترین (modified بزرگ‌تر) اول — ازسویِ هوش مصنوعی
      list.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      return list;
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  static String _basename(String p) =>
      p.split('/').where((s)=>s.isNotEmpty).last;

  static String formatDur(int ms){
    final s = (ms / 1000).round();
    final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = sec.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$m:$ss';
  }

  static List<GalFolder> groupByFolder(List<GalVideo> vids){
    final by = <String, List<GalVideo>>{};
    for (final v in vids) {
      (by[v.folder] ??= []).add(v);
    }
    final out = by.entries
      .map((e) => GalFolder(folder: e.key, videos: e.value))
      .toList();
    out.sort((a, b) => b.count.compareTo(a.count)); // پرحجم‌تر بالاتر
    return out;
  }

  /// thumbnail از کاش اندروید (MethodChannel thumbnailFor) — سریع؛ اگر نبود fallback رنگی.
  static Future<ImageProvider<Object>?> thumbFor(GalVideo v) async {
    try {
      final bytes = await _ch.invokeMethod<List<dynamic>>(
        'thumbnailFor', {'path': v.path});
      if (bytes is List && bytes.isNotEmpty) {
        return MemoryImage(Uint8List.fromList(bytes.cast<int>()));
      }
    } on PlatformException { /* ignore */ }
    return null;
  }
}
