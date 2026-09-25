// lib/library_screen.dart — کتابخانه: تاریخچه، بوکمارک، علاقه‌مندی، پلی‌لیست، پوشه‌ها
//
// بازطراحی VOID: کارت‌های واقعی رسانه (پوستر/تامبنیل)، چیدمان قابل‌انتخاب
// (گرید / لیست / فشرده) که بین همه‌ی تب‌ها مشترک است، هدر با شمارنده،
// و همه‌ی آیکون‌ها از لایه‌ی VzIcons.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'store.dart';
import 'player.dart';
import 'glass.dart';
import 'l10n.dart';
import 'browser.dart' show VzGroupHeader, LibLayout, LibLayoutX, browserThumbFuture;
import 'vz_icons.dart';
import 'vz_motion.dart';
import 'main.dart' show showSnack;
import 'signals.dart';
import 'api_service.dart';
import 'package:url_launcher/url_launcher.dart' as ul;

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override State<LibraryScreen> createState()=>_LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>{
  int _tab = 0; // 0=history 1=bookmarks 2=favorites 3=playlists 4=folders
  LibLayout _layout = LibLayout.grid;
  bool _posWarmed = false;

  @override
  void initState(){
    super.initState();
    Store.load().then((_){ if(mounted) setState((){}); });
    SharedPreferences.getInstance().then((p0){
      final raw = p0.getString('lib_layout');
      final l = LibLayout.values.where((e)=>e.name==raw).firstOrNull;
      if(l!=null && mounted) setState(()=>_layout=l);
    });
  }

  void _setLayout(LibLayout l){
    setState(()=>_layout=l);
    SharedPreferences.getInstance().then((p0)=>p0.setString('lib_layout',l.name));
  }

  void _cycleLayout(){
    final v = LibLayout.values;
    _setLayout(v[(v.indexOf(_layout)+1) % v.length]);
  }

  int get _count => switch(_tab){
    0 => Store.watchHistory.length,
    1 => Store.bookmarked.length,
    2 => Store.favorited.length,
    3 => Store.playlists.length,
    4 => Store.savedFolders.length,
    _ => 0,
  };

  @override
  Widget build(BuildContext context){
    return SafeArea(
      bottom: false,
      child: Column(children: [
        // ── هدر: عنوان + شمارنده + دکمه چیدمان ──
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md + 4, Sp.lg, 0),
          child: Row(children: [
            Text(L.library, style: Ty.title),
            const SizedBox(width: Sp.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Vz.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Vz.accent.withValues(alpha: 0.3)),
              ),
              child: Text('$_count',
                style: Ty.mono.copyWith(fontSize: 11, color: Vz.accent)),
            ),
            const Spacer(),
            // دکمه چیدمان — تپ = چرخش، نگه‌داشتن = شیت
            GestureDetector(
              onTap: _cycleLayout,
              onLongPress: ()=>_showLayoutSheet(context),
              child: VzGlass(
                padding: const EdgeInsets.all(8),
                radius: Rad.s(Rad.xs),
                child: Icon(_layout.icon, size: 18, color: Vz.accent),
              ),
            ),
          ]),
        ),
        const SizedBox(height: Sp.sm),

        // ── تب‌ها ──
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.sm),
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(0, L.history, 'history'),
                _chip(1, L.bookmarks, 'bookmark'),
                _chip(2, L.favorites, 'favorite'),
                _chip(3, L.playlist, 'queue'),
                _chip(4, L.folders, 'pin'),
                 _chip(5, L.sponsors, 'star'),              ],
            ),
          ),
        ),

        Expanded(child: RefreshIndicator(
          color: Vz.accent,
          backgroundColor: Vz.card,
          onRefresh: ()async{ await Store.load(); if(mounted) setState((){}); },
          child: switch(_tab){
            0 => _historyTab(),
            1 => _vListTab(Store.bookmarked.toList().reversed.toList(),
                 'bookmark', Vz.amber,
                 onRemove:(path)async{ await Store.toggleBookmark(path); if(mounted) setState((){}); }),
            2 => _vListTab(Store.favorited.toList().reversed.toList(),
                 'favorite', Vz.magenta,
                 onRemove:(path)async{ await Store.toggleFavorite(path); if(mounted) setState((){}); }),
            3 => _playlistTab(),
            4 => _folderTab(),
            5 => _sponsorTab(),
            _ => const SizedBox.shrink(),
          },
        )),
      ]),
    );
  }

  Widget _chip(int idx, String label, String iconName){
    final active = _tab==idx;
    return Padding(
      padding: const EdgeInsets.only(right: Sp.sm),
      child: VzChip(
        label: label,
        icon: VzIcons.data(iconName),
        selected: active,
        color: [Vz.accentHi, Vz.amber, Vz.magenta, Vz.accent, Vz.green, Vz.amber][idx.clamp(0,5)],
        onTap: ()=>setState(()=>_tab=idx),
      ),
    );
  }

  void _showLayoutSheet(BuildContext context){
    showVzSheet(context:context, builder:(ctx)=>SafeArea(top:false,child:Column(
      mainAxisSize:MainAxisSize.min, children:[
        VzSheetHeader(title:L.layout, icon:VzIcons.data('layout'),
          onClose:()=>Navigator.pop(ctx)),
        for(final l in LibLayout.values)
          VzSheetRow(
            icon:l.icon, title:l.label, subtitle:l.description,
            accent:l==_layout?Vz.accent:null,
            trailing:l==_layout
              ? Icon(VzIcons.data('check'),size:19,color:Vz.accent) : null,
            onTap:(){Navigator.pop(ctx);_setLayout(l);},
          ),
        const SizedBox(height:Sp.sm),
      ])));
  }

  // ── باز کردن یک مسیر ──
  void _openVideoByPath(String path){
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    if(!isUrl){
      final f = File(path);
      if(!f.existsSync()){ showSnack(context, L.fileNotFound); return; }
      // پخش مستقیم (صفحه‌ی جزئیات از منوی نگه‌داشتن در دسترس است)
      Navigator.push(context, MaterialPageRoute(builder: (_)=>
        PlayerScreen(playlist:[f], playlistIndex:0,
          subtitlePath: matchSubtitle(path))));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_)=>
      PlayerScreen(playlist:[File(path)], playlistIndex:0, isOnlineUrl: true)));
  }

  // ── تاریخچه ──
  Widget _historyTab(){
    final list = Store.watchHistory;
    if(list.isEmpty) return _emptyFor('history');

    // موقعیت پخش را در کش بارگذاری کن تا نوار پیشرفت پر شود
    if (!_posWarmed && list.isNotEmpty) {
      _posWarmed = true;
      for (final p0 in list.take(30)) {
        Store.getDur(p0).then((_){}).catchError((_){});
        Store.warmPos(p0).then((_){ if (mounted) setState((){}); });
      }
    }

    // آخرین مورد را بزرگ نشان بده (Continue watching) و بقیه را در چیدمان انتخابی
    final latest = list.first;
    final rest = list.length > 1 ? list.sublist(1) : <String>[];

    return Column(children: [
      // ── Continue watching ──
      if(_layout != LibLayout.compact)
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.sm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            VzGroupHeader(
              icon: VzIcons.data('clock'), label: L.continuePlaying,
              count: 1, color: Vz.accent),
            _ContinueCard(path: latest, onTap: ()=>_openVideoByPath(latest)),
          ]),
        ),
      // ── بقیه ──
      if(rest.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 0),
          child: Row(children: [
            Expanded(child: Text(L.recentViews, style: Ty.caption)),
            TextButton.icon(
              icon: Icon(VzIcons.data('trash'), size: 15, color: Vz.red),
              label: Text(L.deleteAll, style: TextStyle(fontSize: 12, color: Vz.red)),
              onPressed: ()async{
                final ok = await showVzDialog<bool>(
                  context: context, title: L.deleteAllHistory,
                  icon: VzIcons.data('trash'), destructive: true,
                  cancelLabel: L.cancel, confirmLabel: L.delete);
                if(ok==true){ await Store.clearHistory(); if(mounted) setState((){}); }
              }),
          ]),
        ),
      ],
      Expanded(child: _mediaList(
        rest.isEmpty ? list : rest,
        onLongPress:(path)async{ await Store.removeFromHistory(path); if(mounted) setState((){}); },
        emptyText: L.nothingYet,
      )),
    ]);
  }

  // ── لیست عمومی ویدیو (history/bookmarks/favorites) ──
  Widget _vListTab(List<String> paths, String iconName, Color color,
      {void Function(String)? onRemove}){
    if(paths.isEmpty) return _emptyFor(iconName);
    return _mediaList(
      paths,
      accent: color,
      trailingIcon: iconName,
      onRemove: onRemove,
    );
  }

  /// لیست رسانه با چیدمان انتخاب‌شده — مشترک بین همه‌ی تب‌ها.
  Widget _mediaList(
    List<String> paths, {
    Color? accent,
    String? trailingIcon,
    String? emptyText,
    void Function(String)? onLongPress,
    void Function(String)? onRemove,
  }){
    final c = accent ?? Vz.accent;
    if(paths.isEmpty) return Center(child: Text(emptyText ?? L.nothingYet, style: Ty.bodySec));

    switch(_layout){
      case LibLayout.compact:
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
          itemCount: paths.length,
          itemBuilder: (_, i)=>_CompactRow(
            path: paths[i], color: c,
            onTap: ()=>_openVideoByPath(paths[i]),
            onLongPress: onLongPress==null?null:()=>onLongPress(paths[i]),
            onRemove: onRemove==null?null:()=>onRemove(paths[i]),
          ));

      case LibLayout.list:
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
          itemCount: paths.length,
          itemBuilder: (_, i)=>Padding(
            padding: const EdgeInsets.only(bottom: Sp.sm),
            child: _MediaRow(
              path: paths[i], color: c,
              onTap: ()=>_openVideoByPath(paths[i]),
              onLongPress: onLongPress==null?null:()=>onLongPress(paths[i]),
              onRemove: onRemove==null?null:()=>onRemove(paths[i]),
            )));

      case LibLayout.tiles:
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6,
            childAspectRatio: 1),
          itemCount: paths.length,
          itemBuilder: (_, i)=>_MediaCard(
            path: paths[i], color: c, layout: _layout,
            onTap: ()=>_openVideoByPath(paths[i]),
            onLongPress: onLongPress==null?null:()=>onLongPress(paths[i]),
            onRemove: onRemove==null?null:()=>onRemove(paths[i]),
          ));

      case LibLayout.poster:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
          itemCount: paths.length,
          separatorBuilder: (_, __)=>const SizedBox(height: Sp.md),
          itemBuilder: (_, i)=>_MediaCard(
            path: paths[i], color: c, layout: _layout,
            onTap: ()=>_openVideoByPath(paths[i]),
            onLongPress: onLongPress==null?null:()=>onLongPress(paths[i]),
            onRemove: onRemove==null?null:()=>onRemove(paths[i]),
          ));

      case LibLayout.grid:
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,
            childAspectRatio: 0.78),
          itemCount: paths.length,
          itemBuilder: (_, i)=>_MediaCard(
            path: paths[i], color: c, layout: _layout,
            onTap: ()=>_openVideoByPath(paths[i]),
            onLongPress: onLongPress==null?null:()=>onLongPress(paths[i]),
            onRemove: onRemove==null?null:()=>onRemove(paths[i]),
          ));
    }
  }

  // ── پلی‌لیست‌ها ──
  Widget _playlistTab(){
    final playlists = Store.playlists;
    if(playlists.isEmpty) return ListView(children: [
      const SizedBox(height: 40),
      VzEmpty(
        icon: VzIcons.data('queue'), title: L.noPlaylists,
        hint: L.createPlaylist, ctaLabel: L.newItem,
        onCta: ()async{
          final name = await showVzInputDialog(
            context: context, title: L.newPlaylist,
            hint: L.playlistName, icon: VzIcons.data('add'),
            cancelLabel: L.cancel, confirmLabel: L.create);
          if(name==null || name.isEmpty) return;
          await Store.createPlaylist(name);
          if(mounted) setState((){});
        }),
    ]);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
      itemCount: playlists.keys.length,
      itemBuilder: (_, i){
        final name = playlists.keys.elementAt(i);
        final paths = playlists[name]!;
        return _TileRow(
          iconName: 'queue', color: Vz.accent,
          title: name, subtitle: '${paths.length}',
          trailing: PopupMenuButton<String>(
            icon: Icon(VzIcons.data('more'), size: 18, color: Vz.textSec),
            itemBuilder: (_)=>[
              PopupMenuItem(value:'play', child: Text(L.play)),
              PopupMenuItem(value:'delete',
                child: Text(L.delete, style: TextStyle(color: Vz.red))),
            ],
            onSelected:(v) async {
              if(v=='delete'){
                final ok = await showVzDialog<bool>(
                  context: context, title: '${L.delete} "$name"?',
                  icon: VzIcons.data('trash'), destructive: true,
                  cancelLabel: L.cancel, confirmLabel: L.delete);
                if(ok==true){ await Store.deletePlaylist(name); if(mounted) setState((){}); }
              } else if(v=='play' && paths.isNotEmpty){
                final files = paths.map((e)=>File(e)).where((f)=>f.existsSync()).toList();
                if(files.isNotEmpty){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>
                    PlayerScreen(playlist: files, playlistIndex: 0,
                      subtitlePath: matchSubtitle(files.first.path))));
                }
              }
            }),
          onTap: paths.isEmpty ? null : ()async{
            final files = paths.map((e)=>File(e)).where((f)=>f.existsSync()).toList();
            if(files.isEmpty){ showSnack(context, L.fileNotFound); return; }
            Navigator.push(context, MaterialPageRoute(builder: (_)=>
              PlayerScreen(playlist: files, playlistIndex: 0,
                subtitlePath: matchSubtitle(files.first.path))));
          },
        );
      },
    );
  }

  // ── پوشه‌های ذخیره‌شده ──
  Widget _folderTab(){
    final folders = Store.savedFolders;
    if(folders.isEmpty) return _emptyFor('pin');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
      itemCount: folders.length,
      itemBuilder: (_, i){
        final folder = folders[i];
        final exists = Directory(folder).existsSync();
        return _TileRow(
          iconName: 'folder', color: exists ? Vz.amber : Vz.textDim,
          title: p.basename(folder), subtitle: folder,
          dim: !exists,
          trailing: IconButton(
            icon: Icon(VzIcons.data('pin'), size: 16, color: Vz.red),
            onPressed: ()async{ await Store.toggleSavedFolder(folder); if(mounted) setState((){}); }),
          onTap: exists ? ()=>_openFolder(folder) : null,
        );
      },
    );
  }

  void _openFolder(String path){
    vzOpenFolderSignal.value = path;
    vzOpenFolderSignal.notifyListeners();
  }

  // ── تب اسپانسرها — برندها از سرور ──
  // در switch tab: 5 => _sponsorTab()
  Widget _sponsorTab(){
    return FutureBuilder<List<Map<String,dynamic>>>(
      future: ApiService.getSponsors(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Vz.accent));
        }
        final list = snap.data ?? const [];
        if (list.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Vz.card, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Vz.border)),
              child: Icon(VzIcons.data('star'), size: 32, color: Vz.textDim)),
            const SizedBox(height: 12),
            Text(L.noSponsors, style: TextStyle(color: Vz.textSec)),
          ]));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 120),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final s = list[i];
            final isFemale = (s['gender'] ?? 'male') == 'female';
            final hasAvatar = (s['avatar_url'] ?? '').isNotEmpty;
            final hasLink = (s['link'] ?? '').isNotEmpty;
            return VzGlass(
              margin: const EdgeInsets.only(bottom: Sp.md),
              padding: const EdgeInsets.all(Sp.md),
              child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: isFemale
                      ? [const Color(0xFFC76B93), const Color(0xFFC76B93)]
                      : [Vz.accent, Vz.accentHi]),
                    shape: BoxShape.circle),
                  child: hasAvatar
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(s['avatar_url'], width: 56, height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                            Icon(Icons.face_rounded, color: Colors.white, size: 28)))
                    : Icon(Icons.face_rounded, color: Colors.white, size: 28)),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'] ?? '', style: TextStyle(
                    color: Vz.text, fontWeight: FontWeight.bold, fontSize: 15)),
                  if ((s['description'] ?? '').isNotEmpty) Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(s['description'],
                      style: TextStyle(fontSize: 12, color: Vz.textSec))),
                ])),
                if (hasLink) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                      backgroundColor: Vz.accent),
                    onPressed: () => ul.launchUrl(Uri.parse(s['link']),
                      mode: ul.LaunchMode.externalApplication),
                    child: Text(L.view, style: TextStyle(fontSize: 12))),
                ],
              ]),
            );
          },
        );
      },
    );
  }

  Widget _emptyFor(String iconName) => VzEmpty(
    icon: VzIcons.data(iconName),
    title: L.nothingYet,
    hint: switch(_tab){ 4 => L.pinFolderHint, _ => null });

}

