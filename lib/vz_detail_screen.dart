// lib/vz_detail_screen.dart — صفحه‌ی جزئیات سبک Tako Play
//
// چیدمان از روی اپ Tako Play:
//   • پس‌زمینه‌ی بلور‌شده از پوستر (VzBlurBackdrop)
//   • کارت اطلاعات: پوستر + عنوان بزرگ + Released + Status + چیپ ژانرها
//   • بخش «Plot Summary» با chevron بازشو
//   • «Episodes» + دکمه‌ی BookMark
//   • گرید شماره‌ی قسمت‌ها به رنگ اکسنت
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'browser.dart' show browserThumbFuture;
import 'player.dart';
import 'store.dart';
import 'theme.dart';
import 'vz_icons.dart';
import 'vz_motion.dart';
import 'vz_tako.dart';

class VzDetailScreen extends StatefulWidget {
  final File file;
  final List<File> playlist;
  final int index;
  const VzDetailScreen({
    super.key,
    required this.file,
    this.playlist = const [],
    this.index = 0,
  });

  /// صفحه را باز می‌کند و پلیر را با قسمت انتخابی راه می‌اندازد.
  static Future<void> open(
    BuildContext context, {
    required File file,
    List<File> playlist = const [],
    int index = 0,
  }) => Navigator.push(context, MaterialPageRoute(
    builder: (_) => VzDetailScreen(file: file, playlist: playlist, index: index)));

  @override State<VzDetailScreen> createState() => _VzDetailScreenState();
}

