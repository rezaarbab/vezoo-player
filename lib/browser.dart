// lib/browser.dart — Home: مرورگر فایل media-first (NOVA)
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'store.dart';
import 'player.dart';
import 'main.dart' show showSnack;
import 'l10n.dart';
import 'glass.dart';

// ── پالت NOVA — سازگاری با صفحات داخلی ──
Color get kBg      => Vz.bg;
Color get kSurface => Vz.surface;
Color get kCard    => Vz.card;
Color get kBorder  => Vz.border;
Color get kAccent  => Vz.accent;
Color get kCyan    => Vz.accentHi;
Color get kGreen   => Vz.green;
Color get kAmber   => Vz.amber;
Color get kRed     => Vz.red;
Color get kPink    => Vz.magenta;
Color get kTextSec => Vz.textSec;
Color get kTextDim => Vz.textDim;

enum _SortBy{name,date,size,type}

LinearGradient _extGrad(String ext){
  switch(ext){
    case 'mp4': return const LinearGradient(colors:[Color(0xFF7C5CFC),Color(0xFF46349B)]);
    case 'mkv': return LinearGradient(colors:[Vz.accent,Color(0xFF5A4199)]);
    case 'avi': return const LinearGradient(colors:[Color(0xFF9F7AE8),Color(0xFF5D48A8)]);
    case 'mov': return LinearGradient(colors:[Vz.magenta,Color(0xFF8F2B5B)]);
    case 'webm':return const LinearGradient(colors:[Color(0xFF6D28D9),Color(0xFF3B1B75)]);
    case 'flv': return const LinearGradient(colors:[Color(0xFF5B2DA0),Color(0xFF2F1A52)]);
    default:    return LinearGradient(colors:[Vz.cardHi,Vz.surface]);
  }
}

Widget _badge(String text,Color color)=>Container(
  padding:const EdgeInsets.symmetric(horizontal:6,vertical:2),
  decoration:BoxDecoration(color:color.withValues(alpha: 0.12),borderRadius:BorderRadius.circular(5),
      border:Border.all(color:color.withValues(alpha: 0.35),width:0.7)),
  child:Text(text,style:TextStyle(fontSize:10,color:color,fontWeight:FontWeight.w600,height:1.2)),
);

// ── کش thumbnail با MethodChannel → MediaMetadataRetriever ──
final Map<String,Uint8List?> _thumbCache={};
const _thumbChannel=MethodChannel('ir.subteam.subtitle_player/thumbnail');
Future<Uint8List?> _loadThumb(String path)async{
  if(_thumbCache.containsKey(path))return _thumbCache[path];
  try{
    final data=await _thumbChannel.invokeMethod<Uint8List>('getThumbnail',{'path':path,'timeMs':2000,'width':160,'height':90});
    return _thumbCache[path]=data;
  }catch(_){return _thumbCache[path]=null;}
}

// ─────────────────────────────────────────────────────────────────────────────
class BrowserScreen extends StatefulWidget{
  const BrowserScreen({super.key});
  @override State<BrowserScreen> createState()=>BrowserScreenState();
}

class BrowserScreenState extends State<BrowserScreen>{
  static const root='/storage/emulated/0';
  bool _granted=false,_checking=true;
  String _path=root;
  List<Directory> _dirs=[];
  List<File> _videos=[];
  bool _selectMode=false;
  final Set<String> _selected={};
  _SortBy _sortBy=_SortBy.name;
  bool _sortDesc=false;
  _LibLayout _layout=_LibLayout.grid;
  bool _searching=false;
  // جستجو: false=عادی، true=بازگشتی در کل حافظه
  bool _globalSearch=false;
  String _searchQuery='';
  List<File> _searchResults=[];
  bool _searchRunning=false;
  final TextEditingController _searchCtrl=TextEditingController();

  @override void initState(){super.initState();_init();}
  @override void dispose(){_searchCtrl.dispose();super.dispose();}

  Future<void> _init()async{
    await Store.load();
    // چیدمان ذخیره‌شده کاربر
    try{
      final p0=await SharedPreferences.getInstance();
      final raw=p0.getString('lib_layout');
      final l=_LibLayout.values.where((e)=>e.name==raw).firstOrNull;
      if(l!=null&&mounted)setState(()=>_layout=l);
    }catch(_){}
    await _ensurePermission();
  }

  Future<void> _ensurePermission()async{
    setState(()=>_checking=true);
    var ok=await Permission.manageExternalStorage.isGranted;
    if(!ok)ok=(await Permission.manageExternalStorage.request()).isGranted;
    if(!ok)ok=(await Permission.storage.request()).isGranted;
    setState((){_granted=ok;_checking=false;});
    if(ok)_loadDir(_path);
  }

