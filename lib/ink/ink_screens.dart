// lib/ink/ink_screens.dart
// Screens written from scratch for the INK language. They talk to the existing
// services (Store / PlayerScreen / permissions) but share no widget code with
// the legacy NOVA screens.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../l10n.dart';
import '../player.dart';
import '../store.dart';
import 'ink_components.dart';

const Set<String> kInkVideos = {
  '.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.m4v', '.ts', '.3gp', '.mpg',
};

enum InkSort { name, size, date }

extension on InkSort {
  String get label => switch (this) {
        InkSort.name => 'Name',
        InkSort.size => 'Size',
        InkSort.date => 'Date',
      };
}

/// Existing, readable storage roots — used as quick jumps.
List<String> inkStorageRoots() {
  const candidates = [
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Movies',
    '/storage/emulated/0/DCIM/Camera',
    '/storage/emulated/0',
    '/storage',
  ];
  final found = <String>[];
  for (final path in candidates) {
    try {
      if (Directory(path).existsSync()) found.add(path);
    } on FileSystemException {
      // unreadable mount — skip
    }
  }
  return found;
}

String inkHumanSize(int bytes) {
  if (bytes >= 1 << 30) return '${(bytes / (1 << 30)).toStringAsFixed(1)} GB';
  if (bytes >= 1 << 20) return '${(bytes / (1 << 20)).toStringAsFixed(1)} MB';
  if (bytes >= 1 << 10) return '${(bytes / (1 << 10)).toStringAsFixed(0)} KB';
  return '$bytes B';
}

Future<bool> inkEnsureStoragePermission() async {
  if (await Permission.manageExternalStorage.isGranted) return true;
  if ((await Permission.manageExternalStorage.request()).isGranted) return true;
  if (await Permission.storage.isGranted) return true;
  return (await Permission.storage.request()).isGranted;
}

void inkPlay(BuildContext context, String path) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => PlayerScreen(
      playlist: [File(path)],
      playlistIndex: 0,
      subtitlePath: matchSubtitle(path),
    ),
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
//  FILES
// ─────────────────────────────────────────────────────────────────────────────

class InkFilesScreen extends StatefulWidget {
  const InkFilesScreen({super.key});
  @override
  State<InkFilesScreen> createState() => _InkFilesScreenState();
}

class _InkFilesScreenState extends State<InkFilesScreen> {
  final TextEditingController _search = TextEditingController();
  late final List<String> _roots = inkStorageRoots();