// ─────────────────────────────────────────────────────────────────────────────
//  کارت ادامه‌ی تماشا — قهرمان تب تاریخچه
// ─────────────────────────────────────────────────────────────────────────────
class _ContinueCard extends StatelessWidget {
  final String path;
  final VoidCallback onTap;
  const _ContinueCard({required this.path, required this.onTap});

  @override
  Widget build(BuildContext context){
    final isUrl = path.startsWith('http');
    final name = isUrl
      ? Uri.parse(path).pathSegments.lastWhere((s)=>s.isNotEmpty, orElse:()=>path)
      : p.basename(path);
    final progress = Store.getProgress(path); // 0..1 (اگر نبود ۰)
    final thumb = browserThumbFuture(path);

    return VzGlass(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // پوستر عریض
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.s(Rad.md))),
          child: SizedBox(
            height: 150, width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              FutureBuilder<dynamic>(
                future: thumb,
                builder: (ctx, snap){
                  final data = snap.data;
                  if (data != null) {
                    return Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true);
                  }
                  return Container(
                    decoration: BoxDecoration(gradient: Vz.heroGrad),
                    alignment: Alignment.center,
                    child: Icon(VzIcons.data('movie'), size: 42, color: Vz.accent),
                  );
                }),
              // اسکریم
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.center,
                  colors: [Vz.scrimBot, Colors.transparent])))),
              // دکمه پخش با نفس‌کشیدن
              Center(child: VzBreathing(child: Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  gradient: Vz.accentGrad,
                  shape: BoxShape.circle,
                  boxShadow: [Vz.glow]),
                child: Icon(VzIcons.data('play'),
                  color: Vz.onAccent, size: 30)))),
            ]),
          ),
        ),
        // نوار پیشرفت
        if (progress > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 3,
                backgroundColor: Vz.border,
                color: Vz.accent)),
            ),
        // عنوان
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: Ty.label.copyWith(fontSize: 13.5)),
            const SizedBox(height: 3),
            Row(children: [
              Icon(VzIcons.data('clock'), size: 11, color: Vz.textDim),
              const SizedBox(width: 4),
              Expanded(child: Text(
                L.continuePlaying,
                style: Ty.caption.copyWith(fontSize: 10),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (progress > 0)
                Text('${(progress*100).round()}%',
                  style: Ty.mono.copyWith(fontSize: 10, color: Vz.accent)),
            ]),
          ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  کارت رسانه — گرید / پوستر / کاشی
// ─────────────────────────────────────────────────────────────────────────────
class _MediaCard extends StatelessWidget {
  final String path;
  final Color color;
  final LibLayout layout;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemove;
  const _MediaCard({
    required this.path, required this.color, required this.layout,
    required this.onTap, this.onLongPress, this.onRemove,
  });

  bool get _isUrl => path.startsWith('http');
  String get _name => _isUrl
    ? Uri.parse(path).pathSegments.lastWhere((s)=>s.isNotEmpty, orElse:()=>path)
    : p.basename(path);
  String get _sub => _isUrl ? path : p.dirname(path);
  bool get _exists => _isUrl || File(path).existsSync();
  int? get _dur => Store.getCachedDur(path);

  @override
  Widget build(BuildContext context){
    // پوستر: کارت عریض تک‌ستونه | tiles: مربع | گرید: ۰.۷۸
    final isPoster = layout == LibLayout.poster;
    final isTile = layout == LibLayout.tiles;
    final radius = isTile ? Rad.s(Rad.sm) : Rad.s(Rad.md);

    return VzTappable(
      onTap: _exists ? onTap : null,
      onLongPress: onLongPress,
      radius: BorderRadius.circular(radius),
      child: VzPopIn(
        from: 0.96,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(fit: StackFit.expand, children: [
            // تصویر
            FutureBuilder<dynamic>(
              future: browserThumbFuture(path),
              builder: (ctx, snap){
                final data = snap.data;
                if (data != null) {
                  return Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Vz.card,
                    gradient: isTile ? null : Vz.heroGrad),
                  alignment: Alignment.center,
                  child: Icon(
                    _isUrl ? VzIcons.data('link') : VzIcons.data('video'),
                    size: isTile ? 22 : 34,
                    color: _exists ? color.withValues(alpha: 0.7) : Vz.textDim),
                );
              }),
            // اسکریم
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: isPoster
                  ? [Colors.black.withValues(alpha:0.85),
                     Colors.black.withValues(alpha:0.15), Colors.transparent]
                  : [Vz.scrimBot, Vz.scrimMid, Colors.transparent],
                stops: const [0.0, 0.5, 1.0])))),
            // بج‌ها
            if (isPoster)
              Positioned(left: 8, top: 8, child: Row(children: [
                if (!_exists) _pill('warning', Vz.red),
                if (_isUrl) _pill('link', Vz.accent),
              ]))
            else
              Positioned(left: 5, top: 5, child: Row(children: [
                if (!_exists) _pill('warning', Vz.red),
                if (_isUrl) ...[const SizedBox(width:3), _pill('link', Vz.accent)],
              ])),
            // دکمه پخش (فقط پوستر و گرید)
            if (!isTile) Center(child: Container(
              width: isPoster ? 48 : 36,
              height: isPoster ? 48 : 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.24))),
              child: Icon(VzIcons.data('play'),
                color: Colors.white, size: isPoster ? 28 : 22))),
            // مدت‌زمان
            if (_dur != null && _dur! > 0 && !isTile)
              Positioned(right: 6, bottom: isPoster ? 8 : 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(color: Vz.badgeBg,
                    borderRadius: BorderRadius.circular(5)),
                  child: Text(_fmtDur(_dur!),
                    style: TextStyle(fontSize: 10, color: Vz.oviText,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()])))),
            // عنوان
            Positioned(left: 8, right: 8, bottom: isPoster ? 8 : (isTile ? 4 : 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, children: [
                Text(_name,
                  maxLines: isPoster ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTile ? 10 : (isPoster ? 13 : 11.5),
                    fontWeight: isPoster ? FontWeight.w700 : FontWeight.w600,
                    color: Colors.white, height: 1.2)),
                if (isPoster) ...[
                  const SizedBox(height: 2),
                  Text(_sub, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7))),
                ],
              ])),
          ]),
        ),
      ),
    );
  }
  static String _fmtDur(int seconds){
    final d = Duration(seconds: seconds);
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return h > 0
      ? '$h:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}'
      : '$m:${s.toString().padLeft(2,'0')}';
  }

  Widget _pill(String iconName, Color c)=>Container(
    width: 20, height: 20,
    decoration: BoxDecoration(color: Vz.badgeBg, shape: BoxShape.circle),
    child: Center(child: VzIcon(iconName, size: 12, color: c)));
}