  void _loadDir(String path){
    try{
      final items=Directory(path).listSync(followLinks:false);
      final dirs=items.whereType<Directory>().toList();
      final vids=items.whereType<File>().where(
          (f)=>kVideoExt.contains(p.extension(f.path).toLowerCase())).toList();
      dirs.sort((a,b)=>p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase()));
      setState((){_path=path;_dirs=dirs;_videos=vids;_selectMode=false;
        _selected.clear();_searching=false;_searchQuery='';_searchCtrl.clear();
        _searchResults=[];_globalSearch=false;});
    }catch(_){
      if(mounted)showSnack(context, L.noAccess);
    }
  }
  void _goUp(){final par=p.dirname(_path);if(par!=_path&&par.startsWith('/storage'))_loadDir(par);}

  /// API عمومی برای شِل — بازکردن مسیر از Library
  void openPath(String path){ if(Directory(path).existsSync()) _loadDir(path); }

  int _sd(int v)=>_sortDesc?-v:v;
  List<File> get _sortedVideos{
    final s=List<File>.from(_videos);
    switch(_sortBy){
      case _SortBy.name:s.sort((a,b)=>_sd(p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase())));break;
      case _SortBy.date:s.sort((a,b){try{return _sd(a.lastModifiedSync().compareTo(b.lastModifiedSync()));}catch(_){return 0;}});break;
      case _SortBy.size:s.sort((a,b){try{return _sd(a.lengthSync().compareTo(b.lengthSync()));}catch(_){return 0;}});break;
      case _SortBy.type:s.sort((a,b)=>_sd(p.extension(a.path).compareTo(p.extension(b.path))));break;
    }
    return s;
  }
  List<File> get _filteredVideos{
    if(!_searching||_searchQuery.isEmpty)return _sortedVideos;
    if(_globalSearch)return _searchResults;
    return _sortedVideos.where((f)=>p.basename(f.path).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }
  List<Directory> get _filteredDirs{
    if(!_searching||_searchQuery.isEmpty||_globalSearch)return _globalSearch?[]:_dirs;
    return _dirs.where((d)=>p.basename(d.path).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // جستجوی سراسری — recursion دستی تا پوشه‌های ممنوع skip بشن
  Future<void> _runGlobalSearch(String query)async{
    if(query.isEmpty){setState((){_searchResults=[];_searchRunning=false;});return;}
    setState((){_searchResults=[];_searchRunning=true;});
    final results=<File>[];
    final q=query.toLowerCase();
    // شروع از ریشه کل حافظه
    await _deepSearch(Directory(root),q,results);
    // اگه SD card داشت اونم بگرده
    for(final d in _getStorageDevices()){
      if(mounted&&_searchRunning)await _deepSearch(d,q,results);
    }
    if(mounted)setState(()=>_searchRunning=false);
  }

  Future<void> _deepSearch(Directory dir,String query,List<File> results)async{
    if(!mounted||!_searchRunning)return;
    List<FileSystemEntity> entities;
    try{entities=await dir.list(recursive:false).toList();}catch(_){return;}
    for(final e in entities){
      if(!mounted||!_searchRunning)return;
      if(e is File){
        if(kVideoExt.contains(p.extension(e.path).toLowerCase())&&
            p.basename(e.path).toLowerCase().contains(query)){
          results.add(e);
          if(mounted)setState(()=>_searchResults=List.from(results));
        }
      }else if(e is Directory){
        // skip پوشه‌های سیستمی
        final name=p.basename(e.path);
        if(!name.startsWith('.')&&name!='proc'&&name!='sys'&&name!='dev'){
          await _deepSearch(e,query,results);
        }
      }
    }
  }

  Future<void> _openVideo(File video,[List<File>?playlist,int?idx])async{
    final pl=playlist??_filteredVideos;
    final i=idx??pl.indexOf(video);
    await Navigator.push(context,MaterialPageRoute(
      builder:(_)=>PlayerScreen(subtitlePath:matchSubtitle(video.path),playlist:pl,playlistIndex:i<0?0:i),
    ));
    await Store.load();
    if(mounted)setState((){});
  }

  Future<void> _openVideoByPath(String path)async{
    final f=File(path);
    if(!f.existsSync()){showSnack(context, L.fileNotFound);return;}
    await _openVideo(f,[f],0);
  }

  List<Directory> _getStorageDevices(){
    final r=<Directory>[];
    try{for(final e in Directory('/storage').listSync()){
      if(e is Directory&&p.basename(e.path)!='emulated'&&p.basename(e.path)!='self')r.add(e);
    }}catch(_){}
    return r;
  }

  void _showVideoMenu(File f){
    showVzSheet(context: context,
      builder:(ctx)=>VideoMenu(
        file:f,
        onDone:()async{Navigator.pop(ctx);await Store.load();_loadDir(_path);},
        onInfo:(){Navigator.pop(ctx);_showFileInfo(f);},
        onDelete:(){Navigator.pop(ctx);_confirmDelete([f]);},
        onRename:(){Navigator.pop(ctx);_renameFile(f);},
        onSelect:(){Navigator.pop(ctx);setState((){_selectMode=true;_selected.add(f.path);});},
        onCopy:(){Navigator.pop(ctx);_copyFile(f);},
        onMove:(){Navigator.pop(ctx);_moveFile(f);},
        onRate:(){Navigator.pop(ctx);_showRating(f);},
        onNote:(){Navigator.pop(ctx);_showNote(f);},
      ),
    );
  }

  Future<void> _copyFile(File f)async{
    if(Store.savedFolders.isEmpty){showSnack(context, L.noFolderSaved);return;}
    final dest=await _pickFolder(L.copyTo);
    if(dest==null)return;
    try{await f.copy(p.join(dest,p.basename(f.path)));
      if(mounted)showSnack(context, L.copied);}
    catch(_){if(mounted)showSnack(context, L.error);}
  }

  Future<void> _moveFile(File f)async{
    final dest=await _pickFolder(L.transferTo);if(dest==null)return;
    final newPath=p.join(dest,p.basename(f.path));
    try{await f.rename(newPath);}
    catch(_){try{await f.copy(newPath);await f.delete();}catch(e){if(mounted)showSnack(context, L.error);return;}}
    _loadDir(_path);
  }

  Future<String?> _pickFolder(String title)async{
    final all=[...Store.savedFolders];
    if(all.isEmpty){showSnack(context, L.noFolderSaved);return null;}
    return showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(title),
      content:Column(mainAxisSize:MainAxisSize.min,children:all.map((folder)=>ListTile(
        leading:Icon(Icons.folder_rounded,color:kAmber),title:Text(p.basename(folder)),
        onTap:()=>Navigator.pop(ctx,folder),
      )).toList()),
    ));
  }

  Future<void> _confirmDelete(List<File> files)async{
    final ok=await showDialog<bool>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(L.deleteFile),
      content:Text(files.length==1?'${L.delete} «${p.basename(files.first.path)}»?':'${files.length} ${L.delete}?'),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(ctx,false),child:Text(L.cancel)),
        FilledButton(style:FilledButton.styleFrom(backgroundColor:kRed),onPressed:()=>Navigator.pop(ctx,true),child:Text(L.delete)),
      ],
    ));
    if(ok!=true)return;
    for(final f in files){try{await f.delete();}catch(_){}}
    _loadDir(_path);
  }

  Future<void> _renameFile(File f)async{
    final ctrl=TextEditingController(text:p.basenameWithoutExtension(f.path));
    final name=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
      title:Text(L.rename_),
      content:TextField(controller:ctrl,autofocus:true,
          decoration:InputDecoration(hintText:L.newName,border:OutlineInputBorder(),contentPadding:EdgeInsets.symmetric(horizontal:12,vertical:8))),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.cancel)),
        FilledButton(onPressed:()=>Navigator.pop(ctx,ctrl.text.trim()),child:Text(L.confirm)),
      ],
    ));
    if(name==null||name.isEmpty)return;
    try{await f.rename(p.join(p.dirname(f.path),'$name${p.extension(f.path)}'));_loadDir(_path);}
    catch(_){if(mounted)showSnack(context, L.error);}
  }

  Future<void> _showRating(File f)async{
    int rating=Store.ratings[f.path]??0;
    await showDialog(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,ss)=>AlertDialog(
      title:Text(p.basename(f.path),style:const TextStyle(fontSize:13)),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(L.yourRatingLabel,style:TextStyle(color:kTextSec)),const SizedBox(height:12),
        Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(5,(i)=>GestureDetector(
          onTap:()=>ss(()=>rating=i+1),
          child:Padding(padding:const EdgeInsets.all(4),
              child:Icon(i<rating?Icons.star_rounded:Icons.star_outline_rounded,color:kAmber,size:36)),
        ))),
      ]),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.cancel)),
        if(rating>0)TextButton(onPressed:()async{await Store.saveRating(f.path,0);Navigator.pop(ctx);setState((){});},child:Text(L.delete,style:TextStyle(color:kRed))),
        FilledButton(onPressed:()async{await Store.saveRating(f.path,rating);Navigator.pop(ctx);setState((){});},child:Text(L.save)),
      ],
    )));
  }

  Future<void> _showNote(File f)async{
    final ctrl=TextEditingController(text:Store.notes[f.path]??'');
    await showDialog(context:context,builder:(ctx)=>AlertDialog(
      title:Text(L.note),
      content:TextField(controller:ctrl,maxLines:5,autofocus:true,
          decoration:InputDecoration(hintText:L.writtenNote,border:OutlineInputBorder(),contentPadding:EdgeInsets.all(12))),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.cancel)),
        FilledButton(onPressed:()async{await Store.saveNote(f.path,ctrl.text.trim());Navigator.pop(ctx);setState((){});},child:Text(L.save)),
      ],
    ));
  }

  Future<void> _showFileInfo(File f)async{
    final sub=matchSubtitle(f.path);
    final allSubs=findAllSubtitles(f.path);
    String modified='';
    try{modified=f.lastModifiedSync().toString().split('.').first;}catch(_){}
    final dur=await Store.getDur(f.path);
    final rating=Store.ratings[f.path]??0;
    final note=Store.notes[f.path]??'';
    int fileSize=0;try{fileSize=f.lengthSync();}catch(_){}
    final ext=p.extension(f.path).toLowerCase().replaceAll('.','');
    // اطلاعات فرمت از پسوند
    final String codecHint=_codecHint(ext);
    if(!mounted)return;
    showDialog(context:context,builder:(ctx)=>AlertDialog(
      contentPadding:const EdgeInsets.fromLTRB(16,16,16,8),
      title:Row(children:[
        Container(width:4,height:20,decoration:BoxDecoration(color:kAccent,borderRadius:BorderRadius.circular(2))),
        const SizedBox(width:8),
        Expanded(child:Text(p.basename(f.path),style:const TextStyle(fontSize:13,fontWeight:FontWeight.w600))),
      ]),
      content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        _iRow(Icons.folder_open_rounded,kTextSec,L.path,p.dirname(f.path)),
        _iRow(Icons.video_file_rounded,kCyan,L.format,ext.toUpperCase()),
        _iRow(Icons.data_usage_outlined,kTextSec,L.sortSize,sizeStr(f)),
        if(fileSize>0)_iRow(Icons.straighten_rounded,kTextSec,L.precise,'${fileSize} bytes'),
        if(dur>0)_iRow(Icons.timer_outlined,kCyan,L.duration,fmt(Duration(seconds:dur))),
        _iRow(Icons.calendar_today_outlined,kTextSec,L.sortDate,modified),
        _iRow(Icons.info_outline_rounded,kAccent,L.probableCodec,codecHint),
        _iRow(Icons.visibility_outlined,Store.watched.contains(f.path)?kGreen:kTextSec,
            L.status,Store.watched.contains(f.path)?L.watched:L.notWatched),
        if(rating>0)_iRow(Icons.star_rounded,kAmber,L.rating,'${'★'*rating}${'☆'*(5-rating)}'),
        if(note.isNotEmpty)_iRow(Icons.notes_rounded,kTextSec,L.note,note),
        if(allSubs.isNotEmpty)...[
          _iRow(Icons.subtitles_rounded,kGreen,L.subtitle,'${allSubs.length}'),
          ...allSubs.map((s)=>Padding(
            padding:const EdgeInsets.only(right:24,top:2),
            child:Row(children:[
              Icon(Icons.fiber_manual_record_rounded,size:8,color:kGreen.withValues(alpha: 0.6)),
              const SizedBox(width:6),
              Expanded(child:Text(p.basename(s),style:TextStyle(fontSize:11,color:kTextSec))),
            ]),
          )),
        ]else _iRow(Icons.subtitles_rounded,kTextDim,L.subtitle,L.notFound),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.close))],
    ));
  }

  // کدک احتمالی بر اساس پسوند
  String _codecHint(String ext){
    switch(ext){
      case 'mp4': return 'H.264/H.265 (MPEG-4)';
      case 'mkv': return 'H.264/H.265/AV1 (Matroska)';
      case 'avi': return 'DivX/Xvid/MPEG-4';
      case 'mov': return 'H.264/ProRes (QuickTime)';
      case 'webm': return 'VP8/VP9/AV1';
      case 'flv': return 'H.263/H.264 (Flash)';
      case 'ts': return 'H.264/MPEG-2 (Transport Stream)';
      case 'wmv': return 'WMV/VC-1';
      case 'mpg': case 'mpeg': return 'MPEG-1/MPEG-2';
      case 'm4v': return 'H.264 (iTunes Video)';
      default: return ext.toUpperCase();
    }
  }

  Widget _iRow(IconData icon,Color iconColor,String label,String val)=>Padding(
    padding:const EdgeInsets.symmetric(vertical:4),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Container(padding:const EdgeInsets.all(4),decoration:BoxDecoration(color:iconColor.withValues(alpha: 0.1),borderRadius:BorderRadius.circular(5)),
          child:Icon(icon,size:12,color:iconColor)),
      const SizedBox(width:8),
      Text('$label: ',style:TextStyle(color:kTextSec,fontSize:12)),
      Expanded(child:Text(val,style:const TextStyle(fontSize:12,height:1.4),overflow:TextOverflow.ellipsis,maxLines:2)),
    ]),
  );

  @override
  Widget build(BuildContext context){
    final isSaved=Store.savedFolders.contains(_path);
    return PopScope(
      canPop:_path==root&&!_selectMode&&!_searching,
      onPopInvokedWithResult:(didPop,_){
        if(!didPop){
          if(_searching){setState((){_searching=false;_searchQuery='';_searchCtrl.clear();_searchResults=[];_globalSearch=false;});}
          else if(_selectMode){setState((){_selectMode=false;_selected.clear();});}
          else{_goUp();}
        }
      },
      child:Scaffold(
        extendBody:true,
        appBar:_selectMode?_selectBar():_normalBar(isSaved),
        body:_buildBody(),
      ),
    );
  }

  Widget _buildFABs()=>const SizedBox.shrink();

  Widget _fabBtn(IconData icon,String tip,Color color,VoidCallback fn)=>const SizedBox.shrink();

  PreferredSizeWidget _normalBar(bool isSaved)=>AppBar(
    automaticallyImplyLeading:false,
    leading:_path!=root?IconButton(icon:const Icon(Icons.arrow_back_ios_new_rounded,size:18),onPressed:_goUp):null,
    title:_searching
        ?Container(
          padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),
          decoration:BoxDecoration(
            color:kCard,
            borderRadius:BorderRadius.circular(14),
            border:Border.all(color:kAccent.withValues(alpha: 0.25)),
          ),
          child:Row(children:[
            Icon(Icons.search_rounded,size:16,color:kTextDim),
            const SizedBox(width:8),
            Expanded(child:TextField(controller:_searchCtrl,autofocus:true,
                style:TextStyle(fontSize:14,color:Vz.text),
                decoration:InputDecoration.collapsed(
                  hintText:_globalSearch?L.searchingGlobal:L.searchHere,
                  hintStyle:TextStyle(color:kTextDim,fontSize:13)),
                onChanged:(v){setState(()=>_searchQuery=v);if(_globalSearch)_runGlobalSearch(v);})),
            if(_searchRunning)SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:1.5,color:kAccent)),
          ]))
        :Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisSize:MainAxisSize.min,children:[
            Text(_path==root?L.internalStorage:p.basename(_path),overflow:TextOverflow.ellipsis,
                style:TextStyle(fontSize:16,fontWeight:FontWeight.w700,color:Vz.text)),
            if(_path!=root)Text(p.dirname(_path),overflow:TextOverflow.ellipsis,
                style:TextStyle(fontSize:10,color:kTextDim,height:1.2)),
          ]),
    actions:[
      if(_searching)...[
        // toggle: جستجوی کامل کل حافظه
        GestureDetector(
          onTap:(){
            setState(()=>_globalSearch=!_globalSearch);
            if(_globalSearch&&_searchQuery.isNotEmpty)_runGlobalSearch(_searchQuery);
            else setState(()=>_searchResults=[]);
          },
          child:Container(
            margin:const EdgeInsets.symmetric(vertical:8,horizontal:4),
            padding:const EdgeInsets.symmetric(horizontal:10,vertical:4),
            decoration:BoxDecoration(
              color:_globalSearch?kAccent:kCard,
              borderRadius:BorderRadius.circular(16),
              border:Border.all(color:_globalSearch?kAccent:kBorder),
            ),
            child:Row(mainAxisSize:MainAxisSize.min,children:[
              Icon(Icons.public_rounded,size:13,color:_globalSearch?Colors.white:kTextSec),
              const SizedBox(width:4),
              Text(L.searchAll,style:TextStyle(fontSize:11,color:_globalSearch?Colors.white:kTextSec,fontWeight:FontWeight.w600)),
            ]),
          ),
        ),
      ],
      IconButton(icon:Icon(_searching?Icons.close_rounded:Icons.search_rounded,size:20),
          onPressed:(){setState((){_searching=!_searching;if(!_searching){_searchQuery='';_searchCtrl.clear();_searchResults=[];_globalSearch=false;}});}),
      // ── تعویض چیدمان: گرید / لیست / فشرده ──
      if(!_searching)
        GestureDetector(
          onTap:_cycleLayout,
          onLongPress:()=>_showLayoutSheet(context),
          child:Container(
            margin:const EdgeInsets.symmetric(vertical:10,horizontal:2),
            padding:const EdgeInsets.all(7),
            decoration:BoxDecoration(
              color:Vz.card,
              borderRadius:BorderRadius.circular(Rad.xs),
              border:Border.all(color:Vz.border)),
            child:Icon(
              switch(_layout){
                _LibLayout.grid=>Icons.grid_view_rounded,
                _LibLayout.list=>Icons.view_agenda_rounded,
                _LibLayout.compact=>Icons.view_headline_rounded,
              },
              size:18,color:Vz.accent),
          ),
        ),
      // NOVA: Online/IPTV/Library/Settings از طریق NavDock — دکمه‌های تکراری حذف شد
      if(!_searching)...[
        if(_path!=root)IconButton(
          icon:Icon(isSaved?Icons.push_pin_rounded:Icons.push_pin_outlined,color:isSaved?Vz.amber:Vz.textSec,size:20),
          onPressed:()async{await Store.toggleSavedFolder(_path);setState((){});},
        ),
        PopupMenuButton<String>(
          icon:const Icon(Icons.storage_rounded,size:20),
          tooltip:L.selectStorage,
          itemBuilder:(_){
            final items=<PopupMenuEntry<String>>[
              _pmStr(Icons.phone_android_rounded,'/storage/emulated/0','📱 ${L.internalStorage}'),
              _pmStr(Icons.download_rounded,'/storage/emulated/0/Download','⬇ ${L.downloads}'),
              _pmStr(Icons.movie_rounded,'/storage/emulated/0/Movies','🎬 ${L.movies}'),
            ];
            for(final d in _getStorageDevices()){items.add(_pmStr(Icons.sd_card_rounded,d.path,'💾 ${p.basename(d.path)}'));}
            items..add(const PopupMenuDivider())..add(_pmStr(Icons.edit_rounded,'__custom__','📂 ${L.customPath}'));
            return items;
          },
          onSelected:(v){
            if(v=='__custom__'){
              final ctrl=TextEditingController(text:_path);
              showDialog(context:context,builder:(ctx)=>AlertDialog(
                title:Text(L.customPath),
                content:TextField(controller:ctrl,autofocus:true,
                    decoration:InputDecoration(hintText:'/storage/emulated/0/...',border:OutlineInputBorder())),
                actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.cancel)),
                  FilledButton(onPressed:(){final pt=ctrl.text.trim();Navigator.pop(ctx);if(pt.isNotEmpty)_loadDir(pt);},child:Text(L.start))],
              ));
            }else{_loadDir(v);}
          },
        ),
        PopupMenuButton<_SortBy>(
          icon:const Icon(Icons.sort_rounded,size:20),
          onSelected:(v)=>setState((){if(_sortBy==v)_sortDesc=!_sortDesc;else{_sortBy=v;_sortDesc=false;}}),
          itemBuilder:(_)=>[
            _pmSort(_SortBy.name,L.sortName,Icons.sort_rounded),
            _pmSort(_SortBy.date,L.sortDate,Icons.access_time_rounded),
            _pmSort(_SortBy.size,L.sortSize,Icons.data_usage_rounded),
            _pmSort(_SortBy.type,L.sortType,Icons.video_file_rounded),
          ],
        ),
      ],
    ],
  );

  PopupMenuItem<String> _pmStr(IconData icon,String v,String t)=>PopupMenuItem(value:v,height:40,
      child:Row(children:[Icon(icon,size:16,color:kTextSec),const SizedBox(width:10),Text(t,style:const TextStyle(fontSize:13))]));
  PopupMenuItem<_SortBy> _pmSort(_SortBy v,String t,IconData icon)=>PopupMenuItem(value:v,height:40,
      child:Row(children:[Icon(icon,size:16,color:_sortBy==v?kAccent:kTextSec),const SizedBox(width:10),
        Text('$t${_sortBy==v?(_sortDesc?' ↑':' ↓'):''}',style:TextStyle(fontSize:13,color:_sortBy==v?kAccent:Colors.white))]));

  PreferredSizeWidget _selectBar()=>AppBar(
    automaticallyImplyLeading:false,
    backgroundColor:kAccent.withValues(alpha: 0.15),
    leading:IconButton(icon:const Icon(Icons.close_rounded,size:20),onPressed:()=>setState((){_selectMode=false;_selected.clear();})),
    title:Text('${_selected.length} ${L.select}',style:const TextStyle(fontSize:15)),
    actions:[
      if(_selected.isNotEmpty)IconButton(
        icon:Icon(Icons.play_circle_rounded,color:kAccent,size:26),
        tooltip:L.play,
        onPressed:(){
          final sorted=_filteredVideos.where((v)=>_selected.contains(v.path)).toList();
          if(sorted.isEmpty)return;
          setState((){_selectMode=false;_selected.clear();});
          Navigator.push(context,MaterialPageRoute(builder:(_)=>PlayerScreen(
            playlist:sorted.map((v)=>File(v.path)).toList(),
            playlistIndex:0,
          )));
        }),
      TextButton.icon(icon:const Icon(Icons.select_all_rounded,size:18),label:Text(L.allItems,style:TextStyle(fontSize:13)),
          onPressed:()=>setState(()=>_selected.addAll(_filteredVideos.map((v)=>v.path)))),
      IconButton(icon:Icon(Icons.delete_outline_rounded,color:kRed,size:22),
          onPressed:_selected.isEmpty?null:()=>_confirmDelete(_selected.map((s)=>File(s)).toList())),
    ],
  );

  Widget _buildBody(){
    if(_checking)return Center(child:CircularProgressIndicator());
    if(!_granted)return Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:kCard,borderRadius:BorderRadius.circular(20),border:Border.all(color:kBorder)),
          child:Icon(Icons.folder_off_rounded,size:48,color:kTextSec)),
      const SizedBox(height:20),
      Text(L.permissionNeeded,textAlign:TextAlign.center,style:TextStyle(color:kTextSec)),
      const SizedBox(height:20),
      FilledButton.icon(onPressed:_ensurePermission,icon:const Icon(Icons.lock_open_rounded),label:Text(L.grantPermission)),
      const SizedBox(height:8),TextButton(onPressed:openAppSettings,child:Text(L.appSettings)),
    ])));

    return Column(children:[
      Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:16,vertical:7),color:kSurface.withValues(alpha: 0.85),
          child:Row(children:[
            Icon(Icons.folder_open_rounded,size:12,color:kAccent.withValues(alpha: 0.85)),const SizedBox(width:6),
            Expanded(child:Text(_path,style:TextStyle(fontSize:10,color:kTextDim),overflow:TextOverflow.ellipsis)),
            if(_searchRunning)SizedBox(width:12,height:12,child:CircularProgressIndicator(strokeWidth:1.5,color:kAccent)),
            if(_globalSearch&&!_searchRunning&&_searchResults.isNotEmpty)
              Text('${_searchResults.length}',style:TextStyle(fontSize:10,color:kAccent)),
          ])),
      Expanded(child:_buildList()),
    ]);
  }

  Widget _buildList(){
    final fDirs=_filteredDirs,fVids=_filteredVideos;
    final total=fDirs.length+fVids.length;
    if(total==0&&_searchRunning)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
      CircularProgressIndicator(),SizedBox(height:16),Text(L.searchingGlobal,style:TextStyle(color:kTextSec)),
    ]));
    if(total==0)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(padding:const EdgeInsets.all(18),
        decoration:BoxDecoration(
          color:kCard.withValues(alpha: 0.6),shape:BoxShape.circle,
          border:Border.all(color:kBorder.withValues(alpha: 0.8))),
        child:Icon(Icons.grid_view_rounded,size:34,color:kTextDim)),
      const SizedBox(height:16),
      Text(L.noFilesFound,style:TextStyle(color:kTextSec,fontSize:14)),
    ]));

    // ── چیدمان انتخابی کاربر ──
    final cols = MediaQuery.of(context).size.width>600?3:2;
    final header = _path!=root
      ? Padding(
        padding:const EdgeInsets.fromLTRB(4,10,4,4),
        child:Row(children:[
          Icon(Icons.folder_rounded,size:15,color:Vz.accent),
          const SizedBox(width:6),
          Expanded(child:Text(_path,style:Ty.caption.copyWith(fontSize:11),overflow:TextOverflow.ellipsis)),
        ]))
      : const SizedBox.shrink();

    // تایل‌ها
    Widget dirAt(int i)=>_DirTile(dir:fDirs[i],index:i,onTap:()=>_loadDir(fDirs[i].path));
    Widget vidAt(int i){
      final v=fVids[i];
      return _VideoTile(
        file:v,selectMode:_selectMode,selected:_selected.contains(v.path),
        layout:_layout,index:i,
        onTap:_selectMode?()=>setState(()=>_selected.contains(v.path)?_selected.remove(v.path):_selected.add(v.path)):()=>_openVideo(v,fVids,i),
        onLongPress:_selectMode?null:()=>_showVideoMenu(v),
        showPath:_globalSearch,
      );
    }

    return RefreshIndicator(
      onRefresh:()async{if(!_globalSearch){_loadDir(_path);}else if(_searchQuery.isNotEmpty){_runGlobalSearch(_searchQuery);}},
      color:Vz.accent,
      backgroundColor:Vz.card,
      child:_layout==_LibLayout.compact
        // ── فشرده: یک لیست ساده و پرسرعت ──
        ? ListView(
            padding:const EdgeInsets.fromLTRB(Sp.lg,Sp.sm,Sp.lg,130),
            children:[
              header,
              for(var i=0;i<fDirs.length;i++)
                Padding(padding:const EdgeInsets.only(bottom:4),child:dirAt(i)),
              if(fDirs.isNotEmpty)const SizedBox(height:Sp.sm),
              for(var i=0;i<fVids.length;i++)
                Padding(padding:const EdgeInsets.only(bottom:2),child:vidAt(i)),
            ])
        : CustomScrollView(
          physics:const AlwaysScrollableScrollPhysics(),
          slivers:[
            SliverPadding(padding:const EdgeInsets.only(top:4,left:16,right:16,bottom:4),
              sliver:SliverToBoxAdapter(child:header)),

            // ── پوشه‌ها: همیشه گرید افقی ──
            if(fDirs.isNotEmpty)SliverPadding(
              padding:const EdgeInsets.symmetric(horizontal:16),
              sliver:SliverGrid(
                gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:cols,mainAxisSpacing:10,crossAxisSpacing:10,
                  childAspectRatio:1.85),
                delegate:SliverChildBuilderDelegate((ctx,i)=>dirAt(i),childCount:fDirs.length))),

            // ── ویدیوها ──
            if(fVids.isNotEmpty)SliverPadding(
              padding:const EdgeInsets.fromLTRB(16,10,16,0),
              sliver: _layout==_LibLayout.list
                ? SliverList(
                    delegate:SliverChildBuilderDelegate(
                      (ctx,i)=>Padding(padding:const EdgeInsets.only(bottom:Sp.sm),child:vidAt(i)),
                      childCount:fVids.length))
                : SliverGrid(
                    gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:cols,mainAxisSpacing:10,crossAxisSpacing:10,
                      childAspectRatio:0.72),
                    delegate:SliverChildBuilderDelegate((ctx,i)=>vidAt(i),childCount:fVids.length))),

            const SliverPadding(padding:EdgeInsets.only(bottom:130)),
          ],
        ),
    );
  }

  void _openPanel(int page){
    // NOVA: پانل ۸-تبی حذف شد — History/Bookmarks/... در Library و Settings از طریق NavDock
  }

  // ── چیدمان: چرخش سریع با تپ، انتخاب دقیق با نگه‌داشتن ──
  void _cycleLayout(){
    final next = switch(_layout){
      _LibLayout.grid => _LibLayout.list,
      _LibLayout.list => _LibLayout.compact,
      _LibLayout.compact => _LibLayout.grid,
    };
    _setLayout(next);
  }

  void _setLayout(_LibLayout l){
    setState(()=>_layout=l);
    SharedPreferences.getInstance().then((p)=>p.setString('lib_layout',l.name));
  }

  void _showLayoutSheet(BuildContext context){
    showVzSheet(context:context, builder:(ctx)=>SafeArea(top:false,child:Column(
      mainAxisSize:MainAxisSize.min, children:[
        VzSheetHeader(title:L.layout, icon:Icons.dashboard_customize_rounded,
          onClose:()=>Navigator.pop(ctx)),
        for(final l in _LibLayout.values)
          VzSheetRow(
            icon: switch(l){
              _LibLayout.grid=>Icons.grid_view_rounded,
              _LibLayout.list=>Icons.view_agenda_rounded,
              _LibLayout.compact=>Icons.view_headline_rounded,
            },
            title: switch(l){
              _LibLayout.grid=>L.gridView,
              _LibLayout.list=>L.listView,
              _LibLayout.compact=>L.compactView,
            },
            accent: l==_layout?Vz.accent:null,
            trailing: l==_layout
              ? Icon(Icons.check_rounded,size:19,color:Vz.accent)
              : null,
            onTap:(){Navigator.pop(ctx);_setLayout(l);},
          ),
        const SizedBox(height:Sp.sm),
      ])));
  }
}