class _VzDetailScreenState extends State<VzDetailScreen> {
  bool _plotOpen = false;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _bookmarked = Store.bookmarked.contains(widget.file.path);
  }

  String get _name => p.basenameWithoutExtension(widget.file.path);
  List<File> get _episodes => widget.playlist.isEmpty ? [widget.file] : widget.playlist;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vz.bg,
      body: VzBlurBackdrop(
        // پوستر به‌عنوان پایه‌ی بلور — اگر تامبنیل نبود، گرادیان تم
        artwork: _BackdropArt(file: widget.file),
        darken: 0.80,
        blur: 46,
        child: SafeArea(
          child: Column(children: [
            VzCenterBar(
              title: 'Details',
              actions: [
                IconButton(
                  icon: Icon(VzIcons.data(_bookmarked ? 'bookmark' : 'bookmark-off'),
                    color: _bookmarked ? Vz.amber : Vz.textSec, size: 22),
                  onPressed: () async {
                    await Store.toggleBookmark(widget.file.path);
                    if (mounted) setState(() => _bookmarked = !_bookmarked);
                  }),
              ],
            ),
            Expanded(child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                // ── کارت اطلاعات ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // پوستر
                    ClipRRect(
                      borderRadius: Rad.r(Rad.md),
                      child: SizedBox(
                        width: 132, height: 196,
                        child: _PosterArt(file: widget.file),
                      ),
                    ),
                    const SizedBox(width: Sp.lg),
                    // متادیتا
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            letterSpacing: -0.4, color: Vz.text, height: 1.15)),
                        const SizedBox(height: Sp.sm),
                        _metaLine('Released', _yearOf(widget.file)),
                        const SizedBox(height: 4),
                        _metaLine('Status', 'Completed'),
                        const SizedBox(height: Sp.md),
                        // چیپ ژانرها — از پسوند و نام فایل حدس می‌زنیم
                        Wrap(spacing: 7, runSpacing: 7, children: [
                          VzGenreChip(label: _ext.toUpperCase()),
                          const VzGenreChip(label: 'Video'),
                          if (_episodes.length > 1)
                            VzGenreChip(label: '${_episodes.length} Episodes'),
                          const VzGenreChip(label: 'Local'),
                        ]),
                      ])),
                  ]),
                ),

                // ── Plot Summary ──
                const SizedBox(height: Sp.xl),
                _expandable(
                  title: 'Plot Summary',
                  open: _plotOpen,
                  onTap: () => setState(() => _plotOpen = !_plotOpen),
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 0),
                    child: Text(
                      'No plot information is available for a local file. '
                      'Play the video to see its details, or fetch subtitles '
                      'from the player menu.',
                      style: Ty.bodySec.copyWith(fontSize: 13)),
                  ),
                ),

                // ── Episodes ──
                const SizedBox(height: Sp.lg),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 0),
                  child: Row(children: [
                    Text('Episodes',
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        letterSpacing: -0.3, color: Vz.text)),
                    const Spacer(),
                    VzPress(
                      onTap: () async {
                        await Store.toggleBookmark(widget.file.path);
                        if (mounted) setState(() => _bookmarked = !_bookmarked);
                      },
                      scale: 0.95,
                      child: Row(children: [
                        Icon(VzIcons.data(_bookmarked ? 'bookmark' : 'bookmark-off'),
                          size: 18, color: Vz.amber),
                        const SizedBox(width: 6),
                        Text('BookMark',
                          style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700,
                            color: Vz.amber)),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: Sp.md),
                VzEpisodeGrid(
                  count: _episodes.length,
                  current: widget.index + 1,
                  watched: _watchedNumbers(),
                  onTap: (n) {
                    if (n - 1 < _episodes.length) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          playlist: _episodes,
                          playlistIndex: n - 1,
                          subtitlePath: matchSubtitle(_episodes[n - 1].path))));
                    }
                  },
                ),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  String get _ext =>
      p.extension(widget.file.path).toLowerCase().replaceAll('.', '');

  String _yearOf(File f) {
    try {
      return f.lastModifiedSync().year.toString();
    } catch (_) {
      return '—';
    }
  }

  Set<int> _watchedNumbers() {
    final out = <int>{};
    for (var i = 0; i < _episodes.length; i++) {
      if (Store.watched.contains(_episodes[i].path)) out.add(i + 1);
    }
    return out;
  }

  Widget _metaLine(String label, String value) => RichText(
    text: TextSpan(children: [
      TextSpan(text: '$label: ',
        style: Ty.body.copyWith(fontSize: 14, color: Vz.textSec)),
      TextSpan(text: value,
        style: Ty.body.copyWith(fontSize: 14, fontWeight: FontWeight.w700,
          color: Vz.text)),
    ]));

  Widget _expandable({
    required String title,
    required bool open,
    required VoidCallback onTap,
    required Widget body,
  }) => Column(children: [
    VzGlass(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
      onTap: onTap,
      child: Row(children: [
        Text(title, style: Ty.heading),
        const Spacer(),
        AnimatedRotation(
          turns: open ? 0.5 : 0,
          duration: Mo.normal,
          child: Icon(VzIcons.data('chevron-right'),
            size: 18, color: Vz.textDim)),
      ]),
    ),
    AnimatedSize(
      duration: Mo.normal,
      curve: Mo.easeOut,
      alignment: Alignment.topCenter,
      child: open ? body : const SizedBox(width: double.infinity),
    ),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  آرت‌ورک — اگر تامبنیل کش‌شده باشد استفاده می‌شود، وگرنه گرادیان تم
// ─────────────────────────────────────────────────────────────────────────────

class _BackdropArt extends StatelessWidget {
  final File file;
  const _BackdropArt({required this.file});

  @override Widget build(BuildContext context) => LayoutBuilder(
    builder: (ctx, box) => FutureBuilder<dynamic>(
      future: browserThumbFuture(file.path),
      builder: (ctx, snap) {
        final data = snap.data;
        if (data != null) {
          return Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true);
        }
        return DecoratedBox(decoration: BoxDecoration(gradient: Vz.heroGrad));
      },
    ));
}

class _PosterArt extends StatelessWidget {
  final File file;
  const _PosterArt({required this.file});

  @override Widget build(BuildContext context) => FutureBuilder<dynamic>(
    future: browserThumbFuture(file.path),
    builder: (ctx, snap) {
      final data = snap.data;
      if (data != null) {
        return Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true);
      }
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
      return Container(
        decoration: BoxDecoration(gradient: Vz.heroGrad),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(VzIcons.data('video'), size: 34, color: Vz.accent),
          const SizedBox(height: 8),
          Text(ext.toUpperCase(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
              color: Vz.text, letterSpacing: 1.5)),
        ]),
      );
    });
}