// ─────────────────────────────────────────────────────────────────────────────
//  ردیف رسانه — لیست با تامبنیل
// ─────────────────────────────────────────────────────────────────────────────
class _MediaRow extends StatelessWidget {
  final String path;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemove;
  const _MediaRow({required this.path, required this.color,
    required this.onTap, this.onLongPress, this.onRemove});

  bool get _isUrl => path.startsWith('http');
  String get _name => _isUrl
    ? Uri.parse(path).pathSegments.lastWhere((s)=>s.isNotEmpty, orElse:()=>path)
    : p.basename(path);
  String get _sub => _isUrl ? path : p.dirname(path);
  bool get _exists => _isUrl || File(path).existsSync();
  int? get _dur => Store.getCachedDur(path);

  @override
  Widget build(BuildContext context){
    return VzGlass(
      padding: const EdgeInsets.all(Sp.sm),
      onTap: _exists ? onTap : null,
      onLongPress: onLongPress,
      child: Row(children: [
        // تامبنیل
        ClipRRect(
          borderRadius: BorderRadius.circular(Rad.s(Rad.xs)),
          child: SizedBox(
            width: 84, height: 50,
            child: FutureBuilder<dynamic>(
              future: browserThumbFuture(path),
              builder: (ctx, snap){
                final data = snap.data;
                if (data != null) {
                  return Image.memory(data, fit: BoxFit.cover, gaplessPlayback: true);
                }
                return Container(
                  color: Vz.cardHi,
                  alignment: Alignment.center,
                  child: Icon(VzIcons.data('video'), size: 18, color: color));
              }),
          ),
        ),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: Ty.label.copyWith(
              fontSize: 12.5,
              color: _exists ? Vz.text : Vz.textDim)),
          const SizedBox(height: 3),
          Text(_sub, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: Ty.caption.copyWith(fontSize: 10)),
          if (_dur != null && _dur! > 0) ...[
            const SizedBox(height: 3),
            Row(children: [
              Icon(VzIcons.data('clock'), size: 10, color: Vz.textDim),
              const SizedBox(width: 3),
              Text(_MediaCard._fmtDur(_dur!),
                style: Ty.mono.copyWith(fontSize: 10)),
            ]),
          ],
        ])),
        if (onRemove != null)
          IconButton(
            icon: Icon(VzIcons.data('close'), size: 16, color: Vz.red),
            onPressed: onRemove)
        else
          Icon(VzIcons.data('play'), size: 22,
            color: _exists ? color : Vz.textDim),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ردیف فشرده — سبک و سریع
// ─────────────────────────────────────────────────────────────────────────────
class _CompactRow extends StatelessWidget {
  final String path;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onRemove;
  const _CompactRow({required this.path, required this.color,
    required this.onTap, this.onLongPress, this.onRemove});