// ── تایل پوشه — Bento افقی ──
class _DirTile extends StatefulWidget{
  final Directory dir;final VoidCallback onTap;
  final int index;
  const _DirTile({required this.dir,required this.onTap,this.index=0});
  @override State<_DirTile> createState()=>_DirTileState();
}
class _DirTileState extends State<_DirTile> with SingleTickerProviderStateMixin{
  AnimationController? _c;
  @override void initState(){
    super.initState();
    if(Vz.animations){
      _c = AnimationController(vsync:this,duration:const Duration(milliseconds:280));
      // ورود پله‌ای — هر آیتم کمی بعد از قبلی
      Future.delayed(Duration(milliseconds:(widget.index.clamp(0,14))*32),(){
        if(mounted)_c?.forward();
      });
    }
  }
  @override void dispose(){_c?.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final body = _tile();
    if(_c==null) return body;
    final a = CurvedAnimation(parent:_c!,curve:Curves.easeOutCubic);
    return FadeTransition(
      opacity:a,
      child:SlideTransition(
        position:Tween(begin:const Offset(0,0.10),end:Offset.zero).animate(a),
        child:body));
  }

  Widget _tile(){
    return _Pressable(
      onTap:widget.onTap,
      child:Container(
        decoration:BoxDecoration(
          color:Vz.card,
          borderRadius:BorderRadius.circular(Rad.md),
          border:Border.all(color:Vz.border)),
        padding:const EdgeInsets.symmetric(horizontal:Sp.md,vertical:Sp.sm),
        child:Row(children:[
          Container(
            width:36,height:36,
            decoration:BoxDecoration(
              color:Vz.accent.withValues(alpha:0.12),
              borderRadius:BorderRadius.circular(11),
              border:Border.all(color:Vz.accent.withValues(alpha:0.28))),
            child:Icon(Icons.folder_rounded,color:Vz.accent,size:18)),
          const SizedBox(width:Sp.md),
          Expanded(child:Text(p.basename(widget.dir.path),
            style:Ty.label.copyWith(fontSize:12.5),
            maxLines:1,overflow:TextOverflow.ellipsis)),
          Icon(Icons.chevron_right_rounded,color:Vz.textDim,size:18),
        ]),
      ),
    );
  }
}

