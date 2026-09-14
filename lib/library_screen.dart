// lib/library_screen.dart — کتابخانه: تاریخچه، نشانه‌ها، علاقه‌مندی، پلی‌لیست، پوشه‌ها
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:path/path.dart' as p;
import 'dart:io';
import 'store.dart';
import 'player.dart';
import 'glass.dart';
import 'l10n.dart';
import 'main.dart' show showSnack;
import 'signals.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override State<LibraryScreen> createState()=>_LibraryScreenState();
}
class _LibraryScreenState extends State<LibraryScreen>{
  int _tab = 0; // 0=history 1=bookmarks 2=favorites 3=playlists 4=folders

  @override
  void initState(){
    super.initState();
    Store.load().then((_){ if(mounted) setState((){}); });
  }

  @override
  Widget build(BuildContext context){
    return SafeArea(
      bottom: false,
      child: Column(children: [
        // ── هدر ──
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md + 4, Sp.lg, 0),
          child: Row(children: [
            Text(L.library, style: Ty.title),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.sm),
          child: SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(0, L.history, Icons.history_rounded),
                _chip(1, L.bookmarks, Icons.bookmark_rounded),
                _chip(2, L.favorites, Icons.favorite_rounded),
                _chip(3, L.playlist, Icons.queue_music_rounded),
                _chip(4, L.folders, Icons.push_pin_rounded),
              ],
            ),
          ),
        ),
        Expanded(child: RefreshIndicator(
          color: Vz.accent,
          backgroundColor: Vz.card,
          onRefresh: ()async{ await Store.load(); if(mounted) setState((){}); },
          child: switch(_tab){
            0 => _historyTab(),
            1 => _vListTab(Store.bookmarked.toList().reversed.toList(), Icons.bookmark_rounded, Vz.amber,
                 onRemove:(path)async{ await Store.toggleBookmark(path); if(mounted) setState((){}); }),
            2 => _vListTab(Store.favorited.toList().reversed.toList(), Icons.favorite_rounded, Vz.magenta,
                 onRemove:(path)async{ await Store.toggleFavorite(path); if(mounted) setState((){}); }),
            3 => _playlistTab(),
            4 => _folderTab(),
            _ => const SizedBox.shrink(),
          },
        )),
      ]),
    );
  }

  Widget _chip(int idx, String label, IconData icon){
    final active = _tab==idx;
    return Padding(
      padding: const EdgeInsets.only(right: Sp.sm),
      child: VzChip(
        label: label, icon: icon, selected: active,
        color: [Vz.accentHi, Vz.amber, Vz.magenta, Vz.accent, Vz.green][idx],
        onTap: ()=>setState(()=>_tab=idx),
      ),
    );
  }

  void _openVideoByPath(String path){
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    if(!isUrl){
      final f = File(path);
      if(!f.existsSync()){ showSnack(context, L.fileNotFound); return; }
      Navigator.push(context, MaterialPageRoute(builder: (_)=>
        PlayerScreen(playlist:[f], playlistIndex:0, subtitlePath: matchSubtitle(path))));
      return;
    }
    // URL آنلاین — پخش مستقیم
    Navigator.push(context, MaterialPageRoute(builder: (_)=>
      PlayerScreen(playlist:[File(path)], playlistIndex:0, isOnlineUrl: true)));
  }

  // ── History ──
  Widget _historyTab(){
    final list = Store.watchHistory;
    if(list.isEmpty) return _empty(Icons.history_rounded, L.nothingYet);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.sm),
        child: Row(children: [
          Expanded(child: Text(L.recentViews, style: Ty.caption)),
          TextButton.icon(
            icon: Icon(Icons.delete_outline_rounded, size: 15, color: Vz.red),
            label: Text(L.deleteAll, style: TextStyle(fontSize: 12, color: Vz.red)),
            onPressed: ()async{
              final ok = await showVzDialog<bool>(
                context: context, title: L.deleteAllHistory,
                icon: Icons.delete_forever_rounded, destructive: true,
                cancelLabel: L.cancel, confirmLabel: L.delete,
              );
              if(ok==true){ await Store.clearHistory(); if(mounted) setState((){}); }
            }),
        ]),
      ),
      Expanded(child: _vListTab(list, Icons.history_rounded, Vz.textSec,
        onLongPress:(path)async{ await Store.removeFromHistory(path); if(mounted) setState((){}); })),
    ]);
  }

  // ── لیست عمومی ویدیو (history/bookmarks/favorites) ──
  Widget _vListTab(List<String> paths, IconData icon, Color color,
      {Function(String)? onLongPress, void Function(String)? onRemove}){
    if(paths.isEmpty) return _empty(icon, L.nothingYet);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
      itemCount: paths.length,
      itemBuilder: (_, i){
        final path = paths[i];
        final isUrl = path.startsWith('http://') || path.startsWith('https://');
        final exists = isUrl ? true : File(path).existsSync();
        final name = isUrl
          ? Uri.parse(path).pathSegments.lastWhere((s)=>s.isNotEmpty, orElse:()=>path)
          : p.basename(path);
        final sub = isUrl ? path : p.dirname(path);
        return VzGlass(
          margin: const EdgeInsets.only(bottom: Sp.sm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: exists ? ()=>_openVideoByPath(path) : null,
          onLongPress: isUrl
            ? (){ Clipboard.setData(ClipboardData(text: path)); showSnack(context, L.linkCopied, seconds: 2); }
            : (onLongPress != null ? ()=>onLongPress(path) : null),
          child: Row(children: [
            VzIconBadge(
              icon: isUrl ? Icons.link_rounded : icon,
              color: exists ? color : Vz.textDim, size: 17, box: 38),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: Ty.label.copyWith(color: exists ? Vz.text : Vz.textDim)),
              const SizedBox(height: 2),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: Ty.caption.copyWith(fontSize: 10)),
            ])),
            if(onRemove != null)
              IconButton(
                icon: Icon(Icons.close_rounded, size: 16, color: Vz.red),
                onPressed: ()=>onRemove(path)),
          ]),
        );
      },
    );
  }

  // ── Playlists ──
  Widget _playlistTab(){
    final playlists = Store.playlists;
    if(playlists.isEmpty) return ListView(children: [
      const SizedBox(height: 40),
      VzEmpty(
        icon: Icons.queue_music_rounded, title: L.noPlaylists,
        hint: L.createPlaylist, ctaLabel: L.newItem,
        onCta: ()async{
          final name = await showVzInputDialog(
            context: context, title: L.newPlaylist,
            hint: L.playlistName, icon: Icons.add_rounded,
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
        return VzGlass(
          margin: const EdgeInsets.only(bottom: Sp.sm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: paths.isEmpty ? null : ()async{
            final files = paths.map((e)=>File(e)).where((f)=>f.existsSync()).toList();
            if(files.isEmpty){ showSnack(context, L.fileNotFound); return; }
            Navigator.push(context, MaterialPageRoute(builder: (_)=>
              PlayerScreen(playlist: files, playlistIndex: 0,
                subtitlePath: matchSubtitle(files.first.path))));
          },
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: Vz.accentGrad,
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.queue_music_rounded, size: 18, color: Colors.white)),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: Ty.label),
              const SizedBox(height: 2),
              Text('${paths.length}', style: Ty.caption.copyWith(fontSize: 10)),
            ])),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 18, color: Vz.textSec),
              itemBuilder: (_)=>[
                PopupMenuItem(value:'play', child: Text(L.play)),
                PopupMenuItem(value:'delete', child: Text(L.delete, style: TextStyle(color: Vz.red))),
              ],
              onSelected:(v) async {
                if(v=='delete'){
                  final ok = await showVzDialog<bool>(
                    context: context, title: '${L.delete} "$name"?',
                    icon: Icons.delete_outline_rounded, destructive: true,
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
          ]),
        );
      },
    );
  }

  // ── Saved folders ──
  Widget _folderTab(){
    final folders = Store.savedFolders;
    if(folders.isEmpty) return _empty(Icons.push_pin_outlined, L.noSavedFolders);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, 120),
      itemCount: folders.length,
      itemBuilder: (_, i){
        final folder = folders[i];
        final exists = Directory(folder).existsSync();
        return VzGlass(
          margin: const EdgeInsets.only(bottom: Sp.sm),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: exists ? ()=>_openFolder(folder) : null,
          child: Row(children: [
            VzIconBadge(
              icon: Icons.folder_rounded,
              color: exists ? Vz.amber : Vz.textDim, size: 17, box: 38),
            const SizedBox(width: Sp.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.basename(folder), maxLines: 1, overflow: TextOverflow.ellipsis, style: Ty.label),
              const SizedBox(height: 2),
              Text(folder, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: Ty.caption.copyWith(fontSize: 10)),
            ])),
            IconButton(
              icon: Icon(Icons.push_pin_rounded, size: 16, color: Vz.red),
              onPressed: ()async{ await Store.toggleSavedFolder(folder); if(mounted) setState((){}); }),
          ]),
        );
      },
    );
  }

  void _openFolder(String path){
    // شِل به این سیگنال گوش می‌دهد: به Home سوئیچ می‌کند و پوشه را باز می‌کند
    vzOpenFolderSignal.value = path;
    vzOpenFolderSignal.notifyListeners();
  }

  Widget _empty(IconData icon, String title) => VzEmpty(
    icon: icon, title: title,
    hint: switch(_tab){
      4 => L.pinFolderHint,
      _ => null,
    });
}