  bool get _isUrl => path.startsWith('http');
  String get _name => _isUrl
    ? Uri.parse(path).pathSegments.lastWhere((s)=>s.isNotEmpty, orElse:()=>path)
    : p.basename(path);
  bool get _exists => _isUrl || File(path).existsSync();

  @override
  Widget build(BuildContext context){
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(VzIcons.data(_isUrl ? 'link' : 'video'), size: 16,
          color: _exists ? color : Vz.textDim),
        const SizedBox(width: 10),
        Expanded(child: Text(_name,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: Ty.label.copyWith(
            fontSize: 12,
            color: _exists ? Vz.text : Vz.textDim))),
        if (onRemove != null)
          GestureDetector(
            onTap: onRemove,
            child: Icon(VzIcons.data('close'), size: 15, color: Vz.red))
        else
          Icon(VzIcons.data('chevron-right'), size: 15, color: Vz.textDim),
      ]),
    );
    if (!_exists) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, onLongPress: onLongPress, child: row));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ردیف کاشی‌مانند (پلی‌لیست / پوشه) — آیکون‌باکس + عنوان + زیرعنوان + اکشن
// ─────────────────────────────────────────────────────────────────────────────
class _TileRow extends StatelessWidget {
  final String iconName;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dim;
  const _TileRow({required this.iconName, required this.color,
    required this.title, required this.subtitle,
    this.trailing, this.onTap, this.dim = false});

  @override
  Widget build(BuildContext context){
    return VzGlass(
      margin: const EdgeInsets.only(bottom: Sp.sm),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Row(children: [
        VzIconBadge(icon: VzIcons.data(iconName),
          color: dim ? Vz.textDim : color, size: 17, box: 38),
        const SizedBox(width: Sp.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: Ty.label.copyWith(color: dim ? Vz.textDim : Vz.text)),
          const SizedBox(height: 2),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: Ty.caption.copyWith(fontSize: 10)),
        ])),
        if (trailing != null) trailing!,
      ]),
    );
  }
}