// ── کارت ویدیو — گرید / لیست / فشرده ──
class _VideoTile extends StatelessWidget{
  final File file;
  final bool selectMode,selected,showPath,compact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final _LibLayout layout;
  final int index;
  const _VideoTile({required this.file,required this.selectMode,required this.selected,required this.onTap,this.onLongPress,this.showPath=false,this.compact=false,this.layout=_LibLayout.grid,this.index=0});

  @override Widget build(BuildContext context){
    final anim = _EnterAnim(index:index, child:
      switch(layout){
        _LibLayout.grid => _grid(context),
        _LibLayout.list => _row(context),
        _LibLayout.compact => _compactRow(context),
      });
    return GestureDetector(
      onTap:onTap,onLongPress:onLongPress,
      child:anim);
  }

  // ── داده‌های مشترک ──
  String get _name=>p.basename(file.path);
  String get _ext=>p.extension(file.path).toLowerCase().replaceAll('.','');
  bool get _seen=>Store.watched.contains(file.path);
  bool get _bkm=>Store.bookmarked.contains(file.path);
  bool get _fav=>Store.favorited.contains(file.path);
  bool get _hasSub=>matchSubtitle(file.path)!=null;
  int get _rating=>Store.ratings[file.path]??0;
  int? get _dur=>Store.getCachedDur(file.path);