  String? _cwd;
  String _query = '';
  InkSort _sort = InkSort.name;
  bool _granted = false;
  bool _loading = true;
  bool _onlyVideos = true;
  List<FileSystemEntity> _entries = const [];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await Store.load();
    final granted = await inkEnsureStoragePermission();
    if (!mounted) return;
    setState(() => _granted = granted);
    if (!granted) {
      setState(() => _loading = false);
      return;
    }
    final fallback = _roots.isEmpty ? '' : _roots.first;
    final start = Store.savedFolders.firstWhere(
      (f) => Directory(f).existsSync(),
      orElse: () => fallback,
    );
    await _open(start);
  }

  Future<void> _open(String path) async {
    if (path.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    List<FileSystemEntity> entries = const [];
    try {
      entries = Directory(path).listSync(followLinks: false);
    } on FileSystemException {
      entries = const [];
    }
    if (!mounted) return;
    setState(() {
      _cwd = path;
      _entries = entries;
      _loading = false;
      _query = '';
    });
    _search.clear();
  }

  int _sizeOf(FileSystemEntity e) {
    if (e is! File) return 0;
    try {
      return e.lengthSync();
    } on FileSystemException {
      return 0;
    }
  }

  int _modifiedOf(FileSystemEntity e) {
    try {
      return e.statSync().modified.millisecondsSinceEpoch;
    } on FileSystemException {
      return 0;
    }
  }

  /// Folders first, then the selected ordering.
  List<FileSystemEntity> get _visible {
    final q = _query.trim().toLowerCase();
    final list = <FileSystemEntity>[];
    for (final e in _entries) {
      final name = p.basename(e.path);
      if (name.startsWith('.')) continue;
      final isDir = e is Directory;
      if (_onlyVideos &&
          !isDir &&
          !kInkVideos.contains(p.extension(name).toLowerCase())) {
        continue;
      }
      if (q.isNotEmpty && !name.toLowerCase().contains(q)) continue;
      list.add(e);
    }
    int byName(FileSystemEntity a, FileSystemEntity b) => p
        .basename(a.path)
        .toLowerCase()
        .compareTo(p.basename(b.path).toLowerCase());
    switch (_sort) {
      case InkSort.name:
        list.sort(byName);
      case InkSort.size:
        list.sort((a, b) {
          final dirOrder = _dirRank(a).compareTo(_dirRank(b));
          if (dirOrder != 0) return dirOrder;
          return _sizeOf(b).compareTo(_sizeOf(a));
        });
      case InkSort.date:
        list.sort((a, b) {
          final dirOrder = _dirRank(a).compareTo(_dirRank(b));
          if (dirOrder != 0) return dirOrder;
          return _modifiedOf(b).compareTo(_modifiedOf(a));
        });
    }
    return list;
  }

  int _dirRank(FileSystemEntity e) => e is Directory ? 0 : 1;

  void _openEntry(FileSystemEntity e) {
    if (e is Directory) {
      _open(e.path);
      return;
    }
    inkPlay(context, e.path);
  }

  Future<void> _entryActions(FileSystemEntity e) async {
    final path = e.path;
    final name = p.basename(path);
    final isDir = e is Directory;
    final pinned = Store.savedFolders.contains(path);
    await showInkSheet<void>(
      context: context,
      title: name,
      kicker: isDir ? 'folder' : inkHumanSize(_sizeOf(e)),
      child: Padding(
        padding: const EdgeInsets.all(InkSp.x4),
        child: Wrap(spacing: InkSp.x2, runSpacing: InkSp.x2, children: [
          if (!isDir)
            InkButton(
              icon: Icons.play_arrow_rounded,
              label: 'Play',
              onTap: () {
                Navigator.of(context).pop();
                inkPlay(context, path);
              },
            ),
          if (!isDir)
            InkOutlineButton(
              icon: Icons.star_border_rounded,
              label: Store.favorited.contains(path) ? 'Unfavorite' : 'Favorite',
              onTap: () async {
                await Store.toggleFavorite(path);
                if (mounted) Navigator.of(context).pop();
              },
            ),
          if (!isDir)
            InkOutlineButton(
              icon: Icons.bookmark_border_rounded,
              label: Store.bookmarked.contains(path) ? 'Unbookmark' : 'Bookmark',
              onTap: () async {
                await Store.toggleBookmark(path);
                if (mounted) Navigator.of(context).pop();
              },
            ),
          InkOutlineButton(
            icon: isDir
                ? (pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined)
                : Icons.copy_all_rounded,
            label: isDir
                ? (pinned ? 'Unpin folder' : 'Pin folder')
                : 'Copy path',
            onTap: () async {
              if (isDir) {
                await Store.toggleSavedFolder(path);
              } else {
                await Clipboard.setData(ClipboardData(text: path));
              }
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_granted && !_loading) {
      return InkEmpty(
        icon: Icons.folder_off_rounded,
        title: 'Storage access needed',
        hint: L.permissionNeeded,
        action: InkButton(
          icon: Icons.lock_open_rounded,
          label: 'Grant access',
          onTap: () async {
            final ok = await inkEnsureStoragePermission();
            if (!mounted) return;
            setState(() => _granted = ok);
            if (ok) await _boot();
          },
        ),
      );
    }
    final entries = _visible;
    final atRoot = _cwd == null || _cwd == '/' || _roots.contains(_cwd);
    return Column(children: [
      InkHeader(
        title: _cwd == null ? 'Files' : p.basename(_cwd!),
        kicker: _cwd ?? 'no folder open',
        trailing: InkIconButton(
          icon: Icons.arrow_upward_rounded,
          tooltip: 'Parent folder',
          onTap: atRoot ? null : () => _open(p.dirname(_cwd!)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: InkSp.x4),
        child: Row(children: [
          Expanded(
            child: InkField(
              controller: _search,
              hint: 'Filter by name',
              icon: Icons.search_rounded,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(width: InkSp.x2),
          InkIconButton(
            icon: _onlyVideos ? Icons.videocam_rounded : Icons.select_all_rounded,
            tooltip: _onlyVideos ? 'Video files only' : 'All files',
            selected: _onlyVideos,
            onTap: () => setState(() => _onlyVideos = !_onlyVideos),
          ),
        ]),
      ),
      const SizedBox(height: InkSp.x3),
      InkRule(label: '${entries.length} items · by ${_sort.label}'),
      Padding(
        padding: const EdgeInsets.fromLTRB(InkSp.x4, InkSp.x3, InkSp.x4, 0),
        child: Wrap(spacing: InkSp.x2, runSpacing: InkSp.x2, children: [
          for (final s in InkSort.values)
            GestureDetector(
              onTap: () => setState(() => _sort = s),
              child: InkBadge(
                text: s.label,
                filled: _sort == s,
                color: _sort == s ? Ink.accent : Ink.inkFaint,
              ),
            ),
        ]),
      ),
      const SizedBox(height: InkSp.x2),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : entries.isEmpty
                ? InkEmpty(
                    icon: Icons.movie_filter_rounded,
                    title: 'Nothing here',
                    hint: _query.isEmpty
                        ? 'Try another folder from the roots below'
                        : 'No item matches "$_query"',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        InkSp.x4, InkSp.x2, InkSp.x4, InkSp.x6),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: InkSp.x2),
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      final isDir = e is Directory;
                      final name = p.basename(e.path);
                      final ext = p.extension(name).replaceFirst('.', '');
                      return InkCard(
                        index: i + 1,
                        accentBar: isDir,
                        onTap: () => _openEntry(e),
                        semanticLabel: name,
                        padding: const EdgeInsets.symmetric(
                            horizontal: InkSp.x3, vertical: InkSp.x3),
                        child: Row(children: [
                          Icon(
                            isDir
                                ? Icons.folder_rounded
                                : Icons.play_circle_outline_rounded,
                            size: 20,
                            color: isDir ? Ink.accent : Ink.inkSoft,
                          ),
                          const SizedBox(width: InkSp.x3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      InkType.label.copyWith(color: Ink.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isDir ? 'folder' : inkHumanSize(_sizeOf(e)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: InkType.micro.copyWith(
                                      fontSize: 9, color: Ink.inkFaint),
                                ),
                              ],
                            ),
                          ),
                          if (!isDir && ext.isNotEmpty)
                            InkBadge(text: ext, color: Ink.inkFaint),
                          const SizedBox(width: InkSp.x2),
                          InkIconButton(
                            icon: Icons.more_horiz_rounded,
                            tooltip: 'Actions',
                            box: 34,
                            size: 16,
                            onTap: () => _entryActions(e),
                          ),
                        ]),
                      );
                    },
                  ),
      ),
      if (_roots.length > 1) ...[
        const InkRule(label: 'roots'),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: InkSp.x4, vertical: InkSp.x2),
            itemCount: _roots.length,
            separatorBuilder: (_, __) => const SizedBox(width: InkSp.x2),
            itemBuilder: (context, i) => InkOutlineButton(
              label: p.basename(_roots[i]),
              onTap: () => _open(_roots[i]),
            ),
          ),
        ),
      ],
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RECENT
// ────────────────────────────────────────────────────────────────────────────

/// Ledger of what the user watched, starred, bookmarked and collected.
class InkRecentScreen extends StatefulWidget {
  const InkRecentScreen({super.key});
  @override
  State<InkRecentScreen> createState() => _InkRecentScreenState();
}

class _InkRecentScreenState extends State<InkRecentScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Store.load();
    if (mounted) setState(() => _ready = true);
  }

  Future<void> _actions(String path) async {
    final exists = File(path).existsSync();
    await showInkSheet<void>(
      context: context,
      title: p.basename(path),
      kicker: exists ? 'on storage' : 'file missing',
      child: Padding(
        padding: const EdgeInsets.all(InkSp.x4),
        child: Wrap(spacing: InkSp.x2, runSpacing: InkSp.x2, children: [
          if (exists)
            InkButton(
              icon: Icons.play_arrow_rounded,
              label: 'Play',
              onTap: () {
                Navigator.of(context).pop();
                inkPlay(context, path);
              },
            ),
          InkOutlineButton(
            icon: Icons.star_border_rounded,
            label: Store.favorited.contains(path) ? 'Unfavorite' : 'Favorite',
            onTap: () async {
              await Store.toggleFavorite(path);
              if (!mounted) return;
              setState(() {});
              Navigator.of(context).pop();
            },
          ),
          InkOutlineButton(
            icon: Icons.bookmark_border_rounded,
            label: Store.bookmarked.contains(path) ? 'Unbookmark' : 'Bookmark',
            onTap: () async {
              await Store.toggleBookmark(path);
              if (!mounted) return;
              setState(() {});
              Navigator.of(context).pop();
            },
          ),
          InkOutlineButton(
            icon: Icons.history_toggle_off_rounded,
            label: 'Forget',
            onTap: () async {
              await Store.removeFromHistory(path);
              if (!mounted) return;
              setState(() {});
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
    );
  }

  Widget _section(String label, List<String> paths, {String? emptyHint}) {
    if (paths.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkRule(label: label),
        Padding(
          padding: const EdgeInsets.all(InkSp.x4),
          child: Text(emptyHint ?? 'Nothing yet',
              style: InkType.body.copyWith(color: Ink.inkFaint)),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkRule(label: '$label · ${paths.length}'),
      const SizedBox(height: InkSp.x2),
      for (var i = 0; i < paths.length; i++)
        Padding(
          padding: const EdgeInsets.fromLTRB(InkSp.x4, 0, InkSp.x4, InkSp.x2),
          child: InkCard(
            index: i + 1,
            onTap: () => inkPlay(context, paths[i]),
            semanticLabel: p.basename(paths[i]),
            child: Row(children: [
              Icon(
                File(paths[i]).existsSync()
                    ? Icons.play_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 20,
                color: File(paths[i]).existsSync() ? Ink.inkSoft : Ink.danger,
              ),
              const SizedBox(width: InkSp.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.basename(paths[i]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: InkType.label.copyWith(color: Ink.ink)),
                    const SizedBox(height: 2),
                    Text(p.dirname(paths[i]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: InkType.micro
                            .copyWith(fontSize: 9, color: Ink.inkFaint)),
                  ],
                ),
              ),
              InkIconButton(
                icon: Icons.more_horiz_rounded,
                tooltip: 'Actions',
                box: 34,
                size: 16,
                onTap: () => _actions(paths[i]),
              ),
            ]),
          ),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());
    final history = Store.watchHistory;
    final favorites = Store.favorited.toList();
    final bookmarks = Store.bookmarked.toList();
    final playlists = Store.playlists;
    final total = history.length + favorites.length + bookmarks.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: InkSp.x6),
      children: [
        InkHeader(
          title: 'Recent',
          kicker: '$total tracked · ${playlists.length} playlists',
          trailing: InkIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Reload',
            onTap: _load,
          ),
        ),
        if (total == 0 && playlists.isEmpty)
          const InkEmpty(
            icon: Icons.history_rounded,
            title: 'No history yet',
            hint: 'Play something from the Files tab and it appears here.',
          ),
        _section('history', history, emptyHint: 'Nothing watched yet'),
        _section('favorites', favorites, emptyHint: 'No favorites yet'),
        _section('bookmarks', bookmarks, emptyHint: 'No bookmarks yet'),
        if (playlists.isNotEmpty) ...[
          const InkRule(label: 'playlists'),
          const SizedBox(height: InkSp.x2),
          for (final entry in playlists.entries)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(InkSp.x4, 0, InkSp.x4, InkSp.x2),
              child: InkCard(
                accentBar: true,
                semanticLabel: entry.key,
                child: Row(children: [
                  const Icon(Icons.queue_music_rounded,
                      size: 20, color: Ink.accent),
                  const SizedBox(width: InkSp.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: InkType.label.copyWith(color: Ink.ink)),
                        const SizedBox(height: 2),
                        Text('${entry.value.length} items',
                            style: InkType.micro
                                .copyWith(fontSize: 9, color: Ink.inkFaint)),
                      ],
                    ),
                  ),
                  InkIconButton(
                    icon: Icons.playlist_play_rounded,
                    tooltip: 'Play playlist',
                    box: 34,
                    size: 18,
                    selected: entry.value.isNotEmpty,
                    onTap: entry.value.isEmpty
                        ? null
                        : () => inkPlay(context, entry.value.first),
                  ),
                ]),
              ),
            ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SETUP
// ─────────────────────────────────────────────────────────────────────────────

/// Appearance, language, storage and about — written in the INK language.
class InkSetupScreen extends StatefulWidget {
  const InkSetupScreen({super.key});
  @override
  State<InkSetupScreen> createState() => _InkSetupScreenState();
}

class _InkSetupScreenState extends State<InkSetupScreen> {
  static const String _themeKey = 'ink_theme';

  late final List<String> _roots = inkStorageRoots();
  bool _granted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final granted = await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted;
    if (mounted) setState(() => _granted = granted);
  }

  Future<void> _persistTheme(bool dark) async {
    Ink.setDark(dark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, dark ? 'dark' : 'light');
  }

  Widget _card({
    required String title,
    required String caption,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(InkSp.x4, 0, InkSp.x4, InkSp.x3),
      child: InkCard(
        accentBar: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 20, color: Ink.accent),
            const SizedBox(width: InkSp.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.toUpperCase(),
                      style: InkType.micro.copyWith(color: Ink.inkFaint)),
                  const SizedBox(height: 2),
                  Text(caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          InkType.heading.copyWith(fontSize: 14, color: Ink.ink)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: InkSp.x3),
          ...children,
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Ink.isDark;
    return ListView(
      padding: const EdgeInsets.only(bottom: InkSp.x6),
      children: [
        const InkHeader(
          title: 'Setup',
          kicker: 'appearance · language · storage',
        ),
        _card(
          title: 'appearance',
          caption: dark ? 'Carbon paper (dark)' : 'Warm paper (light)',
          icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          children: [
            Row(children: [
              InkBadge(
                text: 'Light',
                filled: !dark,
                color: !dark ? Ink.accent : Ink.inkFaint,
              ),
              const SizedBox(width: InkSp.x2),
              InkBadge(
                text: 'Dark',
                filled: dark,
                color: dark ? Ink.accent : Ink.inkFaint,
              ),
              const Spacer(),
              Switch(value: dark, onChanged: _persistTheme),
            ]),
            const SizedBox(height: InkSp.x2),
            Text(
              'INK keeps surfaces flat: ink outlines, sharp corners and hard '
              'offset shadows instead of blur or glow.',
              style: InkType.body.copyWith(color: Ink.inkFaint),
            ),
          ],
        ),
        _card(
          title: 'language',
          caption: '${kLangNames[L.current] ?? L.current} · ${L.current}',
          icon: Icons.translate_rounded,
          children: [
            Wrap(spacing: InkSp.x2, runSpacing: InkSp.x2, children: [
              for (final code in kSupportedLangs)
                GestureDetector(
                  onTap: () async {
                    await L.set(code);
                    if (mounted) setState(() {});
                  },
                  child: InkBadge(
                    text: kLangNames[code] ?? code,
                    filled: L.current == code,
                    color: L.current == code ? Ink.accent : Ink.inkFaint,
                  ),
                ),
            ]),
          ],
        ),
        _card(
          title: 'storage',
          caption: _granted ? 'Access granted' : 'Access required',
          icon: _granted
              ? Icons.check_circle_outline_rounded
              : Icons.lock_outline_rounded,
          children: [
            if (!_granted)
              InkButton(
                icon: Icons.lock_open_rounded,
                label: _busy ? 'Requesting' : 'Grant storage access',
                onTap: _busy
                    ? null
                    : () async {
                        setState(() => _busy = true);
                        await inkEnsureStoragePermission();
                        await _refreshPermission();
                        if (mounted) setState(() => _busy = false);
                      },
              ),
            if (_granted)
              Wrap(spacing: InkSp.x2, runSpacing: InkSp.x2, children: [
                for (final root in _roots)
                  GestureDetector(
                    onTap: () async {
                      await Store.toggleSavedFolder(root);
                      if (mounted) setState(() {});
                    },
                    child: InkBadge(
                      text: p.basename(root),
                      filled: Store.savedFolders.contains(root),
                      color: Store.savedFolders.contains(root)
                          ? Ink.accent
                          : Ink.inkFaint,
                    ),
                  ),
              ]),
          ],
        ),
        _card(
          title: 'about',
          caption: 'Vezoo ${ApiService.appVersion}',
          icon: Icons.info_outline_rounded,
          children: [
            Text(
              'UI language: INK (flat paper). The player engine and the AI '
              'subtitle pipeline are shared with the default build.',
              style: InkType.body.copyWith(color: Ink.inkFaint),
            ),
            const SizedBox(height: InkSp.x3),
            InkOutlineButton(
              icon: Icons.history_toggle_off_rounded,
              label: 'Clear watch history',
              onTap: () async {
                final ok = await showInkConfirm(
                  context: context,
                  title: 'clear history',
                  message: 'Removes watch history on this device. '
                      'No file is deleted.',
                  confirmLabel: 'Clear',
                  destructive: true,
                );
                if (!ok) return;
                await Store.clearHistory();
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }
}