// lib/gallery_screen.dart — گالری ویدیو (پوستر Plex + پوشه MX)
//
// دو نمای یک صفحه:
//   • poster wall با hero banner (سبک Plex/Netflix)
//   • کارتِ پوشه‌ها (استایل MX Player) — با thumbnail و تعداد فیلم
// داده از MediaStore (channel 'com.vezoo.player/media') می‌آید.

import 'dart:io';

import 'package:flutter/material.dart';

import 'glass.dart';
import 'l10n.dart';
import 'player.dart';
import 'store.dart';
import 'vz_icons.dart';
import 'gallery_service.dart';

enum GalleryMode { plex, folder }

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static List<GalVideo> _all = const [];
  bool _loading = true;
  bool _granted = false;
  GalleryMode _mode = GalleryMode.plex;
  String _query = '';

  final TextEditingController _searchCtrl = TextEditingController();

  @override void initState(){
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final ok = await GalService.ensurePermission();
    if (!mounted) return;
    setState((){ _granted = ok; _loading = ok; });
    if (!ok) return;
    await _refresh();
  }

  Future<void> _refresh() async {
    final vids = await GalService.scanVideos();
    if (!mounted) return;
    setState((){
      _all = vids;
      _loading = false;
    });
  }

  @override void dispose(){
    _searchCtrl.dispose();
    super.dispose();
  }

  List<GalVideo> get filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((v) => v.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(L.gallery, style: Ty.title.copyWith(fontSize: 19)),
        actions: [
          IconButton(
            tooltip: _mode == GalleryMode.plex
                ? L.galleryModeFolder : L.galleryModePoster,
            icon: Icon(VzIcons.data(_mode == GalleryMode.plex ? 'grid' : 'movie'),
              size: 20, color: Vz.textSec),
            onPressed: () => setState((){
              _mode = _mode == GalleryMode.plex
                  ? GalleryMode.folder : GalleryMode.plex;
            })),
        ],
      ),
      body: !_granted
        ? _permissionGate()
        : _loading ? _loadingShimmer() : _content(),
    );
  }

  Widget _permissionGate(){
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(VzIcons.data('folder'), size: 46, color: Vz.textDim),
      const SizedBox(height: 14),
      Padding(padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
        child: Text(L.galleryPermission, textAlign: TextAlign.center,
          style: Ty.bodySec.copyWith(height: 1.5))),
      const SizedBox(height: Sp.lg),
      FilledButton.icon(
        onPressed: _boot,
        icon: const Icon(Icons.verified_user_rounded, size: 18),
        label: Text(L.gallery)),
    ]));
  }

  Widget _loadingShimmer(){
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 140),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
        childAspectRatio: 0.58),
      itemCount: 18,
      itemBuilder: (_, __) => VzSkeletonCard());
  }

  Widget _content(){
    final vids = filtered;
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.xs, Sp.lg, 4),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(()=>_query = v),
          decoration: InputDecoration(
            isDense: true, filled: true, fillColor: Vz.card,
            prefixIcon: Icon(VzIcons.data('search'), size: 18, color: Vz.textDim),
            hintText: L.gallerySearch,
            suffixIcon: _query.isEmpty ? null :
              IconButton(icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: (){_searchCtrl.clear(); setState(()=>_query='');}),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
        )),
      Expanded(child: switch (_mode) {
        GalleryMode.plex  => _plexWall(vids),
        GalleryMode.folder => _folderMode(vids),
      }),
    ]);
  }

  // ───────────── پلیکس/نتفلیکس: هدر hero + poster wall ─────────────
  Widget _plexWall(List<GalVideo> vids){
    if (vids.isEmpty) return _empty();
    final hero = vids.first;
    final rest = vids.skip(1).toList();
    return ListView(children: [
      Stack(children: [
        AspectRatio(aspectRatio: 16 / 7.2, child: _ThumbF(v: hero)),
        // شیشه‌اسکریم پایین
        Positioned(left: 0, right: 0, bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(Sp.lg, 26, Sp.lg, Sp.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent,
                  Colors.black.withValues(alpha: 0.86)])))),
        // متن روی banner
        Positioned(left: 0, right: 0, bottom: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(color: Vz.accent,
                    borderRadius: BorderRadius.circular(5)),
                  child: Text('HD', style: TextStyle(fontSize: 9.5,
                    fontWeight: FontWeight.w900, color: Vz.onAccent))),
                const SizedBox(width: 7),
                if (hero.durText.isNotEmpty) ...[
                  Text(hero.durText,
                    style: TextStyle(fontSize: 10.5, color: Colors.white70)),
                  const SizedBox(width: 7),
                ],
                Text(hero.folderLabel,
                  style: TextStyle(fontSize: 10.5, color: Colors.white60)),
              ]),
              const SizedBox(height: 5),
              Text(hero.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                 style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                   color: Colors.white, letterSpacing: -0.2)),
             ])),
         ),
       ]),
      const SizedBox(height: Sp.md),
      Padding(padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.xs),
        child: Text(L.galleryAll, style: Ty.overline)),
      // ─── Poster wall ۳ ستونه ───
      GridView.builder(
        padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
          childAspectRatio: 0.585),
        itemCount: rest.length,
        itemBuilder: (_, i) => _PosterCard(v: rest[i]),
      ),
    ]);
  }

  // ───────────── MX Player style: folder cards ─────────────
  Widget _folderMode(List<GalVideo> vids){
    final folders = GalService.groupByFolder(vids);
    if (folders.isEmpty) return _empty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 120),
      itemCount: folders.length,
      itemBuilder: (_, i){
        final f = folders[i];
        return VzGlass(
          margin: const EdgeInsets.only(bottom: Sp.md),
          padding: const EdgeInsets.all(Sp.sm),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>
              GalleryFolderScreen(folder: f.folder, videos: f.videos)));
          },
          child: Row(children: [
            SizedBox(width: 74, height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Rad.s(Rad.sm)),
                child: _ThumbF(v: f.videos.first))),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(f.folderLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                  color: Vz.text)),
              const SizedBox(height: 3),
              Text('${f.count} ${L.galleryVideos}',
                style: TextStyle(fontSize: 10.5, color: Vz.textDim)),
            ])),
            Icon(VzIcons.data('chevron-right'), size: 18, color: Vz.textDim),
          ]),
        );
      });
  }

  Widget _empty(){
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(VzIcons.data('video'), size: 44, color: Vz.textDim),
      const SizedBox(height: 12),
      Text(L.nothingYet, style: Ty.bodySec),
    ]));
  }
}