  Color get _border=>selected?Vz.accent:Vz.border;
  Color get _fill=>selected?Vz.accent.withValues(alpha:0.12):Vz.card;

  // ── گرید ──
  Widget _grid(BuildContext context){
    final grad=_extGrad(_ext);
    return AnimatedContainer(
      duration:Mo.fast,curve:Mo.easeOut,
      decoration:BoxDecoration(
        color:_fill,
        borderRadius:BorderRadius.circular(Rad.md),
        border:Border.all(color:_border,width:selected?1.6:1),
        boxShadow:selected?[Vz.glowSoft]:null),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Expanded(child:ClipRRect(
          borderRadius:const BorderRadius.vertical(top:Radius.circular(Rad.md-1)),
          child:Stack(fit:StackFit.expand,children:[
            if(selectMode)
              Container(color:Vz.cardHi,child:Icon(
                selected?Icons.check_circle_rounded:Icons.circle_outlined,
                color:selected?Vz.accent:Vz.textDim,size:30))
            else FutureBuilder<Uint8List?>(
              future:_loadThumb(file.path),
              builder:(ctx,snap){
                if(snap.hasData&&snap.data!=null){
                  return Stack(fit:StackFit.expand,children:[
                    Image.memory(snap.data!,fit:BoxFit.cover,gaplessPlayback:true),
                    Container(decoration:BoxDecoration(
                      gradient:LinearGradient(begin:Alignment.bottomCenter,end:Alignment.center,
                        colors:[Vz.glassDark,Colors.transparent]))),
                  ]);
                }
                return Container(
                  decoration:BoxDecoration(gradient:grad),
                  alignment:Alignment.center,
                  child:snap.connectionState==ConnectionState.waiting
                    ?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:1.5,color:Colors.white30))
                    :Text(_ext.length>3?_ext.substring(0,3).toUpperCase():_ext.toUpperCase(),
                        style:TextStyle(fontSize:13,fontWeight:FontWeight.w800,color:Vz.text,letterSpacing:1.5)));
              }),
            // وضعیت تماشا + علاقه‌مندی — گوشه بالا
            if(!selectMode)Positioned(top:6,left:6,right:6,
              child:Row(children:[
                if(_seen)_pill(Icons.check_rounded,Vz.accent),
                if(_bkm)...[if(_seen)const SizedBox(width:4),_pill(Icons.bookmark_rounded,Vz.accent)],
                if(_fav)...[if(_seen||_bkm)const SizedBox(width:4),_pill(Icons.favorite_rounded,Vz.magenta)],
                const Spacer(),
                if(_hasSub)_pill(Icons.subtitles_rounded,Vz.green),
              ])),
            if(_dur!=null&&_dur!>0&&!selectMode)Positioned(
              right:6,bottom:6,
              child:Container(
                padding:const EdgeInsets.symmetric(horizontal:5,vertical:2),
                decoration:BoxDecoration(color:Vz.badgeBg,borderRadius:BorderRadius.circular(5)),
                child:Text(fmt(Duration(seconds:_dur!)),
                  style:TextStyle(fontSize:10,color:Vz.oviText,fontWeight:FontWeight.w600,
                    fontFeatures:const [FontFeature.tabularFigures()])))),
            if(_rating>0&&!selectMode)Positioned(
              left:6,bottom:6,
              child:Row(children:List.generate(_rating,(i)=>
                Icon(Icons.star_rounded,size:11,color:Vz.amber)))),
            if(!selectMode)Center(child:Container(
              width:40,height:40,
              decoration:BoxDecoration(
                color:Colors.black.withValues(alpha:0.38),
                shape:BoxShape.circle,
                border:Border.all(color:Colors.white.withValues(alpha:0.22))),
              child:Icon(Icons.play_arrow_rounded,color:_seen?Vz.accent:Colors.white,size:25))),
          ]))),
        // ── متادیتا ──
        Padding(
          padding:const EdgeInsets.fromLTRB(9,8,9,9),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(_name,style:Ty.label.copyWith(
              fontSize:12,
              color:_seen?Vz.accent:Vz.text),maxLines:1,overflow:TextOverflow.ellipsis),
            if(showPath)Padding(padding:const EdgeInsets.only(top:2),
              child:Text(p.dirname(file.path),style:Ty.caption.copyWith(fontSize:9),maxLines:1,overflow:TextOverflow.ellipsis)),
            const SizedBox(height:4),
            Text(sizeStr(file),style:Ty.caption.copyWith(fontSize:10)),
          ])),
      ]));
  }

  Widget _pill(IconData icon,Color c)=>Container(
    width:20,height:20,
    decoration:BoxDecoration(color:Vz.badgeBg,shape:BoxShape.circle),
    child:Icon(icon,size:12,color:c));

  // ── لیست ──
  Widget _row(BuildContext context)=>Container(
    padding:const EdgeInsets.all(Sp.sm),
    decoration:BoxDecoration(
      color:_fill,
      borderRadius:BorderRadius.circular(Rad.md),
      border:Border.all(color:_border,width:selected?1.6:1)),
    child:Row(children:[
      _thumb(58,36),
      const SizedBox(width:Sp.md),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(_name,style:Ty.label.copyWith(fontSize:12.5,
          color:_seen?Vz.accent:Vz.text),maxLines:1,overflow:TextOverflow.ellipsis),
        const SizedBox(height:3),
        Row(children:[
          if(_hasSub)_mini(Icons.subtitles_rounded,Vz.green),
          if(_bkm)_mini(Icons.bookmark_rounded,Vz.accent),
          if(_fav)_mini(Icons.favorite_rounded,Vz.magenta),
          if(_rating>0)...List.generate(_rating,(i)=>
            Icon(Icons.star_rounded,size:10,color:Vz.amber)),
          if(_hasSub||_bkm||_fav||_rating>0)const SizedBox(width:6),
          Text(sizeStr(file),style:Ty.caption.copyWith(fontSize:10)),
          if(_dur!=null&&_dur!>0)...[
            Text(' • ',style:Ty.caption.copyWith(fontSize:10)),
            Text(fmt(Duration(seconds:_dur!)),style:Ty.caption.copyWith(fontSize:10)),
          ],
        ]),
      ])),
      if(selectMode)
        Icon(selected?Icons.check_circle_rounded:Icons.circle_outlined,
          size:22,color:selected?Vz.accent:Vz.textDim)
      else
        Icon(Icons.play_circle_rounded,size:26,
          color:_seen?Vz.accent:Vz.textDim),
    ]));

  // ── فشرده ──
  Widget _compactRow(BuildContext context)=>Container(
    padding:EdgeInsets.only(left:selectMode?4:12,right:12,top:2,bottom:2),
    decoration:BoxDecoration(
      color:selected?Vz.accent.withValues(alpha:0.10):Colors.transparent,
      borderRadius:BorderRadius.circular(Rad.xs)),
    child:Row(children:[
      if(selectMode)Padding(padding:const EdgeInsets.only(right:8),
        child:Icon(selected?Icons.check_circle_rounded:Icons.circle_outlined,
          size:19,color:selected?Vz.accent:Vz.textDim)),
      Icon(Icons.play_circle_rounded,size:17,
        color:_seen?Vz.accent:Vz.textDim),
      const SizedBox(width:10),
      Expanded(child:Text(_name,style:Ty.label.copyWith(fontSize:12,
        color:_seen?Vz.accent:Vz.text),maxLines:1,overflow:TextOverflow.ellipsis)),
      if(_hasSub)_mini(Icons.subtitles_rounded,Vz.green),
      if(_bkm)_mini(Icons.bookmark_rounded,Vz.accent),
      if(_fav)_mini(Icons.favorite_rounded,Vz.magenta),
      const SizedBox(width:6),
      Text(sizeStr(file),style:Ty.caption.copyWith(fontSize:10)),
    ]));

  Widget _mini(IconData i,Color c)=>Padding(
    padding:const EdgeInsets.only(right:3),
    child:Icon(i,size:12,color:c));

  Widget _thumb(double w,double h)=>ClipRRect(
    borderRadius:BorderRadius.circular(9),
    child:SizedBox(width:w,height:h,child:Stack(fit:StackFit.expand,children:[
      if(selectMode)Container(color:Vz.cardHi,child:Icon(
        selected?Icons.check_rounded:Icons.circle_outlined,size:20,
        color:selected?Vz.accent:Vz.textDim))
      else FutureBuilder<Uint8List?>(
        future:_loadThumb(file.path),
        builder:(ctx,snap){
          if(snap.hasData&&snap.data!=null){
            return Image.memory(snap.data!,fit:BoxFit.cover,gaplessPlayback:true);
          }
          return Container(
            decoration:BoxDecoration(gradient:_extGrad(_ext)),
            alignment:Alignment.center,
            child:snap.connectionState==ConnectionState.waiting
              ?const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:1.4,color:Colors.white30))
              :Text(_ext.toUpperCase(),style:TextStyle(fontSize:9,
                  fontWeight:FontWeight.w800,color:Vz.text,letterSpacing:0.8)));
        }),
      if(!selectMode&&_seen)Align(alignment:Alignment.bottomRight,
        child:Padding(padding:const EdgeInsets.all(2),
          child:Icon(Icons.check_circle_rounded,size:12,color:Vz.accent))),
    ])));

  Widget _pillBox(Widget child)=>child;
}

/// ورود پله‌ای کارت‌ها — با کلید انیمیشن کاربر خاموش می‌شود.
class _EnterAnim extends StatefulWidget{
  final Widget child; final int index;
  const _EnterAnim({required this.child,required this.index});
  @override State<_EnterAnim> createState()=>_EnterAnimState();
}
class _EnterAnimState extends State<_EnterAnim> with SingleTickerProviderStateMixin{
  AnimationController? _c;
  @override void initState(){
    super.initState();
    if(Vz.animations){
      _c=AnimationController(vsync:this,duration:const Duration(milliseconds:260));
      Future.delayed(Duration(milliseconds:(widget.index.clamp(0,14))*30),(){
        if(mounted)_c?.forward();
      });
    }
  }
  @override void dispose(){_c?.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    if(_c==null)return widget.child;
    final a=CurvedAnimation(parent:_c!,curve:Curves.easeOutCubic);
    return FadeTransition(opacity:a,
      child:ScaleTransition(scale:Tween(begin:0.96,end:1.0).animate(a),
        child:widget.child));
  }
}

/// فشردن نرم — با کلید انیمیشن کاربر هماهنگ است.
class _Pressable extends StatefulWidget{
  final Widget child; final VoidCallback? onTap; final VoidCallback? onLongPress;
  const _Pressable({required this.child,this.onTap,this.onLongPress});
  @override State<_Pressable> createState()=>_PressableState();
}
class _PressableState extends State<_Pressable>{
  bool _down=false;
  @override Widget build(BuildContext context)=>GestureDetector(
    onTap:widget.onTap,
    onLongPress:widget.onLongPress,
    onTapDown:widget.onTap==null?null:(_)=>setState(()=>_down=true),
    onTapUp:(_)=>setState(()=>_down=false),
    onTapCancel:()=>setState(()=>_down=false),
    child:AnimatedScale(
      scale:_down?0.97:1.0,
      duration:Mo.press,curve:Mo.easeOut,
      child:widget.child));
}