class _PosterCard extends StatelessWidget {
  final GalVideo v;
  const _PosterCard({required this.v});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        final f = File(v.path);
        if (!f.existsSync()) return;
        Navigator.push(context, MaterialPageRoute(builder: (_)=>
          PlayerScreen(playlist: [f], playlistIndex: 0,
            subtitlePath: matchSubtitle(v.path))));
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Expanded(child: ClipRRect(
          borderRadius: Rad.r(Rad.sm),
          child: Stack(fit: StackFit.expand, children: [
            _ThumbF(v: v),
            Positioned(bottom: 5, right: 5, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4)),
              child: Text(v.durText, style: const TextStyle(fontSize: 9.5,
                color: Colors.white, fontWeight: FontWeight.w700)))),
          ]))),
        const SizedBox(height: 5),
        Text(v.name, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Vz.text, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(v.folderLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 8.5, color: Vz.textDim)),
      ]));
  }
}

class _ThumbF extends StatelessWidget {
  final GalVideo v;
  const _ThumbF({required this.v});
  @override
  Widget build(BuildContext context){
    return FutureBuilder<ImageProvider<Object>?>(
      future: GalService.thumbFor(v),
      builder: (ctx, snap){
        final px = snap.data;
        if (px != null) return Image(image: px, fit: BoxFit.cover, gaplessPlayback: true);
        return Container(color: Vz.surfaceHi,
          child: Center(child: Icon(VzIcons.data('movie'), size: 28, color: Vz.textDim)));
      });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  گالری یک پوشه — از نمای MX push می‌شود
// ─────────────────────────────────────────────────────────────────────────────
class GalleryFolderScreen extends StatelessWidget {
  final String folder;
  final List<GalVideo> videos;
  const GalleryFolderScreen({super.key, required this.folder, required this.videos});

  @override
  Widget build(BuildContext context){
    final label = folder.split('/').where((s)=>s.isNotEmpty).last;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(label, style: Ty.title.copyWith(fontSize: 17))),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8,
          childAspectRatio: 0.585),
        itemCount: videos.length,
        itemBuilder: (_, i) {
          final v = videos[i];
          return _PosterCard(v: v);
        }));
  }
}