enum _LibLayout { grid, list, compact }

// ── منوی ویدیو ──
class VideoMenu extends StatefulWidget{
  final File file;
  final VoidCallback onDone,onInfo,onDelete,onRename,onSelect,onCopy,onMove,onRate,onNote;
  const VideoMenu({super.key,required this.file,required this.onDone,required this.onInfo,required this.onDelete,required this.onRename,required this.onSelect,required this.onCopy,required this.onMove,required this.onRate,required this.onNote});
  @override State<VideoMenu> createState()=>_VideoMenuState();
}
class _VideoMenuState extends State<VideoMenu>{
  late bool _bkm=Store.bookmarked.contains(widget.file.path);
  late bool _fav=Store.favorited.contains(widget.file.path);
  @override Widget build(BuildContext context)=>SafeArea(top:false,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
    const SizedBox(height:12),
    const Center(child:VzSheetHandle()),
    const SizedBox(height:8),
    Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:Row(children:[
      Container(width:40,height:40,decoration:BoxDecoration(color:kCard,borderRadius:BorderRadius.circular(10),border:Border.all(color:kBorder)),
          child:Icon(Icons.video_file_rounded,color:kAccent,size:20)),
      const SizedBox(width:12),
      Expanded(child:Text(p.basename(widget.file.path),style:const TextStyle(fontWeight:FontWeight.w600,fontSize:13),maxLines:2)),
    ])),
    const SizedBox(height:8),const Divider(height:1),
    _mi(Icons.info_outline_rounded,kTextSec,L.fileInfo,widget.onInfo),
    _mi2(Icons.bookmark_rounded,_bkm?kAmber:kTextSec,_bkm?L.removeBookmark:L.addBookmark,()async{await Store.toggleBookmark(widget.file.path);setState(()=>_bkm=!_bkm);widget.onDone();}),
    _mi2(Icons.favorite_rounded,_fav?kPink:kTextSec,_fav?L.removeFavorite:L.favorites,()async{await Store.toggleFavorite(widget.file.path);setState(()=>_fav=!_fav);widget.onDone();}),
    _mi(Icons.star_outline_rounded,kAmber,L.rating,widget.onRate),
    _mi(Icons.notes_rounded,kTextSec,L.note,widget.onNote),
    const Divider(height:1),
    _mi(Icons.queue_music_rounded,kCyan,L.addToPlaylist,()async{
      final playlists=Store.playlists.keys.toList();
      if(playlists.isEmpty){
        showSnack(context, L.noPlaylist);
        return;
      }
      final name=await showDialog<String>(context:context,builder:(ctx)=>AlertDialog(
        title:Text(L.playlist),
        content:Column(mainAxisSize:MainAxisSize.min,children:playlists.map((pl)=>ListTile(
          dense:true,leading:Icon(Icons.queue_music_rounded,color:kCyan,size:18),
          title:Text(pl,style:const TextStyle(fontSize:13)),
          onTap:()=>Navigator.pop(ctx,pl))).toList()),
        actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:Text(L.cancel))],
      ));
      if(name!=null){
        await Store.addToPlaylist(name,widget.file.path);
        showSnack(context, '${L.addedTo} "$name"');
      }
    }),
    _mi(Icons.copy_rounded,kTextSec,L.copyTo,widget.onCopy),
    _mi(Icons.drive_file_move_outline,kTextSec,L.moveTo,widget.onMove),
    _mi(Icons.edit_rounded,kTextSec,L.rename_,widget.onRename),
    _mi(Icons.select_all_rounded,kTextSec,L.selectGroup,widget.onSelect),
    _mi(Icons.delete_outline_rounded,kRed,L.delete,widget.onDelete),
    const SizedBox(height:8),
  ])));
  Widget _mi(IconData icon,Color iconColor,String title,VoidCallback onTap)=>ListTile(dense:true,
    leading:Container(width:30,height:30,decoration:BoxDecoration(color:iconColor.withValues(alpha: 0.1),borderRadius:BorderRadius.circular(7)),
        child:Icon(icon,color:iconColor,size:15)),
    title:Text(title,style:const TextStyle(fontSize:13)),onTap:onTap);
  Widget _mi2(IconData icon,Color iconColor,String title,VoidCallback onTap)=>_mi(icon,iconColor,title,onTap);
}

